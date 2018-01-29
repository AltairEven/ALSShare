//
//  AELocalDataPlug.m
//  Pods
//
//  Created by Altair on 28/07/2017.
//
//

#import "AELocalDataPlug.h"
#import <AELocalDataKit/AELocalDataKit.h>
#import "AEDKServer.h"

@interface AELocalDataPlug ()

@end

@implementation AELocalDataPlug

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AELocalDataSocket publicSocket] plugInBuiltInPlugs:AELDBuiltInPlugStrategyMemoryCache|AELDBuiltInPlugStrategyDiskFileCache];
    }
    return self;
}

#pragma mark AEDKPlugProtocol

- (BOOL)canHandleProcess:(AEDKProcess *)process {
    if (!process || ![process isKindOfClass:[AEDKProcess class]]) {
        return NO;
    }
    NSString *protocol = [process.request.URL scheme];
    if (![protocol isEqualToString:kAEDKServiceProtocolCache]) {
        return NO;
    }
    
    if ([process.request.HTTPMethod isEqualToString:kAEDKServiceMethodGet] ||
        [process.request.HTTPMethod isEqualToString:kAEDKServiceMethodPOST] ||
        [process.request.HTTPMethod isEqualToString:kAEDKServiceMethodDELETE] ||
        [process.request.HTTPMethod isEqualToString:kAEDKServiceMethodPUT]) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (void)handleProcess:(AEDKProcess *)process {
    if (process.configuration.BeforeProcess) {
        //预处理
        process.configuration.BeforeProcess(process);
    }
    if (![self canHandleProcess:process]) {
        if (process.configuration.Processing) {
            //处理进程
            process.configuration.Processing(1, 0, process.request);
        }
        if (process.configuration.ProcessCompleted) {
            id responseData = nil;
            NSError *error = [NSError errorWithDomain:@"AELocalDataPlug" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"无法处理的操作"}];
            if (process.configuration.AfterProcess) {
                //处理返回值
                responseData = process.configuration.AfterProcess(process, error, nil);
            }
            //处理结束
            process.configuration.ProcessCompleted(process, error, responseData);
        }
        return;
    }
    NSString *path = [process.request.URL path];
    path = [path substringToIndex:[path rangeOfString:@"/"].location];
    AELDPlugMode *plugMode = nil;
    if ([path isEqualToString:kAEDKServiceCachePathMemory]) {
        plugMode = [AELDPlugMode modeWithName:@"AELDMemoryCachePlug" supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear];
    } else if ([path isEqualToString:kAEDKServiceCachePathDisk]) {
        plugMode = [AELDPlugMode modeWithName:@"AELDDiskCachePlug" supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear];
    } else {
        plugMode = [AELDPlugMode modeWithName:@"AELDIntegratedCachePlug" supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear];
    }
    //生成操作模式
    AELDOperationMode *mode = [AELocalDataPlug operationModeFromProcess:process];
    id<AELocalDataPlugProtocal> localDataPlug = [[AELocalDataSocket publicSocket] plugWithMode:plugMode];
    if (!localDataPlug) {
        if (process.configuration.ProcessCompleted) {
            //处理结束
            NSError *error = [NSError errorWithDomain:@"AELocalDataPlug" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"无法处理的操作"}];
            process.configuration.ProcessCompleted(process, error, nil);
        }
    } else {
        //处理
        [localDataPlug startOperation:mode response:^(AELDResponse * _Nonnull response) {
            if (process.configuration.Processing) {
                //处理进程
                process.configuration.Processing(1, response.error ? 0 : 1, process.request);
            }
            if (process.configuration.ProcessCompleted) {
                id responseData = response.responseData;
                if (process.configuration.AfterProcess) {
                    //处理返回值
                    responseData = process.configuration.AfterProcess(process, response.error, response.responseData);
                }
                //处理结束
                process.configuration.ProcessCompleted(process, response.error, responseData);
            }
        }];
    }
}

#pragma mark Private methods

+ (AELDOperationMode *)operationModeFromProcess:(AEDKProcess *)process {
    if (!process || ![process isKindOfClass:[AEDKProcess class]]) {
        return nil;
    }
    NSString *protocol = [process.request.URL scheme];
    if (![protocol isEqualToString:kAEDKServiceProtocolCache]) {
        return nil;
    }
    NSString *query = [process.request.URL query];
    NSArray *keyArray = [query componentsSeparatedByString:@"&"];
    NSString *key = nil;
    for (NSString *param in keyArray) {
        NSArray *paramArray = [param componentsSeparatedByString:@"="];
        NSString *paramKey = [paramArray firstObject];
        if ([paramKey isEqualToString:@"key"]) {
            key = [paramArray lastObject];
        }
    }
    AELDOperationType type = AELDOperationTypeRead;
    if ([process.request.HTTPMethod isEqualToString:kAEDKServiceMethodGet]) {
        type = AELDOperationTypeRead;
    } else if ([process.request.HTTPMethod isEqualToString:kAEDKServiceMethodPOST] || [process.request.HTTPMethod isEqualToString:kAEDKServiceMethodPUT]) {
        type = AELDOperationTypeWrite;
    } else if ([process.request.HTTPMethod isEqualToString:kAEDKServiceMethodDELETE]) {
        if ([key length] == 0) {
            type = AELDOperationTypeClear;
        } else {
            type = AELDOperationTypeDelete;
        }
    } else {
        return nil;
    }
    NSString *modeName = @"AELocalDataPlug";
    AELDOperationMode *mode = [AELDOperationMode modeWithName:modeName operationType:type];
    mode.key = key;
    mode.value = process.configuration.requestBody;
    return mode;
}


@end
