//
//  ModelSubscription.m
//  Hey
//
//  Created by jayantada on 11/06/15.
//  Copyright (c) 2015 Palash Das. All rights reserved.
//

#import "ModelSubscription.h"

@implementation ModelSubscription



-(id) init
{
    if (self=[super init])
    {
        self.strSubscriptionId=@"";
        self.strDeviceUDID=@"";
        self.strPurchaseTime=@"";
        self.purchaseState=0;
        self.strPurchaseToken=@"";
    }
    return self;

}
@end
