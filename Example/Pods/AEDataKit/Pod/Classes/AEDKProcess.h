//
//  AEDKProcess.h
//  AEDataKit
//
//  Created by Altair on 10/07/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEDKServiceConfiguration.h"

typedef enum {
    AEDKProcessStateReady,
    AEDKProcessStateProcessing,
    AEDKProcessStateSuspended,
    AEDKProcessStateCanceling,
    AEDKProcessStateCompleted
}AEDKProcessState;


NS_ASSUME_NONNULL_BEGIN

@interface AEDKProcess : NSOperation

@property (nonatomic, copy, readonly) NSURLRequest *request;

@property (nonatomic, copy) AEDKServiceConfiguration *configuration;

@property (nonatomic, readonly) AEDKProcessState state;

@property (nonatomic, weak) NSOperationQueue *processQueue;

- (instancetype)initWithRequest:(NSURLRequest *)reqeust configuration:(AEDKServiceConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
