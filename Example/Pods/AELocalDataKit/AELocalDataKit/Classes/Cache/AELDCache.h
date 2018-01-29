//
//  AELDCache.h
//  AELocalDataKit
//
//  Created by Altair on 23/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AELDCacheObjectTypeUnknown,
    AELDCacheObjectTypeNSString,
    AELDCacheObjectTypeNSData,
    AELDCacheObjectTypeUIImage,
    AELDCacheObjectTypeOther
}AELDCacheObjectType;

NS_ASSUME_NONNULL_BEGIN

/**
 对NSObject的缓存扩展
 */
@interface NSObject (AELDCacheObject)

@property (nonatomic, copy, readonly) NSString * aeld_CacheKey;    //缓存对象的key

@property (nonatomic, readonly) AELDCacheObjectType aeld_MimeType;  //缓存对象的类型

@property (nonatomic, assign) NSUInteger aeld_TotalBytes;   //缓存对象的内存占用大小，如果缓存对象是UIImage || NSString || NSData || 遵循NSCoding协议，会默认自动填入一个系统计算出来的值（如果需要也可以自行赋值，以用户赋值为准）；否则需要自行赋值。如果这个值为0，将无法存入缓存。

@property (nonatomic, copy) NSDate *__nullable aeld_ExpireDate; //失效时间，默认为nil，即长期有效。如果设置了失效时间并且到期了，内存缓存会在自动清理时，将其清除；磁盘缓存会在自动或者主动清理时，将其清除

@property (nonatomic, copy) NSDictionary *__nullable aeld_UserInfo;  //用户自定义属性。注：对于需要存储到磁盘的缓存对象，需要将该属性encode，否则将丢失。

@property (nonatomic, strong, readonly) NSDate *aeld_LastGetDate; //上一次从缓存中取出的时间，不会被置为nil，除非对象被移出缓存

/**
 判断是否是合法的缓存对象

 @return 是否合法
 */
- (BOOL)aeld_ValidateCacheObject;

@end

/**
 Cache基类，需继承后使用
 */
@interface AELDCache <__covariant ObjectType> : NSObject

@property (nonatomic, copy) NSString *cacheName;    //Cache名称，可用作区分不同Cache

@property (nonatomic, assign) BOOL autoClear;   //是否自动清理，默认为NO

//以下方法在重载时，不要调用super------------
- (BOOL)setObject:(ObjectType)obj forKey:(NSString *)key;
- (ObjectType)objectForKey:(NSString *)key;
- (NSDictionary<NSString *, ObjectType> *)allCachedObjects;
- (BOOL)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;
- (void)autoClearCacheSpace;
//---------------------------------------

@end

NS_ASSUME_NONNULL_END
