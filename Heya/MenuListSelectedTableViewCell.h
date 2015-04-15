//
//  MenuListSelectedTableViewCell.h
//  Heya
//
//  Created by jayantada on 16/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListSelectedTableViewCell : UITableViewCell<UITextFieldDelegate>

@property(strong,nonatomic) IBOutlet UIButton *btnClose;
@property(strong,nonatomic) IBOutlet UIButton *btnChangeMessage;
@property(strong,nonatomic) IBOutlet UIButton *btnPickFromList;
@property(strong,nonatomic) IBOutlet UIButton *btnSubMenu;
@property(strong,nonatomic) IBOutlet UITextField *txtField;
@property(strong,nonatomic) IBOutlet UIImageView *imgBackground;

@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintLeadingImage;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintTrailingImage;

@end
