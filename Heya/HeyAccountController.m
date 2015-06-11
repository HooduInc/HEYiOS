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

@interface HeyAccountController ()<MBProgressHUDDelegate>
{
    NSMutableArray *pointsArray, *totalMsgCountArray;
    NSArray *menuArray;
    NSString *dateDownloaded,*appVersion;
    BOOL isReachable;
    MBProgressHUD *HUD;
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
    menuArray=[NSArray arrayWithObjects:@"Yesterday",@"This month",@"This year",@"Lifetime",@"",@"Version",@"Date Downloaded",@"",@"Account started",@"My Renewal date", nil];
    
    /*NSArray *fontFamilies = [UIFont familyNames];
    for (int i = 0; i < [fontFamilies count]; i++)
    {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
        NSLog (@"%@: %@", fontFamily, fontNames);
    }*/
}

-(void) viewWillAppear:(BOOL)animated
{
    CGFloat currentBundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    appVersion=[NSString stringWithFormat:@"%.01f",currentBundleVersion];
    
    NSDate *downloadDate= (NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:@"applicationInstalledDate"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd.yyyy"];
    dateDownloaded = [formatter stringFromDate:downloadDate];
    
    
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
        labelViewPoints.text=[totalMsgCountArray objectAtIndex:indexPath.row];
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
    //NSString *UDID= [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
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
        //[self.view addSubview:HUD];
        //[HUD show:YES];
        
        [[HeyWebService service] fetchAccountDetailsFromServerWithUDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
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
                    
                    if ([resultDict valueForKey:@"yestarday_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"yestarday_count"]]];
        
                    
                    if ([resultDict valueForKey:@"mounth_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"mounth_count"]]];
            
                    
                    if ([resultDict valueForKey:@"year_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"year_count"]]];
                
                    
                    if ([resultDict valueForKey:@"lifetime_count"])
                        [totalMsgCountArray addObject:[NSString stringWithFormat:@"%@",[resultDict valueForKey:@"lifetime_count"]]];
                
                    
                    [totalMsgCountArray addObject:@""];
                    [totalMsgCountArray addObject:appVersion];
                    [totalMsgCountArray addObject:dateDownloaded];
                    [totalMsgCountArray addObject:@""];
                    [totalMsgCountArray addObject:dateDownloaded];
                    
                    if ([resultDict valueForKey:@"my_renewal_date"])
                    {
                        
                        NSString *renewalDateString=[[resultDict valueForKey:@"my_renewal_date"] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"dd.MM.yyyy"];
                        NSDate *renewalDate= [formatter dateFromString:renewalDateString];
                        [formatter setDateFormat:@"MM.dd.yyyy"];
                        
                        [totalMsgCountArray addObject:[formatter stringFromDate:renewalDate]];
                        
                        [[NSUserDefaults standardUserDefaults] setValue:[formatter stringFromDate:renewalDate] forKey:@"accountRenewalDate"];
                    }
                    
                    NSLog(@"totalMsgCountArray :%ld",(long)totalMsgCountArray.count);
                    [self.myAccountTableView reloadData];
                }

                
            }
        }];
    }
    else
    {
        //fetch from Database
        [self fetchFromDatabase];
        [self.myAccountTableView reloadData];
        [HUD hide:YES];
        [HUD removeFromSuperview];
    }
}

-(void) fetchFromDatabase
{
    NSLog(@"YeesterDay :%ld",(long)[DBManager fetchMessageDetailsWithYestadayDate]);
    NSLog(@"CurrentMonth :%ld",(long)[DBManager fetchMessageDetailsWithCurrentMonth]);
    NSLog(@"CurrentYear :%ld",(long)[DBManager fetchMessageDetailsWithCurrentYear]);
    NSLog(@"LifeTime :%ld",(long)[DBManager fetchMessageDetailsWithLifeTime]);
    
    totalMsgCountArray=[[NSMutableArray alloc] init];
    
    NSString *yesterdayCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithYestadayDate]];
    [totalMsgCountArray addObject:yesterdayCount];
    
    NSString *currentMonthCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithCurrentMonth]];
    [totalMsgCountArray addObject:currentMonthCount];
    
    NSString *currentYearCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithCurrentYear]];
    [totalMsgCountArray addObject:currentYearCount];
    
    NSString *lifeTimeCount=[NSString stringWithFormat:@"%ld",(long)[DBManager fetchMessageDetailsWithLifeTime]];
    [totalMsgCountArray addObject:lifeTimeCount];
    
    [totalMsgCountArray addObject:@""];
    [totalMsgCountArray addObject:appVersion];
    [totalMsgCountArray addObject:dateDownloaded];
    [totalMsgCountArray addObject:@""];
    [totalMsgCountArray addObject:dateDownloaded];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"accountRenewalDate"]) {
        [totalMsgCountArray addObject:[[NSUserDefaults standardUserDefaults] valueForKey:@"accountRenewalDate"]];
    }
    else
        [totalMsgCountArray addObject:@""];
    
    NSLog(@"totalMsgCountArray :%ld",(long)totalMsgCountArray.count);
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
