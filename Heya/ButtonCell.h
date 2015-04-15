//
//  ButtonCell.h
//  Heya
//
//  Created by Jayanta Karmakar on 10/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface ButtonCell : UITableViewCell
{
    
}

@property (nonatomic, strong) IBOutlet UIButton *msg_btn;
@property (nonatomic, strong) IBOutlet UIButton *picklist_btn;
@property (nonatomic, strong) IBOutlet UIButton *changecolor_btn;
@property (nonatomic, strong) IBOutlet UIButton *adddelsubmenu_btn;
@property (strong,nonatomic) NSIndexPath *indexPath;

@property(strong,nonatomic) NSMutableDictionary *dictButtonStatus;

@end
