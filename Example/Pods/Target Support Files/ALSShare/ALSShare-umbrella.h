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

#import "ALSShareService.h"
#import "ALSShareSocket.h"
#import "ALSTencentSharePlug.h"
#import "ALSWeChatSharePlug.h"
#import "ALSWeiboSharePlug.h"
#import "ALSShareContext.h"
#import "ALSShareDefines.h"
#import "ALSSharePlugInitializationInfo.h"
#import "ALSSharePlugProtocol.h"
#import "ALSShareResponse.h"
#import "ALSShareTool.h"

FOUNDATION_EXPORT double ALSShareVersionNumber;
FOUNDATION_EXPORT const unsigned char ALSShareVersionString[];

