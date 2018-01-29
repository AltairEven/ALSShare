//
//  AELDCache.m
//  AELocalDataKit
//
//  Created by Altair on 23/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDCache.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@implementation NSObject (AELDCacheObject)

#pragma mark NSObject-Properties

- (void)setAeld_CacheKey:(NSString *)aeld_CacheKey {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_CacheKey", aeld_CacheKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)aeld_CacheKey {
    return objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_CacheKey");
}

- (void)setAeld_MimeType:(AELDCacheObjectType)aeld_MimeType {
    NSNumber *type = [NSNumber numberWithInteger:aeld_MimeType];
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_MimeType", type, OBJC_ASSOCIATION_ASSIGN);
}

- (AELDCacheObjectType)aeld_MimeType {
    NSNumber *type = objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_MimeType");
    return (AELDCacheObjectType)[type integerValue];
}

- (void)setAeld_TotalBytes:(NSUInteger)aeld_TotalBytes {
    NSNumber *totalBytes = [NSNumber numberWithInteger:aeld_TotalBytes];
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_TotalBytes", totalBytes, OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)aeld_TotalBytes {
    NSNumber *totalBytes = objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_TotalBytes");
    return [totalBytes unsignedIntegerValue];
}

- (void)setAeld_ExpireDate:(NSDate *)aeld_ExpireDate {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_ExpireDate", aeld_ExpireDate, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDate *)aeld_ExpireDate {
    return objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_ExpireDate");
}

- (void)setAeld_UserInfo:(NSDictionary *)aeld_UserInfo {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_UserInfo", aeld_UserInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSDictionary *)aeld_UserInfo {
    return objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_UserInfo");
}

- (void)setAeld_LastGetDate:(NSDate * _Nonnull)aeld_LastGetDate {
    objc_setAssociatedObject(self, @"AELocalDataKit_CacheObject_LastGetDate", aeld_LastGetDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)aeld_LastGetDate {
    return objc_getAssociatedObject(self, @"AELocalDataKit_CacheObject_LastGetDate");
}

#pragma mark NSObject - Public methods

- (BOOL)aeld_ValidateCacheObject {
    if (![self.aeld_CacheKey isKindOfClass:[NSString class]] || [self.aeld_CacheKey length] == 0) {
        return NO;
    }
    //设置缓存对象“类型”和“默认内存占用大小”
    NSUInteger defaultTotalBytes = 0;
    if ([self isKindOfClass:[NSString class]]) {
        [self setAeld_MimeType:AELDCacheObjectTypeNSString];
        
        defaultTotalBytes = strlen([(NSString *)self UTF8String]);
    } else if ([self isKindOfClass:[NSData class]]) {
        [self setAeld_MimeType:AELDCacheObjectTypeNSData];
        
        defaultTotalBytes = [(NSData *)self length];
    } else if ([self isKindOfClass:[UIImage class]]) {
        [self setAeld_MimeType:AELDCacheObjectTypeUIImage];
        
        __weak UIImage *weakSelf = (UIImage *)self;
        CGSize imageSize = CGSizeMake(weakSelf.size.width * weakSelf.scale, weakSelf.size.height * weakSelf.scale);
        CGFloat bytesPerPixel = 4.0;
        CGFloat bytesPerSize = imageSize.width * imageSize.height;
        defaultTotalBytes = (NSUInteger)bytesPerPixel * (NSUInteger)bytesPerSize;
    } else {
        [self setAeld_MimeType:AELDCacheObjectTypeOther];
        
        if ([self conformsToProtocol:@protocol(NSCoding)]) {
            //如果是遵循NSCoding协议的自定义对象，可以先转成NSData，再计算大致的内存占用
            NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:self];
            
            defaultTotalBytes = [encodeData length];
        }
    }
    if (self.aeld_TotalBytes > 0) {
        //说明已经人为设置过大小，无需再重新计算
        return YES;
    } else {
        //否则赋值默认计算的占用值
        self.aeld_TotalBytes = defaultTotalBytes;
    }
    if (self.aeld_TotalBytes == 0 || self.aeld_TotalBytes == NSUIntegerMax) {
        //如果内存占用大小，仍然不合法，则返回非法
        return NO;
    }
    return YES;
}

@end

@implementation AELDCache

- (void)autoClearCacheSpace {
    [self doesNotRecognizeSelector:_cmd];
}

- (BOOL)setObject:(id)obj forKey:(NSString *)key {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (id)objectForKey:(NSString *)key {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary<NSString *, id> *)allCachedObjects {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)removeObjectForKey:(NSString *)key {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)removeAllObjects {
    [self doesNotRecognizeSelector:_cmd];
}

@end
