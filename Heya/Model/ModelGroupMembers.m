//
//  ModelGroupMembers.m
//  Heya
//
//  Created by jayantada on 02/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelGroupMembers.h"

@implementation ModelGroupMembers

-(id) init
{
    if(self==[super init])
    {
        self.strMemberId=@"";
        self.strGroupId=@"";
        self.strFirstName=@"";
        self.strLastName=@"";
        self.strMobileNumber=@"";
        self.strHomePhone=@"";
        self.strProfileImage=@"";
        self.strMemberOrder=@"";
    }
    return self;
}

@end
