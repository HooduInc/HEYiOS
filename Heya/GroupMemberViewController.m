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

@interface GroupMemberViewController ()<GroupMemberTableViewCellDelegate,UITextFieldDelegate,UIAlertViewDelegate>
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
@end

@implementation GroupMemberViewController
NSMutableDictionary *contactInfoDict;

@synthesize groupNameTextField, addNewGroupMemberLabel, groupHelpLabel, addressBookController, groupSwipeTextLabel;
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
            
            //Mostly Coding Part
            [self.view addSubview:HUD];
            [HUD show:YES];
            groupMemberArray = [[NSMutableArray alloc]init];
            groupMemberArray = [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
            dispatch_async(dispatch_get_main_queue(), ^{ // 2
                
                //Mostly UI Updates
                if (groupMemberArray.count>0)
                {
                    self.saveBtn.hidden=YES;
                    groupNameTextField.userInteractionEnabled=NO;
                    groupMemberTableView.hidden = NO;
                    groupHelpLabel.hidden = YES;
                    groupSwipeTextLabel.hidden=NO;
                    
                    //displayGroupImageView.hidden=YES;
                    //groupView.hidden=NO;
                }
                
                [groupMemberTableView reloadData];
                [HUD hide:YES];
                [HUD removeFromSuperview];
            });
        });

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
        NSLog(@"ImageURL: %@",str);
        
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
#pragma  mark PeoplePicker Delegate
#pragma mark

//Works from IOS 8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    multipleContactNoArray=[[NSMutableArray alloc] init];
    
    // Initialize a mutable dictionary and give it initial values.
    contactInfoDict = [[NSMutableDictionary alloc]
                       initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                       forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    
    [contactInfoDict setObject:clickedGroupId forKey:@"groupId"];
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if ([(NSString *)kABPersonPhoneMainLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        //If Phone Number doesn't exists in kABPersonPhoneMainLabel
        if ([(NSString *)kABPersonPhoneMobileLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        //If Phone Number doesn't exists in kABPersonPhoneMobileLabel
        if ([(NSString *)kABPersonPhoneIPhoneLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        
        //If Phone Number doesn't exists in kABPersonIPhoneLabel
        if ([(NSString *)kABHomeLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        //If Phone Number doesn't exists in kABHomeLabel
        if ([(NSString *)kABWorkLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        //If Phone Number doesn't exists in kABWorkLabel
        if ([(NSString *)kABOtherLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
        {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
        }
        
        
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    
    NSLog(@"Contact Dictionary: %@", contactInfoDict);
    CFRelease(phonesRef);
    
    
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person))
    {
        
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        contactImageFromAddressBook = [UIImage imageWithData:contactImageData];
        
        if (multipleContactNoArray.count>1)
        {
            UIAlertView *alertContactDialog=[[UIAlertView alloc] initWithTitle:@"Select Contact" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            
            for(NSString *buttonTitle in multipleContactNoArray)
                [alertContactDialog addButtonWithTitle:buttonTitle];
            [addressBookController dismissViewControllerAnimated:YES completion:nil];
            [alertContactDialog show];
            
        }
        else
            [self insertGroupMember];
        
    }
    
    else
    {
        contactImageFromAddressBook=nil;
        [contactInfoDict setObject:@"man_icon.png" forKey:@"image"];
        
        if (multipleContactNoArray.count>1)
        {
            UIAlertView *alertContactDialog=[[UIAlertView alloc] initWithTitle:@"Select Contact" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            
            for(NSString *buttonTitle in multipleContactNoArray)
                [alertContactDialog addButtonWithTitle:buttonTitle];
            [addressBookController dismissViewControllerAnimated:YES completion:nil];
            [alertContactDialog show];
        }
        else
            [self insertGroupMember];
    }
    
}

#pragma mark
#pragma mark - SwipeableCellDelegate
#pragma mark

- (void)buttonDeleteActionForItemText:(id)sender
{
    GroupMemberTableViewCell *cellGroup=(GroupMemberTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    //NSIndexPath *indexPath=[groupMemberTableView indexPathForCell:cellGroup];
    cellDeleteStatus=YES;
    selectedIndexPath=nil;
    
    NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cellGroup.groupMemberName.text);
    BOOL isDeleted=[DBManager deleteGroupMemberWithMemberId:[NSString stringWithFormat:@"%ld",(long)cellGroup.groupMemberName.tag]];
     
     if(isDeleted)
     {
         groupMemberArray= [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
         [groupMemberTableView reloadData];
     }
    
}


#pragma mark
#pragma mark AlertView Delegate Methods
#pragma mark

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
    {
        NSLog(@"Selected Contact: %@", [alertView buttonTitleAtIndex:buttonIndex]);
        
        [contactInfoDict setObject:[alertView buttonTitleAtIndex:buttonIndex] forKey:@"mobileNumber"];
        
        [self.view addSubview:HUD];
        [HUD show:YES];
        [self insertGroupMember];
        
//        BOOL exists=[DBManager checkGroupMembersExistsinGroupTable:[alertView buttonTitleAtIndex:buttonIndex] groupID:clickedGroupId];
//        
//        if(!exists)
//        {
//            
//        }
//        else
//        {
//            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alert show];
//        }
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
                long long insertID= [DBManager insertGroup:groupNameTextField.text];
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
            addressBookController = [[ABPeoplePickerNavigationController alloc] init];
            [addressBookController setPeoplePickerDelegate:self];
            [self presentViewController:addressBookController animated:YES completion:nil];
        }
    }
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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


-(void) insertGroupMember
{
    if (contactImageFromAddressBook)
    {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[contactImageFromAddressBook CGImage] orientation:(ALAssetOrientation)[contactImageFromAddressBook imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error)
             {
                 NSLog(@"error: %@",error);
             }
             else
             {
                 
                 NSString *urlString = [assetURL absoluteString];
                 //NSLog(@"url %@", urlString);
                 [contactInfoDict setObject:urlString forKey:@"image"];
                 NSLog(@"contactInfoDict: %@",contactInfoDict);
                 
                 ModelGroupMembers *objMember=[[ModelGroupMembers alloc] init];
                 
                 objMember.strGroupId=[contactInfoDict valueForKey:@"groupId"];
                 objMember.strFirstName=[contactInfoDict valueForKey:@"firstName"];
                 objMember.strLastName=[contactInfoDict valueForKey:@"lastName"];
                 objMember.strMobileNumber=[contactInfoDict valueForKey:@"mobileNumber"];
                 objMember.strHomePhone=[contactInfoDict valueForKey:@"homeNumber"];
                 objMember.strProfileImage=[contactInfoDict valueForKey:@"image"];
                 
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
                         
                         groupMemberArray = [[NSMutableArray alloc] init];
                         groupMemberArray = [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
                         
                         self.saveBtn.hidden=YES;
                         groupNameTextField.userInteractionEnabled=NO;
                         groupMemberTableView.hidden = NO;
                         groupHelpLabel.hidden = YES;
                         groupSwipeTextLabel.hidden=NO;
                         [groupMemberTableView reloadData];
                         
                         /*if (groupMemberArray.count==1)
                         {
                             ModelGroupMembers *obj=[groupMemberArray objectAtIndex:0];
                             
                             if (obj.strProfileImage && obj.strProfileImage.length>0)
                             {
                                 NSMutableArray *imageUrlArr=[[NSMutableArray alloc] init];
                                 [imageUrlArr addObject:obj.strProfileImage];
                                 [self noOfViews:imageUrlArr];
                             }
                         }
                         else if (groupMemberArray.count==2)
                         {
                             NSMutableArray *imageUrlArr=[[NSMutableArray alloc] init];
                             for (int i=0; i<groupMemberArray.count; i++)
                             {
                                 ModelGroupMembers *obj=[groupMemberArray objectAtIndex:i];
                                 
                                 if (obj.strProfileImage && obj.strProfileImage.length>0)
                                     [imageUrlArr addObject:obj.strProfileImage];
                             }
                             [self noOfViews:imageUrlArr];
                         }*/
                     }
                 }
                 else
                 {
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     [self alertStatus:@"Already exists." :nil];
                 }
             }
         }];
    }
    else
    {
        [contactInfoDict setObject:@"man_icon.png" forKey:@"image"];
        NSLog(@"contactInfoDict: %@",contactInfoDict);
        
        ModelGroupMembers *objMember=[[ModelGroupMembers alloc] init];
        
        objMember.strGroupId=[contactInfoDict valueForKey:@"groupId"];
        objMember.strFirstName=[contactInfoDict valueForKey:@"firstName"];
        objMember.strLastName=[contactInfoDict valueForKey:@"lastName"];
        objMember.strMobileNumber=[contactInfoDict valueForKey:@"mobileNumber"];
        objMember.strHomePhone=[contactInfoDict valueForKey:@"homeNumber"];
        objMember.strProfileImage=[contactInfoDict valueForKey:@"image"];
        
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
                groupMemberArray = [[NSMutableArray alloc] init];
                groupMemberArray = [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
                
                self.saveBtn.hidden=YES;
                groupNameTextField.userInteractionEnabled=NO;
                groupMemberTableView.hidden = NO;
                groupHelpLabel.hidden = YES;
                groupSwipeTextLabel.hidden=NO;
                
                [groupMemberTableView reloadData];
                
                /*if (groupMemberArray.count==1)
                {
                    ModelGroupMembers *obj=[groupMemberArray objectAtIndex:0];
                    
                    if (obj.strProfileImage && obj.strProfileImage.length>0)
                    {
                        NSMutableArray *imageUrlArr=[[NSMutableArray alloc] init];
                        [imageUrlArr addObject:obj.strProfileImage];
                        [self noOfViews:imageUrlArr];
                    }
                }
                else if (groupMemberArray.count==2)
                {
                    NSMutableArray *imageUrlArr=[[NSMutableArray alloc] init];
                    for (int i=0; i<groupMemberArray.count; i++)
                    {
                        ModelGroupMembers *obj=[groupMemberArray objectAtIndex:i];
                        
                        if (obj.strProfileImage && obj.strProfileImage.length>0)
                            [imageUrlArr addObject:obj.strProfileImage];
                    }
                    [self noOfViews:imageUrlArr];
                }*/
            }
        }
        else
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [self alertStatus:@"Already exists." :nil];
        }
    }
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
@end
