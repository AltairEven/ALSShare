//
//  AELDTools.h
//  AELocalDataKit
//
//  Created by Altair on 30/06/2017.
//  Copyright © 2017 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AELDTools : NSObject

+ (BOOL)setExpendAttributes:(NSDictionary<NSString *, NSString *> *)attrs forPath:(NSString *)path;

+ (NSDictionary<NSString *, NSString *> *)expendAttributesForPath:(NSString *)path;

+ (NSString *)expendAttributeWithKey:(NSString *)key forPath:(NSString *)path;

@end
