//
//  ALSShareService.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareResponse.h"
#import "ALSShareContext.h"
#import "ALSSharePlugInitializationInfo.h"
#import "ALSShareSocket.h"

@interface ALSShareService : NSObject

/**
 当前分享内容，如果非nil，则说明当前app正在分享进行中。
 */
@property (nonatomic, strong, readonly) ALSShareContext *sharingContext;

/**
 单实例

 @return 单实例
 */
+ (instancetype)globalService;

/**
 激活内建的分享插件

 @param strategy 插件的激活策略
 @param delegate 初始化代理
 @param result 激活结果
 */
- (void)activateBuiltInPlugs:(ALSBuiltInSharePlugStrategy)strategy withInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void(^)(NSDictionary<NSNumber *, NSNumber *> *resultInfo))result;

/**
 使对应平台的插件上线

 @param platform 平台
 @param delegate 初始化代理
 @return 是否上线成功
 */
- (BOOL)getShareServiceOnlineWithPlatform:(ALSSharePlatform)platform initializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate;

/**
 使所有平台的插件上线

 @param delegate 初始化代理
 @param result 上线结果
 */
- (void)getAllShareServicesOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void(^)(NSDictionary<NSNumber *, NSNumber *> *resultInfo))result;

/**
 开始分享操作

 @param context 分享内容
 @param response 分享结果
 @return 操作结果
 */
- (BOOL)startShare:(ALSShareContext *)context withResponse:(void(^)(ALSShareResponse *resp))response;

/**
 处理跳转返回的事件信息
 
 @param app UIApplication对象，可直接透传系统的值
 @param url 入参URL
 @param options 相关参数
 @return 处理成功或失败
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

@end
