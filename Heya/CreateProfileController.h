//
//  EditProfileController.h
//  Heya
//
//  Created by jayantada on 30/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CreateProfileController :UIViewController<UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    CGFloat animatedDistance;
}

@property (strong, nonatomic) IBOutlet UIView *onlyForDisplayView;
@property (weak, nonatomic) IBOutlet UILabel *HeyNameDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *FirstNameDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *NumberDisplayLabel;
@property (strong, nonatomic) IBOutlet UIImageView *onlyDisplayprofileImage;



@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *FirstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *heyName;
@property (strong, nonatomic) IBOutlet UITextField *ContactNo;

@property (strong, nonatomic) IBOutlet UIButton *saveBtnLabel;
@property (strong, nonatomic) IBOutlet UIButton *editBtnLabel;
@property (strong, nonatomic) IBOutlet UIButton *addContactBtnLabel;

@property (strong, nonatomic) IBOutlet UIImageView *callIcon;


@property (nonatomic, strong) IBOutlet UIView *contactsContainer;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (nonatomic, strong) NSMutableArray *quickContactsArray;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

- (IBAction)back:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)getContacts:(id)sender;
@end
