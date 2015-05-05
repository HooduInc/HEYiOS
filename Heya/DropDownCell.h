//
//  DropDownCell.h
//  DropDownTest
//
//  Created by Florian Krüger on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DropDownCell : UITableViewCell
{}

- (void) setOpen;
- (void) setClosed;

@property (nonatomic) BOOL isOpen;

@property (nonatomic, weak) IBOutlet UIImageView *mainImage;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrow_up;
@property (nonatomic, weak) IBOutlet UIImageView *arrow_down;
@property (nonatomic, weak) IBOutlet UIButton *btnHeader;

@end
