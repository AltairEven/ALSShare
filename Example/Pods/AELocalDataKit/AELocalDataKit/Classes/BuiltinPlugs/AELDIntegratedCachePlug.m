//
//  AELDIntegratedCachePlug.m
//  Pods
//
//  Created by Altair on 19/09/2017.
//
//

#import "AELDIntegratedCachePlug.h"
#import "AELDMemoryCachePlug.h"
#import "AELDDiskCachePlug.h"
#import "AELDPlugMode.h"
#import "AELDResponse.h"

@interface AELDIntegratedCachePlug ()

@end

@implementation AELDIntegratedCachePlug

#pragma mark AELocalDataPlugProtocal

- (AELDPlugMode *)plugMode {
    return [AELDPlugMode modeWithName:NSStringFromClass([self class]) supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear];
}

- (BOOL)startOperation:(AELDOperationMode *)mode response:(nonnull void (^)(AELDResponse * _Nonnull))response {
    if (!mode) {
        return NO;
    }
    AELDMemoryCachePlug *memoryCachePlug = [[AELocalDataSocket publicSocket] plugWithMode:[AELDPlugMode modeWithName:NSStringFromClass([AELDMemoryCachePlug class]) supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear]];
    AELDDiskCachePlug *diskCachePlug = [[AELocalDataSocket publicSocket] plugWithMode:[AELDPlugMode modeWithName:NSStringFromClass([AELDDiskCachePlug class]) supportOperationType:AELDOperationTypeRead|AELDOperationTypeWrite|AELDOperationTypeDelete|AELDOperationTypeClear]];
    if (!memoryCachePlug && !diskCachePlug) {
        return NO;
    }
    
    __block AELDResponse *operationResp = nil;
    //先操作内存缓存
    BOOL retValue = [memoryCachePlug startOperation:mode response:^(AELDResponse * _Nonnull resp) {
        operationResp = resp;
    }];
    if (mode.operationType == AELDOperationTypeRead && retValue && operationResp.responseData) {
        //如果是“读”操作，则在获取到数据后即返回
        if (response) {
            response(operationResp);
        }
        return YES;
    }
    //如果内存缓存操作失败，或者是非“读”操作，则继续操作磁盘缓存
    retValue = [diskCachePlug startOperation:mode response:^(AELDResponse * _Nonnull resp) {
        operationResp = resp;
    }];
    if (mode.operationType == AELDOperationTypeRead && retValue && operationResp.responseData) {
        //进行到此处，说明磁盘中有缓存，但是内存中没有，则同步一份到内存
        AELDOperationMode *syncMode = [AELDOperationMode modeWithName:mode.name operationType:AELDOperationTypeWrite];
        syncMode.key = mode.key;
        syncMode.value = operationResp.responseData;
        [memoryCachePlug startOperation:syncMode response:^(AELDResponse * _Nonnull response) {
            
        }];
    }
    if (response) {
        response(operationResp);
    }
    
    return YES;
}

- (BOOL)stopOperation {
    return YES;
}

@end
