//
//  ALSShareSocket.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSSharePlugProtocol.h"

typedef enum {
    ALSBuiltInSharePlugStrategyNone      = 0,
    ALSBuiltInSharePlugStrategyWechat    = 1 << 0,
    ALSBuiltInSharePlugStrategyTencent   = 1 << 1,
    ALSBuiltInSharePlugStrategyWeibo     = 1 << 2,
    ALSBuiltInSharePlugStrategyAll       = (1 << 3) - 1
}ALSBuiltInSharePlugStrategy;

@interface ALSShareSocket : NSObject

@property (nonatomic, strong, readonly) NSSet<id<ALSSharePlugProtocol>> *plugsInSocket; //插座中已插入的插件

@property (nonatomic, readonly) ALSBuiltInSharePlugStrategy plugStrategy;  //插件策略

/**
 分享操作插座单实例方法
 
 @return 类实例
 */
+ (instancetype)publicSocket;

/**
 插入内建插件
 
 @param strategy 插件策略
 */
- (void)plugInBuiltInPlugs:(ALSBuiltInSharePlugStrategy)strategy;

/**
 插入插件
 
 @param plug 被插入的插件
 */
- (void)plugIn:(id<ALSSharePlugProtocol>)plug;

/**
 拔出插件
 
 @param platform 被拔出插件的分享操作插件的平台
 */
- (void)plugOutWithPlatform:(ALSSharePlatform)platform;

/**
 获取对应分享操作模式的已插入插件
 
 @param platform 分享操作的平台
 @return 对应分享操作模式的已插入插件
 */
- (id<ALSSharePlugProtocol>)plugWithPlatform:(ALSSharePlatform)platform;

/**
 将对应分享操作模式的已插入插件启动
 
 @param platform 分享操作的平台
 @param delegate 分享操作初始化代理
 @return 是否启动成功
 */
- (BOOL)getOnlineForPlugWithPlatform:(ALSSharePlatform)platform withInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate;

/**
 将所有已插入的插件启动
 
 @param delegate 分享操作代理
 @param result 是否启动成功，resultInfo的key是分享操作模式，value是BOOL类型的启动成功标识
 */
- (void)getAllPlugsOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void(^)(NSDictionary<NSNumber *, NSNumber *> *resultInfo))result;

/**
 获取可处理跳转分享操作返回的事件信息的分享操作SDK
 
 @param app UIApplication对象，可直接透传系统的值
 @param url 入参URL
 @param options 相关参数
 @return 能处理该信息的分享操作SDK
 */
- (id<ALSSharePlugProtocol>)respondingPlugForApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

@end
