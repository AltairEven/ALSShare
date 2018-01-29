//
//  AELDResponse.h
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AELDOperationMode;

NS_ASSUME_NONNULL_BEGIN

/**
 数据操作的返回
 */
@interface AELDResponse : NSObject

@property (nonatomic, copy, readonly) AELDOperationMode *originalMode;  //原始数据操作模式

@property (nonatomic, strong, readonly) id __nullable responseData;  //数据操作结果，如果是wirte则为nil

@property (nonatomic, copy, readonly) NSDictionary *__nullable userInfo; //数据操作返回用户信息

@property (nonatomic, copy, readonly) NSError *__nullable error; //数据操作返回错误信息

/**
 初始化数据操作请求返回的方法
 
 @param originalMode 原始数据操作模式
 @param data 数据操作结果
 @param userInfo 数据操作返回用户信息
 @param error 数据操作返回错误信息
 @return 类实例
 */
- (instancetype)initWithOriginalMode:(AELDOperationMode *)originalMode responseData:(id __nullable)data userInfo:(NSDictionary *__nullable)userInfo error:(NSError *__nullable)error;

@end


NS_ASSUME_NONNULL_END
