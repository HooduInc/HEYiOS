//
//  DropDownCell.m
//  DropDownTest
//
//  Created by Florian Krüger on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropDownCell.h"

@implementation DropDownCell

@synthesize textLabel, arrow_up, arrow_down, isOpen, btnHeader;

- (void) setOpen 
{
    [arrow_down setHidden:YES];
    [arrow_up setHidden:NO];
    [self setIsOpen:YES];
}

- (void) setClosed
{
    [arrow_down setHidden:NO];
    [arrow_up setHidden:YES];
    [self setIsOpen:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
