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

#import "AELocalDataKit.h"
#import "AELDDiskCachePlug.h"
#import "AELDIntegratedCachePlug.h"
#import "AELDMemoryCachePlug.h"
#import "AELDCache.h"
#import "AELDDiskCache.h"
#import "AELDMemoryCache.h"
#import "AELDOperationMode.h"
#import "AELDPlugMode.h"
#import "AELDResponse.h"
#import "AELocalDataSocket.h"
#import "AELDTools.h"

FOUNDATION_EXPORT double AELocalDataKitVersionNumber;
FOUNDATION_EXPORT const unsigned char AELocalDataKitVersionString[];

