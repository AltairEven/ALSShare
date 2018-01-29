//
//  AlisJsonParserProtocol.h
//  Pods
//
//  Created by alisports on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
@class AlisJsonModel;
@protocol AlisJsonParserProtocol <NSObject>

@optional

- (NSString *)code;
- (NSString *)message;
- (id)parsedData;

- (void)adapterWithDic:(NSDictionary *)rawData withBaseParserClass:(Class)baseParserClass;

- (AlisJsonModel *)parserBaseJsonValue:(NSDictionary *)jsonData;

@end
