//
//  AEDKImageViewPlaceholder.m
//  Pods
//
//  Created by Altair on 30/08/2017.
//
//

#import "AEDKImageViewPlaceholder.h"
#import "AEDKTools.h"

@interface AEDKImageViewPlaceholder ()

@end

@implementation AEDKImageViewPlaceholder

#pragma mark Public methods

- (UIImage *)fitPlaceholderImageForSize:(CGSize)size {
    if (!self.placeholderImage) {
        return nil;
    }
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    CGFloat ratio = size.width / size.height;
    if (ratio < self.imageViewMinRatio || ratio > self.imageViewMaxRatio) {
        return nil;
    }
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//    tempImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [tempImageView setContentMode:self.showMode];
    [tempImageView setImage:self.placeholderImage];
    
    UIGraphicsBeginImageContext(size);
    [tempImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)fitPlaceholderImageForView:(UIView *)view {
    return [self fitPlaceholderImageForSize:view.bounds.size];
}

@end
