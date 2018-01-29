//
//  AlisHttpService.h
//  Pods
//
//  Created by alisports on 2017/6/28.
//
//

#import <Foundation/Foundation.h>

/**
 http请求的参数
 */
@interface AlisHttpServiceItem : NSObject

/**
 协议，默认http
 */
@property(copy,nonatomic)NSString *protocol;

/**
 get post etc
 */
@property(copy,nonatomic)NSString *httpMethod;

/**
 请求相对路径
 */
@property(copy,nonatomic)NSString *api;

/**
 服务器配置
 */
@property(copy,nonatomic)NSString *server;

/**
 解析数据的类
 */
@property(copy,nonatomic)NSString *parseClass;

@end
