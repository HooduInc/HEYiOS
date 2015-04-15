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

@interface EditProfileControllerViewController ()<UITextFieldDelegate>
{
    IBOutlet UIImageView *profileImageView;
    IBOutlet UITextField *name;
    IBOutlet UITextField *phone;
    NSString *profileImageString;
    BOOL imageChangeFlag;
}

@end

@implementation EditProfileControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        
        ModelUserProfile *obj=[[ModelUserProfile alloc] init];
        
        obj=[userProfile objectAtIndex:0];
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
        }
        userObj.strPhoneNo=phone.text;
        
        NSData *myData = UIImagePNGRepresentation(profileImageView.image);
        profileImageString= [myData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        userObj.strProfileImage=profileImageString;
        
        [arrayUser addObject:userObj];
        
        
        BOOL isUpdated=[DBManager updateProfile:arrayUser];
        
        if(isUpdated)
        {
            profileImageString=@"";
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Saved Successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
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
@end
