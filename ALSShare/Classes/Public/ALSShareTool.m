//
//  ALSShareTool.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSShareTool.h"

@implementation ALSShareTool
+ (NSUInteger)byteCountOfImage:(UIImage *)image {
    //累计内存占用
    CGImageRef inImage = image.CGImage;
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    NSUInteger bitmapBytesPerRow    = (pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    NSUInteger bitmapByteCount    = (bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    return bitmapByteCount;
}

+ (UIImage *)image:(UIImage *)image byScalingToSize:(CGSize)targetSize retinaFit:(BOOL)needFit {
    if (needFit) {
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        //Determine whether the screen is retina
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        if(screenScale == 2.0){
            UIGraphicsBeginImageContextWithOptions(targetSize, NO, 2.0);
        } else if (screenScale == 3.0){
            UIGraphicsBeginImageContextWithOptions(targetSize, NO, 3.0);
        } else {
            UIGraphicsBeginImageContext(targetSize);
        }
        // 绘制改变大小的图片
        [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        // 从当前context中创建一个改变大小后的图片
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        // 返回新的改变大小后的图片
        return scaledImage;
    }
    
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}

+ (CGSize)sizeOfMemorySize:(NSUInteger)byteCount ofImage:(UIImage *)image {
    CGFloat whRatio = image.size.width / image.size.height;
    CGFloat currentByteCount = [ALSShareTool byteCountOfImage:image];
    
    CGSize newSize = image.size;
    if (currentByteCount > byteCount) {
        while (newSize.width * newSize.height * 4 > byteCount) {
            newSize.height -= 1;
            newSize.width = newSize.height * whRatio;
        }
    } else if (currentByteCount < byteCount) {
        while (newSize.width * newSize.height * 4 < byteCount) {
            newSize.height += 1;
            newSize.width = newSize.height * whRatio;
        }
    }
    newSize.height -= 1;
    newSize.width = newSize.height * whRatio;
    return newSize;
}

+ (UIImage *)image:(UIImage *)image byCompressToMemorySize:(NSUInteger)byteCount {
    CGFloat currentMemorySize = [ALSShareTool byteCountOfImage:image];
    if (currentMemorySize <= byteCount) {
        return image;
    }
    
    CGSize newSize = [self sizeOfMemorySize:byteCount ofImage:image];
    return [ALSShareTool image:image byScalingToSize:newSize retinaFit:NO];
}

+ (BOOL)validateSharePlatform:(ALSSharePlatform)platform {
    return (platform > ALSSharePlatformUnknown && platform < ALSSharePlatformUnDefined);
}

@end
