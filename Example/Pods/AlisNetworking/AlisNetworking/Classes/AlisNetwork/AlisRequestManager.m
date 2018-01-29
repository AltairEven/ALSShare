//
//  AlisRequestManager.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "NSString+help.h"
#import "AlisRequestManager.h"
#import "AlisRequestContext.h"
#import "AlisRequestConfig.h"
#import "AlisPluginManager.h"
#import "AlisRequestConst.h"
#import "AlisService.h"
#import "AlisRequestManager+AlisRequest.h"
#import "AlisRequestConfig.h"
#import "AlisRequestContext.h"
#import "AlisService.h"

typedef NSDictionary *(^ PreRequestBlcok) (void);

#define ALIS_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

@interface AlisRequestManager ()

@property(weak,nonatomic) id<AlisRequestProtocol>requestModel;

@property(strong,nonatomic)AlisPluginManager *pluginManager;

//请求前的预处理BLOCK，可能加一些服务器定制的东西，例如：时间戳等
@property(copy,nonatomic)PreRequestBlcok preRequestBlcok;

@end

@implementation AlisRequestManager

+ (AlisRequestManager *)sharedManager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

+ (AlisRequestManager *)manager{
    return [[[self class]alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        self.requestContext = [AlisRequestContext shareContext];
        self.pluginManager = [AlisPluginManager manager];
        _semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (NSMutableDictionary *)requestSet{
    if (_requestSet == nil) {
        _requestSet = [NSMutableDictionary dictionary];
    }
    return _requestSet;
}

#pragma mark -- config
- (void)setupConfig:(void (^)(AlisRequestConfig *config))block
{
    AlisRequestConfig *__config = [[AlisRequestConfig alloc]init];
    block(__config);
    self.config = __config;
    
    self.preRequestBlcok = ^NSDictionary *(void) {
        //eg 时间戳
//        NSString *timestampString = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970] ];
//        return @[@"timestamp":timestampString];
        return nil;
    };
}

- (void)startRequestModel:(id<AlisRequestProtocol>)requestModel service:(AlisService *)service{
    if (![self canRequest:requestModel]){
        NSLog(@"网络中断，无法访问");
        return;
    }
        
    //request 请求的回调都在该类中
    ServiceAction serviceAction = service.serviceAction;
    if (serviceAction == Resume) {
        [self start_Request:^(AlisRequest *request) {
            request.bindRequestModel = requestModel; //绑定业务层对应的requestModel
            request.serviceName = service.serviceName;
            
            request.preParameters = self.preRequestBlcok();
            [self prepareRequest:request requestModel:requestModel service:service];
            //如果是同步请求
            if (self.config.enableSync) {
                dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
            }
        } service:service];
    }
    else if (serviceAction == Cancel){
        [self cancelRequestByIdentifier:service.serviceName];
    }
    else if (serviceAction == Suspend){
        [self suspendRequestByIdentifier:service.serviceName];
    }
}

- (void)start_Request:(AlisRequestConfigBlock)requestConfigBlock service:(AlisService *)service{
    AlisRequest *request = nil;
    if (service) {
        AlisRequest *_request = self.requestSet[service.serviceName];
        
        if (_request) {
            request = _request;
        }
        else{
            request = [[AlisRequest alloc]init];//一个全新的请求
            requestConfigBlock(request);
        }
        [self startRequest:request];
    }
}

#pragma mark --- 对Request的操作 ---
/**
 发出请求
 @param request 封装的请求
 */
- (void)startRequest:(AlisRequest *)request{
        
    id<AlisPluginProtocol> plugin = nil;
    if (request.mimeType == AlisHttpRequestMimeTypeText) {
        plugin = [self.pluginManager plugin:@"AFNetwoking"];
    }
    else if (request.mimeType == AlisHttpRequestMimeTypeImage) {
        plugin = [self.pluginManager plugin:@"SDWebimage"];
    }
    
    if (plugin == nil) {
        NSLog(@"对应的插件不存在！"); return;
    }

    //设置请求的MD5值。注：可以有其他方式
    request.identifier = [request.url md5WithString];
    NSString *requestIdentifer = request.context.serviceName; 
    if (requestIdentifer) {
        (self.requestSet)[requestIdentifer] = request;
    }
    else{
        NSLog(@"warning: 请求资源的名称为空");
    }
    
    //plugin发出请求，在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
    [plugin parseRequest:request config:_config];
}

- (void)cancelRequest:(AlisRequest *)request{
    if (request == nil)  return;
    if(request.bindRequest){
        [request.bindRequest cancel];
        NSString *serviceName = request.serviceName;
        if (serviceName) {
            [self.requestSet removeObjectForKey:serviceName];
            [request.bindRequestModel.currentServeContainer removeObjectForKey:serviceName];
        }
    }    
}

- (void)cancelRequestwithServiceName:(NSString *)requestIdentifier{
    [self cancelRequestByIdentifier:requestIdentifier];
}

- (void)cancelRequestByIdentifier:(NSString *)requestIdentifier{
    if (requestIdentifier == nil)  return;
    AlisRequest *request = _requestSet[requestIdentifier];
    
    [self cancelRequest:request];
}

- (void)suspendRequest:(AlisRequest *)request{
    if (request == nil)  return;
    if(request.bindRequest){
        [request.bindRequest suspend];
    }    
}

- (void)suspendRequestByIdentifier:(NSString *)requestIdentifier{
    if (requestIdentifier == nil)  return;
    AlisRequest *request = _requestSet[requestIdentifier];
    
    [self suspendRequest:request];
}

#pragma mark --- 
//访问网络前的最后准备，准备好请求地址，头head，参数parameters，body，url，回调方法等等
- (void)prepareRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(AlisService *)service{
    [self adapteAlisRequest:request requestModel:requestModel service:service];
}

- (void)failureWithError:(AlisError *)error withRequest:(AlisRequest *)request{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
        });
    } 
    else {
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,nil,error);
    }
    
    //重试次数，这个需要商榷，如果是主动取消的，就没有必要重试了，应该根据错误类型区别对待
//    if (request.retryCount > 0 ) {
//        request.retryCount --;
//        [self startRequest:request];
//    }
    
}

- (void)successWithResponse:(AlisResponse *)response withRequest:(AlisRequest *)request
{
    __weak typeof (request) weakRequest = request;
    if (self.config.callBackQueue) {
        dispatch_async(self.config.callBackQueue, ^{
            weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
        });
    } 
    else{
        weakRequest.bindRequestModel.businessLayer_requestFinishBlock(request,response,nil);
    }
    
    // [self clearBlocks:request];
    //请求成功，删除请求
    NSString *serviceName = request.serviceName;
    if (serviceName) {
        [self.requestSet removeObjectForKey:serviceName];
        [request.bindRequestModel.currentServeContainer removeObjectForKey:serviceName];
    }
}

- (void)clearBlocks:(AlisRequest *)request{
    request.finishBlock = nil;
    request.progressBlock = nil;
    request.cancelBlock = nil;
    request.startBlock = nil;
}
#pragma mark -- help
//如果网络出现问题，返回失败
- (BOOL)canRequest:(id<AlisRequestProtocol>)requestModel{
    
    if (self.requestContext.networkReachabilityStatus == AlisNetworkReachabilityStatusNotReachable) {
        AlisError *_error = [[AlisError alloc]init];
        _error.name = @"NO_Network";
        _error.detailInfo = @"无网络连接";
        requestModel.businessLayer_requestFinishBlock(nil,nil,_error);
        return NO;
    }
    
    return YES;
}

#pragma mark -- https
- (void)addSSLPinningURL:(NSString *)url {
    NSParameterAssert(url);
    
//    if ([url hasPrefix:@"https"]) {
//        NSString *rootDomainName = [self xm_rootDomainNameFromURL:url];
//        if (rootDomainName && ![self.sslPinningHosts containsObject:rootDomainName]) {
//            [self.sslPinningHosts addObject:rootDomainName];
//        }
//    }
}

- (void)addSSLPinningCert:(NSData *)cert {
    NSParameterAssert(cert);
    
//    NSMutableSet *certSet;
//    if (self.securitySessionManager.securityPolicy.pinnedCertificates.count > 0) {
//        certSet = [NSMutableSet setWithSet:self.securitySessionManager.securityPolicy.pinnedCertificates];
//    } else {
//        certSet = [NSMutableSet set];
//    }
//    [certSet addObject:cert];
//    [self.securitySessionManager.securityPolicy setPinnedCertificates:certSet];
}

#pragma mark -- chainRequest
- (void)sendChainRequest:(AlisChainRConfigBlock )chainRequestConfigBlock success:(AlisChainRSucessBlock)success failure:(AlisChainRFailBlock)failure finish:(AlisChainRFinishedBlock)finish{
    
    AlisChainRequest *chainRequest = [[AlisChainRequest alloc]initWithBlocks:success failure:failure finish:finish];
    if (chainRequestConfigBlock) {
        //设置chainRequest
        chainRequestConfigBlock(chainRequest);
    }
    [self sendChainRequest:chainRequest];
}


/**
 该方法负责将AlisRequest一个一个发送
 @param chainRequest  chainRequest
 */
- (void)sendChainRequest:(AlisChainRequest *)chainRequest{
    if (chainRequest.runningRequest) {
        id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
        //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
        __weak AlisRequestManager *weakSelf = self;
        [self prepareRequest:chainRequest.runningRequest onProgress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        } onSuccess:nil 
          onFailure:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
              [weakSelf handerResponse:chainRequest request:request response:response error:error];      
        } onFinished:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
             [weakSelf handerResponse:chainRequest request:request response:response error:error]; 
        }];
        
        //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
        [plugin parseRequest:chainRequest.runningRequest config:_config];
        //设置请求的MD5值。注：可以有其他方式
        chainRequest.runningRequest.identifier = [chainRequest.runningRequest.url md5WithString];
//        NSString *requestIdentifer = chainRequest.runningRequest.context.serviceName;
//        if (requestIdentifer) {
//            (self.requestSet)[requestIdentifer] = request;
//        }
//        else{
//            NSLog(@"warning: 请求资源的名称不能为空");
//        }

    }
}

/**
 AlisRequest 请求回来的处理
 @param chainRequest chainRequest
 @param request 单个请求
 @param response 单个请求的回复
 @param error 单个请求回复的错误
 */
- (void)handerResponse:(AlisChainRequest *)chainRequest request:(AlisRequest *)request response:(AlisResponse *)response error:(AlisError *)error{
    if([chainRequest onFinishedOneRequest:request response:response error:error]){
        NSLog(@"AlisChainRequest中单个AlisRequest请求成功");
        //请求全部完成
    }
    else{
         NSLog(@"AlisChainRequest中单个AlisRequest请求失败");
        //请求还没有完全完成
        if(chainRequest.runningRequest){
            [self sendChainRequest:chainRequest];
        }
    }  
}

- (void)prepareRequest:(AlisRequest *)request
            onProgress:(AlisRequestProgressRequest)progressBlock
             onSuccess:(AlisRequestFinishRequest)successBlock
             onFailure:(AlisRequestFinishRequest)failureBlock
            onFinished:(AlisRequestFinishRequest)finishedBlock {
    
    if (progressBlock) {
        request.progressBlock = progressBlock;
    }
    
    if (failureBlock) {
        request.finishBlock = failureBlock;
    }
    
    if (finishedBlock) {
        request.finishBlock = finishedBlock;
    }
}

- (void)sendBatchRequest:(AlisBatchRequestConfigBlock)batchRequestConfigBlock
               onSuccess:(nullable AlisBatchRSucessBlock)successBlock
               onFailure:(nullable AlisBatchRFailBlock)failureBlock
              onFinished:(nullable AlisBatchRFinishedBlock)finishedBlock{
    AlisBatchRequest *batchRequest = [[AlisBatchRequest alloc] initWithBlocks:successBlock failure:failureBlock finish:finishedBlock];
    ALIS_SAFE_BLOCK(batchRequestConfigBlock, batchRequest);
    
    if (batchRequest.requestArray.count > 0) {
        [batchRequest.responseArray removeAllObjects];
        for (AlisRequest *request in batchRequest.requestArray) {
            [batchRequest.responseArray addObject:[NSNull null]];
            __weak __typeof(self)weakSelf = self;
            id<AlisPluginProtocol> plugin = [self.pluginManager plugin:@"AFNetwoking"];
                    //在这里解析两部分，一部分是公共的--AlisRequestConfig，一部分是自己的,
            [self prepareRequest:request onProgress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
            } onSuccess:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
                [weakSelf handerBatchResponse:batchRequest request:request response:response error:error];
            }  
              onFailure:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
                [weakSelf handerBatchResponse:batchRequest request:request response:response error:error];
            } onFinished:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
                [weakSelf handerBatchResponse:batchRequest request:request response:response error:error];
            }];
                    
            [plugin parseRequest:request config:_config];
        }
        
//        NSString *identifier = [self xm_identifierForBatchAndChainRequest];
//        [batchRequest setValue:identifier forKey:@"_identifier"];
//        XMLock();
//        [self.runningBatchAndChainPool setValue:batchRequest forKey:identifier];
//        XMUnlock();
        
        //return identifier;
    } else {
       // return nil;
    }
}

- (void)handerBatchResponse:(AlisBatchRequest *)batchRequest request:(AlisRequest *)request response:(AlisResponse *)response error:(AlisError *)error{
    if (batchRequest) {
        [batchRequest onFinishedRequest:request response:response error:error.originalError];
    }
}

@end

#pragma mark -- AlisChainRequest

@interface AlisChainRequest()
{
    //当前请求的 index
    NSInteger _chainIndex;
}

/**
 得到的response数组
 */
@property(strong,nonatomic)NSMutableArray *responseArray;

/**
 保存下次请求的block，以便前一次请求完成后，设置第二次请求。
 */
@property(strong,nonatomic)NSMutableArray *nextRequestArray;

@property(strong,nonatomic)AlisRequest *runningRequest;


/**
 finish 表示整个请求都结束，success 表示部分成功
 */
@property (nonatomic, copy) AlisChainRSucessBlock chainSuccessBlock;
@property (nonatomic, copy) AlisChainRFailBlock chainFailureBlock;
@property (nonatomic, copy) AlisChainRFinishedBlock chainFinishedBlock;

@end

@implementation AlisChainRequest

- (instancetype)initWithBlocks:(AlisChainRSucessBlock)success
               failure:(AlisChainRFailBlock)failure
                finish:(AlisChainRFinishedBlock)finish{
    self = [super init];
    if (self) {
        _chainIndex = 0;
        _responseArray = [NSMutableArray array];
        _nextRequestArray = [NSMutableArray array];
        
        _chainSuccessBlock = success? success:nil;
        _chainFailureBlock = failure? failure:nil;
        _chainFinishedBlock = finish? finish :nil; 
    }
    return self;
}

- (AlisChainRequest *)onFirst:(AlisRequestConfigBlock)firstBlock{
    NSAssert(firstBlock, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray , @"");
    [_responseArray addObject:[NSNull null]];
    _runningRequest = [[AlisRequest alloc]init];
    firstBlock(_runningRequest);
    return self;
}

- (AlisChainRequest *)onNext:(AlisChainNextRBlock)nextBlock{
    NSAssert(nextBlock, @"firstBlock cannot be nil");
    NSAssert(self.nextRequestArray, @"");
    [_responseArray addObject:[NSNull null]];
    [_nextRequestArray addObject:nextBlock];
    return self;
}
/**
 chainRequest每项请求完成都回调
 
 @param request 完成的AlisRequest
 @param responseObject  收到的数据
 @param error error description
 @return YES:表示chain请求全部完成请求， NO:表示还没有都完成
 */
- (BOOL)onFinishedOneRequest:(AlisRequest *)request response:(nullable id)responseObject error:(nullable AlisError *)error{
    BOOL isFinished = NO;
    if (responseObject) {
        //得到第_chainIndex个请求的结果
        [_responseArray replaceObjectAtIndex:_chainIndex withObject:responseObject];
        
        if (_chainIndex < _nextRequestArray.count) {
            _runningRequest = [AlisRequest request];
            AlisChainNextRBlock nextBlock = _nextRequestArray[_chainIndex];
            //设置下一个请求参数
            nextBlock(_runningRequest,responseObject,error);
            
            if (!error) {
                ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            }
            else{
                ALIS_SAFE_BLOCK(_chainFailureBlock,_responseArray);
            }
            isFinished = NO;
        }
        else{
            ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            ALIS_SAFE_BLOCK(_chainFinishedBlock,_responseArray,nil);
            isFinished = YES;
        }
    }
    else{
        if(error){
            [_responseArray replaceObjectAtIndex:_chainIndex withObject:error];
        }
        if (_chainIndex < _nextRequestArray.count) {
            _runningRequest = [AlisRequest request];
            AlisChainNextRBlock nextBlock = _nextRequestArray[_chainIndex];
            //设置下一个请求参数
            nextBlock(_runningRequest,responseObject,error);
            
            if (!error) {
                ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            }
            else{
                ALIS_SAFE_BLOCK(_chainFailureBlock,_responseArray);
            }

            isFinished = NO;
        }
        else{
            ALIS_SAFE_BLOCK(_chainSuccessBlock,_responseArray);
            ALIS_SAFE_BLOCK(_chainFinishedBlock,_responseArray,nil);            
            isFinished = YES;
        }
    }
    
    _chainIndex++;
    return isFinished;
}

@end

#pragma mark - AlisBatchRequest

@interface AlisBatchRequest () {
    dispatch_semaphore_t _lock;
    NSUInteger _finishedCount;
    BOOL _failed;
}
@property (nonatomic, copy) AlisBatchRSucessBlock batchSuccessBlock;
@property (nonatomic, copy) AlisBatchRFailBlock batchFailureBlock;
@property (nonatomic, copy) AlisBatchRFinishedBlock batchFinishedBlock;

@end

@implementation AlisBatchRequest

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _failed = NO;
    _finishedCount = 0;
    _lock = dispatch_semaphore_create(1);
    
    _requestArray = [NSMutableArray array];
    _responseArray = [NSMutableArray array];
    return self;
}

- (instancetype)initWithBlocks:(AlisBatchRSucessBlock)success
                       failure:(AlisBatchRFailBlock)failure
                        finish:(AlisBatchRFinishedBlock)finish{
    self = [super init];
    if (self) {
        _failed = NO;
        _finishedCount = 0;
        _lock = dispatch_semaphore_create(1);
        
        _requestArray = [NSMutableArray array];
        _responseArray = [NSMutableArray array];
        
        _batchSuccessBlock = success? success:nil;
        _batchFailureBlock = failure? failure:nil;
        _batchFinishedBlock = finish? finish :nil; 
    }
    return self;
}

- (BOOL)onFinishedRequest:(AlisRequest *)request response:(id)responseObject error:(NSError *)error {
    BOOL isFinished = NO;
    NSUInteger index = [_requestArray indexOfObject:request];
    if (responseObject) {
        [_responseArray replaceObjectAtIndex:index withObject:responseObject];
    } else {
        _failed = YES;
        if (error) {
            [_responseArray replaceObjectAtIndex:index withObject:error];
        }
    }
    
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        if (!_failed) {
            ALIS_SAFE_BLOCK(_batchSuccessBlock, _responseArray);
            ALIS_SAFE_BLOCK(_batchFinishedBlock, _responseArray, nil);
        } else {
            ALIS_SAFE_BLOCK(_batchFailureBlock, _responseArray);
            ALIS_SAFE_BLOCK(_batchFinishedBlock, _responseArray, nil);
        }
        [self cleanCallbackBlocks];
        isFinished = YES;
    }
    return YES;
}

- (void)cleanCallbackBlocks {
    _batchSuccessBlock = nil;
    _batchFailureBlock = nil;
    _batchFinishedBlock = nil;
}

@end


