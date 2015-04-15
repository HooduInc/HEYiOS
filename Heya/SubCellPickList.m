//
//  SubCellPickList.m
//  Heya
//
//  Created by jayantada on 28/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "SubCellPickList.h"

@implementation SubCellPickList
@synthesize subTextLabel;
@synthesize checkMarkImage;
@synthesize cellEditBtn;
@synthesize indexPath;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
