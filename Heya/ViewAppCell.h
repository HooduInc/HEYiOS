//
//  ViewAppCell.h
//  CitaTimeStaff
//
//  Created by Susanta Mukherjee on 11/03/14.
//  Copyright (c) 2014 Susanta Mukherjee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewAppCell : UITableViewCell<UITextFieldDelegate>{
    
}
- (void) setOpen;
- (void) setClosed;

@property (nonatomic) BOOL isOpen;

//@property (weak, nonatomic) IBOutlet UILabel *subMenu;
@property (weak, nonatomic) IBOutlet UITextField *subMenuText;
@property (nonatomic, weak) IBOutlet UIImageView *bubble_img;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@property (nonatomic, strong) IBOutlet UIButton *changemsg_btn;
@property (nonatomic, weak) IBOutlet UIButton *picfronlist_btn;
@property (nonatomic, weak) IBOutlet UITextField *editmsg_txt;
@end
