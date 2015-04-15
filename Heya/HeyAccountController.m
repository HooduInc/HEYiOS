//
//  HeyAccountController.m
//  Heya
//
//  Created by jayantada on 30/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "HeyAccountController.h"
#import "Reachability.h"
#define ProfileURL @"https://qa.campusclouds.com/hey/account_details"

NSMutableArray *MainArray;
NSArray *menuArray, *pointsArray, *totalArray, *rigthsideArray;
int count=0;
@interface HeyAccountController ()
{
    NSString *totalMesssageSentLifeTime, *totalPointLifeTime;
    NSString *totalMesssageSentCurrentYear, *totalPointCurrentYear;
    NSString *totalMesssageSentCurrentMonth, *totalPointCurrentMonth;
    NSString *totalMesssageSentYesterday, *totalPointYesterday;
    BOOL isReachable;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation HeyAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    menuArray=[NSArray arrayWithObjects:@"Yesterday",@"This month",@"This year",@"Lifetime",@"",@"Version",@"Date Downloaded",@"",@"Account started",@"My Renewal date", nil];
    
    CGFloat currentBundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    NSDate *downloadDate= (NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:@"applicationInstalledDate"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd.yyyy"];
    NSString *newStartDate = [formatter stringFromDate:downloadDate];
    
    
    
    #pragma mark
    #pragma mark Yesterday Message Row
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentYesterday"])
    {
        totalMesssageSentYesterday=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentYesterday"];
    }
    else
    {
        totalMesssageSentYesterday=@"0";
    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointYesterday"])
    {
        totalPointYesterday=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointYesterday"];
    }
    else
    {
        totalPointYesterday=@"0";
    }
    
    
    #pragma mark
    #pragma mark Current Month Message Row
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentCurrentMonth"])
    {
        totalMesssageSentCurrentMonth=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentCurrentMonth"];
    }
    else
    {
        totalMesssageSentCurrentMonth=@"0";
    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointCurrentMonth"])
    {
        totalPointCurrentMonth=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointCurrentMonth"];
    }
    else
    {
        totalPointCurrentMonth=@"0";
    }
    
    
    #pragma mark
    #pragma mark Current Year Message Row
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentCurrentYear"])
    {
        totalMesssageSentCurrentYear=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentCurrentYear"];
    }
    else
    {
        totalMesssageSentCurrentYear=@"0";
    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointCurrentYear"])
    {
        totalPointCurrentYear=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointCurrentYear"];
    }
    else
    {
        totalPointCurrentYear=@"0";
    }
    
    #pragma mark
    #pragma mark Life Time Message Row
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentLifeTime"])
    {
        totalMesssageSentLifeTime=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalMesssageSentLifeTime"];
    }
    else
    {
        totalMesssageSentLifeTime=@"0";
    }
    
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointLifeTime"])
    {
        totalPointLifeTime=[[NSUserDefaults standardUserDefaults] valueForKey:@"totalPointLifeTime"];
    }
    else
    {
        totalPointLifeTime=@"0";
    }
    #pragma mark
    
    pointsArray=[NSArray arrayWithObjects:totalMesssageSentYesterday,totalMesssageSentCurrentMonth,totalMesssageSentCurrentYear,totalMesssageSentLifeTime, nil];
    totalArray=[NSArray arrayWithObjects:totalPointYesterday,totalPointCurrentMonth,totalPointCurrentYear,totalPointLifeTime, nil];
    
    rigthsideArray=[NSArray arrayWithObjects:[NSString stringWithFormat:@"%.02f",currentBundleVersion],newStartDate,newStartDate,newStartDate, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==4 || indexPath.row==7)
        return 20.0f;
    else
      return  45.0f;
    
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
    
    UILabel *menu_lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 150, 40)];
    menu_lbl.font = [UIFont fontWithName:@"Helvetica" size:15];
    menu_lbl.textColor = [UIColor blackColor];
    menu_lbl.text =[menuArray objectAtIndex:indexPath.row];
    [menu_lbl setTextAlignment:NSTextAlignmentLeft];
    [cell addSubview:menu_lbl];

    if([[menuArray objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0)
    {
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
    }
    else if (indexPath.row<4)
    {
        cell.separatorInset=UIEdgeInsetsMake(0.0f, 0, 0.0f, 10000.0f);
        
        UILabel *labelViewTotal = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 58, 38)];
        labelViewTotal.text=[totalArray objectAtIndex:indexPath.row];
        labelViewTotal.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewTotal.textAlignment=NSTextAlignmentCenter;
        labelViewTotal.font=[UIFont fontWithName:@"Helvetica" size:15];
        
        UILabel *labelViewPoints = [[UILabel alloc] initWithFrame:CGRectMake(252, 0, 58, 38)];
        labelViewPoints.text=[pointsArray objectAtIndex:indexPath.row];
        labelViewPoints.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewPoints.textAlignment=NSTextAlignmentCenter;
        labelViewPoints.font=[UIFont fontWithName:@"Helvetica" size:15];
        
        [cell addSubview:labelViewTotal];
        [cell addSubview:labelViewPoints];
        
        if(indexPath.row==3)
        {
            UILabel *labelViewSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, 46, 320, 0.5f)];
            labelViewSeperator.backgroundColor=[UIColor colorWithRed:200/255.0f green:199/255.0f blue:204/255.0f alpha:1.0];
            [cell addSubview:labelViewSeperator];
        }
    }
    else
    {
        UILabel *labelViewPoints = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 100, 38)];
        labelViewPoints.text=[rigthsideArray objectAtIndex:count];
        labelViewPoints.textColor=[UIColor colorWithRed:128/255.0f green:128/255.0f blue:128/255.0f alpha:1.0];
        labelViewPoints.textAlignment=NSTextAlignmentRight;
        labelViewPoints.font=[UIFont fontWithName:@"Helvetica" size:15];
        [cell addSubview:labelViewPoints];
        count++;
    }
    return cell;
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


//Fetch Profile Details from Sever
-(void) fetchProfileDataFromServer
{
    //NSString *UDID= [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *UDID=@"80000000000000";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    NSString *remoteHostName =ProfileURL;
    
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
        NSURL *url = [NSURL URLWithString:ProfileURL];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setAuthenticationScheme:@"https"];
        [request setValidatesSecureCertificate:NO];
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:UDID forKey:@"unique_token"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        [request startAsynchronous];
        [request setTimeOutSeconds:20];
        [request setDelegate:self];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//API Response Method
- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSLog(@"responseString: %@",responseString);
    NSError *error;
    
    NSDictionary *jsonResponeDict= [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
    
    if ([[jsonResponeDict valueForKey:@"success"] boolValue]==true)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!" message:[jsonResponeDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSLog(@"Message: %@",[jsonResponeDict valueForKey:@"message"]);
    }
    
    
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
