//
//  EditProfileController.m
//  Heya
//
//  Created by jayantada on 30/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "CreateProfileController.h"
#import "EditProfileControllerViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "ModelUserProfile.h"

#define RegisterURL @"https://qa.campusclouds.com/hey/profile_details"

@interface CreateProfileController ()<UIAlertViewDelegate>
{
    float keyBoardHeight;
    MBProgressHUD *HUD;
    NSUserDefaults *pref;
    NSMutableDictionary *contactInfoDict;
    NSString *urlString, *contactNumString;
    NSString *UDID, *fullName, *contactNumber, *timeStamp;
    
    BOOL isReachable;
    NSData *profileImageData;
}


@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation CreateProfileController
@synthesize quickContactsArray,contactsContainer, contentScrollView, editBtnLabel, saveBtnLabel,addContactBtnLabel,callIcon;


- (void)viewDidLoad
{
    [super viewDidLoad];
    keyBoardHeight=0.0f;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    pref=[NSUserDefaults standardUserDefaults];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    
    //Dismiss any Keyborad if background is tapped
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.onlyDisplayprofileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.onlyDisplayprofileImage.clipsToBounds = YES;
    
    
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        saveBtnLabel.hidden=YES;
        editBtnLabel.hidden=NO;
        contentScrollView.hidden=YES;
        self.onlyForDisplayView.hidden=NO;
        
        ModelUserProfile *obj=[[ModelUserProfile alloc] init];
        
        obj=[userProfile objectAtIndex:0];
        self.FirstNameDisplayLabel.text=[NSString stringWithFormat:@"%@ %@",obj.strFirstName,obj.strLastName];
        self.HeyNameDisplayLabel.text=obj.strHeyName;
        self.NumberDisplayLabel.text=obj.strPhoneNo;
        
        if(obj.strProfileImage.length>0)
        {
            if([obj.strProfileImage isEqualToString:@"man_icon.png"])
            {
                self.onlyDisplayprofileImage.image = [UIImage imageNamed:@"man_icon.png"];
            }
            else
            {
                NSData *proImageData=[[NSData alloc] initWithBase64EncodedString:obj.strProfileImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage  *proImage = [UIImage imageWithData:proImageData];
                self.onlyDisplayprofileImage.image=proImage;
            }
        }
        
    }
    else
    {
        contentScrollView.hidden=NO;
        self.onlyForDisplayView.hidden=YES;
        
        saveBtnLabel.hidden=NO;
        editBtnLabel.hidden=YES;
        addContactBtnLabel.hidden=NO;
        callIcon.hidden=YES;
        
        /*self.FirstName.text=@"";
        self.lastName.text=@"";
        self.heyName.text=@"";
        self.ContactNo.text=@"";
        self.profileImage.image = [UIImage imageNamed:@"man_icon.png"];*/
        
        [self.FirstName setUserInteractionEnabled:YES];
        [self.lastName setUserInteractionEnabled:YES];
        [self.heyName setUserInteractionEnabled:YES];
        [self.ContactNo setUserInteractionEnabled:YES];
        
        if(conatctNoFetchFromContactList.length>0)
        {
            NSLog(@"Contact: %@",conatctNoFetchFromContactList);
            [self.ContactNo setText:conatctNoFetchFromContactList];
        }
    }
}


-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
    [self.contentScrollView setContentOffset:CGPointZero animated:YES];
}


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    keyBoardHeight=kbSize.height;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButton:(id)sender
{
    
    if (self.FirstName.text.length>0 && self.lastName.text.length>0 && self.heyName.text.length>0 && self.ContactNo.text.length>0)
    {
        [self.FirstName resignFirstResponder];
        [self.lastName resignFirstResponder];
        [self.heyName resignFirstResponder];
        [self.ContactNo resignFirstResponder];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        NSString *remoteHostName =RegisterURL;
        
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
        [self updateInterfaceWithReachability:self.hostReachability];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [self updateInterfaceWithReachability:self.internetReachability];
        
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];
        [self updateInterfaceWithReachability:self.wifiReachability];
        
        if([self isNetworkAvailable])
        {
            NSString *profileImage;
            if([pref objectForKey:@"ProfileImage"])
            {
                NSString *imgValue=[NSString stringWithFormat:@"%@",[pref objectForKey:@"ProfileImage"]];
                
                if([imgValue isEqualToString:@"man_icon.png"])
                    self.profileImage.image = [UIImage imageNamed:[pref objectForKey:@"ProfileImage"]];
                
                else
                {
                    NSData *imgData=(NSData*)[pref objectForKey:@"ProfileImage"];
                    
                    profileImage= [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                    UIImage  *img = [UIImage imageWithData:imgData];
                    self.profileImage.image=img;
                }
                [pref removeObjectForKey:@"ProfileImage"];
            }
            else if(profileImageData!=NULL)
            {
                profileImage= [profileImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                UIImage  *img = [UIImage imageWithData:profileImageData];
                self.profileImage.image=img;
            }
            
            //NSLog(@"IMageString: %@",[profileImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
            
            UDID=@"80000000000000";
            //UDID= [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            
            NSMutableArray *arrayUser=[[NSMutableArray alloc] init];
            ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
            userObj.strFirstName=self.FirstName.text;
            userObj.strLastName=self.lastName.text;
            userObj.strHeyName=self.heyName.text;
            userObj.strPhoneNo=self.ContactNo.text;
            userObj.strDeviceUDID=UDID;
            userObj.strProfileImage=profileImage;
            
            [arrayUser addObject:userObj];
            
            BOOL isInserted=[DBManager addProfile:arrayUser];
        
            if (isInserted)
            {
                [self.view addSubview:HUD];
                [HUD show:YES];
                
                
                fullName=[NSString stringWithFormat:@"%@ %@",userObj.strFirstName,userObj.strLastName];
                contactNumber=self.ContactNo.text;

                [pref setValue:self.ContactNo.text forKey:@"ProfileContactNo"];
                [pref synchronize];
                NSDate *today=[NSDate date];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd-MM-yyyy h:mm:ss"];
                timeStamp = [formatter stringFromDate:today];
                
                NSURL *url = [NSURL URLWithString:RegisterURL];
        
                ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                [request setAuthenticationScheme:@"https"];
                [request setValidatesSecureCertificate:NO];
                [request setRequestMethod:@"POST"];
                
                [request setPostValue:UDID forKey:@"unique_token"];
                [request setPostValue:fullName forKey:@"user_name"];
                [request setPostValue:contactNumber forKey:@"contact_number"];
                [request setPostValue:timeStamp forKey:@"timestamp"];
                [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                
                [request startAsynchronous];
                [request setTimeOutSeconds:20];
                [request setDelegate:self];
              
            }
            
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
                
        }
        else
        {
            [self showNetworkErrorMessage];
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"All fields are mandatory." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

//API Response Method
- (void) requestFinished:(ASIHTTPRequest *)request
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    
    NSString *responseString = [request responseString];
    NSLog(@"responseString: %@",responseString);
    NSError *error;
    
    NSDictionary *jsonResponeDict= [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];

    if ([[jsonResponeDict valueForKey:@"success"] boolValue]==true)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Successfully registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSLog(@"Message: %@",[jsonResponeDict valueForKey:@"message"]);
    }

    
}


- (IBAction)editButtonTapped:(id)sender
{
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        EditProfileControllerViewController *editController = [[EditProfileControllerViewController alloc] initWithNibName:@"EditProfileControllerViewController" bundle:nil];
        
        [self.navigationController pushViewController:editController animated:YES];
    }
}

-(IBAction)changeProfileImageBtnTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)getContacts:(id)sender {
    
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    
    contactInfoDict = [[NSMutableDictionary alloc]
                       initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                       forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    
    
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
        
        if ([(NSString *)kABPersonPhoneMobileLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound) {
            contactNumString =(__bridge NSString *)currentPhoneValue;
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            
            //NSLog(@"mobileNumber: %@",[contactInfoDict valueForKey:@"mobileNumber"]);
        }
        
        //If Phone Number doesn't exists in kABPersonPhoneMobileLabel
        if ([[contactInfoDict objectForKey:@"mobileNumber"] isEqualToString:@""])
        {
            if ([(NSString *)kABHomeLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound) {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            }
        }
        
        //If Phone Number doesn't exists in kABHomeLabel
        if ([[contactInfoDict objectForKey:@"mobileNumber"] isEqualToString:@""])
        {
            if ([(NSString *)kABWorkLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound) {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            }
        }
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    
    CFRelease(phonesRef);
    
    // If the contact has an image then get it too.
    if (ABPersonHasImageData(person))
    {
        
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        [contactInfoDict setObject:contactImageData forKey:@"image"];
    }
    
    else
    {
        [contactInfoDict setObject:@"man_icon.png" forKey:@"image"];
    }
    
    
    if([contactInfoDict valueForKey:@"image"])
    {
        NSString *imgValue=[NSString stringWithFormat:@"%@",[contactInfoDict valueForKey:@"image"]];
        
        if([imgValue isEqualToString:@"man_icon.png"])
            self.profileImage.image = [UIImage imageNamed:[contactInfoDict objectForKey:@"image"]];

        else
        {
            NSData *imgData=[contactInfoDict valueForKey:@"image"];
            UIImage  *img = [UIImage imageWithData:imgData];
            self.profileImage.image=img;
        }
        
        //save to preferance
        [pref setObject:[contactInfoDict objectForKey:@"image"] forKey:@"ProfileImage"];
        [pref synchronize];
    }
    if([contactInfoDict objectForKey:@"mobileNumber"])
    {
        conatctNoFetchFromContactList=[contactInfoDict objectForKey:@"mobileNumber"];
    }
    else
    {
        conatctNoFetchFromContactList=[contactInfoDict objectForKey:@"homeNumber"];
    }
    
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark ImagePicker Delegate Methods
#pragma mark

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [pref removeObjectForKey:@"ProfileImage"];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImage.image = chosenImage;
    
    profileImageData = UIImagePNGRepresentation(chosenImage);
    //profileImageString= [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark
#pragma mark UITexField Delegate Methods
#pragma mark

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField==self.ContactNo || textField==self.heyName)
    {
        if(self.ContactNo.superview.frame.origin.y+self.ContactNo.superview.frame.size.height>keyBoardHeight)
        {
            contentScrollView.contentSize=CGSizeMake(contentScrollView.frame.size.width,contentScrollView.frame.size.height+textField.superview.frame.origin.y);
        
            CGPoint Offset = CGPointMake(0,textField.superview.frame.origin.y/2);
            [contentScrollView setContentOffset:Offset animated:YES];
        }
    }
    
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if(textField==self.ContactNo || textField==self.heyName)
    {
        contentScrollView.contentSize=CGSizeMake(contentScrollView.frame.size.width,contentScrollView.frame.size.height);
        [contentScrollView setContentOffset:CGPointZero animated:YES];
        
    }
    [textField resignFirstResponder];
}


#pragma mark
#pragma mark Reachability Method Implementation
#pragma mark

//Called by Reachability whenever status changes.

-(BOOL)isNetworkAvailable
{
    return isReachable;
}
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NSString* baseLabelText = @"";
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable)
        {
            isReachable=NO;
            baseLabelText = NSLocalizedString(@"Cellular data network is unavailable.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            isReachable=YES;
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        

        NSLog(@"Reachability Message: %@", baseLabelText);
    }
    
    if (reachability == self.internetReachability)
    {
        NSLog(@"internetReachability is possible");
    }
    
    if (reachability == self.wifiReachability)
    {
        NSLog(@"wifiReachability is possible");
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

-(void)showNetworkErrorMessage
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:kNetworkErrorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}


//Called by Reachability whenever status changes.


#pragma mark
#pragma mark AlertView Delegate
#pragma mark

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
        [self.navigationController popViewControllerAnimated:YES];
    
}
@end
