//
//  AEDKServiceConfiguration.m
//  AEDataKit
//
//  Created by Altair on 10/07/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AEDKServiceConfiguration.h"


NSString *const kAEDKServiceProtocolHttp = @"http";
NSString *const kAEDKServiceProtocolHttps = @"https";
NSString *const kAEDKServiceProtocolCache = @"cache";
//NSString *const kAEDKServiceProtocolClass = @"class";
NSString *const kAEDKServiceProtocolDataBase = @"db";


NSString *const kAEDKServiceCachePathMemory = @"kAEDKServiceCachePathMemory";
NSString *const kAEDKServiceCachePathDisk = @"kAEDKServiceCachePathDisk";
NSString *const kAEDKServiceCachePathMemoryAndDisk = @"kAEDKServiceCachePathMemoryAndDisk";

NSString *const kAEDKServiceDataBasePathSimple = @"kAEDKServiceDataBasePathSimple";
NSString *const kAEDKServiceDataBasePathSQL = @"kAEDKServiceDataBasePathSQL";

NSString *const kAEDKServiceMethodGet = @"GET";
NSString *const kAEDKServiceMethodPOST = @"POST";
NSString *const kAEDKServiceMethodHEAD = @"HEAD";
NSString *const kAEDKServiceMethodDELETE = @"DELETE";
NSString *const kAEDKServiceMethodPUT = @"PUT";
NSString *const kAEDKServiceMethodPATCH = @"PATCH";
NSString *const kAEDKServiceMethodOPTIONS = @"OPTIONS";
NSString *const kAEDKServiceMethodTRACE = @"TRACE";
NSString *const kAEDKServiceMethodCONNECT = @"CONNECT";
NSString *const kAEDKServiceMethodMOVE = @"MOVE";
NSString *const kAEDKServiceMethodCOPY = @"COPY";
NSString *const kAEDKServiceMethodLINK = @"LINK";
NSString *const kAEDKServiceMethodUNLINK = @"UNLINK";
NSString *const kAEDKServiceMethodWRAPPED = @"WRAPPED";


@implementation AEDKServiceConfiguration

+ (instancetype)defaultConfiguration {
    AEDKServiceConfiguration *config = [[AEDKServiceConfiguration alloc] init];
    config.displayDebugInfo = NO;
    config.method = kAEDKServiceMethodGet;
    
    return config;
}


#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    AEDKServiceConfiguration *config = [[AEDKServiceConfiguration allocWithZone:zone] init];
    config.displayDebugInfo = self.displayDebugInfo;
    config.specifiedServiceDelegate = self.specifiedServiceDelegate;
    config.method = self.method;
    config.requestParameter = self.requestParameter;
    config.isSynchronized = self.isSynchronized;
    config.requestBody = self.requestBody;
    config.BeforeProcess = self.BeforeProcess;
    config.Processing = self.Processing;
    config.AfterProcess = self.AfterProcess;
    config.ProcessCompleted = self.ProcessCompleted;
    
    return config;
}

@end

@implementation AEDKHttpServiceConfiguration

+ (instancetype)defaultConfiguration {
    AEDKHttpServiceConfiguration *config = [[AEDKHttpServiceConfiguration alloc] init];
    config.displayDebugInfo = NO;
    config.method = kAEDKServiceMethodGet;
    config.mimeType = AEDKHttpServiceMimeTypeText;
    [config setStringEncoding:NSUTF8StringEncoding];
    
    return config;
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    AEDKHttpServiceConfiguration *config = [[AEDKHttpServiceConfiguration allocWithZone:zone] init];
    config.displayDebugInfo = self.displayDebugInfo;
    config.specifiedServiceDelegate = self.specifiedServiceDelegate;
    config.method = self.method;
    config.isSynchronized = self.isSynchronized;
    config.requestBody = self.requestBody;
    config.BeforeProcess = self.BeforeProcess;
    config.Processing = self.Processing;
    config.AfterProcess = self.AfterProcess;
    config.ProcessCompleted = self.ProcessCompleted;
    config.stringEncoding = self.stringEncoding;
    config.mimeType = self.mimeType;
    config.requestParameter = self.requestParameter;
    config.infoAppendingAfterQueryString = [self.infoAppendingAfterQueryString copy];
    config.infoInHttpHeader = [self.infoInHttpHeader copy];
    config.retryCount = self.retryCount;
    
    return config;
}


@end

@implementation AEDKHttpUploadDownloadConfiguration

- (instancetype)initWithType:(AEDKHttpUploadDownloadType)type accociatedFilePath:(NSString *)path {
    self = [super init];
    if (self) {
        self.type = type;
        self.associatedFilePath = path;
    }
    return self;
}


#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    AEDKHttpUploadDownloadConfiguration *config = [[AEDKHttpUploadDownloadConfiguration allocWithZone:zone] init];
    config.type = self.type;
    config.associatedFilePath = self.associatedFilePath;
    
    return config;
}

@end



