//
//  ALSTencentSharePlug.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSTencentSharePlug.h"
#import "ALSShareTool.h"
#import "AEDKWebImageLoader.h"

#if __has_include(<TencentOpenAPI/QQApiInterface.h>)
#define ALS_HAS_TENCENTSDK
#endif

#ifdef ALS_HAS_TENCENTSDK
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#endif


#pragma mark TencentShareObject -----------------------------------------------

typedef enum {
    TencentShareObjectTypeDefault,
    TencentShareObjectTypeImage,
    TencentShareObjectTypeWebPage
}TencentShareObjectType;


@interface TencentShareObject : NSObject

@property (nonatomic, assign) TencentShareObjectType type;

@property(nonatomic, copy) NSString* title; ///< 标题，最长128个字符

@property(nonatomic, copy) NSString* shareDescription; ///<简要描述，最长512个字符

+ (instancetype)shareObjectWithTitle:(NSString *)title shareDescription:(NSString *)description;

@end

@interface TencentImageShareObject : TencentShareObject

@property (nonatomic, strong) UIImage *image;///<分享的图片，必填，最大5M字节

@property(nonatomic, strong) UIImage *thumbImage;///<预览图像数据，最大1M字节

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                         shareDescription:(NSString *)description
                               shareImage:(UIImage *)image
                               thumbImage:(UIImage *)thumb;

@end


@interface TencentWebPageShareObject : TencentShareObject

@property (nonatomic, copy) NSString *pageUrlString;

@property(nonatomic, strong) UIImage *thumbImage;///<预览图像数据，最大1M字节

@property(nonatomic, copy) NSString *thumbImageUrlString;    ///<预览图像URL **预览图像数据与预览图像URL可二选一

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                           shareDescription:(NSString *)description
                              pageUrlString:(NSString *)urlString
                                 thumbImage:(UIImage *)thumb
                        thumbImageUrlString:(NSString *)thumbUrlString;

@end


@implementation TencentShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeDefault;
    }
    return self;
}

+ (instancetype)shareObjectWithTitle:(NSString *)title shareDescription:(NSString *)description {
    TencentShareObject *obj = [[TencentShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    return obj;
}

@end


@implementation TencentImageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeImage;
    }
    return self;
}

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                         shareDescription:(NSString *)description
                               shareImage:(UIImage *)image
                               thumbImage:(UIImage *)thumb {
    if (!image && ![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    
    TencentImageShareObject *obj = [[TencentImageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    obj.image = image;
    obj.thumbImage = thumb;
    return obj;
}

@end


@implementation TencentWebPageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = TencentShareObjectTypeWebPage;
    }
    return self;
}

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                           shareDescription:(NSString *)description
                              pageUrlString:(NSString *)urlString
                                 thumbImage:(UIImage *)thumb
                        thumbImageUrlString:(NSString *)thumbUrlString {
    
    TencentWebPageShareObject *obj = [[TencentWebPageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = description;
    obj.pageUrlString = urlString;
    obj.thumbImage = thumb;
    obj.thumbImageUrlString = thumbUrlString;
    return obj;
}

@end

#pragma mark ALSTencentSharePlug -----------------------------------------------

#ifdef ALS_HAS_TENCENTSDK
@interface ALSTencentSharePlug () <QQApiInterfaceDelegate>

@property (nonatomic, assign) BOOL isPlugOnline;

@property (nonatomic, copy) void (^ shareCallback)(ALSShareResponse *response);

+ (NSString *)errorMessageWithStatusCode:(NSString *)code;

@end
#endif

@implementation ALSTencentSharePlug

#ifdef ALS_HAS_TENCENTSDK
#pragma mari Private methods
+(void)load{
    
}
+ (NSString *)errorMessageWithStatusCode:(NSString *)code {
    NSString *errorMessage = @"QQ发生未知错误，操作失败";
    NSInteger intCode = [code integerValue];
    switch (intCode) {
        case -4:
            {
                errorMessage = @"用户取消操作";
            }
            break;
        default:
            break;
    }
    return errorMessage;
}

+ (QQApiObject *)apiObjectFromQQShareObject:(TencentShareObject *)object {
    if (!object) {
        return nil;
    }
    
    uint64_t contorlFlag = kQQAPICtrlFlagQQShare;
    //ShareDestType shareDestType = ShareDestTypeQQ;
    
    switch (object.type) {
        case TencentShareObjectTypeDefault:
        {
            QQApiObject *apiObject = [[QQApiObject alloc] init];
            apiObject.title = object.title;
            apiObject.description = object.shareDescription;
            apiObject.cflag = contorlFlag;
            //apiObject.shareDestType = shareDestType;
            
            return apiObject;
        }
            break;
        case TencentShareObjectTypeImage:
        {
            TencentImageShareObject *shareObj = (TencentImageShareObject *)object;
            
            if ([ALSShareTool byteCountOfImage:shareObj.image] >= 1024 * 1024 * 5 * 8) {
                return nil;
            }
            NSData *imageData = UIImageJPEGRepresentation(shareObj.image, 0);
            if ([ALSShareTool byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
                return nil;
            }
            NSData *thumbData = nil;
            if (shareObj.thumbImage) {
                thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
            }
            
            QQApiImageObject *imageObject = [QQApiImageObject objectWithData:imageData previewImageData:thumbData title:shareObj.title description:shareObj.shareDescription];
            imageObject.cflag = contorlFlag;
            //imageObject.shareDestType = shareDestType;
            return imageObject;
        }
            break;
        case TencentShareObjectTypeWebPage:
        {
            TencentWebPageShareObject *shareObj = (TencentWebPageShareObject *)object;
            
            NSURL *pageUrl = [NSURL URLWithString:shareObj.pageUrlString];
            
            QQApiURLObject *urlObject = nil;
            
            if ([ALSShareTool byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
                return nil;
            }
            if (shareObj.thumbImage) {
                NSData *thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
                urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageData:thumbData targetContentType:QQApiURLTargetTypeNews];
            } else {
                urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageURL:[NSURL URLWithString:shareObj.thumbImageUrlString] targetContentType:QQApiURLTargetTypeNews];
            }
            urlObject.cflag = contorlFlag;
            //urlObject.shareDestType = shareDestType;
            return urlObject;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (QQApiObject *)apiObjectFromQZoneShareObject:(TencentShareObject *)object {
    if (!object || ![object isKindOfClass:[TencentWebPageShareObject class]]) {
        return nil;
    }
    
    TencentWebPageShareObject *shareObj = (TencentWebPageShareObject *)object;
    
    NSURL *pageUrl = [NSURL URLWithString:shareObj.pageUrlString];
    
    QQApiURLObject *urlObject = nil;
    
    if ([ALSShareTool byteCountOfImage:shareObj.thumbImage] >= 1024 * 1024 * 8) {
        return nil;
    }
    if (shareObj.thumbImage) {
        NSData *thumbData = UIImageJPEGRepresentation(shareObj.thumbImage, 0);
        urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageData:thumbData targetContentType:QQApiURLTargetTypeNews];
    } else {
        urlObject = [QQApiURLObject objectWithURL:pageUrl title:shareObj.title description:shareObj.shareDescription previewImageURL:[NSURL URLWithString:shareObj.thumbImageUrlString] targetContentType:QQApiURLTargetTypeNews];
    }
    urlObject.cflag = kQQAPICtrlFlagQZoneShareOnStart;
    //urlObject.shareDestType = ShareDestTypeQQ;
    return urlObject;
}

- (void)realStartShare:(ALSShareContext *)context {
    TencentWebPageShareObject *tencentShareObject = [TencentWebPageShareObject webPageShareObjectWithTitle:context.shareObject.title shareDescription:context.shareObject.shareDescription pageUrlString:context.shareObject.webPageUrlString thumbImage:context.shareObject.thumbImage thumbImageUrlString:[context.shareObject.thumbImageUrl absoluteString]];
    QQApiObject *shareObject = nil;
    switch (context.scene) {
        case ALSShareSceneTencentQQ:
        {
            shareObject = [ALSTencentSharePlug apiObjectFromQQShareObject:tencentShareObject];
        }
            break;
        case ALSShareSceneTencentQZone:
        {
            shareObject = [ALSTencentSharePlug apiObjectFromQZoneShareObject:tencentShareObject];
        }
            break;
        default:
            break;
    }
    
    if (!shareObject) {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"无效的分享内容"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
    
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:shareObject];
    
    QQApiSendResultCode code = [QQApiInterface sendReq:request];
    
    if (code != EQQAPISENDSUCESS && code != EQQAPIAPPSHAREASYNC) {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
}

#pragma mark QQApiInterfaceDelegate

- (void)onReq:(QQBaseReq *)req {
    
}

- (void)onResp:(QQBaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        //分享
        if (self.shareCallback) {
            ALSShareResponse *response = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            if (![resp.result isEqualToString:@"0"]) {
                NSError *error = [NSError errorWithDomain:@"Tencent Share" code:[resp.result integerValue] userInfo:@{NSLocalizedDescriptionKey:[ALSTencentSharePlug errorMessageWithStatusCode:resp.result]}];
                response.error = error;
            }
            self.shareCallback(response);
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    
}

#pragma mark ALSSharePlugProtocol

- (BOOL)isOnLine {
    return self.isPlugOnline;
}

- (ALSSharePlatform)platform {
    return ALSSharePlatformTencent;
}

- (BOOL)startShare:(ALSShareContext *)context withResponse:(void(^)(ALSShareResponse *resp))response {
    self.shareCallback = response;
    //先下载图片
    if (context.shareObject.thumbImageUrl && !context.shareObject.thumbImage) {
        [AEDKWebImageLoader imageWithUrl:context.shareObject.thumbImageUrl progress:nil completed:^(NSURL * _Nullable imageUrl, UIImage * _Nullable image, NSError * _Nullable error) {
            if (image) {
                context.shareObject.thumbImage = [ALSShareTool image:image byCompressToMemorySize:32 * 1024 * 8];
            }
            [self realStartShare:context];
        }];
    } else {
        [self realStartShare:context];
    }
    return YES;
}

- (BOOL)getOnlineWithInitializationDelegate:(id<ALSSharePlugInitializationProtocol>)delegate {
    if (delegate && [delegate respondsToSelector:@selector(sharePlugInitilizationInfoForPlatform:)]) {
        ALSSharePlugInitializationInfo *info = [delegate sharePlugInitilizationInfoForPlatform:[self platform]];
        self.isPlugOnline = [[TencentOAuth alloc] initWithAppId:info.appKey andDelegate:nil] ? YES : NO;
        if (self.isPlugOnline) {
            self.isPlugOnline = ([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]);
        }
        return self.isPlugOnline;
    }
    return NO;
}

- (BOOL)respondsToOpenUrl:(NSURL *)url {
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [QQApiInterface handleOpenURL:url delegate:self];
}

#endif

@end
