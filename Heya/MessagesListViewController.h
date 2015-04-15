//
//  MessagesListViewController.h
//  Heya
//
//  Created by Jayanta Karmakar on 13/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <stdio.h>

@class AppDelegate;
@interface MessagesListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *menulistTable;
@property (nonatomic, retain) IBOutlet UITableView *menulistTableTwo;
@property (nonatomic, retain) IBOutlet UITableView *menulistTableThree;
@property (nonatomic, retain) IBOutlet UITableView *menulistTableFour;
@property (nonatomic, strong) IBOutlet UIScrollView *messageListScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl* pageControl;
@end
