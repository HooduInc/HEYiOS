//
//  PickFromListController.h
//  Heya
//
//  Created by jayantada on 27/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickFromListController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSString *dropDown1, *dropDown2, *dropDown3, *dropDown4;
    
    BOOL dropDown1Open;
    BOOL dropDown2Open;
    BOOL dropDown3Open;
    BOOL dropDown4Open;
}
@property (nonatomic,assign) BOOL MainMenuFlag, FlagFromSettings;
@property (nonatomic,strong) NSString *MainMenuDetailsFromPrevious, *SubMenuDetailsFromPrevious;
@property (weak, nonatomic) IBOutlet UITableView *pickListTableView;
@property (weak, nonatomic) IBOutlet UILabel *editTextLabel;
@property (nonatomic,strong) NSMutableArray *tempPickList, *mainPickListArray;

- (IBAction)backButton:(id)sender;

@end
