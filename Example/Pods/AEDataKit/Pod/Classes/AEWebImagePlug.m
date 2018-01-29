
//
//  AEWebImagePlug.m
//  Pods
//
//  Created by Altair on 13/09/2017.
//
//

#import "AEWebImagePlug.h"
#import <AlisNetworking/AlisNetworking.h>

@implementation AEWebImagePlug

- (BOOL)canHandleProcess:(AEDKProcess *)process{
    if (!process || ![process isKindOfClass:[AEDKProcess class]]) {
        return NO;
    }
    NSString *protocol = [process.request.URL scheme];
    if (![protocol isEqualToString:kAEDKServiceProtocolHttp] || ![protocol isEqualToString:kAEDKServiceProtocolHttps]) {
        return NO;
    }
    if ([process.configuration isKindOfClass:[AEDKHttpServiceConfiguration class]]) {
        AEDKHttpServiceConfiguration *config = (AEDKHttpServiceConfiguration *)(process.configuration);
        if (config.mimeType == AEDKHttpServiceMimeTypeImage) {
            return YES;
        }
    }
    
    return NO;
}

- (void)handleProcess:(AEDKProcess *)process{
}

- (void)imageWithUrl:(NSURL * __nullable)url
            progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
           completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock{
    AlisRequestFinishBlock imageCompletedBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error) {
        if (completedBlock) {
            completedBlock([NSURL URLWithString:request.url] ,response.originalData ,error.originalError);
        }
    };
    
    AlisRequestProgressBlock imageProcessBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
        if (progress) {
            progress(expectedSize ,receivedSize);
        }
    };
    
    AlisRequest *request = [[AlisRequest alloc]init];
    request.mimeType = AlisHttpRequestMimeTypeImage;
    request.httpMethod = AlisHTTPMethodGET;
    request.url = [url absoluteString];
    request.finishBlock = imageCompletedBlock;
    request.progressBlock = imageProcessBlock;
    
    [[AlisRequestManager manager] startRequest:request]; 
}

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)placeholder
                    progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock{
    
    [imageView alis_setImageWithURL:[url absoluteString] placeholderImage:placeholder options:0 progress:^(AlisRequest *request, long long receivedSize, long long expectedSize) {
        if (progress) {
            progress(expectedSize , receivedSize);
        }
    } completed:^(AlisRequest *request, AlisResponse *response, AlisError *error) {
        if (completedBlock) {
            completedBlock([NSURL URLWithString:request.url] , response.originalData , error.originalError);
        }
    }];
}

@end
