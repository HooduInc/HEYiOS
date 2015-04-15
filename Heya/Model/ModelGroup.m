//
//  ModelGroup.m
//  Heya
//
//  Created by jayantada on 24/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelGroup.h"

@implementation ModelGroup


-(id) init
{
    if(self==[super init])
    {
        self.strGroupId=@"";
        self.strGroupName=@"";
        self.strGroupOrder=@"";
        //self.arrGroupMembers=[NSMutableArray array];
    }
    return self;
}

@end
