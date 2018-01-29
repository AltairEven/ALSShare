//
//  AlisRequest.h
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//。 问题？不指定具体的请求插件，自动判断

#import <Foundation/Foundation.h>
#import "AlisRequestProtocol.h"
#import "AlisPluginProtocol.h"
#import "AlisRequestConst.h"


@class AlisResponse,AlisError,AlisUpLoadFormData,AlisRequestContext;

@interface AlisRequest : NSObject

+ (AlisRequest *_Nullable)request;

/**
 将dataRequrest转化为AlisRequest
*/
+ (AlisRequest *_Nullable)convertFromDataRequrest:(NSURLRequest * _Nullable)dataRequrest;

/**
 请求类型，默认AEDKHttpServiceMimeTypeUndefine
 */
@property (nonatomic, assign) AlisHttpRequestMimeType mimeType;

/**
 解析接口返回JSON数据的类
 */
@property(copy,nonatomic)NSString * _Nullable parseClass;

//请求所处的上下文，先假定为发出请求的类，也可以新增属性：例如->网络环境，电量，内存状况等。
//方便后期的回调
@property(strong,nonatomic) AlisRequestContext * _Nullable context;

//在业务层绑定的requestModel
@property(strong,nonatomic,nullable) id<AlisRequestProtocol> bindRequestModel;
//服务的名称 = <bindRequestModel + “／” + service名称（plist中定义的）>
@property(strong,nonatomic,nullable) NSString *serviceName;

//绑定真正的网络请求
@property(copy,nonatomic,nullable) id bindRequest;

//唯一的标示值
@property(copy,nonatomic,nullable) NSString *identifier;

//服务器地址
@property(copy,nonatomic,nullable) NSString *server;
//path
@property(copy,nonatomic,nullable) NSString *api;

//由server和api组成，，首先server，其次是url,generalServer最低
@property(copy,nonatomic,nullable) NSString *url;

//请求参数
@property(strong,nonatomic,nullable) NSDictionary<NSString *,id> *parameters;
//请求前强加的参数，eg：时间戳
@property(strong,nonatomic) NSDictionary<NSString *,id> * _Nullable preParameters;

//请求头
@property(strong,nonatomic,nullable) NSDictionary<NSString *,NSString *> *header;

//超时时间
@property(nonatomic,assign)NSInteger timeoutInterval;
/**
 请求类型: Normal, Upload or Download, `Normal` by default.
 */
@property (nonatomic, assign) AlisRequestType requestType;

/**
 请求的HTTP方法, 默认`AlisHTTPMethodGET`
 */
@property (nonatomic, assign) AlisHTTPMethodType httpMethod;

//重试次数
@property(assign,nonatomic)NSInteger retryCount;

//是否使用公共server，当request的server设置为nil情况，默认为yes
@property (nonatomic, assign) BOOL useGeneralServer;
//是否添加公共header，默认为yes
@property (nonatomic, assign) BOOL useGeneralHeaders;
//是否添加公共parameter，默认为yes
@property (nonatomic, assign) BOOL useGeneralParameters;


@property(copy,nonatomic,nullable) AlisRequestStartBlock startBlock;
@property(copy,nonatomic,nullable) AlisRequestCancelBlock cancelBlock;
@property(copy,nonatomic,nullable) AlisRequestFinishBlock finishBlock;
@property(copy,nonatomic,nullable) AlisRequestProgressBlock progressBlock;


- (void)addFormDataWithName:(NSString * _Nonnull)name fileData:(NSData * _Nonnull)fileData;
- (void)addFormDataWithName:(NSString * _Nonnull)name fileURL:(NSString * _Nonnull)fileURL;

@property(strong,nonatomic)NSMutableArray<AlisUpLoadFormData *> * _Nullable uploadFormDatas;

/**
 下载路径
 */
@property(copy,nonatomic,nullable)NSString *downloadPath;

@end


//上传文件，都需要以下信息
@interface AlisUpLoadFormData : NSObject

@property(copy,nonatomic,nonnull)NSString *name;
@property(copy,nonatomic,nullable)NSString *fileName;

//fileData优先级更高一些
@property(copy,nonatomic,nullable)NSData *fileData;
@property(copy,nonatomic,nullable)NSURL *fileURL;

@property(copy,nonatomic,nullable)NSString *mimeType;

+ (instancetype _Nullable )formUploadDataWithName:(NSString * _Nonnull)name fileData:(NSData * _Nonnull)fileData;
+ (instancetype _Nullable )formUploadDataWithName:(NSString * _Nonnull)name fileURL:(NSURL * _Nonnull)fileURL;

@end

@interface AlisResponse : NSObject

@property(assign,nonatomic)NSInteger responseCode;
@property(copy  ,nonatomic)NSString  * _Nullable responseMSG;
@property(strong,nonatomic)NSDictionary * _Nullable responseInfo;
@property(strong,nonatomic)id  _Nullable originalData;

- (instancetype _Nullable )initWithInfo:(NSDictionary *_Nullable)info;

@end



@interface AlisError : NSObject

@property(strong,nonatomic)NSError * _Nonnull originalError;
@property(copy,nonatomic)NSString * _Nullable name;
@property(copy,nonatomic)NSDictionary * _Nullable userInfo;
@property(assign,nonatomic)NSInteger code;
@property(copy,nonatomic)NSString * _Nullable detailInfo;

@end
