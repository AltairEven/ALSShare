//
//  NSString+help.m
//  Pods
//
//  Created by alisports on 2017/4/5.
//
//
#import <CommonCrypto/CommonDigest.h>
#import "NSString+help.h"

@implementation NSString (help)

/**
 计算MD5
 */
- (NSString *)md5WithString{
    NSAssert(self, @"string should not nil");
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int) strlen(cStr), result);
    
    NSString *md5String = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    
    return md5String;
}

/**
 全局serviceName变为local的serviceName 
 @param globalServiceName 全局serviceName
 @return local的serviceName
 */
- (NSString *)toLocalServiceName{//:(NSString *)globalServiceName{
    if (self == nil) return nil;
    NSArray *serviceArray = [self componentsSeparatedByString:@"_"];
    if (serviceArray.count == 2) {
        return serviceArray[1];
    }
    return nil;
}

- (NSString *)resourceAction{
    if (self == nil) return nil;
    NSArray *serviceArray = [self componentsSeparatedByString:@"_"];
    if (serviceArray.count == 3) {
        return serviceArray[0];
    }
    return nil;

}


@end
