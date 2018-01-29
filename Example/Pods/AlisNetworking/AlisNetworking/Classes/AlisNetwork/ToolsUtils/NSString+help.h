//
//  NSString+help.h
//  Pods
//
//  Created by alisports on 2017/4/5.
//
//

#import <Foundation/Foundation.h>

@interface NSString (help)


/**
 全局变量变为局部变量
 @return 局部变量
 */
- (NSString *)toLocalServiceName;
/**
 获取对资源的动作（增删改查），eg：resume_uploadData return->resume
 @return 对资源的操作
 */
- (NSString *)resourceAction;

- (NSString *)md5WithString;

@end
