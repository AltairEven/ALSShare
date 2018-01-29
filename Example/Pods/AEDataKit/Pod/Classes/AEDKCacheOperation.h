//
//  AEDKCacheOperation.h
//  Pods
//
//  Created by Altair on 14/09/2017.
//
//

#import <Foundation/Foundation.h>
#import "AEDKProtocol.h"

@class AEDKCacheOperation;

typedef AEDKCacheOperation *(^ AEDKCacheOperationIntegerChain)(NSInteger obj);
typedef AEDKCacheOperation *(^ AEDKCacheOperationObjectChain)(id obj);

typedef enum {
    AEDKCacheOperationTypeRead,
    AEDKCacheOperationTypeWrite,
    AEDKCacheOperationTypeRemove,
    AEDKCacheOperationTypeClear
}AEDKCacheOperationType;


typedef enum {
    AEDKCacheOperationRouteMemory = 1 << 0,
    AEDKCacheOperationRouteDisk = 1 << 1
}AEDKCacheOperationRoute;

@interface AEDKCacheOperation : NSObject <AEDKProtocol>

@property (nonatomic, assign) AEDKCacheOperationType type;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, strong) id value;

@property (nonatomic, assign) AEDKCacheOperationRoute route;

/**
 缓存便捷操作的类实例

 @return 类实例
 */
+ (instancetype)operation;

/**
 使用的操作类型，传入AEDKCacheOperationType

 @return AEDKCacheOperationIntegerChain
 */
- (AEDKCacheOperationIntegerChain)withOperationType;

/**
 操作的缓存路径，传入AEDKCacheOperationRoute
 
 @return AEDKCacheOperationIntegerChain
 */
- (AEDKCacheOperationIntegerChain)from;

/**
 操作使用的key
 
 @return AEDKCacheOperationObjectChain
 */
- (AEDKCacheOperationObjectChain)withKey;

/**
 操作使用的value
 
 @return AEDKCacheOperationObjectChain
 */
- (AEDKCacheOperationObjectChain)withValue;

/**
 操作结果，如果是读操作，则同步返回value

 @return 操作结果
 */
- (id)withResult;

//快捷方法

/**
 便捷的缓存读操作

 @param key 操作使用的key
 @return 读取结果
 */
+ (id)objectForKey:(NSString *)key;

/**
 便捷的缓存写操作

 @param object 需要写的value
 @param key 需要写的key
 */
+ (void)setObject:(id)object forKey:(NSString *)key;

/**
 便捷的缓存删除操作

 @param key 操作使用的key
 */
+ (void)removeObjectForKey:(NSString *)key;

/**
 便捷的缓存清理操作

 @param route 需要清理的路径
 */
+ (void)clearWithRoute:(AEDKCacheOperationRoute)route;

@end
