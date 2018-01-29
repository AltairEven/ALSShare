//
//  AlisServiceProxy.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/21.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisServiceProxy.h"
#import <objc/runtime.h>
#import "AlisRequestManager.h"
#import "AlisService.h"
#import "NSString+help.h"
#import "AlisHttpServiceItem.h"
#import "AlisServicesManager.h"
#import "AlisJsonParseManager.h"
#import "AlisRequestConfig.h"
#import "AlisRequestContext.h"

#define ResumeResource @"resume"
#define CancelResource @"cancel"
#define SuspendResource @"suspend"

//  首先查找订阅的服务（网络接口）
//对资源的操作包括：
//   （1）对资源的操作。
//   （2）取消对资源的操作（资源目前的状态是操作过程中，例如：大文件的下载，上传）
//   （3）暂停对资源的操作
//APP中所有的请求服务都保存在该字典中

/**
 分解请求，并向AlisRequestManager发出请求

 @param _cmd 请求资源的方法名称 ，eg:resume_AskCitieslist_AlisViewController,来自AlisViewController类中，资源名为AskCitieslist，请求方式为resume
 */
void requestContainer(id self, SEL _cmd) {

    NSArray *serviceArray = [NSStringFromSelector(_cmd) componentsSeparatedByString:@"_"];
    if(serviceArray.count != 3){
        NSLog(@"注意：对资源的访问格式有问题");
        return;
    } 
    AlisService *currentService = [[AlisService alloc]initWith:serviceArray serviceProxy:(AlisServiceProxy *)self];
    NSString *globalServiceName = currentService.serviceName;
    //如果连续两次同样请求
    if (globalServiceName && currentService) {
        ((id<AlisRequestProtocol>)self).currentServeContainer[globalServiceName] = currentService;
    }
    
    [[AlisRequestManager sharedManager]startRequestModel:self service:currentService];
}


@interface AlisServiceProxy ()
@end

@implementation AlisServiceProxy

@synthesize currentServeContainer,businessLayer_requestFinishBlock,businessLayer_requestProgressBlock;

+ (AlisServiceProxy *)shareManager{
    static AlisServiceProxy *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AlisServiceProxy alloc]init];
        
    });
    return _manager;
}

- (void)fetchCandidateRequestServices{
    if (_candidateRequestServices != nil) return;
    _candidateRequestServices = [[AlisServicesManager sharedManager]allAlisServices];
}

- (instancetype)init{
    if (self = [super init]) {
        [self fetchCandidateRequestServices];
        self.serviceAgents = [NSMutableDictionary dictionary];
        __weak typeof (self) weakSelf = self;
        self.businessLayer_requestFinishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
            NSLog(@"在业务层完成了请求成功的回调");
            if (error) {
                NSLog(@"失败了:原因->");
                [weakSelf handlerServiceResponse:request serviceName:request.serviceName error:error];
            }
            else{
                if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:response:)]) {
                    [weakSelf parseJSONData:request response:response];
                }
            }
        };
        
        self.businessLayer_requestProgressBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
            float progress = (float)(receivedSize)/expectedSize;
            NSLog(@"下载／上传进度---->%f",progress);
            if ([request.context.makeRequestClass respondsToSelector:@selector(handlerServiceResponse:serviceName:progress:)]) {
                [request.context.makeRequestClass handlerServiceResponse:request serviceName:[request.serviceName toLocalServiceName] progress:progress];
            }
        };
        
        self.currentServeContainer = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *selString = NSStringFromSelector(sel);
    NSString *resourceAction = [selString resourceAction];//对资源的操作
    if (resourceAction ) {
        NSArray *resourceActions = @[ResumeResource,CancelResource,SuspendResource];
        if ([resourceActions containsObject:resourceAction]) {
            class_addMethod([self class], sel, (IMP)requestContainer, "@:");
            return YES;
        }
        else{
            return NO;//[super resolveInstanceMethod:sel];
        }
    }
   
    return NO;//[super resolveInstanceMethod:sel];
}

- (void)injectService:(id<AlisRequestProtocol>)object{
    NSParameterAssert(object);
    NSAssert([object conformsToProtocol:@protocol(AlisRequestProtocol)], @"'object' 需要服从协议");
    
    NSString *classString = NSStringFromClass([object class]);
    _serviceAgents[classString] = object;
}

- (id)beforeRequest:(id)data{
    return nil;
}

- (id)afterRequest:(id)data{
    return nil;
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName response:(id)response{
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName progress:(float)progress{
}

- (void)handlerServiceResponse:(AlisRequest *)request serviceName:(NSString *)serviceName error:(AlisError *)error{
}

#pragma mark -- request parameters
- (NSDictionary *)requestHead:(NSString *)serviceName{
    return nil;
}

- (NSData *)uploadData:(NSString *)serviceName{
    return nil;
}

- (NSDictionary *)additionalInfo:(NSString *)serviceName{
    return nil;
}

- (NSString *)fileURL:(NSString *)serviceName{
    return nil;
}

- (NSDictionary *)requestParams:(NSString *)serviceName{
    return nil;
}

- (NSString *)api:(NSString *)serviceName{
    NSString *api = [self getParam:@"api" serviceName:serviceName];
    if (api){
        return api;
    }
    return nil;
}

- (NSString *)server:(NSString *)serviceName{
    NSString *server = [self getParam:@"server" serviceName:serviceName];
    if (server){
        return server;
    }
    return nil;
}

- (NSString *)parseClass:(NSString *)serviceName{
    NSString *parseClass = [self getParam:@"parseClass" serviceName:serviceName];
    if (parseClass){
        return parseClass;
    }
    return nil;
}

- (AlisRequestType)requestType:(NSString *)serviceName{
    return AlisRequestNormal;
}

- (AlisHTTPMethodType)httpMethod:(NSString *)serviceName{
    NSString *httpMothod = [self getParam:@"httpMethod" serviceName:serviceName];
    if (httpMothod) 
        return AlisHTTPMethodGET;
    
    return AlisHTTPMethodGET;
}

#pragma mark -- help --

/**
 JSON--->Model 解析
 考虑json格式错误
 */
- (void)parseJSONData:(AlisRequest *)request response:(AlisResponse *)response{
    
    id<AlisRequestProtocol> requestObject = request.context.makeRequestClass;
    if (requestObject == nil) {
        NSLog(@"发出该资源请求的类不存在");
        return;
    }
    AlisJsonParseManager *manager = [AlisJsonParseManager sharedManager];
    //todo，根据不同返回的格式适配
//    id parsedData = [manager parseJsonValue:requestObject parseClass:NSClassFromString(request.parseClass) plunginKey:@"EXTensionParse" jsonData:response.responseInfo];
    
    id parsedData2 = [manager parseJsonValue:NSClassFromString(request.parseClass) plunginKey:@"EXTensionParse" jsonData:response.responseInfo];
    
    [requestObject handlerServiceResponse:request serviceName:[request.serviceName toLocalServiceName] response:parsedData2];
}


/**
 从plist文件中读取资源的相关信息

 @param resourceSubkey 资源子信息的名称 
 @param globalServiceName 资源全局名称
 @return 资源子信息的数据，例如 server，api等值
 */
- (NSString *)getParam:(NSString *)resourceSubkey serviceName:(NSString *)globalServiceName{
    NSParameterAssert(resourceSubkey && globalServiceName);
    
    NSArray *sep = [globalServiceName componentsSeparatedByString:@"_"];
    
    if (sep.count < 2 || sep == nil) {
        NSLog(@"service.serviceName 有问题");
        return nil;
    }
    
    NSString *resourceName = sep[1];
    
    NSDictionary *agentServiceActionKeys = _candidateRequestServices[resourceName];
    NSString *value = agentServiceActionKeys[resourceSubkey];
    return value;
    
}

@end

