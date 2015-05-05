//
//  MenuListSelectedTableViewCell.m
//  Heya
//
//  Created by jayantada on 16/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "MenuListSelectedTableViewCell.h"

@implementation MenuListSelectedTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.btnChangeMessage.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    // you probably want to center it
    self.btnChangeMessage.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btnChangeMessage setTitle:@"Edit\nMessage" forState:UIControlStateNormal];
    
    self.btnPickFromList.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    // you probably want to center it
    self.btnPickFromList.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.btnPickFromList setTitle:@"Pick from\nList" forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
