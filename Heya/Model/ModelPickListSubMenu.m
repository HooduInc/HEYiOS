//
//  ModelPickListSubMenu.m
//  Heya
//
//  Created by jayantada on 25/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelPickListSubMenu.h"

@implementation ModelPickListSubMenu

-(id)init
{
    if (self=[super init]) {
        self.strPickSubMenuId=@"";
        self.strPickMenuId=@"";
        self.strPickSubMenuName=@"";
        self.strPickSubMenuOrder=@"";
        self.strPickSubMenuFlag=@"";
    }
    return self;
}

@end
