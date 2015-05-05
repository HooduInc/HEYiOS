//
//  ModelPickListMenu.m
//  Heya
//
//  Created by jayantada on 25/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelPickListMenu.h"

@implementation ModelPickListMenu


-(id)init
{
    if (self=[super init]) {
        self.strPickMenuId=@"";
        self.strPickMenuName=@"";
        self.strPickImage=@"";
        self.strPickMenuOrder=@"";
        self.isSubMenuOpen=NO;
        self.arrPickSubMenu=[[NSMutableArray alloc] init];
    }
    return self;
}

@end
