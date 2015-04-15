//
//  RearrangeGroupTableViewCell.h
//  Heya
//
//  Created by jayantada on 03/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RearrangeGroupTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *consLeadSpace;

@property (nonatomic, strong) NSString *strGroupId;
@property (nonatomic, strong) NSString *strGroupOrder;
@end
