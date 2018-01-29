//
//  ALSShareTool.h
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareDefines.h"

@interface ALSShareTool : NSObject

+ (NSUInteger)byteCountOfImage:(UIImage *)image;

+ (UIImage *)image:(UIImage *)image byScalingToSize:(CGSize)targetSize retinaFit:(BOOL)needFit;

+ (UIImage *)image:(UIImage *)image byCompressToMemorySize:(NSUInteger)byteCount;

+ (BOOL)validateSharePlatform:(ALSSharePlatform)platform;

@end
