//
//  ALSWeiboSharePlug.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSWeiboSharePlug.h"
#import "ALSShareTool.h"
#import "AEDKWebImageLoader.h"


#if __has_include("WeiboSDK.h")
#define ALS_HAS_WEIBOSDK
#endif

#ifdef ALS_HAS_WEIBOSDK
#import "WeiboSDK.h"
#endif

#pragma mark WeiboShareObject ----------------------------------------

typedef enum {
    WeiboShareObjectTypeDefault,
    WeiboShareObjectTypeImage,
    WeiboShareObjectTypeWebPage
}WeiboShareObjectType;

@interface WeiboShareObject : NSObject

@property (nonatomic, assign) WeiboShareObjectType type;

@property (nonatomic, copy) NSString *followingContent;

+ (instancetype)shareObjectWithFollowingContent:(NSString *)content;

@end

@interface WeiboImageShareObject : WeiboShareObject

@property (nonatomic, strong) UIImage *image;

+ (instancetype)imageShareObjectWithFollowingContent:(NSString *)content image:(UIImage *)image;

@end

@interface WeiboWebPageShareObject : WeiboShareObject

@property (nonatomic, copy) NSString *identifier; //必填

@property (nonatomic, copy) NSString *title; //必填

@property (nonatomic, copy) NSString *pageDescription;

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, copy) NSString *scheme;

@property (nonatomic, copy) NSString *webPageUrlString; //必填

+ (instancetype)webPageShareObjectWithFollowingContent:(NSString *)content
                                            identifier:(NSString *)identifier
                                                 title:(NSString *)title
                                             urlString:(NSString *)urlString;

@end


@implementation WeiboShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeDefault;
    }
    return self;
}

+ (instancetype)shareObjectWithFollowingContent:(NSString *)content {
    if (![content isKindOfClass:[NSString class]] || [content length] == 0) {
        return nil;
    }
    WeiboShareObject *obj = [[WeiboShareObject alloc] init];
    obj.followingContent = content;
    return obj;
}

@end


@implementation WeiboImageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeImage;
    }
    return self;
}

+ (instancetype)imageShareObjectWithFollowingContent:(NSString *)content image:(UIImage *)image {
    if ([content length] == 0 && !image) {
        return nil;
    }
    
    WeiboImageShareObject *obj = [[WeiboImageShareObject alloc] init];
    obj.followingContent = content;
    obj.image = image;
    return obj;
}

@end

@implementation WeiboWebPageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeiboShareObjectTypeWebPage;
    }
    return self;
}

+ (instancetype)webPageShareObjectWithFollowingContent:(NSString *)content
                                            identifier:(NSString *)identifier
                                                 title:(NSString *)title
                                             urlString:(NSString *)urlString {
    if ([content length] == 0 && ([identifier length] == 0 || [title length] == 0 || [urlString length] == 0)) {
        return nil;
    }
    
    WeiboWebPageShareObject *obj = [[WeiboWebPageShareObject alloc] init];
    obj.followingContent = content;
    obj.identifier = identifier;
    obj.title = title;
    obj.webPageUrlString = urlString;
    return obj;
}

@end

#pragma makr ALSWeiboSharePlug ----------------------------------------

#ifdef ALS_HAS_WEIBOSDK
@interface ALSWeiboSharePlug ()  <WeiboSDKDelegate>

@property (nonatomic, assign) BOOL isPlugOnline;

@property (nonatomic, strong) WBAuthorizeRequest *authRequest;

@property (nonatomic, copy) void (^ shareCallback)(ALSShareResponse *response);

@end
#endif

@implementation ALSWeiboSharePlug

#ifdef ALS_HAS_WEIBOSDK
#pragma mark Private methods

+ (WBMessageObject *)messageObjectFromWeiboShareObject:(WeiboShareObject *)shareObject {
    if (!shareObject || [shareObject.followingContent length] >= 140) {
        return nil;
    }
    WBMessageObject *messageObj = [WBMessageObject message];
    
    switch (shareObject.type) {
        case WeiboShareObjectTypeDefault:
        {
            [messageObj setText:shareObject.followingContent];
        }
            break;
        case WeiboShareObjectTypeImage:
        {
            WeiboImageShareObject *imageShareObj = (WeiboImageShareObject *)shareObject;
            messageObj.text = imageShareObj.followingContent;
            
            if (imageShareObj.image) {
                NSUInteger byteCount = [ALSShareTool byteCountOfImage:imageShareObj.image];
                if (byteCount >= 32 * 1024 * 8) {
                    return nil;
                }
                
                WBImageObject *imageObj = [WBImageObject object];
                [imageObj setImageData:UIImageJPEGRepresentation(imageShareObj.image, 0)];
                [messageObj setImageObject:imageObj];
            }
        }
            break;
        case WeiboShareObjectTypeWebPage:
        {
            WeiboWebPageShareObject *webShareObj = (WeiboWebPageShareObject *)shareObject;
            messageObj.text = webShareObj.followingContent;
            
            WBWebpageObject *webPageObj = [WBWebpageObject object];
            webPageObj.objectID = webShareObj.identifier;
            webPageObj.title = webShareObj.title;
            webPageObj.description = webShareObj.pageDescription;
            if (webShareObj.thumbnailImage) {
                webPageObj.thumbnailData = UIImageJPEGRepresentation(webShareObj.thumbnailImage, 0);
            }
            webPageObj.scheme = webShareObj.scheme;
            webPageObj.webpageUrl = webShareObj.webPageUrlString;
            
            messageObj.mediaObject = webPageObj;
        }
            break;
        default:
            break;
    }
    return messageObj;
}

+ (NSString *)errorMessageWithStatusCode:(WeiboSDKResponseStatusCode)code {
    NSString *errorMessage = @"新浪微博发生未知错误，操作失败";
    switch (code) {
        case WeiboSDKResponseStatusCodeSuccess:
        {
            errorMessage = @"";
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancel:
        {
            errorMessage = @"用户取消操作";
        }
            break;
        case WeiboSDKResponseStatusCodeSentFail:
        {
            errorMessage = @"发送失败";
        }
            break;
        case WeiboSDKResponseStatusCodeAuthDeny:
        {
            errorMessage = @"授权失败";
        }
            break;
        case WeiboSDKResponseStatusCodeUserCancelInstall:
        {
            errorMessage = @"用户取消安装微博客户端";
        }
            break;
        case WeiboSDKResponseStatusCodePayFail:
        {
            errorMessage = @"支付失败";
        }
            break;
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
        {
            errorMessage = @"分享失败";
        }
            break;
        case WeiboSDKResponseStatusCodeUnsupport:
        {
            errorMessage = @"不支持的请求";
        }
            break;
        case WeiboSDKResponseStatusCodeUnknown:
        {
            errorMessage = @"新浪微博发生未知错误";
        }
            break;
        default:
            break;
    }
    return errorMessage;
}

- (void)realStartShare:(ALSShareContext *)context {
    WeiboWebPageShareObject *shareObject = [WeiboWebPageShareObject webPageShareObjectWithFollowingContent:context.shareObject.followingContent identifier:context.shareObject.identifier title:context.shareObject.title urlString:context.shareObject.webPageUrlString];
    shareObject.thumbnailImage = context.shareObject.thumbImage;
    shareObject.pageDescription = context.shareObject.shareDescription;
    WBMessageObject *messageObject = [ALSWeiboSharePlug messageObjectFromWeiboShareObject:shareObject];
    
    if (!messageObject) {
        NSError *error = [NSError errorWithDomain:@"Weibo Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"无效的分享内容"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObject authInfo:self.authRequest access_token:nil];
    
    BOOL bRet = [WeiboSDK sendRequest:request];
    if (!bRet) {
        NSError *error = [NSError errorWithDomain:@"Tencent Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
}

#pragma mark WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        //分享
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
                NSError *error = [NSError errorWithDomain:@"Weibo Share" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey:[ALSWeiboSharePlug errorMessageWithStatusCode:response.statusCode]}];
                resp.error = error;
            }
            self.shareCallback(resp);
        }
    }
}

#pragma mark ALSSharePlugProtocol

- (BOOL)isOnLine {
    return self.isPlugOnline;
}

- (ALSSharePlatform)platform {
    return ALSSharePlatformWeibo;
}

- (BOOL)startShare:(ALSShareContext *)context withResponse:(void(^)(ALSShareResponse *resp))response {
    //WBSendMessageToWeiboRequest 说明
    //当用户安装了可以支持微博客户端內分享的微博客户端时,会自动唤起微博并分享
    //当用户没有安装微博客户端或微博客户端过低无法支持通过客户端內分享的时候会自动唤起SDK內微博发布器
    //故不用判断是否可以分享
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
        [WeiboSDK enableDebugMode:YES];
        self.isPlugOnline = [WeiboSDK registerApp:info.appKey];
        if (self.isPlugOnline) {
            self.authRequest = [WBAuthorizeRequest request];
            self.authRequest.redirectURI = info.redirectUrl;
            self.authRequest.scope = @"all";
            self.authRequest.shouldShowWebViewForAuthIfCannotSSO = YES;
        }
        return self.isPlugOnline;
    }
    return NO;
}

- (BOOL)respondsToOpenUrl:(NSURL *)url {
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [WeiboSDK handleOpenURL:url delegate:self];
}

#endif

@end
