//
//  service.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/4.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestProtocol.h"
#import "AlisServiceProxy.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ServiceAction) {
    Resume,
    Cancel,
    Suspend
};

typedef NS_ENUM(NSInteger, ServiceType) {
    HTTP,
    LocalData
};

/**
 定义了一种服务，在
 表示此时此刻 需要服务的名称，一个类中很可能有好几个不同值。使用“类名／服务名” 区别不同类中有相同的服务
 */
@class AlisHttpServiceItem;

@interface AlisService : NSObject<NSCopying>

/**
 产生一项服务

 @param globalService 全局服务名称
 @param serviceProxy 服务代理
 */
- (instancetype)initWith:(NSArray *)globalService 
                    serviceProxy:(AlisServiceProxy *)serviceProxy;

/**
 包含网络请求的信息
 */
@property(strong,nonatomic)AlisHttpServiceItem *HttpServiceItem;

/**
 服务的名称
 */
@property(copy,nonatomic)NSString *serviceName;

/**
 服务的类型，例如http等，后期改为枚举类型
 */
@property(assign,nonatomic)ServiceType serviceType;

/**
 服务的行为，例如resume开始，cancel取消,增加，删除等
 */
@property(assign,nonatomic)ServiceAction serviceAction;

/**
 服务的类
 */
@property(strong,nonatomic)id serviceAgent;//requestDelegate

/**
 服务返回后的解释类，HTTP中接口返回后的解释类
 */
//@property(copy,nonatomic,readonly)NSString *parseClass;// responseModel

/**
 服务返回后的基础解释类，HTTP中接口返回后的基础解释类
 */
@property(copy,nonatomic,readonly)NSString *baseParseClass;// responseModel

@end
