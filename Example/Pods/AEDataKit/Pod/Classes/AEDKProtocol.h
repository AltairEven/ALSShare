//
//  AEDKProtocol.h
//  Pods
//
//  Created by Altair on 14/09/2017.
//
//

#import <Foundation/Foundation.h>


@class AEDKService;

@protocol AEDKProtocol <NSObject>

@required

- (AEDKService *)dataService;

@end
