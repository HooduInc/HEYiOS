//
//  OtherSettingsController.m
//  Heya
//
//  Created by jayantada on 29/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "OtherSettingsController.h"
#import "SplashViewController.h"
#import "TermsServiceViewController.h"

@interface OtherSettingsController ()
{
}
@end

@implementation OtherSettingsController
NSUserDefaults *pref;
@synthesize shareHey;

- (void)viewDidLoad {
    [super viewDidLoad];
    pref=[NSUserDefaults standardUserDefaults];
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    BOOL check=[[pref valueForKey:@"shareHey"] boolValue];
    if(check==1)
    {
        [shareHey setOn:YES animated:YES];
    }
    else
    {
        [shareHey setOn:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)shareHey:(id)sender
{
    if(shareHey.isOn)
    {
        NSLog(@"Not Enabled");
        [pref setBool:1 forKey:@"shareHey"];
    }
    else
    {
        NSLog(@"Selected");
        [pref setBool:0 forKey:@"shareHey"];
    }
}

-(IBAction)termsBtnTapped:(id)sender
{
   TermsServiceViewController *firstSplash=[[TermsServiceViewController alloc] initWithNibName:@"TermsServiceViewController" bundle:nil];
    [self.navigationController pushViewController:firstSplash animated:YES];
}

-(IBAction)tutorialBtnTapped:(id)sender
{
  // FirstSplashViewController *firstSplash=[[FirstSplashViewController alloc] initWithNibName:@"FirstSplashViewController" bundle:nil];
    
    
    SplashViewController *firstSplash=[[SplashViewController alloc] init];
    
    if (firstSplash==nil)
    {
        firstSplash=[[[NSBundle mainBundle] loadNibNamed:@"FirstSplashViewController" owner:self options:nil] objectAtIndex:1];
    }
    
    
    firstSplash.comeFromOtherSettings=YES;
    [self.navigationController pushViewController:firstSplash animated:YES];
}

- (IBAction)back:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
@end
