//
//  AEDKPlugProtocol.h
//  AEDataKit
//
//  Created by Altair on 06/07/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEDKProcess.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AEDKPlugProtocol <NSObject>

@required

- (BOOL)canHandleProcess:(AEDKProcess *)process;

- (void)handleProcess:(AEDKProcess *)process;

@end


@protocol AEDKWebImageLoaderPlugProtocol <AEDKPlugProtocol>

@optional

- (void)imageWithUrl:(NSURL * __nullable)url
            progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
           completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL * __nullable)url
            placeholderImage:(UIImage * __nullable)placeholder
                    progress:(void(^ __nullable)(int64_t totalAmount, int64_t currentAmount))progress
                   completed:(void(^ __nullable)(NSURL *__nullable imageUrl, UIImage *__nullable image, NSError *__nullable error))completedBlock;

@end

NS_ASSUME_NONNULL_END
