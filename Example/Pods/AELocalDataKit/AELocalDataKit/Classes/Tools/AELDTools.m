//
//  AELDTools.m
//  AELocalDataKit
//
//  Created by Altair on 30/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import "AELDTools.h"
#import <sys/xattr.h>

@implementation AELDTools

+ (BOOL)setExpendAttributes:(NSDictionary<NSString *, NSString *> *)attrs forPath:(NSString *)path {
    if (![[NSFileManager defaultManager] isWritableFileAtPath:path]) {
        return NO;
    }
    
    for (NSString *key in attrs.allKeys) {
        if (![key isKindOfClass:[NSString class]]) {
            //不处理非NSString类型
            return NO;
        }
        NSString *value = [attrs objectForKey:key];
        if (![value isKindOfClass:[NSString class]]) {
            //不处理非NSString类型
            return NO;
        }
        NSData* expendValue = [value dataUsingEncoding:NSUTF8StringEncoding];
        ssize_t writelen = setxattr([path fileSystemRepresentation],
                                    [key UTF8String],
                                    [expendValue bytes],
                                    [expendValue length],
                                    0,
                                    0);
        if (writelen != 0) {
            return NO;
        }
    }
    
    return YES;
}

+ (NSDictionary<NSString *, NSString *> *)expendAttributesForPath:(NSString *)path {
    char list[1024] = {0};
    char name[100] = {0};
    
    ssize_t size = listxattr([path fileSystemRepresentation], list, 1024, 0);
    if (size == 0) {
        return nil;
    }
    char *pAttrList = malloc(1024);
    char *pOriginalAttrList = pAttrList;//防止内存泄漏
    memset(pAttrList, 0, 1024);
    memcpy(pAttrList, list, 1024);
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    for (int i = 0, j = 0; i < size; i ++, j ++) {
        if (list[i] == '\0') {
            memcpy(name, pAttrList, j);
            NSString *key = [NSString stringWithUTF8String:name];
            memset(name, 0, 100);
            pAttrList = pAttrList + j + 1;
            j = -1;//从0开始
            NSString *value = [AELDTools expendAttributeWithKey:key forPath:path];
            if (value) {
                [tempDic setObject:value forKey:key];
            }
        }
    }
    free(pOriginalAttrList);
    pOriginalAttrList = NULL;
    
    if ([tempDic count] == 0) {
        return nil;
    }
    return [tempDic copy];
}

+ (NSString *)expendAttributeWithKey:(NSString *)key forPath:(NSString *)path {
    if (![key isKindOfClass:[NSString class]] || [key length] == 0) {
        return nil;
    }
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        return nil;
    }
    ssize_t readlen = 1024;
    do {
        char buffer[readlen];
        bzero(buffer, sizeof(buffer));
        size_t leng = sizeof(buffer);
        readlen = getxattr([path fileSystemRepresentation],
                           [key UTF8String],
                           buffer,
                           leng,
                           0,
                           0);
        if (readlen < 0){
            return nil;
        }
        else if (readlen > sizeof(buffer)) {
            continue;
        }else{
            NSData *data = [NSData dataWithBytes:buffer length:readlen];
            NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return result;
        }
    } while (YES);
    return nil;
}

@end
