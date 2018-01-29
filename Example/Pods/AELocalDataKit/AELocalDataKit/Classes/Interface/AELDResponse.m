//
//  AELDResponse.m
//  AELocalDataKit
//
//  Created by Altair on 21/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDResponse.h"
#import "AELDOperationMode.h"

@implementation AELDResponse

- (instancetype)initWithOriginalMode:(AELDOperationMode *)originalMode responseData:(id _Nullable)data userInfo:(NSDictionary * _Nullable)userInfo error:(NSError * _Nullable)error {
    if (![originalMode isKindOfClass:[AELDOperationMode class]]) {
        return nil;
    }
    self = [self init];
    if (self) {
        _originalMode = originalMode;
        _responseData = data;
        _userInfo = userInfo;
        _error = error;
    }
    return self;
}

@end
