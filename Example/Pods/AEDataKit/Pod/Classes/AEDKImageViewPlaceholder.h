//
//  AEDKImageViewPlaceholder.h
//  Pods
//
//  Created by Altair on 30/08/2017.
//
//

#import <Foundation/Foundation.h>

@interface AEDKImageViewPlaceholder : NSObject

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, assign) CGFloat imageViewMinRatio;    //imageview最小宽高比

@property (nonatomic, assign) CGFloat imageViewMaxRatio;    //imageview最大宽高比

@property (nonatomic, assign) UIViewContentMode showMode;

- (UIImage *)fitPlaceholderImageForSize:(CGSize)size;

- (UIImage *)fitPlaceholderImageForView:(UIView *)view;

@end
