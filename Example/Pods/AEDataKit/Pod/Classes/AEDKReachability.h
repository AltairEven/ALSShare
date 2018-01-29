//
//  AEReachability.h
//  AEAssistant
//
//  Created by Qian Ye on 16/4/22.
//  Copyright © 2016年 StarDust. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AEDKNetworkStatusUnknown = -1,
    AEDKNetworkStatusNotReachable = 0,
    AEDKNetworkStatusCellType2G = 1,
    AEDKNetworkStatusCellType3G = 2,
    AEDKNetworkStatusCellType4G = 3,
    AEDKNetworkStatusReachableViaWiFi = 4,
}AEDKNetworkStatus;

@interface AEDKReachability : NSObject

@property (strong, nonatomic) NSString *domain;

@property (nonatomic, readonly) BOOL isNetworkStatusOK;

@property (nonatomic, readonly) AEDKNetworkStatus status;

@property (nonatomic, readonly) BOOL isMonitoring;

+ (instancetype)sharedInstance;

//开始网络状态监控
- (void)startNetworkMonitoringWithStatusChangeBlock:(void(^)(AEDKNetworkStatus status))block;
//停止网络状态监控
- (void)stopNetworkStatusMonitoring;

@end
