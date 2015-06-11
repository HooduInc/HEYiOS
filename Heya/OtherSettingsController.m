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
#import "MBProgressHUD.h"

#import "ModelInAppPurchase.h"
#import <StoreKit/StoreKit.h>

@interface OtherSettingsController ()<UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
    NSArray *inAppProducts;
    NSNumberFormatter * priceFormatter;

}
@end

@implementation OtherSettingsController
NSUserDefaults *pref;
@synthesize shareHey;

- (void)viewDidLoad
{
    [super viewDidLoad];
    pref=[NSUserDefaults standardUserDefaults];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];

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

-(IBAction)subscriptionBtnTapped:(id)sender
{
    [self reload];
}

- (IBAction)back:(id)sender
{
     [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark Fetch InApp Products
#pragma mark


- (void)reload
{
    [self.view addSubview:HUD];
    [HUD show:YES];
    
    inAppProducts = nil;
    [[ModelInAppPurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success)
        {
            inAppProducts = products;
            if (inAppProducts.count>0)
            {
                SKProduct * product = (SKProduct *) inAppProducts[0];
                NSLog(@"Selected Product Details: %@ %@ %0.2f",
                      product.productIdentifier,
                      product.localizedTitle,
                      product.price.floatValue);
                
                
                UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:product.localizedTitle message:[NSString stringWithFormat:@"Description:%@ \nPrice:%@",product.localizedDescription,[priceFormatter stringFromNumber:product.price]] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Cancel",nil];
                 
                 buyAlert.tag=0;
                 [buyAlert show];
            }
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
        }
    }];
}

#pragma mark
#pragma mark AlertView Delegate Methods
#pragma mark

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked: %@ atIndex: %ld",[alertView buttonTitleAtIndex:buttonIndex],(long)buttonIndex);
    
    if (buttonIndex==0)
    {
        SKProduct *product = inAppProducts[alertView.tag];
        
        NSLog(@"Buying %@...", product.productIdentifier);
        [[ModelInAppPurchase sharedInstance] buyProduct:product];
    }
    
}



#pragma mark
#pragma mark Notification
#pragma mark

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [inAppProducts enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier])
        {
            //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            //*stop = YES;
            
            NSLog(@"Notification against %@ registered.",product.productIdentifier);
        }
    }];
    
}
@end
