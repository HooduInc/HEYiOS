//
//  GroupMemberViewController.h
//  Heya
//
//  Created by jayantada on 31/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>


@interface GroupMemberViewController : UIViewController<UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *groupMemberTableView;
@property (nonatomic, strong) NSMutableArray *groupMemberArray;

@property (nonatomic, strong) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *resignEditGroupButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *editGroupButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupHelpLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupSwipeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *addNewGroupMemberLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtnLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

@property (nonatomic, assign) BOOL isNewGroup;
@property (nonatomic, strong) NSString *clickedGroupId;

- (IBAction)enableGroupNameEditButton:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)addButtonTapped:(id)sender;

@end
