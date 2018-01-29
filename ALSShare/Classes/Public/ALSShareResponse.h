//
//  ALSShareResponse.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareDefines.h"

@interface ALSShareResponse : NSObject

@property (nonatomic, readonly) ALSSharePlatform platform;  //分享平台

@property (nonatomic, strong) NSError *error; //分享操作返回错误信息

@property (nonatomic, copy) NSDictionary *userInfo; //分享操作返回用户信息

/**
 初始化分享操作请求返回的方法
 
 @param platform 分享平台
 @return 类实例
 */
- (instancetype)initWithPlatform:(ALSSharePlatform)platform;

@end
