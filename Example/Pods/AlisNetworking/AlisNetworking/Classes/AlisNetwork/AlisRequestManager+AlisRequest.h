//
//  AlisRequestManager+AlisRequest.h
//  PluginsDemo
//
//  Created by alisports on 2017/3/24.
//  Copyright © 2017年 alisports. All rights reserved.
//

#import "AlisRequestManager.h"

@interface AlisRequestManager (AlisRequest)

- (AlisRequest *)adapteAlisRequest:(AlisRequest *)request requestModel:(id<AlisRequestProtocol>)requestModel service:(AlisService *)service;

@end
