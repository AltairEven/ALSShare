//
//  UIImageView+AlisRequest.h
//  Pods
//
//  Created by alisports on 2017/4/7.
//
//

#import <UIKit/UIKit.h>

typedef NSString *(^whichPlugin) (NSArray *plugins);

@interface UIImageView (AlisRequest)

- (void)alis_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(NSUInteger)options progress:(AlisRequestProgressBlock)progressBlock completed:(AlisRequestFinishBlock)completedBlock ; 

- (void)alis_setImageWithURL:(NSString *)url  whichPlugin:(whichPlugin)whichPlugin placeholderImage:(UIImage *)placeholder options:(NSUInteger)options progress:(AlisRequestProgressBlock)progressBlock completed:(AlisRequestFinishBlock)completedBlock ;

@end
