//
//  ALSShareContext.h
//  ALSShare
//
//  Created by Altair on 18/10/2017.
//

#import <Foundation/Foundation.h>
#import "ALSShareDefines.h"

@interface ALSShareObject : NSObject <NSCopying>

/** 分享ID，微博分享必填
 * @note 长度不能超过255个字符
 */
@property (nonatomic, copy) NSString *identifier;

/** 标题
 * @note 长度不能超过128字节
 */
@property (nonatomic, copy) NSString *title;
/** 描述内容
 * @note 长度不能超过512字节
 */
@property (nonatomic, copy) NSString *shareDescription;
/** 缩略图数据
 * @note 大小不能超过32K
 */
@property (nonatomic, strong) UIImage *thumbImage;
/** 缩略图下载链接
 * @note 非QQ分享下载后须压缩至大小不超过32K
 */
@property (nonatomic, copy) NSURL *thumbImageUrl;
/** 网页地址
 * @note 长度不能超过512字节
 */
@property (nonatomic, copy) NSString *webPageUrlString;
/** 分享内容前缀，微博分享选填
 * @note 长度不能超过140个字符
 */
@property (nonatomic, copy) NSString *followingContent;

+ (instancetype)shareObjectWithTitle:(NSString *)title
                         description:(NSString *)description
                          thumbImage:(UIImage *)thumb
                           urlString:(NSString *)urlString;

+ (instancetype)shareObjectWithTitle:(NSString *)title
                         description:(NSString *)description
                       thumbImageUrl:(NSURL *)thumbUrl
                           urlString:(NSString *)urlString;

@end

@interface ALSShareContext : NSObject <NSCopying>

@property (nonatomic, assign) ALSSharePlatform platform;

@property (nonatomic, assign) ALSShareScene scene;

@property (nonatomic, copy) ALSShareObject *shareObject;

- (instancetype)initWithPlatform:(ALSSharePlatform)platform scene:(ALSShareScene)scene shareObject:(ALSShareObject *)shareObject;

@end
