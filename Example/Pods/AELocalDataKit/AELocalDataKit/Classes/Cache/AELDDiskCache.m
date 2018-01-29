//
//  AELDDiskCache.m
//  AELocalDataKit
//
//  Created by Altair on 27/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDDiskCache.h"
#import <objc/runtime.h>
#import "AELDTools.h"

#define AELD_FILEXATTR_EXPIREDATE (@"AELD_FILEXATTR_EXPIREDATE")

@implementation NSObject (AELDDiskCacheObject)

- (void)setAeld_DiskFileXAttr:(NSDictionary<NSString *,NSString *> *)aeld_DiskFileXAttr {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_DiskFileXAttr", aeld_DiskFileXAttr, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary<NSString *,NSString *> *)aeld_DiskFileXAttr {
    return objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_DiskFileXAttr");
}

- (void)setAeld_DiskCache_CacheKey:(NSString *)aeld_CacheKey {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_CacheKey", aeld_CacheKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setAeld_MemoryCache_LastGetDate:(NSDate * _Nullable)aeld_LastGetDate {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_LastGetDate", aeld_LastGetDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface AELDDiskCache ()

@property (nonatomic, strong) dispatch_queue_t synchronizationQueue;

@property (nonatomic, strong) NSFileManager *fileManager;

- (NSString *)cacheDirectoryPath;

- (NSString *)filePathForCacheKey:(NSString *)key;

- (void)initializeStorage;

- (BOOL)saveCacheObject:(id)object;

- (id)loadCacheObjectForKey:(NSString *)key;

@end

@implementation AELDDiskCache

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *queueName = [NSString stringWithFormat:@"com.altaireven.aeldmemorycache-%@", [[NSUUID UUID] UUIDString]];
        self.synchronizationQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
        [self initializeStorage];
        self.fileManager = [NSFileManager new];
    }
    return self;
}

- (NSUInteger)currentDiskUsage {
    __block NSUInteger usage = 0;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        NSString *directoryPath = [self cacheDirectoryPath];
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:directoryPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            usage += [attrs fileSize];
        }
    });
    return usage;
}

#pragma mark Private methods

- (NSString *)cacheDirectoryPath {
    NSString *docment = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *cachePath = [docment stringByAppendingPathComponent:@"/AELDDiskCache"];
    return cachePath;
}

- (NSString *)filePathForCacheKey:(NSString *)key {
    NSString *filePath = [[self cacheDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", key]];
    return filePath;
}

- (void)initializeStorage {
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:[self cacheDirectoryPath] withIntermediateDirectories:YES attributes:nil error:&error];
    if (!result && error) {
        NSLog(@"Create directory failed。%@", error);
    }
}

- (BOOL)saveCacheObject:(id)object {
    NSDate *expireDate = [object aeld_ExpireDate];
    BOOL saved = NO;
    if (expireDate && [expireDate timeIntervalSinceNow] <= 0) {
        return saved;
    }
    @synchronized (object) {
        //防止object被其他线程访问，故使用同步锁
        NSString *filePath = [self filePathForCacheKey:[object aeld_CacheKey]];
        saved = [NSKeyedArchiver archiveRootObject:object toFile:filePath];
        if (saved) {
            if (expireDate) {
                //过期时间
                NSString *expireInfo = [NSString stringWithFormat:@"%.f", [expireDate timeIntervalSince1970]];
                BOOL setExp = [AELDTools setExpendAttributes:@{AELD_FILEXATTR_EXPIREDATE : expireInfo} forPath:filePath];
                if (!setExp) {
                    NSLog(@"Set cache expire date failed.");
                }
            }
            NSDictionary *userInfo = [object aeld_DiskFileXAttr];
            if (userInfo) {
                //自定义属性
                BOOL setXAttr = [AELDTools setExpendAttributes:userInfo forPath:filePath];
                if (!setXAttr) {
                    NSLog(@"Set cache user info failed.");
                }
            }
        }
    }
    return saved;
}

- (id)loadCacheObjectForKey:(NSString *)key {
    NSString *filePath = [self filePathForCacheKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (object) {
        NSDictionary *xattr = [AELDTools expendAttributesForPath:filePath];
        [object setAeld_DiskFileXAttr:xattr];
        [object setAeld_MemoryCache_LastGetDate:[NSDate date]];
    }
    return object;
}

#pragma mark Public methods

+ (instancetype)diskCacheWithName:(NSString *)name {
    AELDDiskCache *cache = [[AELDDiskCache alloc] init];
    cache.cacheName = name;
    [cache setAutoClear:YES];
    return cache;
}

#pragma mark Super methods

- (BOOL)setObject:(id)obj forKey:(NSString *)key {
    [obj setAeld_DiskCache_CacheKey:key];
    if (![obj aeld_ValidateCacheObject] || ![obj conformsToProtocol:@protocol(NSCoding)]) {
        //非法对象
        return NO;
    }
    __block BOOL saved = NO;
    dispatch_barrier_async(self.synchronizationQueue, ^{
        saved = [self saveCacheObject:obj];
    });
    return saved;
}

- (void)setAutoClear:(BOOL)autoClear {
    [super setAutoClear:autoClear];
    if (autoClear) {
        [self autoClearCacheSpace];
    }
}

- (void)autoClearCacheSpace {
    dispatch_barrier_async(self.synchronizationQueue, ^{
        NSString *directoryPath = [self cacheDirectoryPath];
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:directoryPath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
            NSString *expireInfo = [AELDTools expendAttributeWithKey:AELD_FILEXATTR_EXPIREDATE forPath:filePath];
            NSTimeInterval expireTime = [expireInfo doubleValue];
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            if (expireTime > 0 && (expireTime - nowTime) <= 0) {
                //设置了过期时间，并且已经过期，则执行清理
                NSError *err =  nil;
                [self.fileManager removeItemAtPath:filePath error:&err];
                if (err) {
                    NSLog(@"Remove expired cache failed:%@", err);;
                }
            }
        }
    });
}

- (id)objectForKey:(NSString *)key {
    if (![key isKindOfClass:[NSString class]] || [key length] == 0) {
        return nil;
    }
    __block id cacheObject = nil;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        cacheObject = [self loadCacheObjectForKey:key];
    });
    return cacheObject;
}

- (NSDictionary<NSString *, id> *)allCachedObjects {
    __block NSDictionary *objects = nil;
    dispatch_sync(self.synchronizationQueue, ^{
        NSError *error = nil;
        NSArray *files = [self.fileManager contentsOfDirectoryAtPath:[self cacheDirectoryPath] error:&error];
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        for (NSString *key in files) {
            id cacheObject = [self loadCacheObjectForKey:key];
            if (cacheObject) {
                [tempDic setObject:cacheObject forKey:key];
            }
        }
        objects = [tempDic copy];
    });
    return objects;
}

- (BOOL)removeObjectForKey:(NSString *)key {
    if (![key isKindOfClass:[NSString class]] || [key length] == 0) {
        return NO;
    }
    __block BOOL removed = NO;
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        NSString *filePath = [self filePathForCacheKey:key];
        NSError *error =  nil;
        removed = [self.fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"Remove cache failed:%@", error);;
        }
    });
    return removed;
}

- (void)removeAllObjects {
    dispatch_barrier_sync(self.synchronizationQueue, ^{
        NSError *error = nil;
        NSArray *files = [self.fileManager contentsOfDirectoryAtPath:[self cacheDirectoryPath] error:&error];
        NSString *directoryPath = [self cacheDirectoryPath];
        for (NSString *fileName in files) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
            NSError *err =  nil;
            [self.fileManager removeItemAtPath:filePath error:&err];
            if (err) {
                NSLog(@"Remove cache failed:%@", err);;
            }
        }
    });
}

@end
