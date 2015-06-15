//
//  AppDelegate.m
//  Heya
//
//  Created by Jayanta Karmakar on 10/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "AppDelegate.h"
#import "MessagesListViewController.h"
#import "SplashViewController.h"
#import "DBManager.h"

#import <StoreKit/StoreKit.h>
#import "ModelInAppPurchase.h"



@implementation AppDelegate

@synthesize navigationcontrollar,EMOJI_arr,buttonArray,imageArray;
NSUserDefaults *preferances;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [DBManager checkAndCreateDatabaseAtPath:[DBManager getDBPath]];
    self.dbPath = [DBManager getDBPath];
    NSLog(@"Databse Path: %@",self.dbPath);
    
    buttonArray = [[NSMutableArray alloc]init];
    preferances=[NSUserDefaults standardUserDefaults];
    NSDate *applicationInstalledDate;
    
    SplashViewController *splashController = [[SplashViewController alloc]initWithNibName:@"SplashViewController" bundle:nil];
    MessagesListViewController *msgController = [[MessagesListViewController alloc]initWithNibName:@"MessagesListViewController" bundle:nil];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // This is the first launch ever
        // Override point for customization after application launch.
        navigationcontrollar = [[UINavigationController alloc]initWithRootViewController:splashController];
        
        [preferances setBool:YES forKey:@"HasLaunchedOnce"];
        [preferances setObject:@"Standard" forKey:@"themeName"];
         applicationInstalledDate = [NSDate date];
        NSLog(@"Application Installation Dtae: %@",applicationInstalledDate);
        [preferances setValue: applicationInstalledDate forKey:@"applicationInstalledDate"];
        [preferances setBool:1 forKey:@"shareHey"];
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
    
    
    //Transaction Observer if User lost network connection
    [ModelInAppPurchase sharedInstance];
    
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushDeviceTokenId = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"content---%@", pushDeviceTokenId);
    
    
    /*My token is: <70818242 975445b9 7eb911f9 e5bf6327 ab817c60 e10606d9 0ae418c1 d3857fc5>
     2015-06-10 14:05:56.795 Hey[233:16219] content---70818242975445b97eb911f9e5bf6327ab817c60e10606d90ae418c1d3857fc5*/
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
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

@end
