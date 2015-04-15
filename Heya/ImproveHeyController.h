//
//  ImproveHeyController.h
//  Heya
//
//  Created by jayantada on 02/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ImproveHeyController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong) IBOutlet UITextField *emailID;
@property (nonatomic,strong) IBOutlet UITextView *emailContent;
@end
