//
//  Pick4mListViewController.h
//  Heya
//
//  Created by jayantada on 27/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Pick4mListViewController : UIViewController
{
    
}

@property (nonatomic,assign) BOOL MainMenuFlag, FlagFromSettings;
@property (nonatomic,strong) NSString *MainMenuDetailsFromPrevious, *SubMenuDetailsFromPrevious;
@property (nonatomic,strong) NSMutableArray *tempPickList;

@end
