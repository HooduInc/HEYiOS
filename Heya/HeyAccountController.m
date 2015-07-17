//
//  HeyAccountController.m
//  Heya
//
//  Created by jayantada on 30/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "HeyAccountController.h"
#import "ModelMessageSend.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "HeyWebService.h"
#import "ModelUserProfile.h"


#import "ModelInAppPurchase.h"
#import "InAppPurchaseHelper.h"
#import "ModelSubscription.h"
#import <StoreKit/StoreKit.h>

@interface HeyAccountController ()<MBProgressHUDDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton *renewBtn;
    
    MBProgressHUD *HUD;
    NSMutableArray *pointsArray, *totalMsgCountArray;
    NSArray *menuArray;
    NSString *dateDownloadedStr,*appVersion;
    BOOL isReachable;
    
    
    NSArray *inAppProducts;
    NSNumberFormatter * priceFormatter;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation HeyAccountController

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    
    menuArray=[NSArray arrayWithObjects:@"Today",@"This Month",@"This Year",@"Lifetime",@"",@"Version",@"Date Downloaded",@"",@"Account Started",@"My Renewal Date", nil];
    
    CGFloat currentBundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    appVersion=[NSString stringWithFormat:@"%.01f",currentBundleVersion];
    
    NSDate *downloadDate= (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:@"applicationInstalledDate"];
    NSLog(@"applicationInstalledDate: %@",downloadDate);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd.yyyy"];
    dateDownloadedStr = [formatter stringFromDate:downloadDate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    NSTimeInterval timeint=[[NSDate date] timeIntervalSince1970];
    NSLog(@"MiliSeconds: %f",timeint*1000);
    
    dispatch_queue_t myQueue = dispatch_queue_create("hey_account_details", NULL);
    
    dispatch_async(myQueue, ^{
        //stuffs to do in background thread
        [self.view addSubview:HUD];
        [HUD show:YES];
        [self fetchAccountDetailsFromServerORDatabase];
         
        dispatch_async(dispatch_get_main_queue(), ^{
            //stuffs to do in foreground thread, mostly UI updates
            [self.myAccountTableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([totalMsgCountArray count]>0) {
        return [totalMsgCountArray count];
    }
    else
        return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==4 || indexPath.row==7)
        return 15.0f;
    else
      return  30.0f;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    [cell setPreservesSuperviewLayoutMargins:NO];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    UILabel *menu_lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 150, 26)];
    menu_lbl.font = [UIFont fontWithName:@"Helvetica" size:14];
    menu_lbl.textColor = [UIColor blackColor];
    menu_lbl.text =[menuArray objectAtIndex:indexPath.row];
    [menu_lbl setTextAlignment:NSTextAlignmentLeft];
    [cell addSubview:menu_lbl];

    if([[menuArray objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0)
    {
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
    }
    //Message Count Portion
    else if (indexPath.row<4)
    {
        cell.separatorInset=UIEdgeInsetsMake(0.0f, 0, 0.0f, 10000.0f);
        
        UILabel *labelViewTotal = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 58, 24)];
        labelViewTotal.text=[totalMsgCountArray objectAtIndex:indexPath.row];
        labelViewTotal.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewTotal.textAlignment=NSTextAlignmentCenter;
        labelViewTotal.font=[UIFont fontWithName:@"Helvetica" size:14];
        
        UILabel *labelViewPoints = [[UILabel alloc] initWithFrame:CGRectMake(252, 0, 58, 24)];
        labelViewPoints.text=[pointsArray objectAtIndex:indexPath.row];
        labelViewPoints.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewPoints.textAlignment=NSTextAlignmentCenter;
        labelViewPoints.font=[UIFont fontWithName:@"Helvetica" size:14];
        
        [cell addSubview:labelViewTotal];
        [cell addSubview:labelViewPoints];
        
        if(indexPath.row==3)
        {
            UILabel *labelViewSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 320, 0.5f)];
            labelViewSeperator.backgroundColor=[UIColor colorWithRed:200/255.0f green:199/255.0f blue:204/255.0f alpha:1.0];
            [cell addSubview:labelViewSeperator];
        }
    }
    else
    {
        UILabel *labelViewPoints = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 100, 24)];
        labelViewPoints.text=[totalMsgCountArray objectAtIndex:indexPath.row];
        labelViewPoints.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewPoints.textAlignment=NSTextAlignmentRight;
        labelViewPoints.font=[UIFont fontWithName:@"Helvetica" size:14];
        [cell addSubview:labelViewPoints];
    }
    
    
    return cell;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


//Fetch Profile Details from Sever
-(void) fetchAccountDetailsFromServerORDatabase
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    ModelUserProfile *modObj=[userProfile objectAtIndex:0];
    
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
         //fetch from server
        
        [[HeyWebService service] fetchAccountDetailsFromServerWithUDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
            renewBtn.hidden=NO;
            
            if(isError)
            {
                NSLog(@"Couldn't fetch the details.");
                
                [self fetchFromDatabase];
                [self.myAccountTableView reloadData];
            }
            else
            {
                //NSLog(@"Success: %@",result);
                
                NSDictionary *resultDict=(id)result;
                
                if (resultDict)
                {
                    totalMsgCountArray=[[NSMutableArray alloc] init];
                    pointsArray=[[NSMutableArray alloc] init];
                    
                    if ([resultDict valueForKey:@"todays_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"todays_count"]]];
    
                    if ([resultDict valueForKey:@"todays_count_point"])
                        [pointsArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"todays_count_point"]]];
                    
        
                    if ([resultDict valueForKey:@"month_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"month_count"]]];
                    
                    if ([resultDict valueForKey:@"month_count_point"])
                        [pointsArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"month_count_point"]]];
                    
            
                    
                    
                    if ([resultDict valueForKey:@"year_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"year_count"]]];
                    
                    if ([resultDict valueForKey:@"year_count_point"])
                        [pointsArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"year_count_point"]]];
                    
                    
                
        
                    if ([resultDict valueForKey:@"lifetime_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"lifetime_count"]]];
                    
                    if ([resultDict valueForKey:@"lifetime_count_point"])
                        [pointsArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"lifetime_count_point"]]];
                    

                    [totalMsgCountArray addObject:@""];
                    [totalMsgCountArray addObject:appVersion];
                    [totalMsgCountArray addObject:dateDownloadedStr];
                    [totalMsgCountArray addObject:@""];
                    
                    
                    if ([resultDict valueForKey:@"account_started"])
                    {
                       NSString *accountStartedStr= [NSString stringWithFormat:@"%@",[resultDict valueForKey:@"account_started"]];
                        
                        [formatter setDateFormat:@"MM.dd.yyyy"];
                        NSDate *accountStarted=[formatter dateFromString:accountStartedStr];
                        
                        NSString *revisedAccountStartedDateStr=[formatter stringFromDate:accountStarted];
                        [totalMsgCountArray addObject:revisedAccountStartedDateStr];
                        
                    }
                    else
                    {
                        [totalMsgCountArray addObject:dateDownloadedStr];
                    }
                    
                    
                    NSString *renewalDate=[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"my_renewal_date"]];
                    
                    if (![renewalDate isEqualToString:@"0"])
                    {
                        [formatter setDateFormat:@"MM.dd.yyyy"];
                        NSDate *renewalDate= [formatter dateFromString:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"my_renewal_date"]]];
                        
                        [totalMsgCountArray addObject:[formatter stringFromDate:renewalDate]];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:[formatter stringFromDate:renewalDate] forKey:@"accountRenewalDate"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    else
                    {
                        [totalMsgCountArray addObject:@"Not Subscribed"];
                        [[NSUserDefaults standardUserDefaults] setObject:@"Not Subscribed" forKey:@"accountRenewalDate"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    NSLog(@"menuArray: %@",menuArray);
                    NSLog(@"totalMsgCountArray: %@",totalMsgCountArray);
                    NSLog(@"totalMsgCountArray :%ld",(long)totalMsgCountArray.count);
                    NSLog(@"pointsArray: %@",pointsArray);
                    
                    [self.myAccountTableView reloadData];
                }

                
            }
        }];
    }
    else
    {
        renewBtn.hidden=NO;
        //fetch from Database
        [self fetchFromDatabase];
        [self.myAccountTableView reloadData];
    }
}

-(void) fetchFromDatabase
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    NSLog(@"ToDay :%ld",(long)[DBManager fetchMessageDetailsWithTodayDate]);
    NSLog(@"CurrentMonth :%ld",(long)[DBManager fetchMessageDetailsWithCurrentMonth]);
    NSLog(@"CurrentYear :%ld",(long)[DBManager fetchMessageDetailsWithCurrentYear]);
    NSLog(@"LifeTime :%ld",(long)[DBManager fetchMessageDetailsWithLifeTime]);
    
    totalMsgCountArray=[[NSMutableArray alloc] init];
    pointsArray=[[NSMutableArray alloc] init];
    
    
    /*NSString *yesterdayCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithYestadayDate]];
    [totalMsgCountArray addObject:yesterdayCount];
    [pointsArray addObject:[NSString stringWithFormat:@"%d",yesterdayCount.intValue*20]];*/
    
    NSString *todayCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithTodayDate]];
    [totalMsgCountArray addObject:todayCount];
    [pointsArray addObject:[NSString stringWithFormat:@"%d",todayCount.intValue*20]];
    
    NSString *currentMonthCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithCurrentMonth]];
    [totalMsgCountArray addObject:currentMonthCount];
    [pointsArray addObject:[NSString stringWithFormat:@"%d",currentMonthCount.intValue*20]];
    
    NSString *currentYearCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithCurrentYear]];
    [totalMsgCountArray addObject:currentYearCount];
    [pointsArray addObject:[NSString stringWithFormat:@"%d",currentYearCount.intValue*20]];
    
    NSString *lifeTimeCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithLifeTime]];
    [totalMsgCountArray addObject:lifeTimeCount];
    [pointsArray addObject:[NSString stringWithFormat:@"%d",lifeTimeCount.intValue*20]];
    
    NSLog(@"PointsArray: %@",pointsArray);
    
    [totalMsgCountArray addObject:@""];
    [totalMsgCountArray addObject:appVersion];
    [totalMsgCountArray addObject:dateDownloadedStr];
    [totalMsgCountArray addObject:@""];
    [totalMsgCountArray addObject:dateDownloadedStr];
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"accountRenewalDate"])
    {
        [totalMsgCountArray addObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"accountRenewalDate"]];
    }
    else
        [totalMsgCountArray addObject:@""];
    
    NSLog(@"totalMsgCountArray :%ld",(long)totalMsgCountArray.count);
}



#pragma mark
#pragma mark Subscription
#pragma mark

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
             [format setDateFormat:@"MM.dd.yyyy"];
             
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
                      NSDictionary *resultDict=(id)result;
                      
                      if (isError)
                      {
                          NSLog(@"Subscription Fetch Failed: %@",strMsg);
                          NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                                                    objectForKey:kSubscriptionExpirationDateKey];
                          
                          UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Your subscription expired on %@",[format stringFromDate:expirationDate]] delegate:self cancelButtonTitle:@"Renew Now" otherButtonTitles:@"Later",nil];
                          buyAlert.tag=0;
                          [buyAlert show];
                      }
                      else
                      {
                          
                          
                          
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
                              
                              NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                                                        objectForKey:kSubscriptionExpirationDateKey];
                              
                              if ([[[resultDict valueForKey:@"error"] valueForKey:@"response"] containsString:@"FREE Trial!"])
                              {
                                  UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:product.localizedTitle message:[NSString stringWithFormat:@"%@",[[resultDict valueForKey:@"error"] valueForKey:@"response"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                  
                                  buyAlert.tag=0;
                                  [buyAlert show];
                              }
                              
                              else if ([[[resultDict valueForKey:@"error"] valueForKey:@"response"] containsString:@"Your trial period has expired."])
                              {
                                  UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:product.localizedTitle message:[NSString stringWithFormat:@"%@ %@ \nPrice: %@",[[resultDict valueForKey:@"error"] valueForKey:@"response"],product.localizedDescription,[priceFormatter stringFromNumber:product.price]] delegate:self cancelButtonTitle:@"Renew Now" otherButtonTitles:@"Later",nil];
                                  
                                  buyAlert.tag=0;
                                  [buyAlert show];
                              }
                              
                              else
                              {
                                  UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:@"Already Subscribed." message:[NSString stringWithFormat:@"Your subscription will expire on %@",[format stringFromDate:expirationDate]] delegate:self cancelButtonTitle:@"Renew Now" otherButtonTitles:@"Later",nil];
                                  buyAlert.tag=0;
                                  [buyAlert show];
                                  
                                  
                                  
                              }
                          }
                          
                      }
                      
                  }];
                 
             }
         }
         else
         {
             [HUD hide:YES];
             [HUD removeFromSuperview];
             
             UIAlertView *buyAlert= [[UIAlertView alloc] initWithTitle:nil message:@"Failed to load subscription items." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [buyAlert show];
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
        
        /*NSMutableArray *userProfile=[[NSMutableArray alloc] init];
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
                 
             }
         }];*/
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


@end
