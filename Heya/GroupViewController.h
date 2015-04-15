//
//  GroupViewController.h
//  Heya
//
//  Created by jayantada on 30/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewController : UIViewController< UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *groupTableView;
@property (nonatomic, strong) IBOutlet UIView *addGroupView;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSMutableArray *groupListArray;

- (IBAction)addGroupButtonTapped:(id)sender;

@end
