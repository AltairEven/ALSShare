#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AFNetworkingPlugin.h"
#import "SDWebimagePlugin.h"
#import "AlisHttpServiceItem.h"
#import "AlisService.h"
#import "AlisServiceProxy.h"
#import "AlisServicesManager.h"
#import "AlisNetworking.h"
#import "AlisPluginManager.h"
#import "AlisRequestConfig.h"
#import "AlisRequestManager+AlisRequest.h"
#import "AlisRequestManager.h"
#import "AlisJsonBaseItem.h"
#import "AlisJsonModel.h"
#import "AlisJsonParseManager.h"
#import "AlisJsonParsePluginProtocol.h"
#import "AlisJsonParserProtocol.h"
#import "NSString+help.h"
#import "UIImageView+AlisRequest.h"
#import "AlisPluginProtocol.h"
#import "AlisRequest.h"
#import "AlisRequestConst.h"
#import "AlisRequestContext.h"
#import "AlisRequestProtocol.h"
#import "Alis_AFNetworkReachabilityManager.h"

FOUNDATION_EXPORT double AlisNetworkingVersionNumber;
FOUNDATION_EXPORT const unsigned char AlisNetworkingVersionString[];

