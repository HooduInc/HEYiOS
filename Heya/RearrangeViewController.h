//
//  EditMsgViewController.h
//  Heya
//
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RearrangeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    CGFloat animatedDistance;
}
@property (nonatomic, retain) NSMutableArray *editMainMenuMsgArray;
@property(assign,nonatomic) NSInteger pageNumber;

@end
