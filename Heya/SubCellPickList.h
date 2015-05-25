//
//  SubCellPickList.h
//  Heya
//
//  Created by jayantada on 28/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubCellPickList : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *subTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImage;
@property (weak, nonatomic) IBOutlet UIButton *cellEditBtn;
@property (weak, nonatomic) IBOutlet UIButton *fullBtn;
@property (weak, nonatomic) IBOutlet UILabel *topSeperator;
@property (strong,nonatomic) NSIndexPath *indexPath;

@end
