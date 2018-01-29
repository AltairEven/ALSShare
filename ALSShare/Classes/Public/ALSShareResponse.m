//
//  ALSShareResponse.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSShareResponse.h"
#import "ALSShareTool.h"

@implementation ALSShareResponse

- (instancetype)initWithPlatform:(ALSSharePlatform)platform {
    if (![ALSShareTool validateSharePlatform:platform]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _platform = platform;
    }
    return self;
}

@end
