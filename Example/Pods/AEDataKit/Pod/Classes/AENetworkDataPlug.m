//
//  AENetworkDataPlug.m
//  Pods
//
//  Created by Altair on 13/09/2017.
//
//

#import "AENetworkDataPlug.h"
#import <AlisNetworking/AlisNetworking.h>

@implementation AENetworkDataPlug

- (NSString *)plugIdentifier{
    return  NSStringFromClass([self class]);
}

- (BOOL)canHandleProcess:(AEDKProcess *)process{
    if (!process || ![process isKindOfClass:[AEDKProcess class]]) {
        return NO;
    }
    NSString *protocol = [process.request.URL scheme];
    if (![protocol isEqualToString:kAEDKServiceProtocolHttp] && ![protocol isEqualToString:kAEDKServiceProtocolHttps]) {
        return NO;
    }
    if ([process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]]) {
        AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
        if (config.mimeType != AEDKHttpServiceMimeTypeImage) {
            return YES;
        }
    }
    return NO;
}

- (void)handleProcess:(AEDKProcess *)process{
    
    if (process.configuration == nil) return;
    if (![process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]])
        return;
    
    AlisRequest *alisRequest = [self convertAEDKProcess:process];
    [[AlisRequestManager sharedManager]startRequest:alisRequest];
    
}

- (AlisRequest *)convertAEDKProcess:(AEDKProcess *)process{
    if (process.configuration == nil) return nil;
    if (![process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]])
        return nil;
    
    AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
    
    AlisRequest *alisRequest = [[AlisRequest alloc]init];
    NSURLRequest *urlRequet = process.request;
    alisRequest.url = [urlRequet.URL absoluteString];
    alisRequest.parameters = config.requestParameter;
    alisRequest.httpMethod = [self httpMethodConverter:urlRequet.HTTPMethod];
    alisRequest.retryCount = config.retryCount;
    alisRequest.header = config.infoInHttpHeader;
    alisRequest.timeoutInterval = urlRequet.timeoutInterval;
    
    if (config.mimeType == AEDKHttpServiceMimeTypeText) {
        alisRequest.mimeType = AlisHttpRequestMimeTypeText;
    }else if (config.mimeType == AEDKHttpServiceMimeTypeImage) {
        alisRequest.mimeType = AlisHttpRequestMimeTypeImage;
    }
    
    
    if (config.uploadDownloadConfig == nil) {
        alisRequest.requestType = AlisRequestNormal;
    }
    else if (config.uploadDownloadConfig.type == AEDKHttpFileUpload) {
        alisRequest.requestType = AlisRequestUpload;
    }
    else if (config.uploadDownloadConfig.type == AEDKHttpFileDownload) {
        alisRequest.requestType = AlisRequestDownload;
    }
    
    alisRequest.startBlock = ^{
        if (config.BeforeProcess) {
            config.BeforeProcess(process);
        }
    };
    
    alisRequest.progressBlock = ^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        if (config.Processing) {
            config.Processing(expectedSize, receivedSize, process.request);
        }
    };
    
    alisRequest.cancelBlock = ^{
    };
    
    alisRequest.finishBlock = ^(AlisRequest *request, AlisResponse *response, AlisError *error) {
        if (config.AfterProcess) {
            id parseredData = config.AfterProcess( process , error.originalError,response.originalData);
            if (config.ProcessCompleted) {
                config.ProcessCompleted(process, error.originalError, parseredData);
            }
            return;
        }
        if (config.ProcessCompleted) {
            config.ProcessCompleted(process, error.originalError, response.originalData);
        }
    };
    
    return alisRequest;
    
}

- (AlisHTTPMethodType)httpMethodConverter:(NSString *)HTTPMethod{
    if ([HTTPMethod isEqualToString:@"GET"]) {
        return AlisHTTPMethodGET;
    }else if ([HTTPMethod isEqualToString:@"POST"]) {
        return AlisHTTPMethodPOST;
    }else if ([HTTPMethod isEqualToString:@"HEAD"] ) {
        return AlisHTTPMethodHEAD;
    }else if ([HTTPMethod isEqualToString:@"DELETE"]) {
        return AlisHTTPMethodDELETE;
    }else if ([HTTPMethod isEqualToString:@"PUT"]) {
        return AlisHTTPMethodPUT;
    }else if ([HTTPMethod isEqualToString:@"PATCH"]) {
        return AlisHTTPMethodPATCH;
    }
    
    return AlisHTTPMethodGET;
}

@end
