//
//  AELDPlugMode.h
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AELDOperationMode.h"


NS_ASSUME_NONNULL_BEGIN

@interface AELDPlugMode : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *name; //模式名称

@property (nonatomic, readonly) AELDOperationType supportOperationType; //数据操作类型

/**
 初始化数据插件模式的方法
 
 @param name 模式名称
 @param type 支持的操作类型
 @return 类实例
 */
- (instancetype)initWithName:(NSString *)name supportOperationType:(AELDOperationType)type;

/**
 便捷创建数据插件模式实例的方法
 
 @param name 模式名称
 @param type 支持的操作类型
 @return 类实例
 */
+ (instancetype)modeWithName:(NSString *)name supportOperationType:(AELDOperationType)type;

/**
 判断和另一个数据插件模式是否相同
 
 @param mode 另一个数据插件模式
 @return 是否相同
 */
- (BOOL)isEqualToMode:(AELDPlugMode *)mode;

/**
 判断是否支持指定的数据操作模式
 
 @param mode 数据操作模式
 @return 是否支持
 */
- (BOOL)supportOperationMode:(AELDOperationMode *)mode;

/**
 判断是否支持指定的操作类型
 
 @param type 操作类型
 @return 是否支持
 */
- (BOOL)supportOperationType:(AELDOperationType)type;

@end


NS_ASSUME_NONNULL_END
