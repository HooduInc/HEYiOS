//
//  ModelMessageSend.m
//  Heya
//
//  Created by jayantada on 04/05/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelMessageSend.h"

@implementation ModelMessageSend

-(id)init
{
    if (self==[super init])
    {
        self.strMessageInsertId=@"";
        self.strtemplateId=@"";
        self.strDeviceId=@"";
        self.strMessageText=@"";
        self.strFrom=@"";
        self.strTo=@"";
        self.strSendDate=@"";
        self.points=0;
        self.isPushedToServer=0;
    }
    return self;
}

@end
