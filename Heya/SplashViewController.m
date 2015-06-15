//
//  1stViewController.m
//  Heya
//
//  Created by jayantada on 06/05/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "SplashViewController.h"
#import "MessagesListViewController.h"
#import "HorizontalScroller.h"
#import "Reachability.h"
#import "DBManager.h"
#import "ModelUserProfile.h"
#import "HeyWebService.h"
#import "InAppPurchaseHelper.h"
#import <AdSupport/AdSupport.h>

@interface SplashViewController ()<HorizontalScrollerDelegate>
{
    HorizontalScroller *myScroller;
    
    IBOutlet NSLayoutConstraint *consPosTopFirst;
    IBOutlet NSLayoutConstraint *conSecondPageViewAlignY;
    IBOutlet NSLayoutConstraint *conFifthPageViewAlignY;
    IBOutlet NSLayoutConstraint *conSixthPageViewAlignY;
    IBOutlet NSLayoutConstraint *conEightPageViewAlignY;
    IBOutlet NSLayoutConstraint *conNinthPageViewAlignY;
    
    IBOutlet UIButton *navLeftBtn;
    IBOutlet UIButton *navRightBtn;
    
    IBOutlet UIView *vwContainer;
    IBOutlet UIView *vw1;
    IBOutlet UIView *vw2;
    IBOutlet UIView *vw3;
    IBOutlet UIView *vw4;
    IBOutlet UIView *vw5;
    IBOutlet UIView *vw6;
    IBOutlet UIView *vw7;
    IBOutlet UIView *vw8;
    IBOutlet UIView *vw9;
    
    IBOutlet UILabel *superEasyWriting;
    IBOutlet UILabel *simplerFasterLabel;
    IBOutlet UIWebView *eulawebView;
    IBOutlet UIButton *eightCloseBtn;
    IBOutlet UIButton *acceptBtn;
    
    int pageCounter;
    BOOL isReachable;
    
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation SplashViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    superEasyWriting.text=@"Super Easy\nWriting";
    superEasyWriting.numberOfLines=2;
    simplerFasterLabel.text=@"Simpler\n\nFaster\n\nError-free\n\nand Funner!";
    
    NSString *htmlFile=[[NSBundle mainBundle] pathForResource:@"terms_services_preview" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [eulawebView loadHTMLString:htmlString baseURL:nil];
    
    if (isIphone4)
    {
        consPosTopFirst.constant=-60.0f;
        conSecondPageViewAlignY.constant=40.0f;
        conFifthPageViewAlignY.constant=-30.0f;
        conSixthPageViewAlignY.constant=40.0f;
        conEightPageViewAlignY.constant=-10.0f;
        conNinthPageViewAlignY.constant=-10.0f;
    }
    else
    {
        consPosTopFirst.constant=-20.0f;
    }
    
    //NSLog(@"%@",NSStringFromCGRect(vwContainer.frame));
    
    myScroller=[[HorizontalScroller alloc] initWithFrame:CGRectMake(0, 0, vwContainer.frame.size.width, vwContainer.frame.size.height)];
    [myScroller setDelegate:self];
    [vwContainer addSubview:myScroller];
}


- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    pageCounter=0;
    
    if (self.comeFromOtherSettings==NO)
    {
        navLeftBtn.hidden=YES;
        
        [self registerDevice];
    }
    else
        navLeftBtn.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller
{
    return 9;
}

-(UIView*)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index
{
    UIView *myView=nil;
    switch (index) {
        case 0:
            myView=vw1;
            break;
        case 1:
            myView=vw2;
            break;
        case 2:
            myView=vw3;
            break;
        case 3:
            myView=vw4;
            break;
        case 4:
            myView=vw5;
            break;
        case 5:
            myView=vw6;
            break;
        case 6:
            myView=vw7;
            break;
        case 7:
            myView=vw8;
            break;
            
        case 8:
            myView=vw9;
            break;
        default:
            break;
    }
    return myView;
}

-(IBAction)leftNavigationTapped:(id)sender
{
    [self hideLeftNavigationBtn];
    
    [myScroller moveToIndex:--pageCounter];
    
    [self hideLeftNavigationBtn];
}

-(IBAction)rightNavigationTapped:(id)sender
{
    [self hideLeftNavigationBtn];
    
    [myScroller moveToIndex:++pageCounter];
    
    [self hideLeftNavigationBtn];
}

-(IBAction)closeBtnTapped:(id)sender
{
    if (self.comeFromOtherSettings==NO)
    {
        MessagesListViewController *msgController=[[MessagesListViewController alloc] initWithNibName:@"MessagesListViewController" bundle:nil];
        [self.navigationController pushViewController:msgController animated:YES];
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(IBAction)acceptBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"acceptedEULA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [myScroller moveToIndex:++pageCounter];
}

-(IBAction)finalBtnTapped:(id)sender
{
    [self afterMaximumPressed];
}

-(void)beforeZeroPressed
{
    NSLog(@"%s",__FUNCTION__);
    pageCounter=0;
    
    if (self.comeFromOtherSettings==YES)
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)afterMaximumPressed
{
    NSLog(@"%s",__FUNCTION__);
    
    if (self.comeFromOtherSettings==NO)
    {
        MessagesListViewController *msgController=[[MessagesListViewController alloc] initWithNibName:@"MessagesListViewController" bundle:nil];
        [self.navigationController pushViewController:msgController animated:YES];
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)hideLeftNavigationBtn
{
    if (pageCounter==0 && self.comeFromOtherSettings==NO)
        navLeftBtn.hidden=YES;
    else
        navLeftBtn.hidden=NO;
}


-(BOOL)setPaggingEnableForHorizontalScroller:(HorizontalScroller*)scroller
{
    return YES;
}
-(CGFloat)setPaddingForHorizontalScroller:(HorizontalScroller*)scroller
{
    return 0.0f;
}


#pragma mark
#pragma Call Webservice and Register the Device
#pragma mark

-(void)registerDevice
{
    //NSString *UDID= [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *advertisingUDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    //NSLog(@"UDID: %@", UDID);
    NSLog(@"ADvertisingUDID: %@",advertisingUDID);
    
    NSMutableArray *arrayUser=[[NSMutableArray alloc] init];
    ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
    userObj.strFirstName=@"";
    userObj.strLastName=@"";
    userObj.strHeyName=@"";
    userObj.strPhoneNo=@"";
    userObj.strDeviceUDID=advertisingUDID;
    userObj.strProfileImage=@"";
    
    NSDate *today=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *timeStamp = [formatter stringFromDate:today];
    
    userObj.strCurrentTimeStamp=timeStamp;
    
    NSDate *downloadDate= (NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:@"applicationInstalledDate"];
    NSDateFormatter *formatterStart = [[NSDateFormatter alloc] init];
    [formatterStart setDateFormat:@"dd-MM-yyyy"];
    NSString *accountCreated = [formatter stringFromDate:downloadDate];
    
    userObj.strAccountCreated=accountCreated;
    
    [arrayUser addObject:userObj];
    
    BOOL isInserted=[DBManager addProfile:arrayUser];
    
    if (isInserted)
    {
        //Send to server
        
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
            [[HeyWebService service] registerWithUDID:[advertisingUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:@"" ContactNumber:@"" TimeStamp:timeStamp AccountCreated:accountCreated WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
             {
                 if (isError)
                 {
                     NSLog(@"Resigartion Error Message: %@",strMsg);
                     
                     if ([strMsg isEqualToString:@"This Mobile UDID already exists. Try with another!"])
                     {
                         UIAlertView *showDialog=[[UIAlertView alloc] initWithTitle:nil message:@"Already Registerd." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                         
                         [showDialog show];
                         
                         [DBManager updatedToServerForUserWithFlag:1];
                         [DBManager isRegistrationSuccessful:1];
                         
                         //store the trail period date or the subscription date in NSUserDefaults
                         [[HeyWebService service] fetchSubscriptionDateWithUDID:advertisingUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
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
                         //store the trail period date or the subscription date in NSUserDefaults
                         
                     }
                 }
                 
                 else
                 {   [DBManager updatedToServerForUserWithFlag:1];
                     [DBManager isRegistrationSuccessful:1];
                     
                     
                     //send push Notification
                     if (pushDeviceTokenId && pushDeviceTokenId.length>0)
                     {
                         [[HeyWebService service] fetchPushNotificationFromServerWithPushToken:[pushDeviceTokenId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] UDID:[advertisingUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                          {
                              NSLog(@"Push Message: %@",strMsg);
                          }];
                     }
                      //send push Notification
                     
                      //store the trail period date or the subscription date in NSUserDefaults
                     [[HeyWebService service] fetchSubscriptionDateWithUDID:advertisingUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
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
                     //store the trail period date or the subscription date in NSUserDefaults
                     
                     
                 }
                 
             }];
        }
        else
        {
            NSLog(@"Network is not availbale.Please try again Later.");
        }
        
    }
    
    else
        NSLog(@"Database Insertion Failed.");
    
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
