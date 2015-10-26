//
//  FevoriteViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 12/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "FevoriteViewController.h"
#import "RearrangeFevoriteViewController.h"
#import "FevretTableViewCell.h"
#import "ModelFevorite.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>

@interface FevoriteViewController ()<FevretTableViewCellDelegate,UITextFieldDelegate, UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
    NSIndexPath *selectedIndexPath;
    BOOL cellEditingStatus, cellDeleteStatus;
    UIAlertView *saveAlert;
    NSMutableArray *multipleContactNoArray, *arrDisplay;

    UIImage *contactImageFromAddressBook;
}

@end

@implementation FevoriteViewController
NSMutableDictionary *contactInfoDict;
NSString *urlString;
@synthesize fevoriteList_table,fevoritelist_array,number_arr,alphabetArray, testingImage;


#pragma mark
#pragma mark - UIViewController Initilization
#pragma mark

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    alphabetArray = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3", nil];
    saveAlert=[[UIAlertView alloc] initWithTitle:nil message:@"Saved Successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [self setEditing:YES animated:YES];// 3
    [fevoriteList_table setEditing:YES animated:YES];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    selectedIndexPath=nil;
    self.arrContactsData = [[NSMutableArray alloc]init];
    
    [fevoriteList_table setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
    
    [self fetchAndRefresh];
    
    [self.view addSubview:HUD];
    [HUD show:YES];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        
        //Mostly Coding Part
        
        [self fetchAndRefresh];
        
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            
            //Mostly UI Updates
            [fevoriteList_table reloadData];
            [HUD hide:YES];
            [HUD removeFromSuperview];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - ABPeoplePickerNavigationController
#pragma mark

//Works from IOS 8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    multipleContactNoArray=[[NSMutableArray alloc] init];
    
    // Initialize a mutable dictionary and give it initial values.
    contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject)
    {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject)
    {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (phonesRef)
    {
        
        //NSLog(@"isFacebook %d", [self isPersonFacebookContact:person]);
        
        if([self isPersonFacebookContact:person])
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"This contact information synced from facebook to your addressbook. Contact picture may not appear in the favorites." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        for (int i=0; i<ABMultiValueGetCount(phonesRef); i++)
        {
            CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
            CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
            /*
             NSLog(@"ContactLabel: %@",currentPhoneLabel);
             NSLog(@"ContactValue: %@",currentPhoneValue);
             NSLog(@"kABPersonPhoneMobileLabel: %@", kABPersonPhoneMobileLabel);*/
            
            
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
            else
            {
                NSString *localLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(currentPhoneLabel);
                NSLog(@"localLabel: %@",localLabel);
                
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            CFRelease(currentPhoneLabel);
            CFRelease(currentPhoneValue);
        }
        
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
                [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
                [alertContactDialog show];
            }
            else if(multipleContactNoArray.count!=0)
                [self insertFavorite];
            
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
                [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
                [alertContactDialog show];
            }
            else
                [self insertFavorite];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Sorry. Contact number doesn't exist." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    //[self.addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isPersonFacebookContact:(ABRecordRef)person
{
    ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
    
    BOOL returnValue = NO;
    
    if (instantMessage)
    {
        for (NSInteger i=0 ; i < ABMultiValueGetCount(instantMessage); i++)
        {
            CFDictionaryRef instantMessageValue = ABMultiValueCopyValueAtIndex(instantMessage, i);
            CFStringRef instantMessageString = CFDictionaryGetValue(instantMessageValue, kABPersonInstantMessageServiceKey);
                
            if (CFStringCompare(instantMessageString, kABPersonInstantMessageServiceFacebook, 0) == kCFCompareEqualTo)
            {
                returnValue = YES;
            }
            
            CFRelease(instantMessageString);
            CFRelease(instantMessageValue);
        }
    }
    
    //CFRelease(instantMessage);
    
    return returnValue;
}


#pragma mark
#pragma mark - Tableview Delegate
#pragma mark


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count=0;
    if (arrDisplay && arrDisplay.count>0)
    {
        count = arrDisplay.count;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=0;
    if (arrDisplay && arrDisplay.count>0) {
        count=[(NSMutableArray*)[arrDisplay objectAtIndex:section] count];
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self tableView:tableView heightForHeaderInSection:section]-5)];
    bg.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(8, 2, self.view.frame.size.width, 15.0f)];
    titleLabel.font=[UIFont boldSystemFontOfSize:14.0f];
    titleLabel.textColor=[UIColor colorWithRed:114/255.0f green:114/255.0f blue:114/255.0f alpha:1];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    
    if (section==0)
         titleLabel.text=@"Top 5";
    
    else
    {
        long prefix=5*section;
        long suffix=5*(section+1);
        titleLabel.text=[NSString stringWithFormat:@"%ld-%ld",prefix,suffix];
    }
    
    [bg addSubview:titleLabel];
    
    return bg;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"cell1";
    FevretTableViewCell *cell = (FevretTableViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"FevretTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    ModelFevorite *favObj = [[ModelFevorite alloc] init];
    //favObj=[self.arrContactsData objectAtIndex:indexPath.row];
    favObj=[[arrDisplay objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.itemText = [NSString stringWithFormat:@"%@ %@", favObj.strFirstName,favObj.strLastName];
    cell.nameLabelText.tag=[favObj.strFevoriteId intValue];
    cell.nameLabelText.delegate=self;
    
    if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
    {
        
        //cell.profileImg.image = [UIImage imageNamed:favObj.strProfileImage];
        cell.itemImage = [UIImage imageNamed:favObj.strProfileImage];
    }
    else
    {
          NSString *str = favObj.strProfileImage;
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
                        //cell.profileImg.image=image;
                        cell.itemImage=image;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark
#pragma mark - SwipeableCellDelegate
#pragma mark
- (void)buttonChangeActionForItemText:(id)sender
{
    self.saveBtn.hidden=NO;
    FevretTableViewCell *cell=(FevretTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[fevoriteList_table indexPathForCell:cell];
    
    cell.nameLabelText.userInteractionEnabled=YES;
    [cell.nameLabelText becomeFirstResponder];
    selectedIndexPath=indexPath;
    cellEditingStatus=YES;
    cellDeleteStatus=NO;
    
    NSLog(@"In the delegate, Clicked buttonChange-> Before Updating->Name: %@",cell.nameLabelText.text);
    
    
    CGRect rectOfCellInTableView = [fevoriteList_table rectForRowAtIndexPath:indexPath];
    NSLog(@"TextField Origin: %f",rectOfCellInTableView.origin.y+120);
    
    if(isIphone4 || isIphone5)
    {
        if(rectOfCellInTableView.origin.y+120>253)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6)
    {
        if(rectOfCellInTableView.origin.y+120>258)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6)
    {
        if(rectOfCellInTableView.origin.y+120>271)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
        
}

- (void)buttonDeleteActionForItemText:(id)sender
{
    FevretTableViewCell *cell=(FevretTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    //NSIndexPath *indexPath=[fevoriteList_table indexPathForCell:cell];
    //selectedIndexPath=indexPath;
    
    cellEditingStatus=NO;
    cellDeleteStatus=YES;
    selectedIndexPath=nil;

    NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cell.nameLabelText.text);
    BOOL isDeleted=[DBManager deleteFavoriteDetailsWithFavoriteId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]];
    
    if(isDeleted)
        [self fetchAndRefresh];
}

#pragma mark
#pragma mark - IBActions and Methods
#pragma mark


- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)getcontacts:(id)sender
{
    
    self.addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [self.addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:self.addressBookController animated:YES completion:nil];
}

-(IBAction)rearrangeBtnTapped:(id)sender
{
    if (self.arrContactsData.count>0)
    {
        RearrangeFevoriteViewController *rearrangeController=[[RearrangeFevoriteViewController alloc] initWithNibName:@"RearrangeFevoriteViewController" bundle:nil];
        [self.navigationController pushViewController:rearrangeController animated:YES];
    }
}

-(IBAction)saveBtnTapped:(id)sender
{
    if (cellEditingStatus==YES && cellDeleteStatus==NO && selectedIndexPath!=nil)
    {
        
        FevretTableViewCell *cell=(FevretTableViewCell*)[fevoriteList_table cellForRowAtIndexPath:selectedIndexPath];
        
        if (cell.nameLabelText.text.length>0)
        {
            NSLog(@"Updated Name: %@",cell.nameLabelText.text);
            NSLog(@"Favorite ID: %ld",(long)cell.nameLabelText.tag);
           BOOL isUpdated=[DBManager UpdateFavoriteWithId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]  withColoumValue:cell.nameLabelText.text];
            
            if (isUpdated)
            {
                cellEditingStatus=NO;
                cellDeleteStatus=YES;
                selectedIndexPath=nil;
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                self.saveBtn.hidden=YES;
                
                [self fetchAndRefresh];

            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }

        }
    }

}



#pragma mark
#pragma mark TextField Delegate Methods
#pragma mark


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [fevoriteList_table setContentOffset:CGPointZero animated:YES];
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
        [self insertFavorite];
    }
}


#pragma mark
#pragma mark Helper Method
#pragma mark

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

-(void) fetchAndRefresh
{
    arrDisplay=[[NSMutableArray alloc] init];
    self.arrContactsData=[[NSMutableArray alloc] init];
    self.arrContactsData = [DBManager fetchFavorite];
     NSLog(@"No of Elements: %ld",(long)self.arrContactsData.count);
    [self updateSortedArray:^(BOOL finished) {
        NSLog(@"Sections in arrDisplay: %ld",(long)arrDisplay.count);
        NSLog(@"ArrDisplay Contents: %@",arrDisplay);
        [fevoriteList_table reloadData];
    }];
}

-(void)updateSortedArray:(void(^)(BOOL finished))myBlock
{
    if (self.arrContactsData.count>0)
    {
        int j=0;
        BOOL flag=NO;
        NSMutableArray *arrTemp=[NSMutableArray array];
        for (int i=0; i<self.arrContactsData.count; i++)
        {
            [arrTemp addObject:self.arrContactsData[i]];
            if (arrTemp.count==5)
            {
                flag=YES;
                [arrDisplay insertObject:[NSMutableArray arrayWithArray:(NSArray*)arrTemp] atIndex:j++];
                arrTemp=nil;
                arrTemp=[NSMutableArray array];
            }
            else{
                flag=NO;
                continue;
            }
        }
        if (!flag) {
            [arrDisplay insertObject:arrTemp atIndex:j];
        }
    }
    myBlock(YES);
}

-(void) insertFavorite
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
                 
                 urlString = [assetURL absoluteString];
                 NSLog(@"url %@", urlString);
                 [contactInfoDict setObject:urlString forKey:@"image"];
                 //NSLog(@"contactInfoDict: %@",contactInfoDict);
                 
                 ModelFevorite *favObj=[[ModelFevorite alloc] init];
                 favObj.strFirstName=[contactInfoDict valueForKey:@"firstName"];
                 favObj.strLastName=[contactInfoDict valueForKey:@"lastName"];
                 favObj.strMobNumber=[contactInfoDict valueForKey:@"mobileNumber"];
                 favObj.strHomeNumber=[contactInfoDict valueForKey:@"homeNumber"];
                 favObj.strProfileImage=[contactInfoDict valueForKey:@"image"];
                 
                 if(![DBManager checkMobileNumExistsinFavoriteTable:favObj.strMobNumber])
                 {
                     NSMutableArray *favInsertArray=[[NSMutableArray alloc] init];
                     [favInsertArray addObject:favObj];
                     
                     //insert to database
                     [DBManager insertToFavoriteTable:favInsertArray];
                     
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     contactImageFromAddressBook=nil;
                     
                     [self fetchAndRefresh];

                     [saveAlert show];
                     [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
                 }
                 else
                 {
                     [HUD hide:YES];
                     [HUD removeFromSuperview];
                     UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     [alert show];
                 }
                 
                 
             }
         }];
    }
    else
    {
        ModelFevorite *favObj=[[ModelFevorite alloc] init];
        favObj.strFirstName=[contactInfoDict valueForKey:@"firstName"];
        favObj.strLastName=[contactInfoDict valueForKey:@"lastName"];
        favObj.strMobNumber=[contactInfoDict valueForKey:@"mobileNumber"];
        favObj.strHomeNumber=[contactInfoDict valueForKey:@"homeNumber"];
        favObj.strProfileImage=[contactInfoDict valueForKey:@"image"];
        
        if(![DBManager checkMobileNumExistsinFavoriteTable:favObj.strMobNumber])
        {
            NSMutableArray *favInsertArray=[[NSMutableArray alloc] init];
            [favInsertArray addObject:favObj];
            
            //insert to database
            [DBManager insertToFavoriteTable:favInsertArray];
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            contactImageFromAddressBook=nil;
            
            [self fetchAndRefresh];
            
            [saveAlert show];
            [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
        }
        else
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

@end
