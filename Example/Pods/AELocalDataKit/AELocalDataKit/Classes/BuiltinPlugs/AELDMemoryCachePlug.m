//
//  AELDMemoryCachePlug.m
//  Pods
//
//  Created by Altair on 26/07/2017.
//
//

#import "AELDMemoryCachePlug.h"
#import "AELDMemoryCache.h"
#import "AELDPlugMode.h"
#import "AELDResponse.h"

@interface AELDMemoryCachePlug ()

@property (nonatomic, strong) AELDMemoryCache *memoryCache;

@end

@implementation AELDMemoryCachePlug

- (instancetype)init {
    self = [super init];
    if (self) {
        self.memoryCache = [AELDMemoryCache memoryCacheWithName:NSStringFromClass([self class]) willEvictAction:nil];
        [self.memoryCache setCacheBytesLimit:1024*1024*50];
        [self.memoryCache setAutoClearExpectation:1024*1024*30];
    }
    return self;
}

#pragma mark AELocalDataPlugProtocal

- (AELDPlugMode *)plugMode {
    return [AELDPlugMode modeWithName:NSStringFromClass([self class]) supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear];
}

- (BOOL)startOperation:(AELDOperationMode *)mode response:(nonnull void (^)(AELDResponse * _Nonnull))response {
    if (!mode) {
        return NO;
    }
    id obj = nil;
    NSError *error = nil;
    switch (mode.operationType) {
        case AELDOperationTypeRead:
        {
            obj = [self.memoryCache objectForKey:mode.key];
            if (!obj) {
                error = [NSError errorWithDomain:@"AELDMemoryCachePlug" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"找不到对象"}];
            }
        }
            break;
        case AELDOperationTypeWrite:
        {
            if (![self.memoryCache setObject:mode.value forKey:mode.key]) {
                error = [NSError errorWithDomain:@"AELDMemoryCachePlug" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"缓存失败"}];
            }
        }
            break;
        case AELDOperationTypeDelete:
        {
            if (![self.memoryCache removeObjectForKey:mode.key]) {
                error = [NSError errorWithDomain:@"AELDMemoryCachePlug" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"删除缓存失败"}];
            }
        }
            break;
        case AELDOperationTypeClear:
        {
            [self.memoryCache removeAllObjects];
        }
            break;
        default:
            break;
    }
    
    AELDResponse *resp = [[AELDResponse alloc] initWithOriginalMode:mode responseData:obj userInfo:nil error:error];
    if (response) {
        response(resp);
    }
    
    return YES;
}

- (BOOL)stopOperation {
    return YES;
}

@end
