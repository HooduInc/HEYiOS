//
//  ChangeColorView.h
//  Heya
//
//  Created by jayantada on 16/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;
@interface ChangeColorView : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDel;
    NSArray *msglist_arr;
}
@property (nonatomic, assign) NSInteger changeIndex, submenuIndex, flag;
@property (strong, nonatomic) NSMutableArray *theme , *themeName, *imageList;
@property (strong, nonatomic) NSArray *brightArray, *standardArray, *oneColorArray,*outLineArray,*mutedArray;
@property (weak, nonatomic) IBOutlet UITableView *colorTable;

- (IBAction)back:(id)sender;
- (IBAction)saveButton:(id)sender;

@end
