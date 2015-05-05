//
//  ModelMenu.m
//  Heya
//
//  Created by jayantada on 04/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ModelMenu.h"

@implementation ModelMenu

-(id)init
{
    if (self=[super init]) {
        self.strMenuColor=@"";
        self.strMenuId=@"";
        self.strMenuName=@"";
        self.strMenuOrder=@"";
        self.strMenuPageNo=@"";
        self.arrSubMenu=[[NSMutableArray alloc] init];
        self.isSubMenuOpen=NO;
        self.isShowSaveBtn=NO;
        self.iscellAddDelBtnPressed=NO;
    }
    return self;
}

@end
