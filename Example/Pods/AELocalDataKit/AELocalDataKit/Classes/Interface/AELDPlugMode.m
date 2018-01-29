//
//  AELDPlugMode.m
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDPlugMode.h"

@implementation AELDPlugMode

- (instancetype)init {
    return nil;
}

- (instancetype)initWithName:(NSString *)name supportOperationType:(AELDOperationType)type {
    if (![name isKindOfClass:[NSString class]] || [name length] == 0) {
        return nil;
    }
    self = [super init];
    if (self) {
        _name = name;
        _supportOperationType = type;
    }
    return self;
}

+ (instancetype)modeWithName:(NSString *)name supportOperationType:(AELDOperationType)type {
    AELDPlugMode *mode = [[AELDPlugMode alloc] initWithName:name supportOperationType:type];
    return mode;
}

- (BOOL)isEqualToMode:(AELDPlugMode *)mode {
    if (![mode isKindOfClass:[AELDPlugMode class]]) {
        return NO;
    }
    return ([self.name isEqualToString:mode.name] &&
            self.supportOperationType == mode.supportOperationType);
}

- (BOOL)supportOperationMode:(AELDOperationMode *)mode {
    return ([self.name isEqualToString:mode.name] && [self supportOperationType:mode.operationType]);
}

- (BOOL)supportOperationType:(AELDOperationType)type {
    NSUInteger support = self.supportOperationType & type;
    return support == type;
}

#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    AELDPlugMode *mode = [[AELDPlugMode allocWithZone:zone] initWithName:self.name supportOperationType:self.supportOperationType];
    return mode;
}

@end
