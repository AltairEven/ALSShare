//
//  ALSShareContext.m
//  ALSShare
//
//  Created by Altair on 18/10/2017.
//

#import "ALSShareContext.h"

@implementation ALSShareObject

+ (instancetype)shareObjectWithTitle:(NSString *)title
                         description:(NSString *)description
                          thumbImage:(UIImage *)thumb
                           urlString:(NSString *)urlString {
    if (title && ![title isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (description && ![description isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (thumb && ![thumb isKindOfClass:[UIImage class]]) {
        return nil;
    }
    if (!urlString || ![urlString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    ALSShareObject *object = [[ALSShareObject alloc] init];
    object.title = title;
    object.shareDescription = description;
    object.thumbImage = thumb;
    object.webPageUrlString = urlString;
    return object;
}

+ (instancetype)shareObjectWithTitle:(NSString *)title
                         description:(NSString *)description
                       thumbImageUrl:(NSURL *)thumbUrl
                           urlString:(NSString *)urlString {
    if (title && ![title isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (description && ![description isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (thumbUrl && ![thumbUrl isKindOfClass:[NSURL class]]) {
        return nil;
    }
    if (!urlString || ![urlString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    ALSShareObject *object = [[ALSShareObject alloc] init];
    object.title = title;
    object.shareDescription = description;
    object.thumbImageUrl = thumbUrl;
    object.webPageUrlString = urlString;
    return object;
}

- (NSString *)identifier {
    if (!_identifier) {
        _identifier = @"noneId";
    }
    return _identifier;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ALSShareObject *retObj = [[ALSShareObject allocWithZone:zone] init];
    retObj.identifier = self.identifier;
    retObj.title = self.title;
    retObj.shareDescription = self.shareDescription;
    if (self.thumbImage) {
        retObj.thumbImage = [UIImage imageWithCGImage:self.thumbImage.CGImage];
    }
    retObj.thumbImageUrl = self.thumbImageUrl;
    retObj.webPageUrlString = self.webPageUrlString;
    retObj.followingContent = self.followingContent;
    
    return retObj;
}

@end

@implementation ALSShareContext

- (instancetype)initWithPlatform:(ALSSharePlatform)platform scene:(ALSShareScene)scene shareObject:(ALSShareObject *)shareObject {
    self = [super init];
    if (self) {
        _platform = platform;
        _scene = scene;
        _shareObject = shareObject;
    }
    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ALSShareContext *retObj = [[ALSShareContext allocWithZone:zone] init];
    retObj.platform = self.platform;
    retObj.scene = self.scene;
    retObj.shareObject = self.shareObject;
    return retObj;
}

@end
