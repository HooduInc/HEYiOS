//
//  FevoriteViewController.h
//  Heya
//
//  Created by Jayanta Karmakar on 12/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import <QuartzCore/QuartzCore.h>

@interface FevoriteViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>{
    
}

@property (nonatomic, retain) NSMutableArray *number_arr;
@property (nonatomic, strong) NSMutableArray *arrContactsData;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

@property (nonatomic, retain) IBOutlet UITableView *fevoriteList_table;
@property (nonatomic, retain) NSMutableArray *fevoritelist_array,*alphabetArray;
@property (strong, nonatomic) IBOutlet UIImageView *testingImage;
@property (nonatomic, retain) IBOutlet UIButton *saveBtn;

- (IBAction)getcontacts:(id)sender;
- (IBAction)back:(id)sender;


typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);
@end
