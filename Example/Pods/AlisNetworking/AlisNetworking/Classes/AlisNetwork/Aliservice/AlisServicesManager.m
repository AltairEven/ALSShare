//
//  AlisServicesManager.m
//  Pods
//
//  Created by alisports on 2017/6/28.
//
//

#import "AlisServicesManager.h"
#import "AlisHttpServiceItem.h"

@interface AlisServicesManager ()

@property(nonatomic,strong)NSMutableDictionary *services;

@end

@implementation AlisServicesManager

+ (AlisServicesManager *)sharedManager{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (NSMutableDictionary *)services{
    if (_services == nil) {
        _services = [NSMutableDictionary dictionary];
    }
    return _services;
}

- (void)registerService:(AlisHttpServiceItem *)serviceItem key:(NSString *)key{
    if (serviceItem == nil || key == nil) {
        return;
    }
    self.services[key] = serviceItem;
}

- (void)registerServices:(NSDictionary *)services{
    if (services == nil) return;
    [self.services addEntriesFromDictionary:services];
}


- (void)removeService:(NSString *)key{
    [self.services removeObjectForKey:key];
}

- (NSDictionary *)allAlisServices{
    return [_services copy];
}

//获取key对应的插件
- (NSDictionary *)alisServiceForKey:(NSString *)key{
    return _services[key];
}

@end
