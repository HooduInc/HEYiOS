//
//  ModelSubMenu.m
//  Heya
//
//  Created by jayantada on 04/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelSubMenu.h"

@implementation ModelSubMenu

-(id)init
{
    if (self=[super init]) {
        self.strMenuId=@"";
        self.strSubMenuColor=@"";
        self.strSubMenuId=@"";
        self.strSubMenuName=@"";
        self.strSubMenuOrder=@"";
    }
    return self;
}

@end
