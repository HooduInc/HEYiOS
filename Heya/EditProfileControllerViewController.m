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
#import "HeyWebService.h"

@interface EditProfileControllerViewController ()<UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UITextField *name;
    IBOutlet UITextField *phone;
    NSString *profileImageString, *strUDID;
    BOOL imageChangeFlag,isReachable;
    NSUserDefaults *pref;
    NSMutableArray *userProfile;
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
}

-(void) viewWillAppear:(BOOL)animated
{
    userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        
        ModelUserProfile *obj=[[ModelUserProfile alloc] init];
        
        obj=[userProfile objectAtIndex:0];
        strUDID=obj.strDeviceUDID;
        name.text=[NSString stringWithFormat:@"%@ %@",obj.strFirstName,obj.strLastName];
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtnTapped:(id)sender
{
    
    [name resignFirstResponder];
    [phone resignFirstResponder];
    
    NSLog(@"NAME: %@",name.text);
    
    if ([name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] .length>0 && [phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        NSMutableArray *arrayUser=[[NSMutableArray alloc] init];
        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
        
        if ([[name.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] containsString:@" "])
        {
            NSArray *nameArray=[name.text componentsSeparatedByString:@" "];
            userObj.strFirstName=[nameArray objectAtIndex:0];
            userObj.strLastName=[nameArray objectAtIndex:1];
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
        [formatter setDateFormat:@"dd-MM-yyyy"];
        NSString *timeStamp = [formatter stringFromDate:today];
        userObj.strCurrentTimeStamp=timeStamp;
        
        [arrayUser addObject:userObj];
        
        
        BOOL isUpdated=[DBManager updateProfile:arrayUser];
        
        if (isUpdated)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Updated successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
            
            NSString *remoteHostName =HostTwo;
            
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
                
                NSString *createFullName=[NSString stringWithFormat:@"%@ %@",userObj.strFirstName,userObj.strLastName];
                
                [[HeyWebService service] updateProfileWithUDID:[strUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:[createFullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ContactNumber:[userObj.strPhoneNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] TimeStamp:timeStamp WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
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
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please provide your name and contact number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField
{}

-(void) textFieldDidEndEditing:(UITextField *)textField
{}




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
@end
