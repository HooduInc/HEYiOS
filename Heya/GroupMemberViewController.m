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
    saveAlert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Saved Successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
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
    GroupMemberTableViewCell *cell=(GroupMemberTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[groupMemberTableView indexPathForCell:cell];
    selectedIndexPath=indexPath;
    cellDeleteStatus=YES;
    selectedIndexPath=nil;
    
    NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cell.groupMemberName.text);
    BOOL isDeleted=[DBManager deleteGroupMemberWithMemberId:[NSString stringWithFormat:@"%ld",(long)cell.groupMemberName.tag]];
     
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
        
        BOOL exists=[DBManager checkGroupMembersExistsinGroupTable:[alertView buttonTitleAtIndex:buttonIndex] groupID:clickedGroupId];
        
        if(!exists)
        {
            [contactInfoDict setObject:[alertView buttonTitleAtIndex:buttonIndex] forKey:@"mobileNumber"];
            
            [self.view addSubview:HUD];
            [HUD show:YES];
            [self insertGroupMember];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
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
                [self alertStatus:@"Group name already exists." :@"Error!" ];
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
                [self alertStatus:@"Group name already exists." :@"Error!" ];
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
                                                       delegate:self
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
                 
                 NSMutableArray *memberInsertArray=[[NSMutableArray alloc] init];
                 [memberInsertArray addObject:objMember];
                 
                 long long insertId= [DBManager insertGroupMember:memberInsertArray];
                 [HUD hide:YES];
                 [HUD removeFromSuperview];
                 
                 if (insertId!=0)
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
        
        NSMutableArray *memberInsertArray=[[NSMutableArray alloc] init];
        [memberInsertArray addObject:objMember];
        
        long long insertId= [DBManager insertGroupMember:memberInsertArray];
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
        if (insertId!=0)
        {
            groupMemberArray = [[NSMutableArray alloc] init];
            groupMemberArray = [DBManager fetchGroupMembersWithGroupId:clickedGroupId];
            
            self.saveBtn.hidden=YES;
            groupNameTextField.userInteractionEnabled=NO;
            groupMemberTableView.hidden = NO;
            groupHelpLabel.hidden = YES;
            groupSwipeTextLabel.hidden=NO;
            
            [groupMemberTableView reloadData];
        }
    }
}


@end
