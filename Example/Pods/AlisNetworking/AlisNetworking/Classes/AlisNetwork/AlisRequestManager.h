//
//  AlisRequestManager.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  把网络请求的每一个接口都看为一个资源

#import "AlisRequest.h"
#import "AlisPluginProtocol.h"
#import "AlisRequestProtocol.h"

#import <Foundation/Foundation.h>

@class AlisRequestConfig,AlisRequestContext,AlisService;

@interface AlisRequestManager : NSObject

+ (AlisRequestManager * _Nonnull)sharedManager;
+ (AlisRequestManager * _Nonnull)manager;

/**
 HTTPS 网站集合
 */
@property(strong,nonatomic,nullable)NSMutableArray *sslPinningHosts;

/**
 HTTPS 证书集合
 */
@property(strong,nonatomic,nullable)NSMutableArray *certSet;

//所有请求的数组，元素为Alirequest，请求发出，加入数组；请求结束，取消从数组中删掉；请求暂停不删除
@property(strong,nonatomic,nullable)NSMutableDictionary *requestSet;

@property(strong,nonatomic,nullable)AlisRequestContext *requestContext;

@property(strong,nonatomic)dispatch_semaphore_t _Nonnull semaphore;

- (void)startRequest:(AlisRequest * _Nonnull)request;

/**
 发出请求
 
 @param requestModel requestModel AlisServiceProxy
 @param service service 保存发出请求类的信息
 */
- (void)startRequestModel:(id<AlisRequestProtocol> _Nonnull)requestModel service:(AlisService * _Nonnull)service;

- (void)cancelRequest:(AlisRequest * _Nonnull)request;

//注意：
- (void)cancelRequestByIdentifier:(NSString * _Nonnull)requestIdentifier;
- (void)cancelRequestwithServiceName:(NSString * _Nonnull)requestIdentifier;

//设置请求的公有属性，server，head等
@property(strong,nonatomic,nullable)AlisRequestConfig *config;
- (void)setupConfig:(void(^_Nonnull
                          )(AlisRequestConfig * _Nullable config)) block;

/*
 在这里提供了两个请求的方法，建议用第二个，因为这样使得用户层和网络协议层隔离了，用户层完全感觉不到
 网络层的存在，而网络请求所需要的参数可以在用户层找到。
 - (void)startRequest:(AlisRequest *)request;
 - (void)startRequestModel:(id<AlisRequestProtocol>)requestModel;
 
 所有AlisRequest的回调（成功）都在AlisRequestManager中，再在AlisRequestManager中向用户层发回调。
 */

- (void)failureWithError:(AlisError * _Nullable)error withRequest:(AlisRequest *_Nonnull)request;
- (void)successWithResponse:(AlisResponse * _Nullable)response withRequest:(AlisRequest * _Nonnull)request;

- (void)sendChainRequest:(AlisChainRConfigBlock _Nullable)chainRequestConfigBlock
                 success:(nullable AlisChainRSucessBlock)success
                 failure:(nullable AlisChainRFailBlock)failure
                  finish:(nullable AlisChainRFinishedBlock)finish;

- (void)sendBatchRequest:(AlisBatchRequestConfigBlock _Nullable)batchRequestConfigBlock
               onSuccess:(nullable AlisBatchRSucessBlock)successBlock
               onFailure:(nullable AlisBatchRFailBlock)failureBlock
              onFinished:(nullable AlisBatchRFinishedBlock)finishedBlock;

@end


#pragma mark - AlisChainRequest
/**
 V1版 把所有结果都返回，暂时不要管太多
 */
@interface AlisChainRequest : NSObject


@property (nonatomic, copy, readonly) NSString  *_Nullable identifier;
@property (nonatomic, strong, readonly) AlisRequest *_Nullable runningRequest;

- (instancetype _Nullable )initWithBlocks:(AlisChainRSucessBlock _Nullable)success
               failure:(AlisChainRFailBlock _Nullable)failure
                finish:(AlisChainRFinishedBlock _Nullable)finish;

- (AlisChainRequest *_Nullable)onFirst:(AlisRequestConfigBlock _Nullable)firstBlock;
- (AlisChainRequest *_Nullable)onNext:(AlisChainNextRBlock _Nullable)nextBlock;

- (BOOL)onFinishedOneRequest:(AlisRequest *_Nullable)request response:(nullable id)responseObject error:(nullable AlisError *)error;

@end

#pragma mark - AlisBatchRequest

@interface AlisBatchRequest : NSObject

@property (nonatomic, copy, readonly) NSString *_Nullable identifier;
@property (nonatomic, strong, readonly) NSMutableArray *_Nullable requestArray;
@property (nonatomic, strong, readonly) NSMutableArray *_Nullable responseArray;

- (instancetype _Nullable)initWithBlocks:(AlisBatchRSucessBlock _Nullable)success
                       failure:(AlisBatchRFailBlock _Nullable)failure
                        finish:(AlisBatchRFinishedBlock _Nullable)finish;

- (BOOL)onFinishedRequest:(AlisRequest *_Nullable)request response:(nullable id)responseObject error:(nullable NSError *)error;

@end



