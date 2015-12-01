//
//  AppDelegate.m
//  Heya
//
//  Created by Jayanta Karmakar on 10/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "MessagesListViewController.h"
#import "SplashViewController.h"
#import "DBManager.h"
#import "ModelUserProfile.h"
#import "HeyWebService.h"

#import "InAppPurchaseHelper.h"
#import "ModelInAppPurchase.h"
#import "KeychainItemWrapper.h"
#import "Harpy.h"



@interface AppDelegate () <HarpyDelegate>
{
    BOOL isReachable;
    NSUserDefaults *preferances;
}

@end

@implementation AppDelegate

@synthesize uniqueIdentifierStr;
@synthesize navigationcontrollar,EMOJI_arr,buttonArray,imageArray;
@synthesize hostReachability,internetReachability,wifiReachability;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
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
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [DBManager checkAndCreateDatabaseAtPath:[DBManager getDBPath]];
    self.dbPath = [DBManager getDBPath];
    NSLog(@"Databse Path: %@",self.dbPath);
    
    buttonArray = [NSMutableArray array];
    preferances=[NSUserDefaults standardUserDefaults];
    

    #pragma mark - KeyChainUDID Access Start
    
    #warning "Change it to HeyMessagingAppKeyLive before make it live
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"HeyMessagingAppKeyLive" accessGroup:nil];
    
    // Get UDID from keychain (if it exists)
    uniqueIdentifierStr=[keychain objectForKey:(__bridge id)(kSecValueData)];
    
    NSLog(@"KeyChainUDID: %@",uniqueIdentifierStr);
    
    //Generate Random UDID String
    NSString *UID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"UID: %@",UID);
    
    if (uniqueIdentifierStr.length==0)
    {
        [keychain setObject:UID forKey:(__bridge id)(kSecValueData)];
        [keychain setObject:@"HEY" forKey:(id)kSecAttrAccount];
        [keychain setObject:@"HeyMessenger" forKey: (id)kSecAttrService];
        uniqueIdentifierStr=[keychain objectForKey:(__bridge id)(kSecValueData)];
        NSLog(@"KeyChainUDID Added: %@",uniqueIdentifierStr);
    }

    #pragma mark - KeyChainUDID Access End

    SplashViewController *splashController = [[SplashViewController alloc]initWithNibName:@"SplashViewController" bundle:nil];
    MessagesListViewController *msgController = [[MessagesListViewController alloc]initWithNibName:@"MessagesListViewController" bundle:nil];
    
    if (![preferances boolForKey:@"HasLaunchedOnce"])
    {
        // This is the first launch ever
        navigationcontrollar = [[UINavigationController alloc]initWithRootViewController:splashController];
        [preferances setObject:@"Standard" forKey:@"themeName"];
        NSDate *applicationInstalledDate = [NSDate date];
        NSLog(@"Application Installation Date: %@",applicationInstalledDate);
        [preferances setObject:applicationInstalledDate forKey:@"applicationInstalledDate"];
        [preferances setValue:[NSString stringWithFormat:@"%f",[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]] forKey:@"AppVersion"];
        [preferances setBool:0 forKey:@"shareHey"];
        if ([self isNetworkAvailable] == NO)
        {
            [preferances setBool:YES forKey:@"HasLaunchedOnce"];
            [self registerDevice];
        }
        [preferances synchronize];
    }
    else
    {
        // Override point for customization after application launch.
        navigationcontrollar = [[UINavigationController alloc]initWithRootViewController:msgController];
    }

    [self.window setRootViewController:navigationcontrollar];
    navigationcontrollar.navigationBarHidden = YES;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    #pragma mark Check new update avilable or not in the app store.
    
    // Set the App ID for your app
    [[Harpy sharedInstance] setAppID:@"1002913101"]; // iTunes Connect Mobile App ID
    
    // Set the UIViewController that will present an instance of UIAlertController
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    
    // (Optional) Set the Delegate to track what a user clicked on, or to use a custom UI to present your message.
    [[Harpy sharedInstance] setDelegate:self];
    
    // (Optional) The tintColor for the alertController
    //    [[Harpy sharedInstance] setAlertControllerTintColor:[UIColor purpleColor]];
    
    // (Optional) Set the App Name for your app
    [[Harpy sharedInstance] setAppName:@"Hey!"];
    
    /* (Optional) Set the Alert Type for your app
     By default, Harpy is configured to use HarpyAlertTypeOption */
    [[Harpy sharedInstance] setAlertType:HarpyAlertTypeSkip];
    
    
    // Perform check for new version of your app
    [[Harpy sharedInstance] checkVersion];
    
    
    #pragma mark ModelInAppPurchase SharedInstance
    
    //Transaction Observer if User lost network connection
    [ModelInAppPurchase sharedInstance];
    
    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushDeviceTokenId = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"PushDeviceTokenId: %@", pushDeviceTokenId);
    
    
    CGFloat currentBundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    
    NSString *strCurrentVersion = [NSString stringWithFormat:@"%f",currentBundleVersion];
    
    if (pushDeviceTokenId && pushDeviceTokenId.length>0)
    {
        if (![preferances boolForKey:@"HasLaunchedOnce"])
        {
            [preferances setBool:YES forKey:@"HasLaunchedOnce"];
            [self registerDevice];
        }
        else
        {
            //Prompt alert if the user updated the app to new version only.
            if(![strCurrentVersion isEqualToString:[preferances valueForKey:@"AppVersion"]])
            {
                  [[[UIAlertView alloc] initWithTitle:nil message:@"Congratulations! You have succesfully updated the App." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
        [preferances setValue:[NSString stringWithFormat:@"%f",currentBundleVersion] forKey:@"AppVersion"];
        [preferances synchronize];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [self registerDevice];
        [preferances setBool:YES forKey:@"HasLaunchedOnce"];
        [preferances synchronize];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Recieve Notification: %@",[userInfo valueForKey:@"aps"]);
    
    NSString *mainAlertStr=[NSString stringWithFormat:@"%@",[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]];
    
    NSArray *alertArr=[mainAlertStr componentsSeparatedByString:@"~"];
    
    NSLog(@"alertArr: %@",alertArr);
    
    [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",[[alertArr objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark
#pragma mark Call Webservice and Register the Device
#pragma mark

-(void)registerDevice
{
    
    NSMutableArray *arrayUser=[[NSMutableArray alloc] init];
    ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
    userObj.strFirstName=@"";
    userObj.strLastName=@"";
    userObj.strHeyName=@"";
    userObj.strPhoneNo=@"";
    userObj.strDeviceUDID=uniqueIdentifierStr;
    userObj.strProfileImage=@"";
    
    NSDate *today=[NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeStamp = [formatter stringFromDate:today];
    
    userObj.strCurrentTimeStamp=timeStamp;
    
    NSDate *downloadDate= (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:@"applicationInstalledDate"];
    NSDateFormatter *formatterStart = [[NSDateFormatter alloc] init];
    [formatterStart setDateFormat:@"yyyy-MM-dd"];
    NSString *accountCreated = [formatter stringFromDate:downloadDate];
    userObj.strAccountCreated=accountCreated;
    
    [arrayUser addObject:userObj];
    
    BOOL isInserted=[DBManager addProfile:arrayUser];
    
    if (isInserted)
    {
        //Send to server
        
        if([self isNetworkAvailable])
        {
            [[HeyWebService service] registerWithUDID:[uniqueIdentifierStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:@"" ContactNumber:@"" TimeStamp:timeStamp AccountCreated:accountCreated WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
             {
                 if (isError)
                 {
                     NSLog(@"Resigartion Error Message: %@",strMsg);
                     
                     if ([strMsg isEqualToString:@"This Mobile UDID already exists. Try with another!"])
                     {
                         UIAlertView *showDialog=[[UIAlertView alloc] initWithTitle:nil message:@"Already Registered." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                         
                         [showDialog show];
                         
                         [DBManager updatedToServerForUserWithFlag:1];
                         [DBManager isRegistrationSuccessful:1];
                         
                         //store the trail period date or the subscription date in NSUserDefaults
                         [[HeyWebService service] fetchSubscriptionDateWithUDID:uniqueIdentifierStr WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
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
                         //store the trail period date or the subscription date in NSUserDefaults
                         
                     }
                 }
                 
                 else
                 {   [DBManager updatedToServerForUserWithFlag:1];
                     [DBManager isRegistrationSuccessful:1];
                     
                     
                     //send push Notification
                     if (pushDeviceTokenId && pushDeviceTokenId.length>0)
                     {
                         [[HeyWebService service] fetchPushNotificationFromServerWithPushToken:[pushDeviceTokenId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] UDID:[uniqueIdentifierStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                          {
                              NSLog(@"Push Message: %@",strMsg);
                          }];
                     }
                     //send push Notification
                     
                     //store the trail period date or the subscription date in NSUserDefaults
                     [[HeyWebService service] fetchSubscriptionDateWithUDID:uniqueIdentifierStr WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
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


#pragma mark - HarpyDelegate

- (void)harpyDidShowUpdateDialog
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidLaunchAppStore
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidSkipVersion
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidCancel
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyDidDetectNewVersionWithoutAlert:(NSString *)message
{
    NSLog(@"%@", message);
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
