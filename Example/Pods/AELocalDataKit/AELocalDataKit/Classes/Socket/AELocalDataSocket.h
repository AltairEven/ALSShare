//
//  AELocalDataSocket.h
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AELDBuiltInPlugStrategyMemoryCache      = 1 << 0,
    AELDBuiltInPlugStrategyDiskFileCache    = 1 << 1,
    AELDBuiltInPlugStrategySQL              = 1 << 2,   //暂不支持
}AELDBuiltInPlugStrategy;

@class AELDPlugMode;
@class AELDOperationMode;
@class AELDResponse;


NS_ASSUME_NONNULL_BEGIN

/**
 本地数据操作插件需要遵循的协议
 */
@protocol AELocalDataPlugProtocal <NSObject>

@required

/**
 获取数据插件模式
 
 @return 插件模式
 */
- (AELDPlugMode *)plugMode;

/**
 开始数据操作
 
 @param mode 数据操作请求
 @param response 数据操作返回
 @return 是否开始操作成功，非操作结果
 */
- (BOOL)startOperation:(AELDOperationMode *)mode response:(void(^)(AELDResponse *response))response;

/**
 停止数据操作
 
 @return 是否停止成功
 */
- (BOOL)stopOperation;

@end


/**
 本地数据操作插座
 */
@interface AELocalDataSocket : NSObject

@property (nonatomic, strong, readonly) NSSet<id<AELocalDataPlugProtocal>> *plugsInSocket; //插座中已插入的插件

@property (nonatomic, readonly) AELDBuiltInPlugStrategy builtInPlugStrategy;  //内建的插件策略

/**
 本地数据操作插座单实例方法
 
 @return 类实例
 */
+ (instancetype)publicSocket;

/**
 插入内建插件
 
 @param strategy 插件策略
 */
- (void)plugInBuiltInPlugs:(AELDBuiltInPlugStrategy)strategy;

/**
 插入插件
 
 @param plug 被插入的插件
 */
- (void)plugIn:(id<AELocalDataPlugProtocal>)plug;

/**
 拔出插件
 
 @param mode 被拔出插件的数据操作模式
 */
- (void)plugOutWithMode:(AELDPlugMode *)mode;

/**
 获取对应数据操作模式的已插入插件
 
 @param mode 数据操作模式
 @return 对应数据操作模式的已插入插件
 */
- (id<AELocalDataPlugProtocal> __nullable)plugWithMode:(AELDPlugMode *)mode;

/**
 获取包含对应数据操作模式的已插入插件
 
 @param mode 数据操作模式
 @return 对应数据操作模式的已插入插件
 */
- (id<AELocalDataPlugProtocal> __nullable)plugSupportedOperationWithMode:(AELDOperationMode *)mode;

@end


NS_ASSUME_NONNULL_END
