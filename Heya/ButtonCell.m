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
    self.msg_btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.msg_btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.msg_btn setTitle:@"Change\nMessage" forState:UIControlStateNormal];
    
    self.picklist_btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.picklist_btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.picklist_btn setTitle:@"Pick from\nList" forState:UIControlStateNormal];
    
    self.changecolor_btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.changecolor_btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.changecolor_btn setTitle:@"Change\nColor" forState:UIControlStateNormal];
    
    self.adddelsubmenu_btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.adddelsubmenu_btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.adddelsubmenu_btn setTitle:@"Add/Del\nSubmenu" forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
