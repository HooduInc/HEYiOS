//
//  SettingsViewController.h
//  Heya
//
//  Created by Jayanta Karmakar on 16/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UIScrollViewDelegate>
{}
- (IBAction)editProfileButton:(id)sender;
- (IBAction)helpButton:(id)sender;
- (IBAction)selectThemeButtonTapped:(id)sender;
- (IBAction)pickListButton:(id)sender;
- (IBAction)favouriteButton:(id)sender;
- (IBAction)groupButton:(id)sender;
- (IBAction)otherSettingsButton:(id)sender;
- (IBAction)accountButton:(id)sender;
- (IBAction)back:(id)sender;

@property(nonatomic, strong) IBOutlet UIScrollView *settingsScrollView;
@property(nonatomic, strong) IBOutlet UIView *fourthView;
@property (weak, nonatomic) IBOutlet UIImageView *settingsProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *settingsPhoneNo;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *themeNameLabel;

@end
