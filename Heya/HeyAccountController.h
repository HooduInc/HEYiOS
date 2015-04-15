//
//  AppDetailsController.h
//  Heya
//
//  Created by jayantada on 30/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeyAccountController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}
@property (weak, nonatomic) IBOutlet UITableView *myAccountTableView;
- (IBAction)back:(id)sender;

@end
