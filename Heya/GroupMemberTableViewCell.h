//
//  GroupMemberTableViewCell.h
//  Heya
//
//  Created by jayantada on 01/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GroupMemberTableViewCellDelegate <NSObject>
- (void)buttonChangeActionForItemText:(id)sender;
- (void)buttonDeleteActionForItemText:(id)sender;
@end

@interface GroupMemberTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UIView *myContentView;
@property (nonatomic, weak) IBOutlet UIButton *deleteTextBtn;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImgBackground;
@property (nonatomic, strong) IBOutlet UILabel *groupMemberName;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;

@property (nonatomic, weak) id <GroupMemberTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) UIImage *itemImage;

@property (nonatomic, strong) IBOutlet NSString *strMemberId;
@property (nonatomic, strong) IBOutlet NSString *strMemberOrder;

@end