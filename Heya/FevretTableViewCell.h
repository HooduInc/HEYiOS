//
//  FevretTableViewCell.h
//  Heya
//
//  Created by Jayanta Karmakar on 12/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@protocol FevretTableViewCellDelegate <NSObject>
- (void)buttonChangeActionForItemText:(id)sender;
- (void)buttonDeleteActionForItemText:(id)sender;
@end

@interface FevretTableViewCell : UITableViewCell
{
    
}


@property (nonatomic, strong) IBOutlet UIView *myForegroundContentView;

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) UIImage *itemImage;

@property (nonatomic, weak) IBOutlet UIButton *changeTextBtn;
@property (nonatomic, weak) IBOutlet UIButton *deleteTextBtn;
@property (nonatomic, weak) id <FevretTableViewCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *name_lbl;
@property (nonatomic, strong) IBOutlet UIImageView *profileImgBackground;
@property (nonatomic, strong) IBOutlet UITextField *nameLabelText;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;

@property (nonatomic, strong) NSString *favoriteId;
@property (nonatomic, strong) NSString *favoriteOrder;

@end
