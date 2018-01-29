//
//  AELDOperationMode.m
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDOperationMode.h"

@implementation AELDOperationMode

- (instancetype)init {
    return nil;
}

- (instancetype)initWithName:(NSString *)name operationType:(AELDOperationType)type {
    if (![name isKindOfClass:[NSString class]] || [name length] == 0) {
        return nil;
    }
    if (type != AELDOperationTypeRead && type != AELDOperationTypeWrite && type != AELDOperationTypeDelete && type != AELDOperationTypeClear) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _name = [name copy];
        _synchronization = AELDOperationSynchronized;
        _operationType = type;
    }
    return self;
}

+ (instancetype)modeWithName:(NSString *)name operationType:(AELDOperationType)type {
    AELDOperationMode *mode = [[AELDOperationMode alloc] initWithName:name operationType:type];
    return mode;
}

@end
