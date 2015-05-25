//
//  AppDelegate.h
//  Heya
//
//  Created by Jayanta Karmakar on 10/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{}

@property (nonatomic, retain) NSString *dbPath;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationcontrollar;
@property (nonatomic, strong) NSArray *EMOJI_arr;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *imageArray;


@end
