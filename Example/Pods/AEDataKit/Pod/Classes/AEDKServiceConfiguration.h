//
//  AEDKServiceConfiguration.h
//  AEDataKit
//
//  Created by Altair on 10/07/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AEDKProcess;


NS_ASSUME_NONNULL_BEGIN

//数据服务协议
extern NSString *const kAEDKServiceProtocolHttp;    //http
extern NSString *const kAEDKServiceProtocolHttps;   //https
extern NSString *const kAEDKServiceProtocolCache;    //缓存
//extern NSString *const kAEDKServiceProtocolClass;   //类
extern NSString *const kAEDKServiceProtocolDataBase;    //数据库



//数据服务路径
//缓存的服务路径
extern NSString *const kAEDKServiceCachePathMemory;
extern NSString *const kAEDKServiceCachePathDisk;
extern NSString *const kAEDKServiceCachePathMemoryAndDisk;
//数据库的服务路径
extern NSString *const kAEDKServiceDataBasePathSimple;
extern NSString *const kAEDKServiceDataBasePathSQL;

//数据服务处理方式
extern NSString *const kAEDKServiceMethodGet;   //对应http/https协议的GET方式，或者其他协议的数据获取
extern NSString *const kAEDKServiceMethodPOST;  //对应http/https协议的POST方式，或者其他协议的数据修改
extern NSString *const kAEDKServiceMethodHEAD;  //对应http/https协议的HEAD方式，或者其他协议的数据描述获取
extern NSString *const kAEDKServiceMethodDELETE;//对应http/https协议的DELETE方式，或者其他协议的数据删除
extern NSString *const kAEDKServiceMethodPUT;   //对应http/https协议的PUT方式，或者其他协议的数据新增
extern NSString *const kAEDKServiceMethodPATCH; //对应http/https协议的PATCH方式
extern NSString *const kAEDKServiceMethodOPTIONS;   //对应http/https协议的OPTIONS方式
extern NSString *const kAEDKServiceMethodTRACE; //对应http/https协议的TRACE方式
extern NSString *const kAEDKServiceMethodCONNECT;   //对应http/https协议的CONNECT方式
extern NSString *const kAEDKServiceMethodMOVE;  //对应http/https协议的MOVE方式
extern NSString *const kAEDKServiceMethodCOPY;  //对应http/https协议的COPY方式
extern NSString *const kAEDKServiceMethodLINK;  //对应http/https协议的LINK方式
extern NSString *const kAEDKServiceMethodUNLINK;    //对应http/https协议的UNLINK方式
extern NSString *const kAEDKServiceMethodWRAPPED;   //对应http/https协议的WRAPPED方式


@interface AEDKServiceConfiguration : NSObject <NSCopying>

/**
 是否开启日志，默认NO
 */
@property (nonatomic, assign) BOOL displayDebugInfo;

/**
 指定的服务代理（类名）
 */
@property (nonatomic, copy) NSString *specifiedServiceDelegate;

/**
 服务进程的操作方式
 */
@property (nonatomic, copy) NSString *method;

/**
 请求参数
 */
@property (nonatomic, copy) NSDictionary *requestParameter;

/**
 是否同步操作的服务
 */
@property (nonatomic, assign) BOOL isSynchronized;

/**
 服务进程携带的操作实体，如http/https请求中的dataBody，file保存请求中需要操作的对象实体，或者cache请求中的缓存实体等，默认nil
 */
@property (nonatomic, strong) id requestBody;

/**
 服务进程开始前，该block通知用户当前进程，如需修改则直接修改
 */
@property (nonatomic, copy) void (^__nullable BeforeProcess)(AEDKProcess *process);

/**
 服务进程进行中
 */
@property (nonatomic, copy) void (^__nullable Processing)(int64_t totalAmount, int64_t currentAmount, NSURLRequest *currentRequest);

/**
 服务进程结束前，该block通知用户当前服务的返回数据，需要用户返回解析后的数据模型
 */
@property (nonatomic, copy) id (^__nullable AfterProcess)(AEDKProcess *currentProcess, NSError *error, id __nullable responseData);

/**
 服务进程完成后，得到执行结果。如果用户实现了AfterProcess，则返回用户解析后的数据模型，否则返回原始数据
 */
@property (nonatomic, copy) void (^ ProcessCompleted)(AEDKProcess *currentProcess, NSError *error, id __nullable responseModel);

/**
 默认配置

 @return 配置实例
 */
+ (instancetype)defaultConfiguration;

@end

@class AEDKHttpUploadDownloadConfiguration;

typedef enum {
    AEDKHttpServiceMimeTypeUndefine,
    AEDKHttpServiceMimeTypeText,
    AEDKHttpServiceMimeTypeImage,
    AEDKHttpServiceMimeTypeOther
}AEDKHttpServiceMimeType;

@interface AEDKHttpServiceConfiguration : AEDKServiceConfiguration

/**
 字符编码
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
 请求类型，默认AEDKHttpServiceMimeTypeUndefine
 */
@property (nonatomic, assign) AEDKHttpServiceMimeType mimeType;

/**
 上传下载配置
 */
@property (nonatomic, copy) AEDKHttpUploadDownloadConfiguration *uploadDownloadConfig;

/**
 拼在链接后的用户信息
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *infoAppendingAfterQueryString;

/**
 http头中的用户信息
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *infoInHttpHeader;

/**
 重试次数， 默认0
 */
@property (nonatomic, assign) NSUInteger retryCount;

@end

typedef enum {
    AEDKHttpFileUpload,
    AEDKHttpFileDownload
}AEDKHttpUploadDownloadType;

@interface AEDKHttpUploadDownloadConfiguration : NSObject <NSCopying>

/**
 上传下载类型
 */
@property (nonatomic, assign) AEDKHttpUploadDownloadType type;

/**
 关联的文件路径，用于上传或下载
 */
@property (nonatomic, copy) NSString *associatedFilePath;

/**
 初始化方法

 @param type 上传下载类型
 @param path 关联文件路径
 @return 类实例
 */
- (instancetype)initWithType:(AEDKHttpUploadDownloadType)type accociatedFilePath:(NSString *)path;

@end


NS_ASSUME_NONNULL_END

