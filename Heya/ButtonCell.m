//
//  ButtonCell.m
//  Heya
//
//  Created by Jayanta Karmakar on 10/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "ButtonCell.h"

@implementation ButtonCell

@synthesize msg_btn,changecolor_btn,picklist_btn,adddelsubmenu_btn;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
