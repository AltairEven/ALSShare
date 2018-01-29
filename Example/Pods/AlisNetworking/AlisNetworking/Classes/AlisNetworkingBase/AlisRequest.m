//
//  AlisRequest.m
//  PluginsDemo
//
//  Created by alisports on 2017/2/22.
//  Copyright © 2017年 alisports. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "AlisRequest.h"
#import "AlisRequestContext.h"

@implementation AlisRequest

+ (AlisRequest *)request{
    return [[[self class]alloc] init];
}

+ (AlisRequest *)convertFromDataRequrest:(NSURLRequest *)dataRequrest{
    AlisRequest *httpRequest = [[[self class]alloc] init];
    return httpRequest;
}

- (instancetype)init
{
    if (self = [super init]) {
        _timeoutInterval = 15;
        _useGeneralServer = YES;
        _useGeneralHeaders = YES;
        _useGeneralParameters = YES;
        
        _requestType = AlisRequestNormal;
        _httpMethod = AlisHTTPMethodGET;
        _bindRequestModel = nil;
        _retryCount = 3;
        
        _context = [[AlisRequestContext alloc]init];
    }
    return self;
}

- (NSMutableArray<AlisUpLoadFormData *> *)uploadFormDatas {
    if (!_uploadFormDatas) {
        _uploadFormDatas = [NSMutableArray array];
    }
    return _uploadFormDatas;
}

- (void)addFormDataWithName:(NSString *)name fileData:(NSData *)fileData{
    AlisUpLoadFormData *formData = [AlisUpLoadFormData formUploadDataWithName:name fileData:fileData];
    [self.uploadFormDatas addObject:formData];
    
}

- (void)addFormDataWithName:(NSString *)name fileURL:(NSString *)fileURL{
    NSURL *_fileURL = [NSURL URLWithString:fileURL];
    AlisUpLoadFormData *formData = [AlisUpLoadFormData formUploadDataWithName:name fileURL:_fileURL];
    [self.uploadFormDatas addObject:formData];
}

@end


@implementation AlisUpLoadFormData

+ (instancetype)formUploadDataWithName:(NSString *)name fileData:(NSData *)fileData{
    AlisUpLoadFormData *formData = [[AlisUpLoadFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formUploadDataWithName:(NSString *)name fileURL:(NSURL *)fileURL{
    AlisUpLoadFormData *formData = [[AlisUpLoadFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

@end

@implementation AlisResponse

- (instancetype)initWithInfo:(NSDictionary *)info{
    if (self == [super init]) {
        //todo 适配型
        self.responseCode = [info[@"res_code"] integerValue];
        self.responseMSG =  info[@"res_msg"];
        self.responseInfo = info[@"data"];
    }
    return self;
}

@end


@implementation AlisError
@end

