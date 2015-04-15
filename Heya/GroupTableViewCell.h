//
//  GroupTableViewCell.h
//  Heya
//
//  Created by jayantada on 30/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GroupTableViewCellDelegate <NSObject>
- (void)groupButtonChangeActionForItemText:(id)sender;
- (void)buttonDeleteActionForItemText:(id)sender;
@end

@interface GroupTableViewCell : UITableViewCell
{
    
}

@property (nonatomic, strong) IBOutlet UIView *myConteView;
@property (nonatomic, weak) IBOutlet UIButton *changeTextBtn;
@property (nonatomic, weak) IBOutlet UIButton *deleteTextBtn;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImgBackground;
@property (nonatomic, strong) IBOutlet UITextField *groupNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;

@property (nonatomic, weak) id <GroupTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) UIImage *itemImage;

@property (nonatomic, strong) IBOutlet NSString *groupIdString;
@property (nonatomic, strong) IBOutlet NSString *groupOrderString;


@end
