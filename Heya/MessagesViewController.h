//
//  MessagesViewController.h
//  Heya
//
//  Created by Jayanta Karmakar on 17/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AssetsLibrary/AssetsLibrary.h"
#import "AOTag.h"
#import "FbGraph.h"
#import "SBJSON.h"

@class AppDelegate;
@interface MessagesViewController : UIViewController <MFMessageComposeViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,AOTagDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,UIScrollViewDelegate, UITextViewDelegate>
{
    AppDelegate *appDel;
    FbGraph *objFBGraph;
}

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic)  UIImagePickerController *imagePicker;
@property (strong, nonatomic) IBOutlet UIScrollView *contactsScroller;
@property (strong, nonatomic) IBOutlet UILabel *heyFeverLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *editingScrollView;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIScrollView *feviratScroll;
@property (nonatomic, strong) IBOutlet UIScrollView *groupScrollView;
@property (nonatomic, strong) IBOutlet UIButton *smileButtonSelected;
@property (nonatomic, strong) IBOutlet UIView *sendView;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (nonatomic, strong) NSString *getMessageStr;
@property (nonatomic, strong) IBOutlet UIButton *take_photo_btn,*selectPhoto_btn,*smile_btn,*addPhone_btn,*share_btn;


@property (nonatomic, strong) IBOutlet UIView *tagImg1,*tagImg2,*tagImg3,*tagImg4;
@property (nonatomic, strong) NSArray *EMOJI_arr;
@property (nonatomic, strong) NSMutableArray *number_arr, *buttonArray;
@property (nonatomic, strong) NSMutableArray *quickContactsArray, *arrFavData, *arrGroupList, *arrGroupMember;

@property (nonatomic, strong) IBOutlet UIView *contactsContainer;
@property (nonatomic, strong) IBOutlet UIImageView *toPeopleImg;
@property (nonatomic, strong) IBOutlet UILabel *peopleNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *closeButton;


- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)smile:(id)sender;
- (IBAction)addPhone:(id)sender;
- (IBAction)shareHey:(id)sender;
- (IBAction)sendsms:(id)sender;
- (IBAction)whatsApp:(id)sender;
- (IBAction)getcontacts:(id)sender;
- (IBAction)back:(id)sender;

- (IBAction)gotoFevoriteViewController:(id)sender;
- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)editGroupButtonTapped:(id)sender;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

@end
