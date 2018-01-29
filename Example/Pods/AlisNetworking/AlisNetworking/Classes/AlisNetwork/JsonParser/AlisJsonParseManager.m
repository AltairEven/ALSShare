//
//  AlisJsonParseManager.m
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//
#import "AlisJsonParseManager.h"

@interface AlisJsonParseManager()
//real plugin
@property(strong,nonatomic)NSMutableDictionary *pluginsDictionary;

@end

@implementation AlisJsonParseManager

+ (AlisJsonParseManager *)sharedManager{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

- (instancetype)init{
    if (self = [super init]) {
        self.pluginsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark -- plugin
- (void)registerPlugin:(id<AlisJsonParsePluginProtocol>)plugin key:(NSString *)key
{
}

- (void)removePlugin:(NSString *)key{
    NSParameterAssert(key);
    //[self.pluginsDictionary removeObjectForKey:pluginList];
}

//- (void)registerALLPlugins{
//}

- (id<AlisJsonParsePluginProtocol>)plugin:(NSString *)key{
    NSAssert(key, @"key should not nil");
    NSAssert(self.pluginsDictionary  || self.pluginsDictionary.count > 0, @"pluginsDictionary has problems");
    //这里应该判断是否有重复的key
    NSArray *keys = self.pluginsDictionary.allKeys;
    
    if ([keys containsObject:key]) {
        if (self.pluginsDictionary[key]) {
            return self.pluginsDictionary[key];
        }
    }
    else{
        Class class = NSClassFromString(key);
        id _object = [[class alloc]init];
        
        NSAssert([_object conformsToProtocol:@protocol(AlisJsonParsePluginProtocol)], @"the plugin do not conform 'AlisJsonParsePluginProtocol'");
        [self.pluginsDictionary setObject:_object forKey:key];
        
        return _object;
    }
    
    return nil;
}

- (id)parseJsonValue:(id<AlisJsonParserProtocol>)baseJsonParser parseClass:(Class)parseClass plunginKey:(NSString *)key jsonData:(NSDictionary *)jsonData{
    id<AlisJsonParsePluginProtocol> plugin = [self plugin:@"EXTensionParse"];
    id parsedData = [plugin parseJsonValue:baseJsonParser parseClass:parseClass jsonData:jsonData ];
    return parsedData;
}

- (id)parseJsonValue:(Class)parseClass plunginKey:(NSString *)key jsonData:(NSDictionary *)jsonData{
    id<AlisJsonParsePluginProtocol> plugin = [self plugin:@"EXTensionParse"];
    id parsedData = [plugin parseJsonValue:parseClass jsonData:jsonData ];
    return parsedData;
}


@end





