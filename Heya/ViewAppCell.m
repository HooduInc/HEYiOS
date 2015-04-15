//
//  ViewAppCell.m
//  CitaTimeStaff
//
//  Created by Susanta Mukherjee on 11/03/14.
//  Copyright (c) 2014 Susanta Mukherjee. All rights reserved.
//

#import "ViewAppCell.h"

@implementation ViewAppCell

@synthesize bubble_img,changemsg_btn,picfronlist_btn,editmsg_txt;
@synthesize subMenuText;


- (void)awakeFromNib {
    // Initialization code
    editmsg_txt.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    subMenuText.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) setOpen
{
    [self setIsOpen:YES];
}

- (void) setClosed
{
    [self setIsOpen:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
