//
//  AEReachability.m
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import "AEDKReachability.h"
#import "AEDKNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static AEDKReachability *_sharedManager = nil;

@interface AEDKReachability ()

@property (nonatomic, strong) AEDKNetworkReachabilityManager *reachabilityManager;

@end

@implementation AEDKReachability
@synthesize domain;
@synthesize isNetworkStatusOK = _isNetworkStatusOK;
@synthesize reachabilityManager;
@synthesize status = _status;

- (id)init
{
    self = [super init];
    if (self) {
        //默认有效,因为监控开始时网络状态未知
        _isNetworkStatusOK = YES;
    }
    
    return self;
}



+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate = 0;
    
    dispatch_once(&predicate, ^ (void) {
        _sharedManager = [[AEDKReachability alloc] init];
    });
    
    return _sharedManager;
}



- (void)startNetworkMonitoringWithStatusChangeBlock:(void (^)(AEDKNetworkStatus))block
{
    //初始化网络状态监控
    if (self.domain && ![self.domain isEqualToString:@""]) {
        self.reachabilityManager = [AEDKNetworkReachabilityManager managerForDomain:self.domain];
    } else {
        self.reachabilityManager = [AEDKNetworkReachabilityManager sharedManager];
    }
    [self.reachabilityManager startMonitoring];
    _isMonitoring = YES;
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.reachabilityManager setReachabilityStatusChangeBlock:^(AEDKNetworkReachabilityStatus status){
        AEDKNetworkStatus netStatus = AEDKNetworkStatusUnknown;
        switch (status) {
            case AEDKNetworkReachabilityStatusUnknown:
            {
                _isNetworkStatusOK = NO;
                _status = AEDKNetworkStatusUnknown;
                netStatus = AEDKNetworkStatusUnknown;
            }
                break;
            case AEDKNetworkReachabilityStatusNotReachable:
            {
                _isNetworkStatusOK = NO;
                _status = AEDKNetworkStatusNotReachable;
                netStatus = AEDKNetworkStatusNotReachable;
            }
                break;
            case AEDKNetworkReachabilityStatusReachableViaWWAN:
            {
                _isNetworkStatusOK = YES;
                //os version > 7.0
                CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
                NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
                if (currentRadioAccessTechnology) {
                    if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                        _status = AEDKNetworkStatusCellType4G;
                        netStatus = AEDKNetworkStatusCellType4G;
                    } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                        _status = AEDKNetworkStatusCellType2G;
                        netStatus = AEDKNetworkStatusCellType2G;
                    } else {
                        _status = AEDKNetworkStatusCellType3G;
                        netStatus = AEDKNetworkStatusCellType3G;
                    }
                }
            }
                break;
            case AEDKNetworkReachabilityStatusReachableViaWiFi:
            {
                _isNetworkStatusOK = YES;
                _status = AEDKNetworkStatusReachableViaWiFi;
                netStatus = AEDKNetworkStatusReachableViaWiFi;
            }
                break;
            default:
                break;
        }
        
        if (block) {
            block(netStatus);
        }
    }];
    
}


- (void)stopNetworkStatusMonitoring
{
    [[AEDKNetworkReachabilityManager sharedManager] stopMonitoring];
    
    _isNetworkStatusOK = NO;
    _isMonitoring = NO;
}

@end
