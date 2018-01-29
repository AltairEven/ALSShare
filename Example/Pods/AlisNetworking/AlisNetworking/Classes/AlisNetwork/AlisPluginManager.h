//
//  AlisPluginManager.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/26.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import "AlisPluginProtocol.h"
#import <Foundation/Foundation.h>

@interface AlisPluginManager : NSObject

+ (AlisPluginManager *)manager;

- (void)registerPlugin:(id<AlisPluginProtocol>)plugin key:(NSString *)key;

- (void)registerPlugins:(NSDictionary *)pluginsDic;

- (void)removePlugin:(NSString *)key;

- (void)registerALLPlugins;

- (NSArray *)allPlugins;

//获取key对应的插件
- (id<AlisPluginProtocol>)plugin:(NSString *)key;

@end
