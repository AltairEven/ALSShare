//
//  AlisRequestProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  在每个请求中个性化的东西

#import <Foundation/Foundation.h>
#import "AlisRequestConst.h"

@class AlisRequest,AlisResponse,AlisError,Service;

typedef void(^AlisRequestFinishRequest) (AlisRequest *request ,AlisResponse *response ,AlisError *error);
typedef void(^AlisRequestProgressRequest)(AlisRequest *request ,long long receivedSize, long long expectedSize);

@protocol AlisRequestProtocol <NSObject>

//添加请求前后的处理
- (id)beforeRequest:(id)data;
- (id)afterRequest:(id)data;

/**
 解析接口返回的JSON数据的类

 @param serviceName 资源名称
 @return 解析接口返回的JSON数据的类
 */
- (NSString *)parseClass:(NSString *)serviceName;

- (AlisRequestType)requestType:(NSString *)serviceName;
//相对路径
- (NSString *)api:(NSString *)serviceName;
- (NSString *)server:(NSString *)serviceName;

- (NSDictionary *)requestParams:(NSString *)serviceName;

/**
 设置HTTP的head，比如认证，cookie等
 @return 返回字典
 */
- (NSDictionary *)requestHead:(NSString *)serviceName;

- (AlisHTTPMethodType)httpMethod:(NSString *)serviceName;


//定义了一种服务
//@property(copy,nonatomic)Service *currentService;
//当前服务的容器，成员是字典，key 为服务的全局名称，value为发出服务请求的类（类型为“Service”）
@property(strong,nonatomic)NSMutableDictionary *currentServeContainer;

//或者可以改为代理
@property(copy,nonatomic)AlisRequestFinishRequest businessLayer_requestFinishBlock;
@property(copy,nonatomic)AlisRequestProgressRequest businessLayer_requestProgressBlock;

#pragma mark -- 上传文件情况使用
//文件在沙盒里的位置,如果上传，就是源地址／如果下载任务，就是目的地址
- (NSString *)fileURL:(NSString *)serviceName;
//上传情况下的data
- (NSData *)uploadData:(NSString *)serviceName;
//附加消息
- (NSDictionary *)additionalInfo:(NSString *)serviceName;

//处理访问资源后的结果
- (void)handlerServiceResponse:(AlisRequest *)request  serviceName:(NSString *)serviceName  response:(id)response;

/**
 访问资源的程度，一般是http 上传下载
 
 @param request 网络请求
 @param progress 程度，百分比
 */
- (void)handlerServiceResponse:(AlisRequest *)request  serviceName:(NSString *)serviceName progress:(float)progress;

/**
 访问资源的程度，一般是http 上传下载
 @param request 网络请求
 @serviceName 
 */
- (void)handlerServiceResponse:(AlisRequest *)request  serviceName:(NSString *)serviceName error:(AlisError *)error;

@end
