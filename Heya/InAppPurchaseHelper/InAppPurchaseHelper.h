//
//  ModelInAppPurchase.h
//  Chosen
//
//  Created by jayantada on 25/05/15.
//  Copyright (c) 2015 appsbee. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface InAppPurchaseHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

@end
