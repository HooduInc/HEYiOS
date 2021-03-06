//
//  SettingsViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 16/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "SettingsViewController.h"
#import "ThemeViewController.h"
#import "Pick4mListViewController.h"
#import "FevoriteViewController.h"
#import "GroupViewController.h"
#import "OtherSettingsController.h"
#import "HeyAccountController.h"
#import "CreateProfileController.h"
#import "ImproveHeyController.h"
#import "ModelUserProfile.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize settingsScrollView;
NSUserDefaults *preferances;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    preferances=[NSUserDefaults standardUserDefaults];
    
    CGRect mainRect=[[UIScreen mainScreen] bounds];
    
    self.settingsProfileImage.layer.cornerRadius = self.settingsProfileImage.frame.size.width / 2;
    self.settingsProfileImage.clipsToBounds = YES;
    self.settingsProfileImage.layer.borderColor=[UIColor colorWithRed:208/255.0f green:208/255.0f  blue:211/255.0f  alpha:1].CGColor;
    self.settingsProfileImage.layer.borderWidth=1.0f;
    
    if(isIphone4)
        self.settingsScrollView.contentSize = CGSizeMake(self.settingsScrollView.frame.size.width, mainRect.size.height+80);
    else
        self.settingsScrollView.contentSize = CGSizeMake(self.settingsScrollView.frame.size.width, mainRect.size.height-self.settingsScrollView.frame.origin.y+self.fourthView.frame.size.height+2);
}

-(void) viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    [self.themeNameLabel setText:[preferances valueForKey:@"themeName"]];
    
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if(userProfile.count>0)
    {
        ModelUserProfile *obj=[userProfile firstObject];
        
        if (obj.strFirstName.length>0 || obj.strLastName.length>0)
            self.userName.text=[NSString stringWithFormat:@"%@ %@",obj.strFirstName, obj.strLastName];
        else
            self.userName.text=@"User Name";
        
        
        if (obj.strPhoneNo.length>0)
            self.settingsPhoneNo.text=obj.strPhoneNo;
        else
            self.settingsPhoneNo.text=@"Phone No.";
        
        
        if(obj.strProfileImage.length>0)
        {
            if([obj.strProfileImage isEqualToString:@"man_icon.png"])
            {
                self.settingsProfileImage.image = [UIImage imageNamed:@"man_icon.png"];
            }
            else
            {
                NSData *proImageData=[[NSData alloc] initWithBase64EncodedString:obj.strProfileImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage  *proImage = [UIImage imageWithData:proImageData];
                self.settingsProfileImage.image=proImage;
            }
        }
        else
            self.settingsProfileImage.image = [UIImage imageNamed:@"man_icon.png"];
    }
    else
    {
        self.userName.text=@"User Name";
        self.settingsPhoneNo.text=@"Phone No.";
        self.settingsProfileImage.image = [UIImage imageNamed:@"man_icon.png"];
    }
    
}


- (IBAction)selectThemeButtonTapped:(id)sender {
    
    ThemeViewController *tVc = [[ThemeViewController alloc] initWithNibName:@"ThemeViewController" bundle:nil];
    [self.navigationController pushViewController:tVc animated:YES];
    

}

- (IBAction)pickListButton:(id)sender {
    
    //PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
    Pick4mListViewController *pickListController = [[Pick4mListViewController alloc] initWithNibName:@"Pick4mListViewController" bundle:nil];
    pickListController.FlagFromSettings=YES;
    [self.navigationController pushViewController:pickListController animated:YES];
}

- (IBAction)favouriteButton:(id)sender
{
    FevoriteViewController *fevoriteController = [[FevoriteViewController alloc] initWithNibName:@"FevoriteViewController" bundle:nil];
    [self.navigationController pushViewController:fevoriteController animated:YES];
    
}

- (IBAction)groupButton:(id)sender
{
    GroupViewController *groupController = [[GroupViewController alloc] initWithNibName:@"GroupViewController" bundle:nil];
    [self.navigationController pushViewController:groupController animated:YES];
}

- (IBAction)otherSettingsButton:(id)sender
{
    OtherSettingsController *otherController = [[OtherSettingsController alloc] initWithNibName:@"OtherSettingsController" bundle:nil];
    [self.navigationController pushViewController:otherController animated:YES];
}

- (IBAction)accountButton:(id)sender {
    
    HeyAccountController *accountController = [[HeyAccountController alloc] initWithNibName:@"HeyAccountController" bundle:nil];
    [self.navigationController pushViewController:accountController animated:YES];
}

- (IBAction)editProfileButton:(id)sender
{
    CreateProfileController *createController = [[CreateProfileController alloc] initWithNibName:@"CreateProfileController" bundle:nil];

    [self.navigationController pushViewController:createController animated:YES];
    
}

- (IBAction)helpButton:(id)sender {
    
    ImproveHeyController *master=[[ImproveHeyController alloc] initWithNibName:@"ImproveHeyController" bundle:nil];
    [self.navigationController pushViewController:master animated:YES];
}


- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
