//
//  service.m
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisHttpServiceItem.h"
#import "AlisService.h"

@implementation AlisService

- (instancetype)initWith:(NSArray *)globalService 
            serviceProxy:(AlisServiceProxy *)serviceProxy{
    if (self = [super init]) {
        
        NSString *serviceAction             = globalService[0];
        NSString *localServiceName          = globalService[1];
        NSString *currentServiceAgentString = globalService[2];
        
        AlisHttpServiceItem *alisHttpServiceItem = serviceProxy.candidateRequestServices[localServiceName];
        if (alisHttpServiceItem == nil) {
            NSLog(@"没有为该服务配置请求服务");
        }
        
        NSDictionary *cc = serviceProxy.serviceAgents;
        id currentServiceAgent = cc[currentServiceAgentString];
        if( currentServiceAgent == nil){
            NSLog(@"%@ 没有注册服务，请先调用 'injectService' 方法注册服务",currentServiceAgentString);
        }
        
        //之后的AlisRequest唯一绑定一个serviceName，表示请求为这个网络请求的service服务 
        //注意：globalServiceName 为该服务的唯一全局的识别码
        _serviceName = [NSString stringWithFormat:@"%@_%@",currentServiceAgentString,localServiceName];
        _serviceAction = [self convertServiceActionFromString:serviceAction];
        _HttpServiceItem = alisHttpServiceItem;
        _serviceAgent = currentServiceAgent;
        _serviceType = HTTP;

    }
    return self;

}

- (ServiceType)convertServiceTypeFromString:(NSString *)yy{
    if ([yy isEqualToString:@"http"] || [yy isEqualToString:@"https"]) {
        return HTTP;
    }
    return HTTP;
}

- (ServiceAction)convertServiceActionFromString:(NSString *)yy{
    if ([yy isEqualToString:@"resume"]) {
        return Resume;
    }else if ([yy isEqualToString:@"cancel"]) {
        return Cancel;
    }else if ([yy isEqualToString:@"suspend"]) {
        return Suspend;
    }
    
    return Resume;
}

- (instancetype)copyWithZone:(NSZone *)zone{
    AlisService *copy = [[[self class] allocWithZone:zone] init];
    copy.serviceName = self.serviceName;
    copy.serviceType = self.serviceType;
    copy.serviceAction = self.serviceAction;
    copy.serviceAgent = self.serviceAgent;
    return copy;
}


@end
