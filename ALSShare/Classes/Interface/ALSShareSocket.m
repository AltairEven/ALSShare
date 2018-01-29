//
//  ALSShareSocket.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSShareSocket.h"

@implementation ALSShareSocket

+ (instancetype)publicSocket {
    static ALSShareSocket *sharedSocket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSocket = [[ALSShareSocket alloc] init];
    });
    return sharedSocket;
}

- (void)plugInBuiltInPlugs:(ALSBuiltInSharePlugStrategy)strategy {
    _plugStrategy = strategy;
    
    if ((strategy & ALSBuiltInSharePlugStrategyWechat) == ALSBuiltInSharePlugStrategyWechat) {
        Class wechatPlugClass = NSClassFromString(@"ALSWeChatSharePlug");
        if (wechatPlugClass) {
            [self plugIn:[[wechatPlugClass alloc] init]];
        }
    }
    if ((strategy & ALSBuiltInSharePlugStrategyWeibo) == ALSBuiltInSharePlugStrategyWeibo) {
        Class weiboPlugClass = NSClassFromString(@"ALSWeiboSharePlug");
        if (weiboPlugClass) {
            [self plugIn:[[weiboPlugClass alloc] init]];
        }
    }
    if ((strategy & ALSBuiltInSharePlugStrategyTencent) == ALSBuiltInSharePlugStrategyTencent) {
        Class tencentPlugClass = NSClassFromString(@"ALSTencentSharePlug");
        if (tencentPlugClass) {
            [self plugIn:[[tencentPlugClass alloc] init]];
        }
    }
}

- (void)plugIn:(id<ALSSharePlugProtocol>)plug {
    if (!plug || ![plug conformsToProtocol:@protocol(ALSSharePlugProtocol)]) {
        return;
    }
    //由于可能会遇到插件自身属性的修改，所以先拔出已插入的相同登陆模式的插件
    [self plugOutWithPlatform:[plug platform]];
    //将插件插入插座
    NSMutableSet *plugs = [self.plugsInSocket mutableCopy];
    if (!plugs) {
        plugs = [[NSMutableSet alloc] init];
    }
    [plugs addObject:plug];
    _plugsInSocket = [plugs copy];
}

- (void)plugOutWithPlatform:(ALSSharePlatform)platform {
    //获取指定登陆模式的已插入插件
    id<ALSSharePlugProtocol> plug = [self plugWithPlatform:platform];
    if (plug) {
        //如果存在，则将其从插座中拔出
        NSMutableSet *plugs = [self.plugsInSocket mutableCopy];
        [plugs removeObject:plug];
        _plugsInSocket = [plugs copy];
    }
}

- (id<ALSSharePlugProtocol>)plugWithPlatform:(ALSSharePlatform)platform {
    __block id<ALSSharePlugProtocol> plug = nil;
    //遍历插座上已插入的插件
    [self.plugsInSocket enumerateObjectsUsingBlock:^(id<ALSSharePlugProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj platform] == platform) {
            //如果插件的登陆模式和比对的登陆模式相同，则获取该插件，并停止遍历
            plug = obj;
            *stop = YES;
        }
    }];
    return plug;
}

- (BOOL)getOnlineForPlugWithPlatform:(ALSSharePlatform)platform withInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate {
    //获取指定登陆模式的已插入插件
    id<ALSSharePlugProtocol> plug = [self plugWithPlatform:platform];
    if (plug && [plug respondsToSelector:@selector(getOnlineWithInitializationDelegate:)]) {
        //如果插件存在并且实现了启动方法，则将插件启动
        return [plug getOnlineWithInitializationDelegate:delegate];
    }
    return NO;
}

- (void)getAllPlugsOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void (^)(NSDictionary<NSNumber *,NSNumber *> *))result {
    NSMutableDictionary *resultInfo = [[NSMutableDictionary alloc] init];
    //遍历插座上已插入的插件
    [self.plugsInSocket enumerateObjectsUsingBlock:^(id<ALSSharePlugProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        ALSSharePlatform plugPlatform = [obj platform];
        BOOL res = NO;
        if ([obj respondsToSelector:@selector(getOnlineWithInitializationDelegate:)]) {
            //如果插件实现了启动方法，则将插件启动，并记录
            res = [obj getOnlineWithInitializationDelegate:delegate];
        } else {
            //如果插件没有实现启动方法，则记录启动状态
            res = [obj isOnLine];
        }
        [resultInfo setObject:[NSNumber numberWithBool:res] forKey:[NSNumber numberWithInteger:plugPlatform]];
    }];
    if (result) {
        result([resultInfo copy]);
    }
}

- (id<ALSSharePlugProtocol>)respondingPlugForApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    __block id<ALSSharePlugProtocol> plug = nil;
    //遍历插座上已插入的插件
    [self.plugsInSocket enumerateObjectsUsingBlock:^(id<ALSSharePlugProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(respondsToOpenUrl:)]) {
            //如果插件可以处理该url，则获取该插件，并停止遍历
            if ([obj respondsToOpenUrl:url]) {
                plug = obj;
                *stop = YES;
            }
        }
    }];
    return plug;
}

@end
