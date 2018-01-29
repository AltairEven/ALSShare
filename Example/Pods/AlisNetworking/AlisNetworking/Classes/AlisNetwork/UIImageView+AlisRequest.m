//
//  UIImageView+AlisRequest.m
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//
#import "AlisRequestManager.h"
#import "AlisRequestConfig.h"
#import "AlisRequest.h"
#import "AlisRequestConst.h"
#import "UIImageView+AlisRequest.h"

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

@implementation UIImageView (AlisRequest)

- (void)alis_setImageWithURL:(NSString *)url whichPlugin:(whichPlugin)whichPlugin placeholderImage:(UIImage *)placeholder options:(NSUInteger)options progress:(AlisRequestProgressBlock)progressBlock completed:(AlisRequestFinishBlock)completedBlock {
    
   // [self cancelCurrentImageLoad];
    self.image = placeholder;
    __weak UIImageView *weakSelf = self;
    // 完成时，刷新界面，再调用原有完成方法
    AlisRequestFinishBlock imageCompletedBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error) {
        dispatch_main_sync_safe(^{
            if (!weakSelf) return ;
            // 图片比较简单，只需取出image即可。
            // 也可自己实现一个ANResponse子类，在initWithInfo:里做解析。
            id object = [response.responseInfo objectForKey:@"image"];
            if ([object isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)object;
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.image = image;
                        [weakSelf setNeedsLayout];
                    });
                }
            }
            if (completedBlock) {
                completedBlock(request, response, error);
            }
        });
    };
    
    AlisRequestProgressBlock imageProcessBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
    
    };
    
    AlisRequest *request = [[AlisRequest alloc]init];
    request.mimeType = AlisHttpRequestMimeTypeImage;
    request.url = url;
    request.finishBlock = imageCompletedBlock;
    request.progressBlock = imageProcessBlock;
    
    [[AlisRequestManager manager] startRequest:request];
}
    
- (void)alis_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(NSUInteger)options progress:(AlisRequestProgressBlock)progressBlock completed:(AlisRequestFinishBlock)completedBlock {
    
    // [self cancelCurrentImageLoad];
    self.image = placeholder;
    __weak UIImageView *weakSelf = self;
    // 完成时，刷新界面，再调用原有完成方法
    AlisRequestFinishBlock imageCompletedBlock = ^(AlisRequest *request ,AlisResponse *response ,AlisError *error) {
        dispatch_main_sync_safe(^{
            if (!weakSelf) return ;
            if ([response.originalData isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage *)(response.originalData);
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.image = image;
                        [weakSelf setNeedsLayout];
                    });
                }
            }
            if (completedBlock) {
                completedBlock(request, response, error);
            }
        });
    };
    
    AlisRequestProgressBlock imageProcessBlock = ^(AlisRequest *request ,long long receivedSize, long long expectedSize){
        if (progressBlock) {
            progressBlock(request , receivedSize ,expectedSize);
        }
    };
    
    AlisRequest *request = [[AlisRequest alloc]init];
    request.mimeType = AlisHttpRequestMimeTypeImage;
    request.httpMethod = AlisHTTPMethodGET;
    request.url = url;
    request.finishBlock = imageCompletedBlock;
    request.progressBlock = imageProcessBlock;
    
    [[AlisRequestManager manager] startRequest:request];
}

@end
