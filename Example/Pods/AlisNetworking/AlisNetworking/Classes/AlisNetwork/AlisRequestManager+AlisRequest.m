//
//  AlisRequestManager+AlisRequest.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

/**
 按照传过来的参数，组装AlisRequest

 @param AlisRequest 
 @return 
 
 */
#import "AlisService.h"
#import "AlisRequestManager+AlisRequest.h"
#import "NSString+help.h"
#import "AlisHttpServiceItem.h"
#import "AlisRequestConfig.h"
#import "AlisRequestContext.h"

@implementation AlisRequestManager (AlisRequest)

- (AlisRequest *)adapteAlisRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(AlisService *)service{
    //设置请求的上下文
    request.context.makeRequestClass = service.serviceAgent;
    request.context.serviceName = service.serviceName;
    NSString *localServiceName = [request.context.serviceName toLocalServiceName];
    // NSAssert([requestModel respondsToSelector:@selector(api)], @"request API should not nil");
    /*****************
     **********设置请求类型（上传／下载等）**************************/
    if ([service.serviceAgent respondsToSelector:@selector(requestType:)]) {
        request.requestType = [service.serviceAgent requestType:localServiceName];
    }
    
    if (request.requestType == AlisRequestUnknow) {
        if ([requestModel respondsToSelector:@selector(requestType:)]) {
            request.requestType = [requestModel requestType:request.context.serviceName];
        }else{
            NSLog(@"'requestType' 没有设置，默认在AlisRequest中设置");
        }
    }
    
    /***************************为上传，下载配置下载存储／上传源地址，数据）**************************/
    if (request.requestType == AlisRequestDownload) {
        if ([service.serviceAgent respondsToSelector:@selector(fileURL:)]) {
            request.downloadPath = [service.serviceAgent fileURL:localServiceName];
        }else if ([requestModel respondsToSelector:@selector(fileURL:)]) {
            request.downloadPath = [requestModel fileURL:request.context.serviceName];
        }
        if(request.downloadPath == nil){
            NSLog(@"下载任务，没有设置下载的路径!!!");
        }
    }
    else if (request.requestType == AlisRequestUpload) {
        if ([service.serviceAgent respondsToSelector:@selector(fileURL:)]) {
            [request addFormDataWithName:@"test1" fileURL:[service.serviceAgent fileURL:localServiceName]];
        }
        
        if ([service.serviceAgent respondsToSelector:@selector(uploadData:)]) {
            if ([service.serviceAgent uploadData:localServiceName] != nil) {
                [request addFormDataWithName:@"test2" fileData:[service.serviceAgent uploadData:localServiceName]];
            }
        }
        
        if(request.uploadFormDatas.count == 0){
            NSLog(@"上传任务，上传的内容为空!!!");
        }
    }
    
    /***************************设置请求http方法：get/post etc）**************************/
    if ([service.serviceAgent respondsToSelector:@selector(httpMethod:)]) {
        request.httpMethod = [service.serviceAgent httpMethod:localServiceName];
    }
    
    if(request.httpMethod == AlisHTTPMethodUnknow){
        if ([requestModel respondsToSelector:@selector(httpMethod:)]) {
            request.httpMethod = [requestModel httpMethod:request.context.serviceName];
        }else{
            NSLog(@"'httpMethod' 没有设置，默认在AlisRequest中设置");
        }
    }
    
    /*************************接口返回JSON数据的解析类************************/
    if ([service.serviceAgent respondsToSelector:@selector(parseClass:)]) {
        request.parseClass = [service.serviceAgent parseClass:localServiceName];
    }
    
    if (request.parseClass == nil) {
        if (service.HttpServiceItem.parseClass) {
            request.parseClass = service.HttpServiceItem.parseClass;
        }else{
            NSLog(@"'parseClass' 没有设置，这个需要手动设置");
        }
    }
    /***************************设置请求URL**************************/
    /************************由域名和相对路径组成**********************/
    if ([service.serviceAgent respondsToSelector:@selector(api:)]) {
        request.api = [service.serviceAgent api:localServiceName];
    }
    
    if (request.api == nil) {
        if (service.HttpServiceItem.api) {
            request.api = service.HttpServiceItem.api;
        }else{
            NSLog(@"'api' 没有设置，这个必须手动设置");
        }
    }
    /***************************设置请求域名 **************************/
    if ([service.serviceAgent respondsToSelector:@selector(server:)]) {
        request.server = [service.serviceAgent server:localServiceName];
    }
        
    if (request.server == nil) {
        if (service.HttpServiceItem.server) {
            request.server = service.HttpServiceItem.server;
        }
        
        if ( request.server == nil && request.useGeneralServer == YES){
            request.server = self.config.generalServer;
        }
        
        if ( request.server == nil){
            NSLog(@"'server' 没有设置，这个要设置");
        }
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@",request.server,request.api];
    NSAssert(urlString, @"url should not nil");
    request.url = urlString;//[requestModel url];
    
    /***************************设置请求头**************************/
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    if ([service.serviceAgent respondsToSelector:@selector(requestHead:)]) {
        if ([service.serviceAgent requestHead:localServiceName]) {
            [header addEntriesFromDictionary:[service.serviceAgent requestHead:localServiceName]];
        }
    }
    if ([requestModel respondsToSelector:@selector(requestHead:)]) {
        if ([requestModel requestHead:localServiceName]){ 
            [header addEntriesFromDictionary:[requestModel requestHead:request.context.serviceName]];
        }
    }
    if (request.useGeneralHeaders) {
        if (self.config.generalHeader) {
            [header addEntriesFromDictionary:self.config.generalHeader];
        }
    }
    if (header == nil || header.count == 0){
        NSLog(@"'head' 一无所有");
    }
    request.header = header;
    
    /***************************设置请求参数**************************/
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([service.serviceAgent respondsToSelector:@selector(requestParams:)]) {
        NSDictionary *params = [service.serviceAgent requestParams:localServiceName];
        if(params){
            [parameters addEntriesFromDictionary:params];
        }
    }
    if ([requestModel respondsToSelector:@selector(requestParams:)]) {
        NSDictionary *params = [requestModel requestParams:request.context.serviceName];
        if(params){
            [parameters addEntriesFromDictionary:params];
        }
    }
    if (request.useGeneralParameters) {
        NSDictionary *params = self.config.generalParamters;
        if(params){
            [parameters addEntriesFromDictionary:params];
        }
    }
    
    if (request.preParameters ) {
         [parameters addEntriesFromDictionary:request.preParameters];
    }
    if (parameters == nil || parameters.count == 0) {
        NSLog(@"'请求参数' 一无所有");
    }
    request.parameters = parameters;
    /***************************设置请求的回调**************************/
    request.finishBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error){
        if(self.config.enableSync){
            dispatch_semaphore_signal(self.semaphore);
        }
        //各个业务层的回调
        if (error) {
            [self failureWithError:error withRequest:request];
        }
        else{
            [self successWithResponse:response withRequest:request];
        }
    };
    
    __weak typeof (request) weakRequest = request;
    request.progressBlock = ^(AlisRequest *request,long long receivedSize, long long expectedSize){
        //各个业务层的回调
        weakRequest.bindRequestModel.businessLayer_requestProgressBlock(request,receivedSize,expectedSize);
    };
    
    return request;
}
@end
