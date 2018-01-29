//
//  ALSSharePlugProtocol.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareDefines.h"
#import "ALSShareContext.h"
#import "ALSShareResponse.h"
#import "ALSSharePlugInitializationInfo.h"

/**
 分享操作插件需要遵循的协议
 */
@protocol ALSSharePlugProtocol <NSObject>

@required

/**
 获取是否在线，即是否启动成功
 
 @return 是否在线
 */
- (BOOL)isOnLine;

/**
 获取分享插件支持的平台
 
 @return 插件模式
 */
- (ALSSharePlatform)platform;


/**
 开始分享
 
 @param context 分享内容
 @param response 分享结果
 @return 是否发起分享
 */
- (BOOL)startShare:(ALSShareContext *)context withResponse:(void(^)(ALSShareResponse *resp))response;

@optional

/**
 启动分享操作插件
 
 @param delegate 分享操作插件启动所需信息的代理
 @return 启动是否成功
 */
- (BOOL)getOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate;

/**
 是否可以处理跳转分享操作返回事件
 
 @param url 入参URL
 @return 是否可处理
 */
- (BOOL)respondsToOpenUrl:(NSURL *)url;

/**
 处理跳转分享操作返回的事件信息
 
 @param app UIApplication对象，可直接透传系统的值
 @param url 入参URL
 @param options 相关参数
 @return 处理成功或失败
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

@end
