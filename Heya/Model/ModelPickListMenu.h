//
//  ModelPickListMenu.h
//  Heya
//
//  Created by jayantada on 25/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelPickListMenu : NSObject

@property(strong,nonatomic) NSString *strPickMenuId;
@property(strong,nonatomic) NSString *strPickMenuName;
@property(strong,nonatomic) NSString *strPickImage;
@property(strong,nonatomic) NSString *strPickMenuOrder;
@property(strong,nonatomic) NSMutableArray *arrPickSubMenu;

@end
