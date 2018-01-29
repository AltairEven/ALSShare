//
//  AFNetworkingPlugin.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/24.
//  Copyright © 2017年 alisports. All rights reserved.
//
#if __has_include(<AFNetworking/AFNetworking.h>)
    #define ALS_HAS_AFNetworking
#endif

#ifdef ALS_HAS_AFNetworking
#import <AFNetworking/AFNetworking.h>
#import "AlisPluginProtocol.h"
#import <Foundation/Foundation.h>

@interface AFNetworkingPlugin : NSObject<AlisPluginProtocol>

@end

#endif
