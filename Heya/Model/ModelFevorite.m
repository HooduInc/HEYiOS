//
//  ModelFevorite.m
//  Heya
//
//  Created by jayantada on 24/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelFevorite.h"

@implementation ModelFevorite


-(id)init
{
    if(self==[super init])
    {
        self.strFevoriteId=@"";
        self.strFirstName=@"";
        self.strLastName=@"";
        self.strFevoriteId=@"";
        self.strMobNumber=@"";
        self.strHomeNumber=@"";
        self.strProfileImage=@"";
        self.strFavouriteOrder=@"";
    }
    return self;
}
@end
