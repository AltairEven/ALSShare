//
//  AlisRequestContext.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisRequestProtocol.h"
#import "AlisRequestConst.h"
#import <Foundation/Foundation.h>


//网络请求的环境
@interface AlisRequestContext : NSObject

+ (AlisRequestContext *)shareContext;

@property(assign,nonatomic)AlisNetworkReachabilityStatus networkReachabilityStatus;

/**
 发出请求的类
 */
@property(weak,nonatomic)id<AlisRequestProtocol> makeRequestClass;

/**
 服务的名称(全局的)
 */
@property(copy,nonatomic)NSString *serviceName;

@end
