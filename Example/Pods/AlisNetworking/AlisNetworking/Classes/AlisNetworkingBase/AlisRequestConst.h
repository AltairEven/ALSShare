//
//  AliRequestConst.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/23.
//  Copyright © 2017年 alisports. All rights reserved.
//

#ifndef AlisRequestConst_h
#define AlisRequestConst_h
#import <Foundation/Foundation.h>

@class AlisRequest,AlisChainRequest,AlisRequestManager,AlisError,AlisResponse,AlisBatchRequest;
/**
 网络状况
 */
typedef NS_ENUM(NSInteger, AlisNetworkReachabilityStatus) {
    AlisNetworkReachabilityStatusUnknown          = -1,
    AlisNetworkReachabilityStatusNotReachable     = 0,
    AlisNetworkReachabilityStatusReachableViaWWAN = 1,
    AlisNetworkReachabilityStatusReachableViaWiFi = 2,
};
/**
 请求类型
 */
typedef NS_ENUM(NSInteger, AlisRequestType) {
    AlisRequestUnknow    = -1,
    AlisRequestNormal    = 0,    //!< Normal HTTP request type, such as GET, POST, ...
    AlisRequestUpload    = 1,    //!< Upload request type
    AlisRequestDownload  = 2,    //!< Download request type
};

/**
 请求方法
 */
typedef NS_ENUM(NSInteger, AlisHTTPMethodType) {
    AlisHTTPMethodUnknow = -1,
    AlisHTTPMethodGET    = 0,    //!< GET
    AlisHTTPMethodPOST   = 1,    //!< POST
    AlisHTTPMethodHEAD   = 2,    //!< HEAD
    AlisHTTPMethodDELETE = 3,    //!< DELETE
    AlisHTTPMethodPUT    = 4,    //!< PUT
    AlisHTTPMethodPATCH  = 5,    //!< PATCH
};

typedef void(^AlisRequestStartBlock) (void);
typedef void(^AlisRequestCancelBlock) (void);
typedef void(^AlisRequestFinishBlock) (AlisRequest * _Nonnull request ,AlisResponse * _Nullable response ,AlisError * _Nullable error);
typedef void(^AlisRequestProgressBlock)(AlisRequest * _Nonnull request ,long long receivedSize, long long expectedSize);

typedef void(^AlisRequestConfigBlock)( AlisRequest *_Nonnull request);

typedef void (^AlisChainNextRBlock)(AlisRequest *_Nonnull request, id _Nullable responseObject, AlisError * __nullable error);

typedef void (^AlisChainRConfigBlock)( AlisChainRequest * _Nonnull request);
typedef void (^AlisBatchRequestConfigBlock)(AlisBatchRequest * _Nonnull batchRequest);

typedef void(^AlisChainRSucessBlock)(NSArray * __nullable responseArray);
typedef void(^AlisChainRFailBlock)(NSArray * __nullable errorArray);
typedef void(^AlisChainRFinishedBlock)(NSArray * _Nonnull responseArray ,NSArray * __nullable errorArray);

typedef void(^AlisBatchRSucessBlock)(NSArray * __nullable responseArray);
typedef void(^AlisBatchRFailBlock)(NSArray * __nullable errorArray);
typedef void(^AlisBatchRFinishedBlock)(NSArray * _Nonnull responseArray ,NSArray * __nullable errorArray);


#endif /* AliRequestConst_h */
