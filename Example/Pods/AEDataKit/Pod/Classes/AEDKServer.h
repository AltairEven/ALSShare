//
//  AEDKServer.h
//  AEDataKit
//
//  Created by Altair on 07/07/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEDKPlugProtocol.h"
#import "AEDKProtocol.h"

@class AEDKServiceConfiguration;

NS_ASSUME_NONNULL_BEGIN

#define AEDK_ERROR_CANCEL (-999)

typedef enum {
    AEDKServiceTypeUnkown,
    AEDKServiceTypeHttp,
    AEDKServiceTypeCache,
    AEDKServiceTypeDB
}AEDKServiceType;

/**
 数据服务，遵循数据服务协议的服务
 协议格式如下：
 http://domain/path?parameterKey1=parameterValue1&parameterKey2=parameterValue2
 https://domain/path?parameterKey1=parameterValue1&parameterKey2=parameterValue2
 cache://cacheIdentifier/memoryAndDisk?key=keyname
 db://table.dbname/simple?key1=keyname1&key2=kename2
 db://dbname/sql?urlencodedSQLQueryString
 */
@interface AEDKService : NSObject

/**
 数据服务的名称，用于区别不同的服务，同时唯一
 */
@property (nonatomic, copy) NSString *name;

/**
 数据服务的协议
 */
@property (nonatomic, copy) NSString *protocol;

/**
 数据服务的域
 如果是Http/Https，则表示url的domain；
 如果是Cache，则表示缓存名称，即缓存的id
 ---如果是Class，则表示提供服务的类名（暂不使用）；
 如果是DataBase，则表示表名和数据库文件名。
 */
@property (nonatomic, copy) NSString *__nullable domain;

/**
 数据服务的路径，需用“/”隔开（第一位补“/”，如“/path1/path2/..”）。
 如果是Cache，则表示读取路径是从内存缓存，还是磁盘缓存，或者都有（参考kAEDKServiceCachePath）；
 如果是DataBase，则表示是简单的键值读写，还是sql语句执行（参考kAEDKServiceDataBasePath）
 */
@property (nonatomic, copy) NSString *__nullable path;

/**
 服务配置项
 */
@property (nonatomic, copy) AEDKServiceConfiguration * configuration;

/**
 服务类型
 */
@property (nonatomic, readonly) AEDKServiceType type;

- (instancetype)initWithName:(NSString *)name protocol:(NSString *)protocol serviceConfiguration:(AEDKServiceConfiguration *)config;

- (instancetype)initWithName:(NSString *)name protocol:(NSString *)protocol domain:(NSString *__nullable)domain path:(NSString *__nullable)path serviceConfiguration:(AEDKServiceConfiguration *)config;

@end

@interface AEDKServer : NSObject

+ (instancetype)server;

//Service---------------------------------------------------

- (BOOL)registerService:(AEDKService *)service;

- (void)registerServices:(NSArray<AEDKService *> *)services;

- (BOOL)unregisterServiceWithName:(NSString *)name;

- (void)unregisterAllServices;

- (AEDKService *__nullable)registeredServiceWithName:(NSString *)name;

- (NSArray<AEDKService *> *__nullable)registeredServices;

- (AEDKProcess *__nullable)requestServiceWithName:(NSString *)name;

- (AEDKProcess *__nullable)requestService:(AEDKService *)service;

- (AEDKProcess *__nullable)requestWithPerformer:(id<AEDKProtocol>)performer;

//Delegate----------------------------------------------------

- (BOOL)addDelegate:(id<AEDKPlugProtocol>)delegate;

- (NSArray<id<AEDKPlugProtocol>> *__nullable)allDelegates;

- (BOOL)removeDelegateWithClassName:(NSString *)className;

- (BOOL)removeDelegate:(id<AEDKPlugProtocol>)delegate;

@end

NS_ASSUME_NONNULL_END
