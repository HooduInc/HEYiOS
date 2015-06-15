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
#import "Reachability.h"
#import "HeyWebService.h"
#import "ModelInAppPurchase.h"
#import "ModelUserProfile.h"
#import "InAppPurchaseHelper.h"
#import "ModelSubscription.h"
#import <StoreKit/StoreKit.h>

@interface OtherSettingsController ()<UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
    BOOL isReachable;
    NSArray *inAppProducts;
    NSNumberFormatter * priceFormatter;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

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
    NSTimeInterval timeint=[[NSDate date] timeIntervalSince1970];
    NSLog(@"MiliSeconds: %f",timeint*1000);


    
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
        [self reload];
    }
    
    else
    {
        UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:nil message:kNetworkErrorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [buyAlert show];
    }
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
    [[ModelInAppPurchase sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
    {
        if (success)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            inAppProducts = products;
            
            NSDateFormatter *format=[[NSDateFormatter alloc] init];
            [format setDateFormat:@"dd-MM-yyyy"];
            
            if (inAppProducts.count>0)
            {
                SKProduct * product = (SKProduct *) inAppProducts[0];
                NSLog(@"Selected Product Details: %@ %@ %0.2f",
                      product.productIdentifier,
                      product.localizedTitle,
                      product.price.floatValue);
                
                NSMutableArray *userProfile=[[NSMutableArray alloc] init];
                userProfile=[DBManager fetchUserProfile];
                ModelUserProfile *modObj=[userProfile objectAtIndex:0];
                
                //Check & store the trail period date or the subscription date in NSUserDefaults
                [[HeyWebService service] fetchSubscriptionDateWithUDID:modObj.strDeviceUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                 {
                     if (isError)
                     {
                         NSLog(@"Subscription Fetch Failed: %@",strMsg);
                         NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                                                   objectForKey:kSubscriptionExpirationDateKey];
                         
                         UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your subscription expired on %@",[format stringFromDate:expirationDate]] delegate:self cancelButtonTitle:@"Renew" otherButtonTitles:@"Cancel",nil];
                         buyAlert.tag=0;
                         [buyAlert show];
                     }
                     else
                     {
                         NSDictionary *resultDict=(id)result;
                        
                         
                         if ([[resultDict valueForKey:@"status"] boolValue]==true)
                         {
                             if ([[resultDict valueForKey:@"error"] containsString:@"expire on"])
                             {
                                 NSArray* mainMsgArrayString = [[resultDict valueForKey:@"error"] componentsSeparatedByString: @"expire on"];
                                 
                                 NSString *serverDateString=[[mainMsgArrayString objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                 
                                 if (serverDateString.length>0)
                                 {
                                     
                                     NSDate * serverDate =[format dateFromString:serverDateString];
                                     NSLog(@"Server Date: %@",serverDate);
                                     
                                     if (serverDate)
                                     {
                                         [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:kSubscriptionExpirationDateKey];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                     }
                                 }
                             }
                             
                             NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                                                       objectForKey:kSubscriptionExpirationDateKey];
                             
                             if ([[resultDict valueForKey:@"error"] containsString:@"You are in trial period."])
                             {
                                 UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:product.localizedTitle message:[NSString stringWithFormat:@"Description:%@ \nPrice:%@",product.localizedDescription,[priceFormatter stringFromNumber:product.price]] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Cancel",nil];
                                 
                                 buyAlert.tag=0;
                                 [buyAlert show];
                             }
                             else
                             {
                                 UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:@"Already subscribed." message:[NSString stringWithFormat:@"Subscription expires in %@",[format stringFromDate:expirationDate]] delegate:self cancelButtonTitle:@"Renew" otherButtonTitles:@"Cancel",nil];
                                 buyAlert.tag=0;
                                 [buyAlert show];
                             }
                         }
                             
                     }
                     
                 }];

            }
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
        
        #warning Remove at the time of LIVE
        
        NSMutableArray *userProfile=[[NSMutableArray alloc] init];
        userProfile=[DBManager fetchUserProfile];
        ModelUserProfile *modObj=[userProfile objectAtIndex:0];
        
        ModelSubscription *objSub=[[ModelSubscription alloc] init];
        objSub.strDeviceUDID=modObj.strDeviceUDID;
        
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        
        objSub.strPurchaseTime=[NSString stringWithFormat:@"%f",timeInMiliseconds*1000];
        objSub.purchaseState=1;
        
        [[HeyWebService service] createSubscriptionWithUDID:objSub.strDeviceUDID PurchaseTime:objSub.strPurchaseTime PurchaseState:[NSString stringWithFormat:@"%d",objSub.purchaseState] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
         {
             if (isError)
             {
                 NSLog(@"Subscription not Completed");
             }
             else
             {
                 NSDictionary *resultDict=(id)result;
                 
                 NSLog(@"Subscription details: %@",[resultDict valueForKey:@"error"]);
                 
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
                              if ([[resultDict valueForKey:@"error"] containsString:@"expire on"])
                              {
                                  NSArray* mainMsgArrayString = [[resultDict valueForKey:@"error"] componentsSeparatedByString: @"expire on"];
                                  
                                  NSString *serverDateString=[[mainMsgArrayString objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                  
                                  if (serverDateString.length>0)
                                  {
                                      NSDateFormatter *format=[[NSDateFormatter alloc] init];
                                      [format setDateFormat:@"dd-MM-yyyy"];
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
                      }
                }];
                 
             }
         }];
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



//Called by Reachability whenever status changes.
@end
