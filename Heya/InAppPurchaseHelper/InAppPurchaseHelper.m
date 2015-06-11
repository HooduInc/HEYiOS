//
//  ModelInAppPurchase.m
//  Chosen
//
//  Created by jayantada on 25/05/15.
//  Copyright (c) 2015 appsbee. All rights reserved.
//

#import "InAppPurchaseHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

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

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
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

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

@end
