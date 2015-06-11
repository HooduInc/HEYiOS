//
//  ModelUserProfile.m
//  Heya
//
//  Created by jayantada on 12/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelUserProfile.h"

@implementation ModelUserProfile

-(id)init
{
    if (self=[super init])
    {
        self.strProfileId=@"";
        self.strFirstName=@"";
        self.strLastName=@"";
        self.strHeyName=@"";
        self.strPhoneNo=@"";
        self.strDeviceUDID=@"";
        self.strProfileImage=@"";
        self.strCurrentTimeStamp=@"";
        self.strAccountCreated=@"";
        self.isSendToServer=0;
        self.isRegistered=0;
    }
    return self;
}
@end
