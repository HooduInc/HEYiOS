//
//  ModelInAppPurchase.m
//  Chosen
//
//  Created by jayantada on 25/05/15.
//  Copyright (c) 2015 appsbee. All rights reserved.
//

#import "ModelInAppPurchase.h"

@implementation ModelInAppPurchase

+ (ModelInAppPurchase *)sharedInstance {
    static dispatch_once_t once;
    static ModelInAppPurchase * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.com.chosenn.battelaxe",nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
