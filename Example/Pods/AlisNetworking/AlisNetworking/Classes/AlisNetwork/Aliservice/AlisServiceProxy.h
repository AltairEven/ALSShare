//
//  AlisServiceProxy.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/21.
//  Copyright © 2017年 alisports. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "AlisRequestProtocol.h"
#import <Foundation/Foundation.h>


/**
 完整的对资源的操作，包括 资源的操作者，资源名，操作资源的方式
 资源访问格式: eg-->resume_AskCitiesInfo_AlisVierwController
 @param yy 资源名称
 */
#define resumeService(yy) {[[AlisServiceProxy shareManager] performSelector:NSSelectorFromString([@"resume_"  stringByAppendingFormat:@"%@_%@", yy,NSStringFromClass([self class])])];}

#define cancelService(yy) {[[AlisServiceProxy shareManager] performSelector:NSSelectorFromString([@"cancel_"  stringByAppendingFormat:@"%@_%@", yy,NSStringFromClass([self class])])];}

#define suspendService(yy) {[[AlisServiceProxy shareManager] performSelector:NSSelectorFromString([@"suspend_"  stringByAppendingFormat:@"%@_%@", yy,NSStringFromClass([self class])])];}

#define ServiceEqual(yy,xx) ([yy isEqualToString:xx])

// VC 的service层
// 用户层指明自己遵守的协议<AlisRequestProtocol>，之后请求所需要的数据，参数都在用户层这里查找
// 网络请求成功的结果返回裸数据，用户层根据业务的不同做相应的处理
// 发出资源请求的很有可能不是VCService或其子类，有可能是其他OC对象转发给VCService的，这个需要注意
// 支持消息转发和消息继承
@protocol VCServiceProtocol <NSObject>

/**
 对对象注册服务
 @param object object description
 */
- (void)injectService:(id<AlisRequestProtocol>)object;

@end

@interface AlisServiceProxy : NSObject<AlisRequestProtocol,VCServiceProtocol>

+ (AlisServiceProxy *)shareManager;

/**
 委托服务类的集合
 */
@property(strong,nonatomic)NSMutableDictionary *serviceAgents;

/**
 可以提供服务项目的集合
 */
@property(strong,nonatomic)NSDictionary *candidateRequestServices;

@end

