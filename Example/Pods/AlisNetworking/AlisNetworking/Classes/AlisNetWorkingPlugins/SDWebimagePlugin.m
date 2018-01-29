//
//  SDWebimagePlugin.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//  关键是保存了 AlisRequest 几个block，

#import "SDWebimagePlugin.h"

#ifdef ALS_HAS_SDWebImage

#import "AlisRequest.h"

@implementation SDWebimagePlugin

#if __has_include(<AlisNetworking/AlisNetworking.h>)
    NETWORKINGPLUGIN_EXPORT_MODULE();
#endif

- (instancetype)init{
    self = [super init];
    return self;
}

- (NSArray *)supportSevervice{
    return @[@"Image"];
}

- (AlisHttpRequestMimeType)supportHttpRequestMimeType{
    return AlisHttpRequestMimeTypeImage;
}

- (void)parseRequest:(AlisRequest *)request config:(AlisRequestConfig *)config{
    [self startRequest:request config:config];
}

- (void)startRequest:(AlisRequest *)request config:(AlisRequestConfig *)config{
    //第三方的请求发起
    NSURL *requestURL = [NSURL URLWithString:request.url];    
   // request.bindRequest =
    [[SDWebImageManager sharedManager] loadImageWithURL:requestURL options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (request.progressBlock) {
                request.progressBlock(request,receivedSize,expectedSize);
            }
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (request.finishBlock) {
                AlisResponse *response = [self parseResponse:image request:request];
                AlisError *_error = [self parseError:error];
                request.finishBlock(request ,response ,_error);
            }
    }];    
}

- (AlisResponse *)parseResponse:(id)rawResponse request:(AlisRequest *)request{
    if ( !rawResponse || ![rawResponse isKindOfClass:[UIImage class]]) {
        return nil;
    }
    AlisResponse *response = [[AlisResponse alloc]init];
    response.originalData = rawResponse;
    return response;
}

- (AlisError *)parseError:(NSError *)rawError{
    if (!rawError || ![rawError isKindOfClass:[NSError class]]) {
        return nil;
    }
    
    AlisError *_error = [[AlisError alloc]init];
    _error.originalError = rawError;
    _error.code = ((NSError *)rawError).code;
    _error.name = ((NSError *)rawError).domain;
    _error.userInfo = ((NSError *)rawError).userInfo;
    return _error;
}

@end

#endif
