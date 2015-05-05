//
//  MenuListTableViewCell.h
//  Heya
//
//  Created by jayantada on 12/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListTableViewCell : UITableViewCell

@property(strong,nonatomic) IBOutlet UIImageView *imgBackground;
@property(strong,nonatomic) IBOutlet UIButton *btnClose;
@property(strong,nonatomic) IBOutlet UITextField *txtFiled;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintLeadingSpace;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintTrailingSpace;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseWidth;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseHeight;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintBgImgBottomSpace;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintBgImgTopSpace;

@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintbtnArrowWidth;
@property(strong,nonatomic) IBOutlet NSLayoutConstraint *constraintbtnSaveWidth;
@property(strong,nonatomic) IBOutlet UIButton *btnHeader;
@property(strong,nonatomic) IBOutlet UIButton *btnArrow;
@property(strong,nonatomic) IBOutlet UIButton *btnSave;
@end
