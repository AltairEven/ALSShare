//
//  AlisJsonParseProtocol.h
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//

#import <Foundation/Foundation.h>
#import "AlisJsonParserProtocol.h"
/**
 JSON解析协议
 */
@protocol AlisJsonParsePluginProtocol <NSObject>

/**
 解析JSON格式数据，返回模型数据
 @param baseJsonParser 解析JSON第一层的解析类
 @param jsonData  原始JSON数据
 @return 解析后的Model数据
 */
- (id)parseJsonValue:(id<AlisJsonParserProtocol>)baseJsonParser parseClass:(Class)parseClass  jsonData:(NSDictionary *)jsonData;

- (id)parseJsonValue:(Class)parseClass  jsonData:(NSDictionary *)jsonData;

@end
