//
//  AlisJsonParseManager.h
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//
#import "AlisJsonParserProtocol.h"
#import "AlisJsonParsePluginProtocol.h"
#import <Foundation/Foundation.h>

@interface AlisJsonParseManager : NSObject

+ (AlisJsonParseManager *)sharedManager;

- (void)registerPlugin:(id<AlisJsonParsePluginProtocol>)plugin key:(NSString *)key;
- (id<AlisJsonParsePluginProtocol>)plugin:(NSString *)key;


/**
 解析接口JSON数据

 @param baseJsonParser 提供第一层JSON解析的类
 @param parseClass JSON有效数据的解析类
 @param key plugin的key
 @param jsonData 接口返回的JSON
 @return 解析完成的数据
 */
- (id)parseJsonValue:(id<AlisJsonParserProtocol>)baseJsonParser parseClass:(Class)parseClass plunginKey:(NSString *)key jsonData:(NSDictionary *)jsonData;

- (id)parseJsonValue:(Class)parseClass plunginKey:(NSString *)key jsonData:(NSDictionary *)jsonData;

@end
