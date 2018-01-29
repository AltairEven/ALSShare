//
//  AlisJsonBaseItem.h
//  Pods
//
//  Created by alisports on 2017/4/7.
//
// 抛给业务方

#import <Foundation/Foundation.h>

@interface AlisJsonBaseItem : NSObject

@property(assign,nonatomic)NSInteger res_code;
@property(strong,nonatomic)NSString  *res_msg;
@property(strong,nonatomic)id        data;

@end
