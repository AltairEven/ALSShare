//
//  ALSShareService.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSShareService.h"
#import "ALSShareSocket.h"

@implementation ALSShareService

+ (instancetype)globalService {
    static ALSShareService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[ALSShareService alloc] init];
    });
    return service;
}

- (void)activateBuiltInPlugs:(ALSBuiltInSharePlugStrategy)strategy withInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void (^)(NSDictionary<NSNumber *,NSNumber *> *))result {
    [[ALSShareSocket publicSocket] plugInBuiltInPlugs:strategy];
    [[ALSShareSocket publicSocket] getAllPlugsOnlineWithInitializationDelegate:delegate response:result];
}

- (BOOL)getShareServiceOnlineWithPlatform:(ALSSharePlatform)platform initializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate {
    return [[ALSShareSocket publicSocket] getOnlineForPlugWithPlatform:platform withInitializationDelegate:delegate];
}

- (void)getAllShareServicesOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate response:(void(^)(NSDictionary<NSNumber *, NSNumber *> *resultInfo))result {
    [[ALSShareSocket publicSocket] getAllPlugsOnlineWithInitializationDelegate:delegate response:result];
}

- (BOOL)startShare:(ALSShareContext *)context withResponse:(void(^)(ALSShareResponse *resp))response {
    _sharingContext = context;
    //获取已插入的插件
    id<ALSSharePlugProtocol> plug = [[ALSShareSocket publicSocket] plugWithPlatform:context.platform];
    if (plug && [plug isOnLine]) {
        //如果插件存在，并且已启动，则开始使用插件的分享方法
        return [plug startShare:context withResponse:^(ALSShareResponse *resp) {
            _sharingContext = nil;
            if (response) {
                response(resp);
            }
        }];
    }
    _sharingContext = nil;
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    id<ALSSharePlugProtocol> plug = [[ALSShareSocket publicSocket] plugWithPlatform:_sharingContext.platform];
    if (!plug || ![plug isOnLine]) {
        return NO;
    }
    return [plug application:app openURL:url options:options];
}

@end
