//
//  EditMsgTableViewCell.m
//  Heya
//
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "EditMsgTableViewCell.h"

@implementation EditMsgTableViewCell
@synthesize msgTextField, arrow_up, arrow_down, isOpen, cellBgImageView;

- (void)awakeFromNib {
    // Initialization code
    msgTextField.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];

}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


// Textfield Delegate Methods

/*static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 230;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [textField.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [textField.window convertRect:textField.bounds fromView:textField];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction)-50;
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = textField.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [textField setFrame:viewFrame];
    [UIView commitAnimations];
    
    //NSLog(@"Start Editing:%@",textField.text);
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = textField.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [textField setFrame:viewFrame];
    [UIView commitAnimations];
    
    //NSLog(@"End Editing:%@",textField.text);
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
