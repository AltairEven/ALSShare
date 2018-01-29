//
//  AELDDiskCache.h
//  AELocalDataKit
//
//  Created by Altair on 27/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <AELocalDataKit/AELocalDataKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 对NSObject的磁盘缓存扩展
 */
@interface NSObject (AELDDiskCacheObject)

@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *__nullable aeld_DiskFileXAttr;  //缓存对象在磁盘存储时的附加文件属性。注：目前只支持key和value都是NSString类型

@end

/**
 磁盘缓存
 */
@interface AELDDiskCache<__covariant ObjectType> : AELDCache

@property (nonatomic, readonly) NSUInteger currentDiskUsage;    //当前磁盘占用

/**
 便捷初始化方法，并默认设置了“自动清理”
 
 @param name 缓存名称
 @return 缓存实例
 */
+ (instancetype)diskCacheWithName:(NSString *)name;

/**
 加入磁盘缓存

 @param obj 缓存对象，需要遵循NSCoding协议
 @param key 缓存对象的key
 @return 缓存成功或者失败
 */
- (BOOL)setObject:(ObjectType<NSCoding>)obj forKey:(NSString *)key;

/**
 *  清除过期的缓存对象，如果设置了自动清理，则该方法在初始化后会自动调用
 */
- (void)autoClearCacheSpace;

@end

NS_ASSUME_NONNULL_END
