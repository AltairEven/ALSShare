//
//  AlisPluginProtocol.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  定义了每个模块可以提供什么样的服务和能力
#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define JS_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define JS_EXTERN extern __attribute__((visibility("default")))
#endif

typedef enum {
    AlisHttpRequestMimeTypeUndefine,
    AlisHttpRequestMimeTypeText,
    AlisHttpRequestMimeTypeImage,
    AlisHttpRequestMimeTypeOther
}AlisHttpRequestMimeType;


//AlisRequet 自定义的request
//AlisResponse 自定义的response
@class AlisResponse,AlisError,AlisRequestConfig,AlisRequest;

@protocol AlisPluginProtocol <NSObject>

#define NETWORKINGPLUGIN_EXPORT_MODULE(js_name) \
JS_EXTERN void NetworkingPluginRegisterModule(Class); \
+ (NSString *)moduleName { return @#js_name; } \
+ (void)load { NetworkingPluginRegisterModule(self); }

/**
 支持的网络请求类型， todo 目前定为每个plugin仅限一种
 */
- (AlisHttpRequestMimeType)supportHttpRequestMimeType;
/**
 *  将我们自定义的reqeust转换为可以真正发出网络请求的reqeust。
 *
 *  @param request     请求（可能需要请求的一些参数来生成响应，如responseClass等）。
 *  @param config  公共配置项,配置公共的请求config，eg：server等。
 *
 */
- (void)parseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config;

/**
 *  解析接口返回的remoteResponse，得到我们想要的数据。
 *
 *  @param remoteResponse 服务器的响应
 *  @param request     请求（可能需要请求的一些参数来生成响应，如responseClass等）。
 *
 *  @return 响应 AlisResponse。
 */
- (AlisResponse *)parseResponse:(id)remoteResponse request:(AlisRequest *)request;

/**
 *  解析接口返回的错误信息。
 *
 *  @param remoteError 服务器的错误响应
 *
 *  @return 响应 AlisResponse。
 */

- (AlisError *)parseError:(NSError *)remoteError;

@required
/**
 *  定义可以提供的服务，例如 本地缓存,图片下载，一般的下载， 同步下载等。方便manager判断
 */
- (NSArray *)supportSevervice;

@end
