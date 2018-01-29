//
//  ALSWeChatSharePlug.m
//  ALSShare
//
//  Created by Altair on 13/10/2017.
//

#import "ALSWeChatSharePlug.h"
#import "ALSShareTool.h"
#import "AEDKWebImageLoader.h"


#if __has_include("WXApi.h")
#define ALS_HAS_WECHATSDK
#endif

#ifdef ALS_HAS_WECHATSDK
#import "WXApi.h"
#import "WXApiObject.h"
#endif

#pragma mark WeChatShareObject ----------------------------

typedef enum {
    WeChatShareObjectTypeDefault,
    WeChatShareObjectTypeImage,
    WeChatShareObjectTypeWebPage
}WeChatShareObjectType;


@interface WeChatShareObject : NSObject

@property (nonatomic, assign) WeChatShareObjectType type;

/** 标题
 * @note 长度不能超过512字节
 */
@property (nonatomic, copy) NSString *title;
/** 描述内容
 * @note 长度不能超过1K
 */
@property (nonatomic, copy) NSString *shareDescription;
/** 缩略图数据
 * @note 大小不能超过32K
 */
@property (nonatomic, strong) UIImage *thumbImage;
/**
 * @note 长度不能超过64字节
 */
@property (nonatomic, copy) NSString *mediaTagName;
/**
 *
 */
@property (nonatomic, copy) NSString *messageExt;

@property (nonatomic, copy) NSString *messageAction;

+ (instancetype)shareObjectWithTitle:(NSString *)title description:(NSString *)des thumbImage:(UIImage *)thumb;

@end

@interface WeChatImageShareObject : WeChatShareObject

/** 图片真实数据内容
 * @note 大小不能超过10M
 */
@property (nonatomic, strong) UIImage *image;
/** 图片url
 * @note 长度不能超过10K
 */
@property (nonatomic, copy) NSString *imageUrlString;

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                              description:(NSString *)des
                               thumbImage:(UIImage *)thumb
                               shareImage:(UIImage *)image
                      shareImageUrlString:(NSString *)urlString;

@end

@interface WeChatWebPageShareObject : WeChatShareObject

/** 网页的url地址
 * @note 不能为空且长度不能超过10K
 */
@property (nonatomic, copy) NSString *webPageUrlString;

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                                description:(NSString *)des
                                 thumbImage:(UIImage *)thumb
                           webPageUrlString:(NSString *)urlString;

@end


@implementation WeChatShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeChatShareObjectTypeDefault;
    }
    return self;
}

+ (instancetype)shareObjectWithTitle:(NSString *)title description:(NSString *)des thumbImage:(UIImage *)thumb {
    if (!title && !des && !thumb) {
        return nil;
    }
    
    WeChatShareObject *obj = [[WeChatShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = des;
    obj.thumbImage = thumb;
    return obj;
}

@end


@implementation WeChatImageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeChatShareObjectTypeImage;
    }
    return self;
}

+ (instancetype)imageShareObjectWithTitle:(NSString *)title
                              description:(NSString *)des
                               thumbImage:(UIImage *)thumb
                               shareImage:(UIImage *)image
                      shareImageUrlString:(NSString *)urlString {
    if (!image && !urlString) {
        return nil;
    }
    WeChatImageShareObject *obj = [[WeChatImageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = des;
    obj.thumbImage = thumb;
    obj.image = image;
    obj.imageUrlString = urlString;
    return obj;
}

@end


@implementation WeChatWebPageShareObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = WeChatShareObjectTypeWebPage;
    }
    return self;
}

+ (instancetype)webPageShareObjectWithTitle:(NSString *)title
                                description:(NSString *)des
                                 thumbImage:(UIImage *)thumb
                           webPageUrlString:(NSString *)urlString {
    if (!urlString || ![urlString isKindOfClass:[NSString class]]) {
        return nil;
    }
    WeChatWebPageShareObject *obj = [[WeChatWebPageShareObject alloc] init];
    obj.title = title;
    obj.shareDescription = des;
    obj.thumbImage = thumb;
    obj.webPageUrlString = urlString;
    return obj;
}

@end


#pragma mark ALSWeChatSharePlug ------------------------------------

#ifdef ALS_HAS_WECHATSDK

@interface ALSWeChatSharePlug () <WXApiDelegate>

@property (nonatomic, assign) BOOL isPlugOnline;

@property (nonatomic, copy) void (^ shareCallback)(ALSShareResponse *response);

@end
#endif

@implementation ALSWeChatSharePlug
#ifdef ALS_HAS_WECHATSDK
#pragma mark Private methods

+ (int)sceneFromShareScene:(ALSShareScene)scene {
    return scene - 1;
}

+ (WXMediaMessage *)messageFromShareObject:(WeChatShareObject *)object {
    if (!object) {
        return nil;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = object.title;
    message.description = object.shareDescription;
    if (object.thumbImage) {
        NSUInteger byteCount = [ALSShareTool byteCountOfImage:object.thumbImage];
        if (byteCount >=  32 * 1024 * 8) {
            return nil;
        }
        [message setThumbImage:object.thumbImage];
    }
    message.mediaTagName = object.mediaTagName;
    message.messageExt = object.messageExt;
    message.messageAction = object.messageAction;
    
    switch (object.type) {
        case WeChatShareObjectTypeDefault:
        {
        }
            break;
        case WeChatShareObjectTypeImage:
        {
            WeChatImageShareObject *shareObj = (WeChatImageShareObject *)object;
            
            WXImageObject *imageObj = [WXImageObject object];
            if (shareObj.image) {
                imageObj.imageData = UIImageJPEGRepresentation(shareObj.image, 0);
            }
            
            message.mediaObject = imageObj;
        }
            break;
        case WeChatShareObjectTypeWebPage:
        {
            WeChatWebPageShareObject *shareObj = (WeChatWebPageShareObject *)object;
            
            WXWebpageObject *webPageObj = [WXWebpageObject object];
            webPageObj.webpageUrl = shareObj.webPageUrlString;
            
            message.mediaObject = webPageObj;
        }
            break;
        default:
            break;
    }
    
    return message;
}

+ (NSString *)errorMessageWithStatusCode:(int)code {
    NSString *errorMessage = @"微信发生未知错误，操作失败";
    switch (code) {
        case 0:
        {
            errorMessage = @"";
        }
            break;
        case -1:
        {
            errorMessage = @"错误";
        }
            break;
        case -2:
        {
            errorMessage = @"用户取消操作";
        }
            break;
        case -3:
        {
            errorMessage = @"发送失败";
        }
            break;
        case -4:
        {
            errorMessage = @"授权失败";
        }
            break;
        case -5:
        {
            errorMessage = @"微信不支持";
        }
            break;
        default:
            break;
    }
    return errorMessage;
}

- (void)realStartShare:(ALSShareContext *)context {
    WeChatWebPageShareObject *shareObject = [WeChatWebPageShareObject webPageShareObjectWithTitle:context.shareObject.title description:context.shareObject.shareDescription thumbImage:context.shareObject.thumbImage webPageUrlString:context.shareObject.webPageUrlString];
    WXMediaMessage *message = [ALSWeChatSharePlug messageFromShareObject:shareObject];
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"WeChat Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"无效的分享内容"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
    
    SendMessageToWXReq *request = [[SendMessageToWXReq alloc] init];
    request.message = message;
    request.scene = [ALSWeChatSharePlug sceneFromShareScene:context.scene];
    BOOL ret = [WXApi sendReq:request];
    if (!ret) {
        NSError *error = [NSError errorWithDomain:@"WeChat Share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
        if (self.shareCallback) {
            ALSShareResponse *resp = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            resp.error = error;
            self.shareCallback(resp);
        }
    }
}

#pragma mark WXApiDelegate

-(void)onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        //分享
        if (self.shareCallback) {
            ALSShareResponse *response = [[ALSShareResponse alloc] initWithPlatform:[self platform]];
            if (resp.errCode != 0) {
                NSError *error = [NSError errorWithDomain:@"WeChat Share" code:resp.errCode userInfo:@{NSLocalizedDescriptionKey:[ALSWeChatSharePlug errorMessageWithStatusCode:resp.errCode]}];
                response.error = error;
            }
            self.shareCallback(response);
        }
    }
}

#pragma mark ALSSharePlugProtocol

- (BOOL)isOnLine {
    return self.isPlugOnline;
}

- (ALSSharePlatform)platform {
    return ALSSharePlatformWeChat;
}

- (BOOL)startShare:(ALSShareContext *)context withResponse:(void (^)(ALSShareResponse *))response {
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
        self.isPlugOnline = [WXApi registerApp:info.appKey];
        if (self.isPlugOnline) {
            self.isPlugOnline = ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]);
        }
        return self.isPlugOnline;
    }
    return NO;
}

- (BOOL)respondsToOpenUrl:(NSURL *)url {
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}
#endif

@end
