//
//  ALSSharePlugInitializationInfo.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSSharePlugInitializationInfo.h"

@implementation ALSSharePlugInitializationInfo

- (instancetype)initWithSharePlatform:(ALSSharePlatform)platform appKey:(NSString *)key appSecret:(NSString *)secret urlScheme:(NSString *)scheme andRedirectUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.platform = platform;
        self.appKey = key;
        self.appSecret = secret;
        self.urlScheme = scheme;
        self.redirectUrl = url;
    }
    return self;
}

+ (instancetype)infoWithSharePlatform:(ALSSharePlatform)platform appKey:(NSString *)key appSecret:(NSString *)secret urlScheme:(NSString *)scheme andRedirectUrl:(NSString *)url {
    return [[ALSSharePlugInitializationInfo alloc] initWithSharePlatform:platform appKey:key appSecret:secret urlScheme:scheme andRedirectUrl:url];
}


#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    ALSSharePlugInitializationInfo *info = [[ALSSharePlugInitializationInfo allocWithZone:zone] initWithSharePlatform:self.platform appKey:self.appKey appSecret:self.appSecret urlScheme:self.urlScheme andRedirectUrl:self.redirectUrl];
    return info;
}

@end
