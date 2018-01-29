//
//  AEDKWebImageLoader.m
//  Pods
//
//  Created by Altair on 30/08/2017.
//
//

#import "AEDKWebImageLoader.h"
#import "AEDKServer.h"
#import <objc/runtime.h>

@interface AEDKWebImageLoader ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *defaultPlaceholderImages;

@end

@implementation AEDKWebImageLoader



@end


@implementation AEDKWebImageLoader (UIImage)

+ (void)imageWithUrl:(NSURL *)url progress:(void (^)(int64_t, int64_t))progress completed:(void (^)(NSURL * _Nullable, UIImage * _Nullable, NSError * _Nullable))completedBlock {
    NSArray<id<AEDKPlugProtocol>> *delegates = [[AEDKServer server] allDelegates];
    BOOL hasDelegate = NO;
    //有指定的服务代理
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:@protocol(AEDKWebImageLoaderPlugProtocol)] && [delegate respondsToSelector:@selector(imageWithUrl:progress:completed:)]) {
            [delegate imageWithUrl:url progress:progress completed:completedBlock];
            hasDelegate = YES;
            break;
        }
    }
    if (!hasDelegate && completedBlock) {
        NSError *error = [NSError errorWithDomain:@"AEDKImageLoader" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Loader delegate not found."}];
        completedBlock(url, nil, error);
    }
}

@end


@implementation AEDKWebImageLoader (UIImageView)

- (void)setDefaultPlaceholders:(NSArray<AEDKImageViewPlaceholder *> *)defaultPlaceholders {
    objc_setAssociatedObject(self, @"AEDKWebImageLoader_defaultPlaceholders", defaultPlaceholders, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray<AEDKImageViewPlaceholder *> *)defaultPlaceholders {
    return objc_getAssociatedObject(self, @"AEDKWebImageLoader_defaultPlaceholders");
}

#pragma mark Private methods

- (UIImage *)getSuitablePlaceholderForImageView:(UIImageView *)imageView {
    if (!imageView || ![imageView isKindOfClass:[UIImageView class]]) {
        return nil;
    }
    UIImage *placeholder = nil;
    for (AEDKImageViewPlaceholder *ph in self.defaultPlaceholders) {
        placeholder = [ph fitPlaceholderImageForView:imageView];
        if (placeholder) {
            break;
        }
    }
    return placeholder;
}

#pragma mark Public methods

- (void)setImageForImageView:(UIImageView *)imageView withUrl:(NSURL *)url {
    [self setImageForImageView:imageView withURL:url placeholderImage:nil progress:nil completed:nil];
}

- (void)setImageForImageView:(UIImageView *)imageView withUrl:(NSURL *)url placeholderImage:(UIImage *)image {
    [self setImageForImageView:imageView withURL:url placeholderImage:image progress:nil completed:nil];
}

- (void)setImageForImageView:(UIImageView *)imageView withURL:(NSURL *)url completed:(void (^)(NSURL * _Nullable, UIImage * _Nullable, NSError * _Nullable))completedBlock {
    [self setImageForImageView:imageView withURL:url placeholderImage:nil progress:nil completed:completedBlock];
}

- (void)setImageForImageView:(UIImageView *)imageView withURL:(NSURL *)url placeholderImage:(UIImage *)image completed:(void (^)(NSURL * _Nullable, UIImage * _Nullable, NSError * _Nullable))completedBlock {
    [self setImageForImageView:imageView withURL:url placeholderImage:image progress:nil completed:completedBlock];
}

- (void)setImageForImageView:(UIImageView *)imageView withURL:(NSURL *)url progress:(void (^)(int64_t, int64_t))progress completed:(void (^)(NSURL * _Nullable, UIImage * _Nullable, NSError * _Nullable))completedBlock {
    [self setImageForImageView:imageView withURL:url placeholderImage:nil progress:progress completed:completedBlock];
}

- (void)setImageForImageView:(UIImageView *)imageView withURL:(NSURL *)url placeholderImage:(UIImage *)placeholder progress:(void (^)(int64_t, int64_t))progress completed:(void (^)(NSURL * _Nullable, UIImage * _Nullable, NSError * _Nullable))completedBlock {
    NSArray<id<AEDKPlugProtocol>> *delegates = [[AEDKServer server] allDelegates];
    BOOL hasDelegate = NO;
    //有指定的服务代理
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:@protocol(AEDKWebImageLoaderPlugProtocol)] && [delegate respondsToSelector:@selector(setImageForImageView:withURL:placeholderImage:progress:completed:)]) {
            if (!placeholder) {
                placeholder = [self getSuitablePlaceholderForImageView:imageView];
            }
            [delegate setImageForImageView:imageView withURL:url placeholderImage:placeholder progress:progress completed:completedBlock];
            hasDelegate = YES;
            break;
        }
    }
    if (!hasDelegate && completedBlock) {
        NSError *error = [NSError errorWithDomain:@"AEDKImageLoader" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Loader delegate not found."}];
        completedBlock(url, nil, error);
    }
}

@end
