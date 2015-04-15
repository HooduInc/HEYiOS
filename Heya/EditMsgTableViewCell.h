//
//  EditMsgTableViewCell.h
//  Heya
//
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditMsgTableViewCell : UITableViewCell<UITextFieldDelegate>
{
    CGFloat animatedDistance;
}
- (void) setOpen;
- (void) setClosed;

@property (nonatomic) BOOL isOpen;
@property (nonatomic, retain) IBOutlet UITextField *msgTextField;
@property (nonatomic, retain) IBOutlet UIImageView *arrow_up;
@property (nonatomic, retain) IBOutlet UIImageView *arrow_down;
@property (nonatomic, retain) IBOutlet UIImageView *cellBgImageView;


@end
