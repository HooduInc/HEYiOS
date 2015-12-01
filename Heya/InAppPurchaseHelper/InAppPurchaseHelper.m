//
//  ModelInAppPurchase.m
//  Chosen
//
//  Created by jayantada on 25/05/15.
//  Copyright (c) 2015 appsbee. All rights reserved.
//

#import "InAppPurchaseHelper.h"
#import <StoreKit/StoreKit.h>
#import "ModelUserProfile.h"
#import "HeyWebService.h"
#import "ModelSubscription.h"
#import "ModelUserProfile.h"
#import <libkern/OSAtomic.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const kSubscriptionExpirationDateKey = @"ExpirationDate";
NSString *const kSubscriptionPurchaseState = @"PurchaseState";

@interface InAppPurchaseHelper () <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@end


@implementation InAppPurchaseHelper
{
    SKProductsRequest *productsRequest;
    RequestProductsCompletionHandler requsetCompletionHandler;
    NSSet * allProductIdentifiers;
    NSMutableSet *purchasedProductIdentifiers;
}


- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        allProductIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in allProductIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased)
            {
                [purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
                
                //Transaction Observer
                [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            }
            else
            {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    requsetCompletionHandler = [completionHandler copy];
    
    // 2
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:allProductIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    productsRequest = nil;
    
    NSArray * skProducts = response.products;
    
    NSLog(@"No. Of Products: %ld",(long)response.products.count);
    if (response.products.count>0)
    {
        NSLog(@"Loaded list of products...%@",response.products);
        /*for (SKProduct * skProduct in skProducts)
        {
            NSLog(@"Found product: %@ %@ %0.2f",skProduct.productIdentifier,skProduct.localizedTitle,skProduct.price.floatValue);
        }*/
    }
    
    
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    requsetCompletionHandler(YES, skProducts);
    requsetCompletionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    productsRequest = nil;
    
    requsetCompletionHandler(NO, nil);
    requsetCompletionHandler = nil;
    
}


- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    
    if (userProfile.count>0)
    {
        ModelUserProfile *modObj=[userProfile firstObject];
        
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
         }];
    }
    

    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark
#pragma mark - Non Renwable Subscription Method Implementation
#pragma mark

/*- (int)daysRemainingOnSubscription
{
    //1
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults]
                              objectForKey:kSubscriptionExpirationDateKey];
    
    //2
    NSTimeInterval timeInt = [expirationDate timeIntervalSinceDate:[NSDate date]];
    
    //3
    int days = timeInt / 60 / 60 / 24;
    
    //4
    if (days > 0)
    {
        return days;
    }
    else
    {
        return 0;
    }
}


- (NSDate *)getExpirationDateForMonths:(int)months
{
    
    NSDate *originDate = nil;
    
    //1
    if ([self daysRemainingOnSubscription] > 0)
    {
        originDate = [[NSUserDefaults standardUserDefaults]
                      objectForKey:kSubscriptionExpirationDateKey];
    }
    else
    {
        originDate = [NSDate date];
    }
    
    //2
    NSDateComponents *dateComp = [[NSDateComponents alloc] init];
    [dateComp setMonth:months];
    [dateComp setDay:1]; //add an extra day to subscription because we love our users
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComp
                                                         toDate:originDate
                                                        options:0];
}
 
- (NSString *)getExpirationDateString
{
    __block NSString *returnValue=@"";
    
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    ModelUserProfile *modObj=[userProfile objectAtIndex:0];
    
     __block int32_t counter = 0;
    OSAtomicIncrement32(&counter);
    
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
                 
                 NSDate * serverDate = [NSDate dateWithTimeIntervalSince1970:1409030961];
                 returnValue=[NSString stringWithFormat:@"Subscription \nExpires on : %@ ",serverDate];
             }
             else
             {
                 returnValue= @"Not Subscribed";
             }
         }
         OSAtomicDecrement32(&counter);
         
     }];
    
    while (counter > 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    
    return returnValue;
    
}

- (void)purchaseSubscriptionWithMonths:(int)months
{
    //1
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    ModelUserProfile *modObj=[userProfile objectAtIndex:0];
    
    
    [[HeyWebService service] fetchSubscriptionDateWithUDID:modObj.strDeviceUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
    {
        
        if (isError)
        {
            NSLog(@"Subscription Fetch Failed: %@",strMsg);
        }
        else
        {
            
            NSDictionary *resultDict=(id)result;
            
            if (resultDict)
            {
                NSLog(@"Subscription details recieved.");
            }
            
            
            NSDate * serverDate = [NSDate dateWithTimeIntervalSince1970:1409030961];
            
            NSDate * localDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionExpirationDateKey];
            
            //3
            if ([serverDate compare:localDate] == NSOrderedDescending) {
                [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:kSubscriptionExpirationDateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //4
            NSDate * expirationDate = [self getExpirationDateForMonths:months];
            
            //5
            [object addObject:expirationDate forKey:kSubscriptionExpirationDateKey];
            [object saveInBackground];
            
            [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:kSubscriptionExpirationDateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
    }];
}*/
 
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    
    // Start of the new code you need to add
    //if ([productIdentifier isEqualToString:@"HeyMessenger.HooduInc.com.180subscribe"])
    //{
        //[self purchaseSubscriptionWithMonths:12];
    //}
    //END OF NEW CODE
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

@end
