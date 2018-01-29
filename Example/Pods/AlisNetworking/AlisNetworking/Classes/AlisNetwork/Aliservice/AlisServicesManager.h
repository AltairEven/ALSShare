//
//  AlisServicesManager.h
//  Pods
//
//  Created by alisports on 2017/6/28.
//
//
@class AlisHttpServiceItem;

#import <Foundation/Foundation.h>

//服务的管理器
@interface AlisServicesManager : NSObject

+ (AlisServicesManager *)sharedManager;

- (void)registerService:(AlisHttpServiceItem *)serviceItem key:(NSString *)key;

- (void)registerServices:(NSDictionary *)services;

- (void)removeService:(NSString *)key;

- (NSDictionary *)allAlisServices;

//获取key对应的插件
- (AlisHttpServiceItem *)alisServiceForKey:(NSString *)key;
@end
