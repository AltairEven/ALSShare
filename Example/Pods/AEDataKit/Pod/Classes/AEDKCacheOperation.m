//
//  AEDKCacheOperation.m
//  Pods
//
//  Created by Altair on 14/09/2017.
//
//

#import "AEDKCacheOperation.h"
#import "AEDKServer.h"
#import "AEDKTools.h"

@interface AEDKCacheOperation ()

@end

@implementation AEDKCacheOperation
@synthesize key = _key;

+ (instancetype)operation {
    AEDKCacheOperation *operation = [[AEDKCacheOperation alloc] init];
    return operation;
}

#pragma mark Setter & Getter

- (void)setKey:(NSString *)key {
    _key = [[AEDKTools urlEncodeString:key] copy];
}

- (NSString *)key {
    return [AEDKTools urlDecodeString:_key];
}

#pragma mark Chain Methods

- (AEDKCacheOperationIntegerChain)withOperationType {
    return ^AEDKCacheOperation * (NSInteger type) {
        self.type = (AEDKCacheOperationType)type;
        return self;
    };
}

- (AEDKCacheOperationIntegerChain)from {
    return ^AEDKCacheOperation * (NSInteger route) {
        self.route = (AEDKCacheOperationRoute)route;
        return self;
    };
}

- (AEDKCacheOperationObjectChain)withKey {
    return ^AEDKCacheOperation * (NSString *key) {
        self.key = key;
        return self;
    };
}

- (AEDKCacheOperationObjectChain)withValue {
    return ^AEDKCacheOperation * (id value) {
        self.value = value;
        return self;
    };
}

- (id)withResult {
    AEDKProcess *quickProcess = [[AEDKServer server] requestWithPerformer:self];
    __block id result = nil;
    quickProcess.configuration.ProcessCompleted = ^(AEDKProcess * _Nonnull currentProcess, NSError * _Nonnull error, id  _Nullable responseModel) {
        result = responseModel;
    };
    [quickProcess start];
    return result;
}

#pragma mark Quick Methods

+ (id)objectForKey:(NSString *)key {
    key = [AEDKTools urlEncodeString:key];
    return [[AEDKCacheOperation operation].withKey(key) withResult];
}

+ (void)setObject:(id)object forKey:(NSString *)key {
    key = [AEDKTools urlEncodeString:key];
    [[AEDKCacheOperation operation].withKey(key).withValue(object).withOperationType(AEDKCacheOperationTypeWrite) withResult];
}

+ (void)removeObjectForKey:(NSString *)key {
    key = [AEDKTools urlEncodeString:key];
    [[AEDKCacheOperation operation].withKey(key).withOperationType(AEDKCacheOperationTypeRemove) withResult];
}

+ (void)clearWithRoute:(AEDKCacheOperationRoute)route {
    [[AEDKCacheOperation operation].withOperationType(AEDKCacheOperationTypeClear).from(route) withResult];
}

#pragma mark AEDKProtocol

- (AEDKService *)dataService {
    NSString *name = [NSString stringWithFormat:@"com.altaireven.cacheoperation-%@", [[NSUUID UUID] UUIDString]];
    NSString *path = kAEDKServiceCachePathMemoryAndDisk;
    if (_route == AEDKCacheOperationRouteMemory) {
        path = kAEDKServiceCachePathMemory;
    } else if (_route == AEDKCacheOperationRouteDisk) {
        path = kAEDKServiceCachePathDisk;
    } else {
        path = kAEDKServiceCachePathMemoryAndDisk;
    }
    path = [NSString stringWithFormat:@"/%@/%@", path, self.key];
    
    AEDKServiceConfiguration *config = [AEDKServiceConfiguration defaultConfiguration];
    switch (self.type) {
        case AEDKCacheOperationTypeRead:
        {
            config.method = kAEDKServiceMethodGet;
        }
            break;
        case AEDKCacheOperationTypeWrite:
        {
            config.method = kAEDKServiceMethodPOST;
        }
            break;
        case AEDKCacheOperationTypeRemove:
        case AEDKCacheOperationTypeClear:
        {
            config.method = kAEDKServiceMethodDELETE;
        }
            break;
        default:
            break;
    }
    if (self.key) {
        config.requestParameter = @{@"key" : self.key};
    }
    config.requestBody = self.value;
    
    AEDKService *service = [[AEDKService alloc] initWithName:name protocol:@"cache" domain:@"AEDKCacheOperation" path:path serviceConfiguration:config];
    
    return service;
}

@end
