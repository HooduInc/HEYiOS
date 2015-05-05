//
//  ModelMenu.h
//  Heya
//
//  Created by jayantada on 04/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelMenu : NSObject

@property(strong,nonatomic) NSString *strMenuId;
@property(strong,nonatomic) NSString *strMenuName;
@property(strong,nonatomic) NSString *strMenuOrder;
@property(strong,nonatomic) NSString *strMenuColor;
@property(strong,nonatomic) NSString *strMenuPageNo;
@property(strong,nonatomic) NSMutableArray *arrSubMenu;
@property(assign,nonatomic) BOOL isSubMenuOpen;
@property(assign,nonatomic) BOOL isShowSaveBtn;
@property(assign,nonatomic) BOOL iscellAddDelBtnPressed;
@end
