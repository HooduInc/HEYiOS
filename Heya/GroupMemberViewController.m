//
//  GroupMemberViewController.m
//  Heya
//
//  Created by jayantada on 31/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "GroupMemberViewController.h"
#import "GroupViewController.h"
#import "GroupMemberTableViewCell.h"
#import "ModelGroup.h"
#import "ModelGroupMembers.h"
#import "MBProgressHUD.h"


#import "KBContactsSelectionViewController.h"
#import "APContact.h"
#import "APPhoneWithLabel.h"

@import Photos;

@interface GroupMemberViewController ()<GroupMemberTableViewCellDelegate,UITextFieldDelegate,UIAlertViewDelegate,KBContactsSelectionViewControllerDelegate>
{
    MBProgressHUD *HUD;
    NSIndexPath *selectedIndexPath;
    UIAlertView *saveAlert;
    BOOL cellDeleteStatus;
    NSMutableArray *multipleContactNoArray;
    UIImage *contactImageFromAddressBook;
    
    IBOutlet UIView *groupView;
    IBOutlet UIView *displayGroupImageView;
}

@property (weak) KBContactsSelectionViewController* presentedCSVC;

@end

@implementation GroupMemberViewController
NSMutableDictionary *contactInfoDict;

@synthesize groupNameTextField, addNewGroupMemberLabel, groupHelpLabel, groupSwipeTextLabel;
@synthesize clickedGroupId, isNewGroup;
@synthesize groupMemberTableView, groupMemberArray;



#pragma mark
#pragma  mark ViewController Initialization
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    saveAlert=[[UIAlertView alloc] initWithTitle:nil message:@"Saved Successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    groupView.layer.cornerRadius = groupView.frame.size.width / 2;
    groupView.clipsToBounds = YES;
    groupView.layer.borderColor=[UIColor colorWithRed:208/255.0f green:208/255.0f  blue:211/255.0f  alpha:1].CGColor;
    groupView.layer.borderWidth=1.0f;
    
    int photolibaryAccessStatus = [self AssetLibraryAuthStatus];
    
    if (photolibaryAccessStatus==0 || photolibaryAccessStatus==1 || photolibaryAccessStatus==4)
    {
        [self alertStatus:@"Privacy Warning!" :@"Permission was not granted for photos.\nTip: Go to settings->Hey and allow photos."];
    }
    [self PHAssetAuthStatus];
}

-(void) viewWillAppear:(BOOL)animated
{
    [groupMemberTableView setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
    
    self.addBtnLabel.userInteractionEnabled=YES;
    groupNameTextField.userInteractionEnabled=NO;
    if(clickedGroupId.length==0 && isNewGroup==YES)
    {
        self.saveBtn.hidden=NO;
        groupMemberTableView.hidden = YES;
        groupHelpLabel.hidden = NO;
        groupSwipeTextLabel.hidden=YES;
        groupNameTextField.userInteractionEnabled=YES;
        [groupNameTextField becomeFirstResponder];
        
        //displayGroupImageView.hidden=NO;
        //groupView.hidden=YES;
        
    }
    else
    {
        
        NSLog(@"Clicked GroupID: %@",clickedGroupId);
        NSMutableArray *groupDetailsArray=[[NSMutableArray alloc] init];
        groupDetailsArray=[DBManager fetchDataFromGroupWithGroupId:clickedGroupId];

        
        ModelGroup *objGroup=[groupDetailsArray objectAtIndex:0];
        self.groupNameTextField.text = objGroup.strGroupName;
        
        [self.view addSubview:HUD];
        [HUD show:YES];
        
        [self fetchGroupMembersAndRefresh];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark
#pragma  mark Tableview Delegate
#pragma mark

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (groupMemberArray.count>0)
    {
        NSLog(@"No. of Members: %ld",(long)[groupMemberArray count]);
        return [groupMemberArray count];
    }
    else
        return 0;
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *tableIdentfier = @"GroupMemberTableCell";
    GroupMemberTableViewCell *cell = (GroupMemberTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentfier];
    
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"GroupMemberTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.delegate=self;
    ModelGroupMembers *objMember = [groupMemberArray objectAtIndex:indexPath.row];
    cell.groupMemberName.text =[NSString stringWithFormat:@"%@ %@",objMember.strFirstName, objMember.strLastName];
    cell.groupMemberName.tag=[objMember.strMemberId intValue];
    
    if([objMember.strProfileImage isEqualToString:@"man_icon.png"])
    {
        cell.profileImg.image = [UIImage imageNamed:objMember.strProfileImage];
    }
    else
    {
        NSString *str = objMember.strProfileImage;
        //NSLog(@"ImageURL: %@",str);
        
        //ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        NSURL *myAssetUrl = [NSURL URLWithString:str];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            @autoreleasepool {
                CGImageRef iref = [rep fullScreenImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.profileImg.image=image;
                    });
                    iref = nil;
                }
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:myAssetUrl resultBlock:resultblock failureBlock:failureblock];
        
    }
    
    return cell;
    
    
}


#pragma mark
#pragma mark - SwipeableCellDelegate
#pragma mark

- (void)buttonDeleteActionForItemText:(id)sender
{
    GroupMemberTableViewCell *cellGroup=(GroupMemberTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[groupMemberTableView indexPathForCell:cellGroup];
    
    cellDeleteStatus=YES;
    selectedIndexPath=nil;
    
    ModelGroupMembers *selectedGroupObj = [groupMemberArray objectAtIndex:indexPath.row];
    
    if (selectedGroupObj)
    {
        NSLog(@"ProfileImage URL:%@",selectedGroupObj.strProfileImage);
        
        if([selectedGroupObj.strProfileImage containsString:@"assets-library:"])
        {
            float currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            NSLog(@"currentVersion: %f",currentVersion);
            
            NSURL *photosUrl=[NSURL URLWithString:selectedGroupObj.strProfileImage];
            __block NSArray *arrphotosUrl=[NSArray arrayWithObjects:photosUrl, nil];
            
            if (currentVersion>=8.0)
            {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                    PHFetchResult *assetsToBeDeleted = [PHAsset fetchAssetsWithALAssetURLs:arrphotosUrl options:nil];
                    [PHAssetChangeRequest deleteAssets:assetsToBeDeleted];
                } completionHandler:^(BOOL success, NSError *error) {
                    
                    
                    if (success)
                    {
                        NSLog(@"Deleted from assets library.");
                    }
                    else
                    {
                        NSLog(@"Problem in deleting asset. %@", error);
                    }
                    NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cellGroup.groupMemberName.text);
                    BOOL isDeleted=[DBManager deleteGroupMemberWithMemberId:[NSString stringWithFormat:@"%ld",(long)cellGroup.groupMemberName.tag]];
                    
                    if(isDeleted)
                    {
                        [self fetchGroupMembersAndRefresh];
                    }
                }];
                
            }
            else
            {
                NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cellGroup.groupMemberName.text);
                BOOL isDeleted=[DBManager deleteGroupMemberWithMemberId:[NSString stringWithFormat:@"%ld",(long)cellGroup.groupMemberName.tag]];
                
                if(isDeleted)
                {
                    [self fetchGroupMembersAndRefresh];
                }
            }
        }
        else
        {
            //NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cell.nameLabelText.text);
            NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cellGroup.groupMemberName.text);
            BOOL isDeleted=[DBManager deleteGroupMemberWithMemberId:[NSString stringWithFormat:@"%ld",(long)cellGroup.groupMemberName.tag]];
            
            if(isDeleted)
            {
                [self fetchGroupMembersAndRefresh];
            }
        }
    }
  
}

#pragma mark
#pragma  mark IBAction Methods
#pragma mark

- (IBAction)enableGroupNameEditButton:(id)sender
{
    
    if ([sender tag] == 0)
    {
        self.saveBtn.hidden=NO;
        groupNameTextField.userInteractionEnabled=YES;
        [groupNameTextField becomeFirstResponder];
        self.editGroupButtonLabel.hidden=YES;
        self.resignEditGroupButtonLabel.hidden=NO;
        self.addBtnLabel.userInteractionEnabled=NO;
    }
    
    if ([sender tag] == 1)
    {
        self.saveBtn.hidden=YES;
        [groupNameTextField resignFirstResponder];
        groupNameTextField.userInteractionEnabled=NO;
        self.editGroupButtonLabel.hidden=NO;
        self.resignEditGroupButtonLabel.hidden=YES;
        self.addBtnLabel.userInteractionEnabled=YES;
    }
    
}

- (IBAction)saveButtonTapped:(id)sender
{
    if ([self.groupNameTextField.text length] == 0)
    {
        [self alertStatus:@"Please enter group name to add members." :nil ];
        
    }
    else
    {
        groupNameTextField.userInteractionEnabled=NO;
        self.addBtnLabel.userInteractionEnabled=YES;
        [groupNameTextField resignFirstResponder];
        if (clickedGroupId.length>0)
        {
            if (![DBManager checkGroupNameExistsinGroupTable:groupNameTextField.text])
            {
                BOOL isUpdated= [DBManager updateGroupNameWithGroupId:clickedGroupId withGroupName:groupNameTextField.text];
                
                if (isUpdated==YES)
                    [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self alertStatus:@"Group name already exists." :nil ];
            }
        }
        else
        {
            if (![DBManager checkGroupNameExistsinGroupTable:groupNameTextField.text])
            {
                long long insertID = [DBManager insertGroup:groupNameTextField.text];
                if (insertID!=0)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else
            {
                [self alertStatus:@"Group name already exists." :nil ];
            }
        }
    }
}

- (IBAction)addButtonTapped:(id)sender
{
    if ([groupNameTextField.text length] == 0)
    {
        [self alertStatus:@"Please enter group name to add members." :nil ];
        
    }
    else
    {
        if([clickedGroupId isEqualToString:@""] || [clickedGroupId length]==0)
        {
            //don't do anything
        }
        else
        {
            __block KBContactsSelectionViewController *vc = [KBContactsSelectionViewController contactsSelectionViewControllerWithConfiguration:^(KBContactsSelectionConfiguration *configuration) {
                configuration.shouldShowNavigationBar = YES;
                configuration.tintColor = [UIColor colorWithRed:11.0/255 green:211.0/255 blue:24.0/255 alpha:1];
                configuration.title = @"All Contacts";
                configuration.selectButtonTitle = @"";
                
                //configuration.mode = KBContactsSelectionModeMessages | KBContactsSelectionModeEmail;
                configuration.mode = KBContactsSelectionModeMessages;
                configuration.skipUnnamedContacts = YES;
                configuration.customSelectButtonHandler = ^(NSArray * contacts) {
                    //NSLog(@"%@", contacts);
                };
                /*configuration.contactEnabledValidation = ^(id contact) {
                 APContact * _c = contact;
                 if ([_c phonesWithLabels].count > 0) {
                 
                 NSString * phone = ((APPhoneWithLabel*) _c.phonesWithLabels[0]).phone;
                 if ([phone containsString:@"888"]) {
                 return NO;
                 }
                 }
                 return YES;
                 };*/
            }];
            [vc setDelegate:self];
            [self presentViewController:vc animated:YES completion:NULL];
            //[self.navigationController pushViewController:vc animated:YES];
            
            self.presentedCSVC = vc;
            
            __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 24)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"Select people you want to text";
            
            vc.additionalInfoView = label;
            
            /*addressBookController = [[ABPeoplePickerNavigationController alloc] init];
            [addressBookController setPeoplePickerDelegate:self];
            [self presentViewController:addressBookController animated:YES completion:nil];*/
        }
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KBContactsSelectionViewControllerDelegate
- (void) contactsSelection:(KBContactsSelectionViewController*)selection didSelectContact:(APContact *)contact {
    
    __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@ Selected", @(self.presentedCSVC.selectedContacts.count)];
    
    self.presentedCSVC.additionalInfoView = label;
    
    NSLog(@"Selected Contact: %@", self.presentedCSVC.selectedContacts);
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (self.presentedCSVC.selectedContacts.count>0)
    {
        APContact *selectedContact =[self.presentedCSVC.selectedContacts firstObject];
        multipleContactNoArray=[NSMutableArray array];
        
        if (selectedContact)
        {
            
            ModelGroupMembers *objMember=[[ModelGroupMembers alloc] init];
            
            objMember.strGroupId=clickedGroupId;
            
            if(selectedContact.firstName)
                objMember.strFirstName=selectedContact.firstName;
            else
                objMember.strFirstName=@"";
            if(selectedContact.lastName)
                objMember.strLastName=selectedContact.lastName;
            else
                objMember.strLastName=@"";
            objMember.strMobileNumber=[[selectedContact.phonesWithLabels firstObject] phone];
            objMember.strHomePhone=[[selectedContact.phonesWithLabels firstObject] phone];
            
            
            
            [self.view addSubview:HUD];
            [HUD show:YES];
            if (selectedContact.thumbnail)
            {
                int photolibaryAccessStatus = [self AssetLibraryAuthStatus];
                
                if (photolibaryAccessStatus==3)
                {
                    __block NSString *imageURL =@"";
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeImageToSavedPhotosAlbum:[selectedContact.thumbnail CGImage] orientation:(ALAssetOrientation)[selectedContact.thumbnail imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
                     {
                         if (error)
                         {
                             [HUD hide:YES];
                             [HUD removeFromSuperview];
                             NSLog(@"Fetch Error: %@",error);
                             objMember.strProfileImage=@"man_icon.png";
                         }
                         else
                         {
                             imageURL = [assetURL absoluteString];
                             //NSLog(@"imageURL url %@", imageURL);
                             objMember.strProfileImage=imageURL;
                         }
                         [self insertGroupMemberWithGroupMemObj:objMember];
                     }];
                }
                else
                {
                    objMember.strProfileImage=@"man_icon.png";
                    [self insertGroupMemberWithGroupMemObj:objMember];
                }
            }
            else
            {
                objMember.strProfileImage=@"man_icon.png";
                [self insertGroupMemberWithGroupMemObj:objMember];
            }
        }
        else
        {
            [self alertStatus:nil :@"Failed to fetch the contact details. Please try again."];
        }
    }
    
    else
    {
        [self alertStatus:nil :@"Failed to fetch the contact details. Please try again."];
    }
    
}

- (void) contactsSelection:(KBContactsSelectionViewController*)selection didRemoveContact:(APContact *)contact {
    
    __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@ Selected", @(self.presentedCSVC.selectedContacts.count)];
    self.presentedCSVC.additionalInfoView = label;
    
    NSLog(@"%@", self.presentedCSVC.selectedContacts);
}

- (void)contactsSelectionWillLoadContacts:(KBContactsSelectionViewController *)csvc
{
//    HUD.labelText = @"Loading Contacts";
//    [self.view addSubview:HUD];
//    [HUD show:YES];
}
- (void)contactsSelectionDidLoadContacts:(KBContactsSelectionViewController *)csvc
{
//    [HUD hide:YES];
//    [HUD removeFromSuperview];
}



#pragma mark
#pragma  mark TextField Delegate Methods
#pragma mark


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma  mark Other Helper Methods
#pragma mark

- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

-(id)getSuperviewOfType:(id)superview fromView:(id)myView
{
    if ([myView isKindOfClass:[superview class]]) {
        return myView;
    }
    else
    {
        id temp=[myView superview];
        while (1) {
            if ([temp isKindOfClass:[superview class]]) {
                return temp;
            }
            temp=[temp superview];
        }
    }
    return nil;
}
-(void) hideAlertView
{
    [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void) insertGroupMemberWithGroupMemObj:(ModelGroupMembers*)objMember
{
    
    BOOL exists=[DBManager checkGroupMembersExistsinGroupTable:objMember.strMobileNumber groupID:clickedGroupId];
    
    if(!exists)
    {
        NSMutableArray *memberInsertArray=[[NSMutableArray alloc] init];
        [memberInsertArray addObject:objMember];
        
        long long insertId= [DBManager insertGroupMember:memberInsertArray];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if (insertId>0)
        {
            
            [saveAlert show];
            [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
            
            [self fetchGroupMembersAndRefresh];
        }
    }
    else
    {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        [self alertStatus:@"Already exists." :nil];
    }
}

-(void) fetchGroupMembersAndRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //Mostly Coding Part
        groupMemberArray = [NSMutableArray array];
        groupMemberArray = [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
        
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            
            //Mostly UI Updates
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            self.saveBtn.hidden=YES;
            groupNameTextField.userInteractionEnabled=NO;
            groupMemberTableView.hidden = NO;
            groupHelpLabel.hidden = YES;
            groupSwipeTextLabel.hidden=NO;
            [groupMemberTableView reloadData];
        });
    });
    
}

-(void)noOfViews:(NSMutableArray *)imageURLArray
{
    int num=(int)[imageURLArray count];
    
    NSLog(@"imageURLArray count: %ld",(long)[imageURLArray count]);
    
    if (num==1)
    {
        UIImageView *One=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, groupView.frame.size.width, groupView.frame.size.height)];
        [One setBackgroundColor:[UIColor grayColor]];
        
        NSString *imageURL=[imageURLArray objectAtIndex:0];
        
        NSLog(@"ImageURL :%@",imageURL);
        if ([imageURL isEqualToString:@"man_icon.png"])
        {
            [One setImage:[UIImage imageNamed:@"man_icon.png"]];
        }
        else
        {
            NSURL *myAssetUrl = [NSURL URLWithString:imageURL];
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
            {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                @autoreleasepool {
                    CGImageRef iref = [rep fullScreenImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [One setImage:image];
                            [groupView addSubview:One];
                        });
                        iref = nil;
                    }
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
            {
                NSLog(@"Can't get image - %@",[myerror localizedDescription]);
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:myAssetUrl resultBlock:resultblock failureBlock:failureblock];
            
        }
        
    }
    
    else if (num==2)
    {
        UIImageView *One=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, groupView.frame.size.width, groupView.frame.size.height)];
        [One setBackgroundColor:[UIColor grayColor]];
        
        NSString *imageURL1=[imageURLArray objectAtIndex:0];
        
        if ([imageURL1 isEqualToString:@"man_icon.png"])
            [One setImage:[UIImage imageNamed:@"man_icon.png"]];
        
        else
        {
            NSURL *myAssetUrl = [NSURL URLWithString:imageURL1];
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
            {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                @autoreleasepool {
                    CGImageRef iref = [rep fullScreenImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [One setImage:image];
                        });
                        iref = nil;
                    }
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
            {
                NSLog(@"Can't get image - %@",[myerror localizedDescription]);
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:myAssetUrl resultBlock:resultblock failureBlock:failureblock];
        }
        [groupView addSubview:One];
        
        UIImageView *Two=[[UIImageView alloc] initWithFrame:CGRectMake(groupView.frame.size.width/2, 0, groupView.frame.size.width*8, groupView.frame.size.height*8)];
        [Two setBackgroundColor:[UIColor grayColor]];
        
        NSString *imageURL2=[imageURLArray objectAtIndex:1];
        NSLog(@"imageURL2 :%@",imageURL2);
        
        if ([imageURL2 isEqualToString:@"man_icon.png"])
        {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"pic_man_icon" ofType:@"png"];
            UIImage *existingImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
            
            // Create new image context (retina safe)
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(existingImage.size.width, existingImage.size.height), NO, [UIScreen mainScreen].scale);
            
            // Create rect for image
            CGRect rect = CGRectMake(0, 0, groupView.frame.size.width, groupView.frame.size.height);
            
            // Draw the image into the rect
            [existingImage drawInRect:rect];
            
            // Saving the image, ending image context
            UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [Two setImage:newImage];
            [groupView addSubview:Two];
        }
        else
        {
            NSURL *myAssetUrl = [NSURL URLWithString:imageURL2];
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
            {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                @autoreleasepool {
                    CGImageRef iref = [rep fullScreenImage];
                    if (iref) {
                        UIImage *image = [UIImage imageWithCGImage:iref];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Create new image context (retina safe)
                            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, [UIScreen mainScreen].scale);
                            
                            // Create rect for image
                            CGRect rect = CGRectMake(0, 0, groupView.frame.size.width, groupView.frame.size.height);
                            
                            // Draw the image into the rect
                            [image drawInRect:rect];
                            
                            // Saving the image, ending image context
                            UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
                            UIGraphicsEndImageContext();
                            
                            [Two setImage:newImage];
                            
                            [groupView addSubview:Two];
                        });
                        iref = nil;
                    }
                }
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
            {
                NSLog(@"Can't get image - %@",[myerror localizedDescription]);
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:myAssetUrl resultBlock:resultblock failureBlock:failureblock];
        }
        
    }
}


#pragma mark AssetLibrary Authorization Status

-(int)AssetLibraryAuthStatus
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status)
    {
        case ALAuthorizationStatusRestricted:
            return 0;
            
        case ALAuthorizationStatusDenied:
            return 1;
            
        case ALAuthorizationStatusNotDetermined:
            return 2;
            
        case ALAuthorizationStatusAuthorized:
            return 3;
            
            
        default:
            return 4;
    }
}

#pragma mark PHAsset Authorization Status

-(void)PHAssetAuthStatus

{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
    }
    
    else if (status == PHAuthorizationStatusNotDetermined)
    {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
            }
            
            else {
                // Access has been denied.
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}

@end
