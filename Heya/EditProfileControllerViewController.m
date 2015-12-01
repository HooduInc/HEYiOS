//
//  EditProfileControllerViewController.m
//  Heya
//
//  Created by jayantada on 23/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "EditProfileControllerViewController.h"
#import "ModelUserProfile.h"
#import "CustomUITextFieldType.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "InAppPurchaseHelper.h"
#import "HeyWebService.h"

@interface EditProfileControllerViewController ()<UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    CGFloat animatedDistance;
    IBOutlet UIView *innerView;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UITextField *name;
    IBOutlet UITextField *phone;
    NSString *profileImageString, *strUDID;
    BOOL imageChangeFlag,isReachable;
    NSUserDefaults *pref;
}


@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation EditProfileControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    pref=[NSUserDefaults standardUserDefaults];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds = YES;
    profileImageView.layer.borderColor=[UIColor colorWithRed:208/255.0f green:208/255.0f  blue:211/255.0f  alpha:1].CGColor;
    profileImageView.layer.borderWidth=1.0f;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        ModelUserProfile *obj=[userProfile firstObject];
        
        strUDID=obj.strDeviceUDID;
        if (obj.strLastName.length>0) {
            name.text=[NSString stringWithFormat:@"%@ %@",obj.strFirstName,obj.strLastName];
        }
        else
            name.text=obj.strFirstName;
        //heyName.text=obj.strHeyName;
        phone.text=obj.strPhoneNo;
        
        if(imageChangeFlag==NO)
        {
           
            if(obj.strProfileImage.length>0)
            {
                if([obj.strProfileImage isEqualToString:@"man_icon.png"])
                {
                    profileImageView.image = [UIImage imageNamed:@"man_icon.png"];
                }
                else
                {
                    NSData *proImageData=[[NSData alloc] initWithBase64EncodedString:obj.strProfileImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage  *proImage = [UIImage imageWithData:proImageData];
                    profileImageView.image=proImage;
                }
            }
        }
        else
        {
            NSData *myData = UIImagePNGRepresentation(profileImageView.image);
            profileImageString= [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeProfileImageBtnTapped:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imageChangeFlag=YES;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)back:(id)sender
{
    [name resignFirstResponder];
    [phone resignFirstResponder];
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtnTapped:(id)sender
{
    [name resignFirstResponder];
    [phone resignFirstResponder];
    
    //NSLog(@"NAME: %@",name.text);
    
    if ([name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] .length>0 && [phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        NSMutableArray *arrayUser=[[NSMutableArray alloc] init];
        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
        
        if ([[name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] containsString:@" "])
        {
            NSArray *nameArray=[name.text componentsSeparatedByString:@" "];
            NSLog(@"nameArray count: %ld",(long)nameArray.count);
            
            if (nameArray.count>2)
            {
                userObj.strFirstName=[nameArray objectAtIndex:0];
                
                for (int i=1; i<nameArray.count; i++)
                {
                    if(i==1)
                        userObj.strLastName=[NSString stringWithFormat:@"%@",[nameArray objectAtIndex:i]];
                    else
                        userObj.strLastName=[NSString stringWithFormat:@"%@ %@",userObj.strLastName,[nameArray objectAtIndex:i]];
                }
                
            }
            else
            {
                userObj.strFirstName=[nameArray objectAtIndex:0];
                userObj.strLastName=[nameArray objectAtIndex:1];
            }
            
            
        }
        else
        {
            userObj.strFirstName=[name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            userObj.strLastName=@"";
        }
        userObj.strPhoneNo=phone.text;
        
        NSData *myData = UIImagePNGRepresentation(profileImageView.image);
        profileImageString= [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        userObj.strProfileImage=profileImageString;
        
        NSDate *today=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *timeStamp = [formatter stringFromDate:today];
        userObj.strCurrentTimeStamp=timeStamp;
        
        [arrayUser addObject:userObj];
        
        
        BOOL isUpdated=[DBManager updateProfile:arrayUser];
        
        if (isUpdated)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Updated successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
            
            NSString *remoteHostName =HeyBaseURL;
            
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
                [self.view addSubview:HUD];
                [HUD show:YES];

                NSMutableArray *userProfile=[[NSMutableArray alloc] init];
                userProfile=[DBManager fetchUserProfile];
                
                if (userProfile.count>0)
                {
                    ModelUserProfile *modObj=[userProfile firstObject];
                    
                    NSString *createFullName=[NSString stringWithFormat:@"%@ %@",modObj.strFirstName,modObj.strLastName];
                    
                    NSString *accountCreationDateStr=@"";
                    NSLog(@"Account Creation Date: %@",modObj.strAccountCreated);
                    if (modObj.strAccountCreated && modObj.strAccountCreated.length>0)
                    {
                        //[formatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate *accountCreationDate=[formatter dateFromString:modObj.strAccountCreated];
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                        accountCreationDateStr=[formatter stringFromDate:accountCreationDate];
                    }
                    
                    NSLog(@"isSendToServer Status: %d",modObj.isRegistered);
                    if (modObj.isRegistered==0)
                    {
                        [[HeyWebService service] registerWithUDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:[createFullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ContactNumber:[modObj.strPhoneNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] TimeStamp:timeStamp AccountCreated:accountCreationDateStr WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                         {
                             [HUD hide:YES];
                             [HUD removeFromSuperview];
                             if (isError)
                             {
                                 NSLog(@"Resigartion Error Message: %@",strMsg);
                                 
                                 if ([strMsg containsString:@"This Mobile UDID already exists. Try with another!"])
                                 {
                                     UIAlertView *showDialog=[[UIAlertView alloc] initWithTitle:nil message:@"Already Registered." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                     
                                     [showDialog show];
                                     
                                     [DBManager updatedToServerForUserWithFlag:1];
                                     [DBManager isRegistrationSuccessful:1];
                                     
                                 }
                             }
                             
                             else
                             {   [DBManager updatedToServerForUserWithFlag:1];
                                 [DBManager isRegistrationSuccessful:1];
                                 NSLog(@"Resigartion Success Message: %@",strMsg);
                                 
                                 if (pushDeviceTokenId && pushDeviceTokenId.length>0)
                                 {
                                     [[HeyWebService service] fetchPushNotificationFromServerWithPushToken:[pushDeviceTokenId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] UDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                                      {
                                          NSLog(@"Push Message: %@",strMsg);
                                      }];
                                 }
                                 
                                 //store the trail period date or the subscription date in NSUserDefaults
                                 [[HeyWebService service] fetchSubscriptionDateWithUDID:modObj.strDeviceUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                                  {
                                      if (isError)
                                      {
                                          NSLog(@"Subscription Fetch Failed: %@",strMsg);
                                      }
                                      else
                                      {
                                          NSDictionary *resultDict=(id)result;
                                          if ([[resultDict valueForKey:@"status"] boolValue]==true)
                                          {
                                              NSString *serverDateString=[NSString stringWithFormat:@"%@", [[resultDict valueForKey:@"error"] valueForKey:@"date"]];
                                              
                                              if (serverDateString && serverDateString.length>0)
                                              {
                                                  NSDateFormatter *format=[[NSDateFormatter alloc] init];
                                                  [format setDateFormat:@"MM.dd.yyyy"];
                                                  NSDate * serverDate =[format dateFromString:serverDateString];
                                                  NSLog(@"Server Date: %@",serverDate);
                                                  if (serverDate)
                                                  {
                                                      [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:kSubscriptionExpirationDateKey];
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                  }
                                              }
                                              
                                          }
                                      }
                                      
                                  }];
                                 //store the trail period date or the subscription date in NSUserDefaults
                                 
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                         }];
                    }
                    else
                    {
                        [[HeyWebService service] updateProfileWithUDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:[createFullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ContactNumber:[userObj.strPhoneNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] TimeStamp:timeStamp WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                         {
                             
                             [HUD hide:YES];
                             [HUD removeFromSuperview];
                             if (isError)
                                 NSLog(@"Updation Error Message: %@",strMsg);
                             
                             else
                             {
                                 NSLog(@"Updation Success Message: %@",strMsg);
                                 [DBManager updatedToServerForUserWithFlag:1];
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                             
                         }];
                        
                    }
                }
            }
            else
            {
                NSLog(@"Internet Connection is not available.");
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Something wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Please provide your name and contact number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark
#pragma mark ImagePicker Delegate Methods
#pragma mark

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [name resignFirstResponder];
    [phone resignFirstResponder];
    
    profileImageView.image=[UIImage imageNamed:@""];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    profileImageView.image = chosenImage;
    
    NSData *myData = UIImagePNGRepresentation(profileImageView.image);
    profileImageString= [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark UITexField Delegate Methods
#pragma mark

static const CGFloat KEYBOARD_ANIMATION_DURATION =0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 180;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (isIphone4 || isIphone5)
    {
        if (textField==phone)
        {
            CGRect textFieldRect = [innerView.window convertRect:textField.bounds fromView:textField];
            CGRect viewRect = [innerView.window convertRect:innerView.bounds fromView:innerView];
            CGFloat midline = textFieldRect.origin.y + textFieldRect.size.height-80;
            CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
            CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
            CGFloat heightFraction = numerator / denominator;
            if (heightFraction < 0.0)
            {
                heightFraction = 0.0;
            }
            else if (heightFraction > 1.0)
            {
                heightFraction = 1.0;
            }
            UIInterfaceOrientation orientation =
            [[UIApplication sharedApplication] statusBarOrientation];
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
            }
            else
            {
                animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
            }
            CGRect viewFrame = innerView.frame;
            viewFrame.origin.y -= animatedDistance;
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
            [innerView setFrame:viewFrame];
            [UIView commitAnimations];
        }
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (isIphone4 || isIphone5)
    {
        if (textField==phone)
        {
            [self endAnimation];
            [textField resignFirstResponder];
        }
    }
    
}


-(void) endAnimation
{
    CGRect viewFrame = innerView.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [innerView setFrame:viewFrame];
    [UIView commitAnimations];
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
    [[[UIAlertView alloc] initWithTitle:nil message:kNetworkErrorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}
@end
