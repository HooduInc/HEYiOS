//
//  EditMsgViewController.h
//  Heya
//
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
//#import "UITableView+Reorder.h"

@interface EditMsgViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    NSString *dropDown1;
    NSString *dropDown2;
    NSString *dropDown3;
    
    BOOL dropDown1Open;
    BOOL dropDown2Open;
    BOOL dropDown3Open;
    BOOL dropDown4Open;
    BOOL dropDown5Open;
    BOOL dropDown6Open;
    BOOL dropDown7Open;
    BOOL dropDown8Open;
    CGFloat animatedDistance;

}

@property (nonatomic, strong) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIScrollView *editMessageListScrollView;
@property (nonatomic, strong) IBOutlet UITableView *editMsgTableView;
@property (nonatomic, strong) IBOutlet UITableView *editMsgTableViewTwo;
@property (nonatomic, strong) IBOutlet UITableView *editMsgTableViewThree;
@property (nonatomic, strong) IBOutlet UITableView *editMsgTableViewFour;

@property (nonatomic, retain) NSMutableArray *cellBgImageArray;
@property (nonatomic, retain) NSMutableArray *menuMessageArray, *editMainMenuMsgArray, *mainArrayWithCategory;
@property (nonatomic, retain) UITextField *mainMenuText;
@property (nonatomic, assign) NSInteger openSectionIndex;


- (IBAction)editMessageListScrollChangePage;
- (IBAction)back:(id)sender;
- (IBAction)SaveDataToDB:(id)sender;
- (IBAction)rearrangeButton:(id)sender;

@end
