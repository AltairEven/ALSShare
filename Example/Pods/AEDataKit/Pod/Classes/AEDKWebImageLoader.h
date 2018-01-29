//
//  AEDKWebImageLoader.h
//  Pods
//
//  Created by Altair on 30/08/2017.
//
//

#import <Foundation/Foundation.h>
#import "AEDKImageViewPlaceholder.h"

typedef enum {
    AEDKWebImageLoadViaNoNet = 1 << 0,
    AEDKWebImageLoadVia2G = 1 << 1,
    AEDKWebImageLoadVia3G = 1 << 2,
    AEDKWebImageLoadVia4G = 1 << 3,
    AEDKWebImageLoadViaWifi = 1 << 4
}AEDKImageLoadStrategy;

NS_ASSUME_NONNULL_BEGIN

@interface AEDKWebImageLoader : NSObject

@property (nonatomic, assign) AEDKImageLoadStrategy loadStrategy;

@end

@interface AEDKWebImageLoader (UIImage)

+ (void)imageWithUrl:(NSURL * __nullable)url
            progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
           completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

@end

@interface AEDKWebImageLoader (UIImageView)

@property (nonatomic, strong) NSArray<AEDKImageViewPlaceholder *> *defaultPlaceholders;

- (void)setImageForImageView:(UIImageView *)imageView
                     withUrl:(NSURL * __nullable)url;

- (void)setImageForImageView:(UIImageView *)imageView
                     withUrl:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)image;

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)image
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
                    progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)placeholder
                    progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

@end

NS_ASSUME_NONNULL_END
