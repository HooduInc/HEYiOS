//
//  RearrangeTableViewCell.m
//  Heya
//
//  Created by jayantada on 30/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "RearrangeFavTableViewCell.h"

@implementation RearrangeFavTableViewCell




- (void)awakeFromNib
{
    self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width / 2;
    self.profileImg.clipsToBounds = YES;
    self.profileImg.contentMode=UIViewContentModeScaleAspectFill;
    self.profileImg.layer.borderColor=[UIColor colorWithRed:208/255.0f green:208/255.0f  blue:211/255.0f  alpha:1].CGColor;
    self.profileImg.layer.borderWidth=1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
