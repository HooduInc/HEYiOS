//
//  ModelSubscription.h
//  Hey
//
//  Created by jayantada on 11/06/15.
//  Copyright (c) 2015 Palash Das. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelSubscription : NSObject
@property(strong,nonatomic) NSString *strSubscriptionId;
@property(strong,nonatomic) NSString *strDeviceUDID;
@property(strong,nonatomic) NSString *strPurchaseTime;
@property(assign,nonatomic) int purchaseState;
@property(strong,nonatomic) NSString *strPurchaseToken;

@end
