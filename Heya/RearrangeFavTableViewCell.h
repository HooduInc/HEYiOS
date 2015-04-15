//
//  RearrangeTableViewCell.h
//  Heya
//
//  Created by jayantada on 30/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RearrangeFavTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *name_lbl;
@property (nonatomic, strong) IBOutlet UIImageView *profileImg;
@property (strong,nonatomic) IBOutlet NSLayoutConstraint *consLeadSpace;

@property (nonatomic, strong) NSString *favoriteId;
@property (nonatomic, strong) NSString *favoriteOrder;

@end
