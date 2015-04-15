//
//  RearrangeGroupTableViewCell.m
//  Heya
//
//  Created by jayantada on 03/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "RearrangeGroupTableViewCell.h"

@implementation RearrangeGroupTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width / 2;
    self.profileImg.clipsToBounds = YES;
    self.profileImg.contentMode=UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
