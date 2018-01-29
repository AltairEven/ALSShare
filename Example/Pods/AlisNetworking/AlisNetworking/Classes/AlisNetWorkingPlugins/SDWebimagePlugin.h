//
//  SDWebimagePlugin.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#if __has_include(<SDWebImage/SDWebImageManager.h>)
#define ALS_HAS_SDWebImage
#endif

#ifdef ALS_HAS_SDWebImage
#import <Foundation/Foundation.h>
#import "AlisPluginProtocol.h"
#import <SDWebImage/SDWebImageManager.h>

@interface SDWebimagePlugin : NSObject<AlisPluginProtocol>
@end

#endif

