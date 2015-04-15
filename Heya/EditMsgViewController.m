//
//  EditMsgViewController.m
//  Heya
//
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "EditMsgViewController.h"
#import "EditMsgTableViewCell.h"
#import "EditMsgBtnTableViewCell.h"
#import "ViewAppCell.h"
#import "ChangeColorView.h"
#import "PickFromListController.h"
#import "RearrangeViewController.h"

#import "CategoryClass.h"
#import "SectionView.h"


#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface EditMsgViewController ()

@end

@implementation EditMsgViewController

@synthesize editMsgTableView, editMsgTableViewTwo, editMsgTableViewThree, editMsgTableViewFour, editMessageListScrollView;
@synthesize cellBgImageArray, menuMessageArray, editMainMenuMsgArray, mainArrayWithCategory ,mainMenuText,openSectionIndex;

NSUserDefaults *preferances;
NSString *saveEditValue;
int sendIDToDB, sendSubMenuIDToDB, menuflag, submenuInsertionFlag, rearrangeFlag;
static NSString *CellIdentifier = @"Cell";
NSMutableArray *indexPathArrayUniversal;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.editMessageListScrollView.contentSize = CGSizeMake(1280, self.editMessageListScrollView.frame.size.height);
    
}
-(void) viewWillAppear:(BOOL)animated
{
    indexPathArrayUniversal = [[NSMutableArray alloc] init];// used to catch the indexpath of opened cells
    
    editMsgTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    editMsgTableViewTwo.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    editMsgTableViewThree.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    editMsgTableViewFour.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    preferances=[NSUserDefaults standardUserDefaults];
    
    menuMessageArray = [[NSMutableArray alloc] init];
    editMainMenuMsgArray = [[NSMutableArray alloc] init];
    mainArrayWithCategory = [[NSMutableArray alloc]init];
    
    menuMessageArray = [DBManager fetchmenu:0 noOfRows:32];
    NSLog(@"menuMessageArray = %@",menuMessageArray);
    for(int i=0; i< [menuMessageArray count]; i++)
    {
        CategoryClass *catclass_obj = [[CategoryClass alloc]init];
        
        NSMutableDictionary *menuMsgListDic = [[NSMutableDictionary alloc] init];
        menuMsgListDic = [menuMessageArray objectAtIndex:i];
        NSMutableArray *submenuExists =[[NSMutableArray alloc] init];
        submenuExists=[DBManager fetchSubmenuWithmenuId:[menuMsgListDic valueForKey:@"MenuId"]];
        
        
        if ([submenuExists count]>0)
        {
            NSMutableArray *tempArr=[[NSMutableArray alloc] init];
            for(int j=0; j<[submenuExists count];j++)
            {
                //NSLog(@"submenuExists: %@",[[submenuExists objectAtIndex:j] valueForKey:@"SubMenuName"]);
                [tempArr addObject:[NSString stringWithFormat:@"%@", [[submenuExists objectAtIndex:j] valueForKey:@"SubMenuName"]]];
            }
            catclass_obj.menuname =[NSString stringWithFormat:@"%@",[menuMsgListDic valueForKey:@"MenuName"]] ;
            catclass_obj.menulist =tempArr;
            NSLog(@"SubMenuList: %@",catclass_obj.menulist);
        }
        else
        {
        catclass_obj.menuname =[NSString stringWithFormat:@"%@",[menuMsgListDic valueForKey:@"MenuName"]] ;
        }
    
        [menuMsgListDic  setValue:submenuExists forKey:@"SubMenu"];
        [editMainMenuMsgArray addObject:menuMsgListDic];
        [mainArrayWithCategory addObject:catclass_obj];
    }
    
    NSLog(@"Main Array: %@",editMainMenuMsgArray);
    
    [editMsgTableView reloadData];
    [editMsgTableViewTwo reloadData];
    [editMsgTableViewThree reloadData];
    [editMsgTableViewFour reloadData];
    
    
    //[NSTimer scheduledTimerWithTimeInterval: 0.25 target:self selector:@selector(refreshTable) userInfo:nil repeats:NO];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([editMainMenuMsgArray count]==0)
        return 0;
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = [editMainMenuMsgArray objectAtIndex:section];
    NSArray *arr = [dic valueForKey:@"SubMenu"];
    unsigned long count=[arr count]+2;
    
    switch (section) {
        case 0:
            if (dropDown1Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
                //return 2;
            }
            else
            {
                return 1;
            }
            break;
            
        case 1:
            if (dropDown2Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 2:
            if (dropDown3Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 3:
            if (dropDown4Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 4:
            if (dropDown5Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 5:
            if (dropDown6Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 6:
            if (dropDown7Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }
        case 7:
            if (dropDown8Open)
            {
                if(submenuInsertionFlag==1)
                {
                    
                    return count+1;
                }
                else
                {
                    return count;
                }
            }
            else
            {
                return 1;
            }


        default:
            return 1;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    if(submenuInsertionFlag==1)
                        return 40;
                    else
                    return 77;
                    break;
                }

            }
            
            break;
        }
        case 1:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }

            }
            
            break;
        }
        case 2:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }

            }
            
            break;
        }

        case 3:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }
            }
            
            break;
        }
        case 4:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }
            }
            
            break;
        }
        case 5:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }
            }
            
            break;
        }
        case 6:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                    
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }
            }
            
            break;
        }
        case 7:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    return 65;
                    break;
                }
                case 1:
                {
                    return 40;
                }
                default:
                {
                    return 77;
                    break;
                }
            }
            
            break;
        }



        default:
            return 65;
            break;
    }

    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DropDownCellIdentifier = @"EditMsgTableViewCell";
    
    switch ([indexPath section])
    {
        case 0:
        {
            
            switch ([indexPath row]) {
                case 0: {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                            NSLog(@"Section 0 Menu: %@",MenuColor);
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        
                        if (dropDown1Open) {
                            [cell setOpen];
                        }
                        
                        //[[cell textLabel] setText:dropDown1];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                
                                cell.addDelSubMenuButton.titleLabel.text =[NSString stringWithFormat:@"%ld,%ld", (long)[indexPath section], (long)[indexPath row]];
                                
                                [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
        
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                        
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 1:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        
                        if (dropDown2Open) {
                            [cell setOpen];
                        }
                        
                        [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                        
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 2:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }


                        if (dropDown3Open) {
                            [cell setOpen];
                        }
                        
                        [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 3:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }


                        if (dropDown4Open) {
                            [cell setOpen];
                        }
                        
                      //  [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }

                        }
                        return cell;

                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                                
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }


                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            //NSLog(@"Submenu Values: %@",dic);
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }

                    break;
                }
            }
            
            break;
        }
        case 4:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }

                        if (dropDown5Open) {
                            [cell setOpen];
                        }
                        
                        [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        
                        else
                        {
                        
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                           
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 5:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        
                        if (dropDown6Open) {
                            [cell setOpen];
                        }
                        
                       // [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 6:
        {
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if (dropDown7Open) {
                            [cell setOpen];
                        }
                        
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==1)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }

                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        case 7:
        {
            
            switch ([indexPath row])
            {
                case 0: {
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        if(tableView.tag==1)
                        {
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==2)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==3)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }
                        if(tableView.tag==4)
                        {
                            
                            NSString *MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            cell.cellBgImageView.image = [UIImage imageNamed:MenuColor];
                            cell.msgTextField.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"];
                            cell.msgTextField.enabled=NO;
                        }

                        if (dropDown8Open) {
                            [cell setOpen];
                        }
                        
                        [[cell textLabel] setText:dropDown2];
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default:
                {
                    EditMsgBtnTableViewCell *cell = (EditMsgBtnTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    ViewAppCell *viewAppCell = (ViewAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (indexPath.row ==  1)
                    {
                        
                        if (cell == nil) {
                            //NSLog(@"New Cell Made");
                            
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgBtnTableViewCell" owner:nil options:nil];
                            
                            cell=[topLevelObjects objectAtIndex:0];
                            
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==2)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuId"];
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==3)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            if(tableView.tag==4)
                            {
                                cell.editMsgButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.changeColorButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                cell.pickListButton.titleLabel.text = [NSString stringWithFormat:@"%@,%@", [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"], [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuName"]];
                                cell.addDelSubMenuButton.titleLabel.text = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuId"];
                                
                                
                                 [cell.editMsgButton addTarget:self action:@selector(changemenufromlist:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.pickListButton addTarget:self action:@selector(pickFromList:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.changeColorButton addTarget:self action:@selector(changemenucolor:) forControlEvents:UIControlEventTouchUpInside];
                                [cell.addDelSubMenuButton addTarget:self action:@selector(addDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                            }
                            
                        }
                        return cell;
                        
                    }
                    else
                    {
                        if(submenuInsertionFlag==1)
                        {
                            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ViewCellNormal"
                                                                         owner:self options:nil];
                            viewAppCell=[nib objectAtIndex:0];
                            
                            viewAppCell.subMenuText.text = @"";
                            
                            
                        }
                        else
                        {
                            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ViewCelledit" owner:nil options:nil];
                            
                            for(id currentObject in topLevelObjects)
                            {
                                if([currentObject isKindOfClass:[ViewAppCell class]])
                                {
                                    viewAppCell = (ViewAppCell *)currentObject;
                                    break;
                                }
                            }
                            
                            NSMutableArray *arr;
                            NSString *MenuColor;
                            if(tableView.tag==1)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==2)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+8] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==3)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+16] valueForKey:@"MenuColor"];
                            }
                            if(tableView.tag==4)
                            {
                                arr = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"SubMenu"];
                                MenuColor = [[editMainMenuMsgArray objectAtIndex:[indexPath section]+24] valueForKey:@"MenuColor"];
                            }
                            
                            
                            
                            NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 2)] ;
                            viewAppCell.editmsg_txt.text = [dic valueForKey:@"SubMenuName"];
                            viewAppCell.editmsg_txt.enabled=NO;
                            viewAppCell.bubble_img.image = [UIImage imageNamed:MenuColor];
                            viewAppCell.changemsg_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"]];
                            viewAppCell.picfronlist_btn.titleLabel.text =[NSString stringWithFormat:@"%@,%@, %@",[dic valueForKey:@"MenuId"],[dic valueForKey:@"SubmenuId"], [dic valueForKey:@"SubMenuName"]];
                            
                            [viewAppCell.changemsg_btn addTarget:self action:@selector(changeSubMenuName:) forControlEvents:UIControlEventTouchUpInside];
                            [viewAppCell.picfronlist_btn addTarget:self action:@selector(pickFromListForSubMenu:) forControlEvents:UIControlEventTouchUpInside];
                        }
                        return viewAppCell;
                    }
                    
                    break;
                }
            }
            
            break;
        }
        default:
            return nil;
            break;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [editMainMenuMsgArray objectAtIndex:[indexPath section]];
    NSArray *arr = [dic valueForKey:@"SubMenu"];
    NSLog(@"array count %lu", (unsigned long)[arr count]);
    
    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    switch ([indexPath section])
    {
        case 0:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    unsigned long count=[arr count]+2;
                    
                    if(submenuInsertionFlag==1)
                    {
                        count=count+1;
                        for (int i = 1; i <count; i++)
                        {
                            path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                            [indexPathArray addObject:path];
                            [indexPathArrayUniversal addObject:path];
                            
                        }
                    }
                    else
                    {
                        for (int i = 1; i <count; i++)
                        {
                            path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                            [indexPathArray addObject:path];
                        }
                    }
                    //NSLog(@"indexPathArrayUniversal %@", indexPathArrayUniversal);
                
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown1Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
                        //openSectionIndex = NSNotFound;
                        submenuInsertionFlag=0;
                        
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown1Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                        
                    }
                    
                    break;
                }
                default:
                {
                    if(submenuInsertionFlag==1)
                    {
                        [tableView cellForRowAtIndexPath:indexPath];
                        NSArray *indexPathArray = [NSArray arrayWithObjects:indexPath, nil];
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                        
                    }
                    if (submenuInsertionFlag==0)
                    {
                        
                        NSArray *indexPathArray = [NSArray arrayWithObjects:indexPath, nil];
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationBottom];
                    }
                    break;
                }
            }
            
            break;
        }
        case 1:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                        
                    }
                    
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown2Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        
                        /*if (dropDown1Open)
                        {
                            NSLog(@"Cell is Open");
                            NSLog(@"indexPathArrayUniversal %@", indexPathArrayUniversal);
                            [cell setClosed];
                            
                            [tableView deleteRowsAtIndexPaths:indexPathArrayUniversal withRowAnimation:UITableViewRowAnimationBottom];
                        }*/
                        
                        [cell setOpen];
                        dropDown2Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 2:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown3Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown3Open = [cell isOpen];
                        
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                        NSLog(@"indexPath: %@",indexPathArray);
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 3:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown4Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown4Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 4:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown5Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown5Open = [cell isOpen];

                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 5:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown6Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown6Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 6:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown7Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown7Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }
        case 7:
        {
            
            switch ([indexPath row]) {
                case 0:
                {
                    //EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    unsigned long count=[arr count]+2;
                    
                    if(submenuInsertionFlag==1)
                    {
                        count=count+1;
                        for (int i = 1; i <count; i++) {
                            path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                            [indexPathArray addObject:path];
                        }
                    }
                    
                    for (int i = 1; i <([arr count] +2); i++) {
                        path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                        [indexPathArray addObject:path];
                    }
                    
                    
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                        dropDown8Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    else
                    {
                        [cell setOpen];
                        dropDown8Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    break;
                }
            }
            
            break;
        }


        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


//This method is due to the move cells icons is on right by default, we need to move it.
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
    if([sourceIndexPath section]==[destinationIndexPath section])
    {
        NSLog(@"Source Row Index: %ld", (long)[sourceIndexPath row]);
        NSLog(@"Destination Row Index: %ld", (long)[destinationIndexPath row]);
        
        NSString *actualMenuIdSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"MenuId"];
        NSArray *allSubMenuSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"SubMenu"];
        
        NSMutableDictionary *actualSubMenuDicSource=[allSubMenuSource objectAtIndex:[sourceIndexPath row]-1];
        NSLog(@"actualSubMenuDicSource: %@", actualSubMenuDicSource);
        NSString *actualSubMenuIdSource=[actualSubMenuDicSource valueForKey:@"SubmenuId"];
        NSString *actualSubMenuOrderSource=[actualSubMenuDicSource valueForKey:@"SubMenuOrder"];
        NSLog(@"SubmenuIdSource AND SubmenuOrderSource %@,%@",actualSubMenuIdSource,actualSubMenuOrderSource);
        
        
        NSMutableDictionary *actualSubMenuDicDestination=[allSubMenuSource objectAtIndex:[destinationIndexPath row]-1];
        //NSLog(@"actualSubMenuDicDestination: %@", actualSubMenuDicDestination);
        NSString *actualSubMenuIdDestination=[actualSubMenuDicDestination valueForKey:@"SubmenuId"];
        NSString *actualSubMenuOrderDestination=[actualSubMenuDicDestination valueForKey:@"SubMenuOrder"];
        NSLog(@"SubmenuIdDestination AND SubmenuOrderDestination %@,%@",actualSubMenuIdDestination,actualSubMenuOrderDestination);
         NSString *stringToMove = [allSubMenuSource objectAtIndex:[sourceIndexPath row]-1];
                                     
        [[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"SubMenu"] removeObjectAtIndex:[sourceIndexPath row]-1];
        
        [[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"SubMenu"] insertObject:stringToMove atIndex:[destinationIndexPath row]-1];
        
        //[DBManager updateSubMenuOrderWithMenuId:actualMenuIdSource withSubMenuId:actualSubMenuIdSource withSubMenuOrder:actualSubMenuOrderSource withSubMenuIdDestination:actualSubMenuIdDestination withSubMenuOrderDestination:actualSubMenuOrderDestination];
        
        //[DBManager updateMenuOrderWithMenuId:actualMenuIdSource withMenuOrder:actualMenuOrderSource withMenuIdDestination:actualMenuIdDestination withMenuOrderDestination:actualMenuOrderDestination];

    }
    else
    {
        NSString *actualMenuOrderSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"MenuOrder"];
        NSLog(@"actualMenuOrderSource: %@", actualMenuOrderSource);
        NSString *actualMenuIdSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"MenuId"];
        NSLog(@"Source Section Index: %ld", (long)[sourceIndexPath section]);
        NSLog(@"actualMenuIdSource: %@\n", actualMenuIdSource);
        
        
        NSString *actualMenuOrderDestination=[editMainMenuMsgArray[destinationIndexPath.section] valueForKey:@"MenuOrder"];
        NSLog(@"actualMenuOrderSource: %@", actualMenuOrderDestination);
        NSString *actualMenuIdDestination=[editMainMenuMsgArray[destinationIndexPath.section] valueForKey:@"MenuId"];
        NSLog(@"Destination Section Index: %ld", (long)[destinationIndexPath section]);
        NSLog(@"actualMenuIdSource: %@", actualMenuIdDestination);

        NSString *stringToMove = editMainMenuMsgArray[sourceIndexPath.section];
        //NSLog(@"stringToMove: %@", stringToMove);
        [editMainMenuMsgArray removeObjectAtIndex:sourceIndexPath.section];
        [editMainMenuMsgArray insertObject:stringToMove atIndex:destinationIndexPath.section];
        
        
        [DBManager updateMenuOrderWithMenuId:actualMenuIdSource withMenuOrder:actualMenuOrderSource withMenuIdDestination:actualMenuIdDestination withMenuOrderDestination:actualMenuOrderDestination];
    }
    
    //rearrangeFlag=1;
}

/*- (NSIndexPath *) tableView: (UITableView *) tableView targetIndexPathForMoveFromRowAtIndexPath: (NSIndexPath *) sourceIndexPath toProposedIndexPath: (NSIndexPath *) proposedDestinationIndexPath
 {
     NSLog(@"sourceIndexPath: %ld",(long)[sourceIndexPath section]);
     NSLog(@"proposedDestinationIndexPath: %ld",(long)[proposedDestinationIndexPath section]);
     
     NSString *actualMenuOrderSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"MenuOrder"];
     NSLog(@"actualMenuOrderSource: %@", actualMenuOrderSource);
     NSString *actualMenuIdSource=[editMainMenuMsgArray[sourceIndexPath.section] valueForKey:@"MenuId"];
     NSLog(@"Source Section Index: %ld", (long)[sourceIndexPath section]);
     NSLog(@"actualMenuIdSource: %@\n", actualMenuIdSource);
     
     
     NSString *actualMenuOrderDestination=[editMainMenuMsgArray[proposedDestinationIndexPath.section] valueForKey:@"MenuOrder"];
     NSLog(@"actualMenuOrderSource: %@", actualMenuOrderDestination);
     NSString *actualMenuIdDestination=[editMainMenuMsgArray[proposedDestinationIndexPath.section] valueForKey:@"MenuId"];
     NSLog(@"Destination Section Index: %ld", (long)[proposedDestinationIndexPath section]);
     NSLog(@"actualMenuIdSource: %@", actualMenuIdDestination);
     
     NSString *stringToMove = editMainMenuMsgArray[sourceIndexPath.section];
     //NSLog(@"stringToMove: %@", stringToMove);
     [editMainMenuMsgArray removeObjectAtIndex:sourceIndexPath.section];
     [editMainMenuMsgArray insertObject:stringToMove atIndex:proposedDestinationIndexPath.section];
     
     
     [DBManager updateMenuOrderWithMenuId:actualMenuIdSource withMenuOrder:actualMenuOrderSource withMenuIdDestination:actualMenuIdDestination withMenuOrderDestination:actualMenuOrderDestination];


     rearrangeFlag=1;

     return proposedDestinationIndexPath;
 }*/


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (IBAction)rearrangeButton:(id)sender {
    
    RearrangeViewController *reController=[[RearrangeViewController alloc] initWithNibName:@"RearrangeViewController" bundle:nil];
    
    reController.editMainMenuMsgArray=[[NSMutableArray alloc] init];
    reController.editMainMenuMsgArray=editMainMenuMsgArray;
    
    [self.navigationController pushViewController:reController animated:YES];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
 [super setEditing: editing animated: YES];
     
 EditMsgTableViewCell *cell = (EditMsgTableViewCell*)[editMsgTableView  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
     
     [self tableView:editMsgTableView willDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
 
 if (editing)
 {
 //UIView* reorderControl = [cell huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
 //NSLog(@"%@", reorderControl);
 //[reorderControl setBackgroundColor:[UIColor redColor]];
 }
}


//Gesture Delegate methods

/*- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    NSIndexPath *indexPath = [editMsgTableView indexPathForRowAtPoint:[sender locationInView:editMsgTableView]];
    [editMsgTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    // If you have custom logic in table view delegate method, also invoke this method too
    [self tableView:editMsgTableView didSelectRowAtIndexPath:indexPath];
}

-(void) resizeReorderControl: (UITableView *)tableView reorderCell:(UITableViewCell *)bCell{
    
    UIView* reorderControl = [bCell huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
    if (!reorderControl) {
        reorderControl = [bCell huntedSubviewWithClassName:@"UITableViewCellScrollView"]; // for iOS7
    }
    //Then I added my gesture recognizer:

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecognizer.delegate = self;
    [reorderControl addGestureRecognizer:tapGestureRecognizer];
   
}*/



- (void) changemenufromlist:(UIButton*)sender
{
    //NSLog(@"Sender Tag: %ld",(long)sender.tag);
    menuflag = 1;
    NSString *menuID=sender.titleLabel.text;
    NSLog(@"MenuID: %@",menuID);
    
    if([menuID intValue]<8)
    {
       EditMsgTableViewCell *cell = (EditMsgTableViewCell*)[editMsgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[menuID intValue]-1]];
        cell.msgTextField.enabled = YES;
        [cell.msgTextField becomeFirstResponder];
        
        NSLog(@"Section: %d", [menuID intValue]-1);
        NSLog(@"Text: %@",cell.msgTextField.text);
    }
    
    if([menuID intValue]>=8 && [menuID intValue]<16)
    {
        EditMsgTableViewCell *cell = (EditMsgTableViewCell*)[editMsgTableViewTwo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[menuID intValue]-9]];
        cell.msgTextField.enabled = YES;
        [cell.msgTextField becomeFirstResponder];
        
        NSLog(@"Section: %d", [menuID intValue]-9);
        NSLog(@"Text: %@",cell.msgTextField.text);
       
    }
    
    if([menuID intValue]>=16 && [menuID intValue]<24)
    {
        EditMsgTableViewCell *cell = (EditMsgTableViewCell*)[editMsgTableViewThree cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[menuID intValue]-17]];
        cell.msgTextField.enabled = YES;
        [cell.msgTextField becomeFirstResponder];
        
        NSLog(@"Section: %d", [menuID intValue]-17);
        NSLog(@"Text: %@",cell.msgTextField.text);
    }
    
    if([menuID intValue]>=24 && [menuID intValue]<=32)
    {
        EditMsgTableViewCell *cell = (EditMsgTableViewCell*)[editMsgTableViewFour cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[menuID intValue]-25]];
        cell.msgTextField.enabled = YES;
        [cell.msgTextField becomeFirstResponder];
        
        NSLog(@"Section: %d", [menuID intValue]-26);
        NSLog(@"Text: %@",cell.msgTextField.text);
    }
    

    sendIDToDB=[menuID intValue]; //store MenuID
    
    //NSLog(@"Cell Message: %@",cell.msgTextField.text);
    //NSLog(@"MenuID: %d",sendIDToDB);

}

- (void) changeSubMenuName:(UIButton*)sender{
    
    NSArray *subStrings = [sender.titleLabel.text componentsSeparatedByString:@","];
    NSString *menuID = [subStrings objectAtIndex:0];
    NSString *subMenuID = [subStrings objectAtIndex:1];
    
    NSLog(@"MenuID:%@ and SubmenuID:%@ ",menuID,subMenuID);
    
    ViewAppCell *viewAppCell = (ViewAppCell *)[editMsgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[subMenuID intValue]+1 inSection:[menuID intValue]-1]];
    viewAppCell.editmsg_txt.enabled = YES;
    [viewAppCell.editmsg_txt becomeFirstResponder];
    
    sendIDToDB=[menuID intValue];
    sendSubMenuIDToDB=[subMenuID intValue];
}


- (void) pickFromList:(UIButton*)sender{
    
    
    NSString *MenuDetails=sender.titleLabel.text;
    NSLog(@"MenuID: %@",MenuDetails);
    
    PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
    pickListController.MainMenuDetailsFromPrevious=MenuDetails;
    pickListController.MainMenuFlag=YES;
    pickListController.FlagFromSettings=NO;
    [self.navigationController pushViewController:pickListController animated:YES];
}


- (void) pickFromListForSubMenu:(UIButton*)sender{
    
    NSString *SubMenuDetails=sender.titleLabel.text;
    NSLog(@"SubMenuDetails: %@",SubMenuDetails);
    
    PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
    pickListController.SubMenuDetailsFromPrevious=SubMenuDetails;
    pickListController.FlagFromSettings=NO;
    [self.navigationController pushViewController:pickListController animated:YES];
}


- (void) changemenucolor:(UIButton*)sender{
    
    menuflag = 1;
    NSString *menuID=sender.titleLabel.text;
    NSLog(@"Clicked: %ld", [menuID integerValue]);
    
    ChangeColorView *colorController = [[ChangeColorView alloc] initWithNibName:@"ChangeColorView" bundle:nil];
    colorController.changeIndex = [menuID integerValue];
    
    //colorController.submenuIndex=idPath;
    [self.navigationController pushViewController:colorController animated:YES];
}


-(void) addDelSubMenu:(UIButton*)sender
{
    
//    NSArray *tmpIndexPath=[sender.titleLabel.text componentsSeparatedByString:@","];
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[tmpIndexPath objectAtIndex:1] integerValue]+1 inSection:[[tmpIndexPath objectAtIndex:0] integerValue]];
//    
//    if(sender.enabled)
//    {
//      submenuInsertionFlag=1;
//      [self tableView:editMsgTableView didSelectRowAtIndexPath:indexPath];
//      //sender.enabled=NO;
//        
//    }
  
    //NSMutableArray *submenuExists =[[NSMutableArray alloc] init];
    //submenuExists=[DBManager fetchSubmenuWithmenuId:@"4"];
    //[[editMainMenuMsgArray objectAtIndex:0] setValue:[submenuExists objectAtIndex:0] forKey:@"SubMenu"];
    //NSLog(@"Menu Message: %@",[editMainMenuMsgArray objectAtIndex:0]);
    //[editMsgTableView reloadData];
    
    
}



- (IBAction)SaveDataToDB:(id)sender {
    
   if(rearrangeFlag==1)
   {
       [self setEditing:NO];
       [editMsgTableView setEditing:NO];
       [editMsgTableViewTwo setEditing:NO];
       [editMsgTableViewThree setEditing:NO];
       [editMsgTableViewFour setEditing:NO];
       
       [self viewWillAppear:YES];
       [self.editMsgTableView reloadData];
       [self.editMsgTableViewTwo reloadData];
       [self.editMsgTableViewThree reloadData];
       [self.editMsgTableViewFour reloadData];
       
       rearrangeFlag=0;
   }

        if(menuflag == 1)
        {
            menuflag = 0;
            if(sendIDToDB)
            {
                //section starts from 0
                //menu starts from 1 in database
                EditMsgTableViewCell *cell;
                if(sendIDToDB<8)
                {
                    cell = (EditMsgTableViewCell*)[editMsgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendIDToDB-1]];
                    
                    if(cell.msgTextField.text.length>0)
                    {
                        [DBManager updatemenuWithMenuId:[NSString stringWithFormat:@"%d",sendIDToDB] withMenuTitle:cell.msgTextField.text];
                        
                        
                        [cell.msgTextField resignFirstResponder];
                        [self viewWillAppear:YES];
                        //[self.editMsgTableView reloadData];
                    }
                }
                
                if(sendIDToDB>=8 && sendIDToDB<16)
                {
                    cell = (EditMsgTableViewCell*)[editMsgTableViewTwo cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendIDToDB-9]];
                    
                    
                    if(cell.msgTextField.text.length>0)
                    {
                        [DBManager updatemenuWithMenuId:[NSString stringWithFormat:@"%d",sendIDToDB] withMenuTitle:cell.msgTextField.text];
                        
                        
                        [cell.msgTextField resignFirstResponder];
                        [self viewWillAppear:YES];
                        //[self.editMsgTableViewTwo reloadData];
                    }
                }
                
                if(sendIDToDB>=16 && sendIDToDB<24)
                {
                    cell = (EditMsgTableViewCell*)[editMsgTableViewThree cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendIDToDB-17]];
                    
                    if(cell.msgTextField.text.length>0)
                    {
                        [DBManager updatemenuWithMenuId:[NSString stringWithFormat:@"%d",sendIDToDB] withMenuTitle:cell.msgTextField.text];
                        
                        
                        [cell.msgTextField resignFirstResponder];
                        [self viewWillAppear:YES];
                        //[self.editMsgTableViewThree reloadData];
                    }
                }
                
                if(sendIDToDB>=24 && sendIDToDB<=32)
                {
                    cell = (EditMsgTableViewCell*)[editMsgTableViewFour cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sendIDToDB-25]];
                    
                    if(cell.msgTextField.text.length>0)
                    {
                        [DBManager updatemenuWithMenuId:[NSString stringWithFormat:@"%d",sendIDToDB] withMenuTitle:cell.msgTextField.text];
                        
                        
                        [cell.msgTextField resignFirstResponder];
                        [self viewWillAppear:YES];
                        //[self.editMsgTableViewFour reloadData];
                    }
                }
                
                NSLog(@"MenuID: %d",sendIDToDB);
                NSLog(@"Text Value: %@",cell.msgTextField.text);
            
                
            }
        }
        else
        {
            menuflag=0;
            if(sendIDToDB && sendSubMenuIDToDB)
            {
                ViewAppCell *viewAppCell = (ViewAppCell*)[editMsgTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sendSubMenuIDToDB+1 inSection:sendIDToDB-1]];
                
                
                NSLog(@"Menu ID & SubMenuID: %@, %@",[NSString stringWithFormat:@"%d",sendIDToDB], [NSString stringWithFormat:@"%d",sendSubMenuIDToDB]);
                NSLog(@"Text Value: %@",viewAppCell.editmsg_txt.text);
            
                if(viewAppCell.editmsg_txt.text.length>0)
                {
                    [DBManager updatesubnemuWithMenuId:[NSString stringWithFormat:@"%d,%d",sendIDToDB,sendSubMenuIDToDB] withsubmenutitle:viewAppCell.editmsg_txt.text];
                
                    [viewAppCell.editmsg_txt resignFirstResponder];
                    [self viewWillAppear:YES];
                    /*[self.editMsgTableView reloadData];
                    [self.editMsgTableViewTwo reloadData];
                    [self.editMsgTableViewThree reloadData];
                    [self.editMsgTableViewFour reloadData];*/
                }
            }
        }

        //[self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)editMessageListScrollChangePage{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.editMessageListScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.editMessageListScrollView.frame.size;
    [self.editMessageListScrollView scrollRectToVisible:frame animated:YES];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.editMessageListScrollView.frame.size.width;
    int page = floor((self.editMessageListScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}

- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
