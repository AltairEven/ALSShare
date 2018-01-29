//
//  AlisJsonModel.h
//  Pods
//
//  Created by alisports on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "AlisJsonParserProtocol.h"

/**
 我们自定义的JsonModel
 */
@interface AlisJsonModel : NSObject<AlisJsonParserProtocol>

//@property(strong,nonatomic)nserror   *error;
@property(assign,nonatomic)NSInteger resCode;
@property(strong,nonatomic)NSString  *resMsg;
@property(strong,nonatomic)id        data;

- (void)initWithDictionary:(NSDictionary *)dic;
@end
