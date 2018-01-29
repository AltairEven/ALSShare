//
//  ALSSharePlugInitializationInfo.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareDefines.h"

@interface ALSSharePlugInitializationInfo : NSObject <NSCopying>

@property (nonatomic, assign) ALSSharePlatform platform;

@property (nonatomic, copy) NSString *appKey;

@property (nonatomic, copy) NSString *appSecret;

@property (nonatomic, copy) NSString *urlScheme;

@property (nonatomic, copy) NSString *redirectUrl; //ALSSharePlatformWeibo时传入redirectUrl，

/**
 快捷创建实例对象的方法
 
 @param platform platform
 @param key appKey
 @param secret appSecret
 @param scheme urlScheme
 @param url redirectUrl
 @return 类实例
 */
+ (instancetype)infoWithSharePlatform:(ALSSharePlatform)platform appKey:(NSString *)key appSecret:(NSString *)secret urlScheme:(NSString *)scheme andRedirectUrl:(NSString *)url;

@end

@protocol ALSSharePlugInitializationProtocol <NSObject>

@required

/**
 获取初始化信息
 
 @param platform 分享平台
 @return 初始化信息数组
 */
- (ALSSharePlugInitializationInfo *)sharePlugInitilizationInfoForPlatform:(ALSSharePlatform)platform;

@end
