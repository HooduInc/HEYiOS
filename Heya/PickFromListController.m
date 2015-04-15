//
//  PickFromListController.m
//  Heya
//
//  Created by jayantada on 27/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "PickFromListController.h"
#import "DropDownCell.h"
#import "SubCellPickList.h"

#import "ModelPickListMenu.h"
#import "ModelPickListSubMenu.h"

#import "ModelMenu.h"
#import "ModelSubMenu.h"

@interface PickFromListController ()<UITextFieldDelegate>
{
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *editButton;
    
    NSIndexPath *selectedTextFieldIndexPath;
    NSString *editedPickId, *editedPickMenuId;
    NSString *checkPreviousPickText;
    BOOL isEditEnabled;
    
    NSString *MenuID,*MenuName ,*SubMenuID, *MenuIDFromSub, *SubMenuName;
}
@end

@implementation PickFromListController

@synthesize mainPickListArray,tempPickList,MainMenuDetailsFromPrevious,SubMenuDetailsFromPrevious,MainMenuFlag,FlagFromSettings;

#pragma mark
#pragma mark ViewController Initialization
#pragma mark


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(FlagFromSettings==YES)
    {
        editButton.hidden=NO;
        saveButton.hidden=YES;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    self.editTextLabel.hidden=YES;
   if(MainMenuFlag)
   {
       NSArray *Strings = [MainMenuDetailsFromPrevious componentsSeparatedByString:@","];
       MenuID = [Strings objectAtIndex:0];
       MenuName = [Strings objectAtIndex:1];
   }
   else
   {
       NSArray *subStrings = [SubMenuDetailsFromPrevious componentsSeparatedByString:@","];
       MenuIDFromSub = [subStrings objectAtIndex:0];
       SubMenuID = [subStrings objectAtIndex:1];
       SubMenuName = [subStrings objectAtIndex:2];
   }
    
    tempPickList=[[NSMutableArray alloc] init];
    tempPickList=[DBManager fetchAllPickFromListUpdated];
    
    //First Make all Picklist DisplayFlag '0'
    for(int x=0; x< [tempPickList count]; x++)
    {
        ModelPickListMenu *objMenu=[tempPickList objectAtIndex:x];
        for(int y=0; y<[objMenu.arrPickSubMenu count];y++)
        {
            ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:y];
            [DBManager updatePickSubMenuWithPickId:objSub.strPickSubMenuId withTableColoum:@"displayFlag" withColoumValue:@"0"];
        }
    }
    //First Make all Picklist DisplayFlag '0'
    
    //Check with Menu and SubMenu and if Matches Then Set Picklist DisplayFlag '1'
    NSMutableArray *arrAllPageValue=[[NSMutableArray alloc] init];
    
    for (int i=1; i<=4; i++)
        [arrAllPageValue addObject:[DBManager fetchMenuForPageNo:i]];
    
    for(int con=0; con<arrAllPageValue.count; con++)
    {
        NSMutableArray *arrDisplayTable=[arrAllPageValue objectAtIndex:con];
    
        for (int m=0; m<arrDisplayTable.count; m++)
        {
            ModelMenu *obj=[arrDisplayTable objectAtIndex:m];
            
            for(int x=0; x<[tempPickList count]; x++)
            {
                ModelPickListMenu *objMenu=[tempPickList objectAtIndex:x];
                
                for(int y=0; y<[objMenu.arrPickSubMenu count];y++)
                {
                    ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:y];
                    
                    //For Menu Checking
                    if ([[objSub.strPickSubMenuName lowercaseString] isEqualToString:[obj.strMenuName lowercaseString]])
                    {
                        [DBManager updatePickSubMenuWithPickId:objSub.strPickSubMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                    }
                    
                    //For SubMenu Checking
                    for (int y=0; y<[obj.arrSubMenu count]; y++)
                    {
                        ModelSubMenu *objSubMenu=[obj.arrSubMenu objectAtIndex:y];
                        if ([[objSub.strPickSubMenuName lowercaseString] isEqualToString:[objSubMenu.strSubMenuName lowercaseString]])
                        {
                            [DBManager updatePickSubMenuWithPickId:objSub.strPickSubMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                        }
                        
                    }
                }
     
            }
        }
    }
    //Check with Menu and SubMenu and if Matches Then Set Picklist DisplayFlag '1'
    
    tempPickList=[DBManager fetchAllPickFromListUpdated];
    [self.pickListTableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark
#pragma mark UITableView Delegate Methods
#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tempPickList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    ModelPickListMenu *obj=[tempPickList objectAtIndex:section];
    unsigned long count=[obj.arrPickSubMenu count]+1;
    
    switch (section) {
        case 0:
            if (dropDown1Open)
            {
                return count;
    
            }
            else
            {
                return 1;
            }
            break;
            
        case 1:
            if (dropDown2Open)
            {
                
                return count;
                
            }
            else
            {
                return 1;
            }
        case 2:
            if (dropDown3Open)
            {
                
                return count;
                
            }
            else
            {
                return 1;
            }
            
        case 3:
            if (dropDown4Open)
            {
                
                return count;
                
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return 0;
            break;
        }
            
        default:
            return 1;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f];
    return headerView;
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
                default:
                {
                    return 45;
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
                default:
                {
                    return 45;
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
                default:
                {
                    return 45;
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
                default:
                {
                    return 45;
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
    static NSString *CellIdentifier = @"Cell";
    static NSString *DropDownCellIdentifier = @"DropDownCell";
    
    switch ([indexPath section]) {
        case 0: {
            
            switch ([indexPath row]) {
                case 0: {
                    
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if (dropDown1Open) {
                            [cell setOpen];
                        }
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        
                        cell.mainImage.image = [UIImage imageNamed:objMenu.strPickImage];
                        cell.textLabel.text = objMenu.strPickMenuName;
                    }
                    return cell;
                    break;
                }
                default:
                {
                    SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New sub Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        cell.indexPath=indexPath;
                        //NSLog(@"Row: %ld",(long)[indexPath row]-1);
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];

                        cell.subTextLabel.text = objSub.strPickSubMenuName;
                        cell.subTextLabel.delegate=self;
                        
                        if([objSub.strPickSubMenuFlag intValue]==1)
                        {
                            cell.checkMarkImage.hidden=NO;
                        }
                        
                        cell.cellEditBtn.titleLabel.text=[NSString stringWithFormat:@"%ld, %ld, %d, %d",(long)[indexPath row], (long)[indexPath section], [objSub.strPickSubMenuId intValue], [objSub.strPickMenuId intValue]];
                        
                        [cell.cellEditBtn addTarget:self action:@selector(cellEditBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if(isEditEnabled==YES)
                        {
                            [cell.cellEditBtn setHidden:NO];
                        }
                        else
                        {
                            [cell.cellEditBtn setHidden:YES];
                        }

                    }
                    return cell;
                    
                    break;
                }
            }
            
            break;
        }
        case 1: {
            
            switch ([indexPath row]) {
                case 0: {
                    
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if (dropDown2Open) {
                            [cell setOpen];
                        }
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        
                        cell.mainImage.image = [UIImage imageNamed:objMenu.strPickImage];
                        cell.textLabel.text = objMenu.strPickMenuName;
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    
                    SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New sub Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        cell.indexPath=indexPath;
                        
                        //NSLog(@"Row: %ld",(long)[indexPath row]-1);
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                        
                        cell.subTextLabel.text = objSub.strPickSubMenuName;
                        cell.subTextLabel.delegate=self;
                        
                        if([objSub.strPickSubMenuFlag intValue]==1)
                        {
                            cell.checkMarkImage.hidden=NO;
                        }
                        
                        cell.cellEditBtn.titleLabel.text=[NSString stringWithFormat:@"%ld, %ld, %d, %d",(long)[indexPath row], (long)[indexPath section], [objSub.strPickSubMenuId intValue], [objSub.strPickMenuId intValue]];
                        
                        [cell.cellEditBtn addTarget:self action:@selector(cellEditBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if(isEditEnabled==YES)
                        {
                            [cell.cellEditBtn setHidden:NO];
                        }
                        else
                        {
                            [cell.cellEditBtn setHidden:YES];
                        }
                    }
                    
                    return cell;
                    
                    break;
                }
            }
            
            break;
        }
            
        case 2: {
            
            switch ([indexPath row]) {
                case 0: {
                    
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if (dropDown3Open) {
                            [cell setOpen];
                        }
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        
                        cell.mainImage.image = [UIImage imageNamed:objMenu.strPickImage];
                        cell.textLabel.text = objMenu.strPickMenuName;
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    
                    SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New sub Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        cell.indexPath=indexPath;
                        
                        //NSLog(@"Row: %ld",(long)[indexPath row]-1);
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                        
                        cell.subTextLabel.text = objSub.strPickSubMenuName;
                        cell.subTextLabel.delegate=self;
                        
                        if([objSub.strPickSubMenuFlag intValue]==1)
                        {
                            cell.checkMarkImage.hidden=NO;
                        }
                        
                        cell.cellEditBtn.titleLabel.text=[NSString stringWithFormat:@"%ld, %ld, %d, %d",(long)[indexPath row], (long)[indexPath section], [objSub.strPickSubMenuId intValue], [objSub.strPickMenuId intValue]];
                        
                        [cell.cellEditBtn addTarget:self action:@selector(cellEditBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if(isEditEnabled==YES)
                        {
                            [cell.cellEditBtn setHidden:NO];
                        }
                        else
                        {
                            [cell.cellEditBtn setHidden:YES];
                        }
                       
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
            }
            
            break;
        }
            
        case 3: {
            
            switch ([indexPath row]) {
                case 0: {
                    
                    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil){
                        //NSLog(@"New Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        if (dropDown4Open) {
                            [cell setOpen];
                        }
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        
                        cell.mainImage.image = [UIImage imageNamed:objMenu.strPickImage];
                        cell.textLabel.text = objMenu.strPickMenuName;
                    }
                    
                    // Configure the cell.
                    return cell;
                    
                    break;
                }
                default: {
                    SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    
                    if (cell == nil)
                    {
                        //NSLog(@"New sub Cell Made");
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                        cell.indexPath=indexPath;
                        
                        //NSLog(@"Row: %ld",(long)[indexPath row]-1);
                        
                        ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
                        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                        
                        cell.subTextLabel.text = objSub.strPickSubMenuName;
                        cell.subTextLabel.delegate=self;
                        
                        if([objSub.strPickSubMenuFlag intValue]==1)
                        {
                            cell.checkMarkImage.hidden=NO;
                        }
                        
                        cell.cellEditBtn.titleLabel.text=[NSString stringWithFormat:@"%ld, %ld, %d, %d",(long)[indexPath row], (long)[indexPath section], [objSub.strPickSubMenuId intValue], [objSub.strPickMenuId intValue]];
                        
                        [cell.cellEditBtn addTarget:self action:@selector(cellEditBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        if(isEditEnabled==YES)
                        {
                            [cell.cellEditBtn setHidden:NO];
                        }
                        else
                        {
                            [cell.cellEditBtn setHidden:YES];
                        }
                        
                    }
                    return cell;
                    
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
    ModelPickListMenu *objMenu=[tempPickList objectAtIndex:[indexPath section]];
    unsigned long count=[objMenu.arrPickSubMenu count]+1;
    
    
    switch ([indexPath section]) {
        case 0: {
            
            switch ([indexPath row]) {
                case 0:
                {
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                
                        for (int i = 1; i <count; i++)
                        {
                            path = [NSIndexPath indexPathForRow:[indexPath row]+i inSection:[indexPath section]];
                            [indexPathArray addObject:path];
                        }
                    
                    if ([cell isOpen])
                    {
                        [cell setClosed];
                       
                        dropDown1Open = [cell isOpen];
                        
                        [tableView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
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
                    SubCellPickList *cell = (SubCellPickList*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSLog(@"Text: %@",cell.subTextLabel.text);
                    BOOL recordExistsForMenu, recordExistsForSubMenu;
                    
                    recordExistsForMenu= [DBManager checkmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"menuname"];
                    
                    recordExistsForSubMenu= [DBManager checkSubmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"submenuname"];
                    
                    ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                    
                    //NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 1)] ;
                    cell.subTextLabel.text =objSub.strPickSubMenuName;
                    
                    if(FlagFromSettings==NO)
                    {
                    
                        if(!recordExistsForMenu && !recordExistsForSubMenu)
                        {
                            if(MainMenuFlag)
                            {
                                NSLog(@"MenuID from Previous: %@",MenuID);
                                NSLog(@"MenuName from Previous: %@",MenuName);
                                [DBManager updatemenuWithMenuId:MenuID withTableColoum:@"menuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:MenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                                
                            }
                            else
                            {
                                NSLog(@"MenuID from Previous: %@",MenuIDFromSub);
                                NSLog(@"SUBMenuID from Previous: %@",SubMenuID);
                                NSLog(@"MenuName from Previous: %@",SubMenuName);
                                [DBManager updateSubmenuWithMenuId:MenuIDFromSub subMenuID:SubMenuID withTableColoum:@"submenuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:SubMenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                            }
                            
                            [DBManager updatePickSubMenuWithPickId:objSub.strPickMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already selected."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    break;
                }
            }
            
            break;
        }
        case 1: {
            
            switch ([indexPath row]) {
                case 0:
                {
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <count; i++)
                    {
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
                        [cell setOpen];
                        dropDown2Open = [cell isOpen];
                        
                        [tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationTop];
                    }
                    
                    break;
                }
                default:
                {
                    SubCellPickList *cell = (SubCellPickList*) [tableView cellForRowAtIndexPath:indexPath];
                
                    NSLog(@"Text: %@",cell.subTextLabel.text);
                    BOOL recordExistsForMenu, recordExistsForSubMenu;
                    
                    recordExistsForMenu= [DBManager checkmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"menuname"];
                    
                    recordExistsForSubMenu= [DBManager checkSubmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"submenuname"];
                    
                    ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                    
                    //NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 1)] ;
                    cell.subTextLabel.text =objSub.strPickSubMenuName;
                    
                    if(FlagFromSettings==NO)
                    {
                        
                        if(!recordExistsForMenu && !recordExistsForSubMenu)
                        {
                            if(MainMenuFlag)
                            {
                                NSLog(@"MenuID from Previous: %@",MenuID);
                                NSLog(@"MenuName from Previous: %@",MenuName);
                                [DBManager updatemenuWithMenuId:MenuID withTableColoum:@"menuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:MenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                                
                            }
                            else
                            {
                                NSLog(@"MenuID from Previous: %@",MenuIDFromSub);
                                NSLog(@"SUBMenuID from Previous: %@",SubMenuID);
                                NSLog(@"MenuName from Previous: %@",SubMenuName);
                                [DBManager updateSubmenuWithMenuId:MenuIDFromSub subMenuID:SubMenuID withTableColoum:@"submenuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:SubMenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                            }
                            
                            [DBManager updatePickSubMenuWithPickId:objSub.strPickMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already selected."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    break;
                }
            }
            
            break;
        }
            
        case 2: {
            
            switch ([indexPath row]) {
                case 0:
                {
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <count; i++)
                    {
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
                    }
                    
                    break;
                }
                default:
                {
                    SubCellPickList *cell = (SubCellPickList*) [tableView cellForRowAtIndexPath:indexPath];
                    //cell.checkMarkImage.hidden=NO;
                    NSLog(@"Text: %@",cell.subTextLabel.text);
                    
                    BOOL recordExistsForMenu, recordExistsForSubMenu;
                    
                    recordExistsForMenu= [DBManager checkmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"menuname"];
                    
                    recordExistsForSubMenu= [DBManager checkSubmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"submenuname"];
                    
                    ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                    
                    //NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 1)] ;
                    cell.subTextLabel.text =objSub.strPickSubMenuName;
                    
                    if(FlagFromSettings==NO)
                    {
                        
                        if(!recordExistsForMenu && !recordExistsForSubMenu)
                        {
                            if(MainMenuFlag)
                            {
                                NSLog(@"MenuID from Previous: %@",MenuID);
                                NSLog(@"MenuName from Previous: %@",MenuName);
                                [DBManager updatemenuWithMenuId:MenuID withTableColoum:@"menuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:MenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                                
                            }
                            else
                            {
                                NSLog(@"MenuID from Previous: %@",MenuIDFromSub);
                                NSLog(@"SUBMenuID from Previous: %@",SubMenuID);
                                NSLog(@"MenuName from Previous: %@",SubMenuName);
                                [DBManager updateSubmenuWithMenuId:MenuIDFromSub subMenuID:SubMenuID withTableColoum:@"submenuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:SubMenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                            }
                            
                            [DBManager updatePickSubMenuWithPickId:objSub.strPickMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already selected."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    break;
                }
            }
            
            break;
        }
            
            
        case 3: {
            
            switch ([indexPath row]) {
                case 0:
                {
                    DropDownCell *cell = (DropDownCell*) [tableView cellForRowAtIndexPath:indexPath];
                    NSIndexPath *path;
                    NSMutableArray *indexPathArray = [[NSMutableArray alloc] init];
                    
                    for (int i = 1; i <count; i++)
                    {
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
                    SubCellPickList *cell = (SubCellPickList*) [tableView cellForRowAtIndexPath:indexPath];
                    
                    NSLog(@"Text: %@",cell.subTextLabel.text);
                    
                    BOOL recordExistsForMenu, recordExistsForSubMenu;
                    
                    recordExistsForMenu= [DBManager checkmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"menuname"];
                    
                    recordExistsForSubMenu= [DBManager checkSubmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"submenuname"];
                    
                    ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row-1];
                    
                    //NSMutableDictionary *dic = [arr objectAtIndex:([indexPath row]- 1)] ;
                    cell.subTextLabel.text =objSub.strPickSubMenuName;
                    
                    if(FlagFromSettings==NO)
                    {
                        
                        if(!recordExistsForMenu && !recordExistsForSubMenu)
                        {
                            if(MainMenuFlag)
                            {
                                NSLog(@"MenuID from Previous: %@",MenuID);
                                NSLog(@"MenuName from Previous: %@",MenuName);
                                [DBManager updatemenuWithMenuId:MenuID withTableColoum:@"menuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:MenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                                
                            }
                            else
                            {
                                NSLog(@"MenuID from Previous: %@",MenuIDFromSub);
                                NSLog(@"SUBMenuID from Previous: %@",SubMenuID);
                                NSLog(@"MenuName from Previous: %@",SubMenuName);
                                [DBManager updateSubmenuWithMenuId:MenuIDFromSub subMenuID:SubMenuID withTableColoum:@"submenuname" withColoumValue:cell.subTextLabel.text];
                                [DBManager updatePickSubMenuWithPickName:SubMenuName withTableColoum:@"displayFlag" withColoumValue:@"0"];
                            }
                            
                            [DBManager updatePickSubMenuWithPickId:objSub.strPickMenuId withTableColoum:@"displayFlag" withColoumValue:@"1"];
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already selected."
                                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
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



#pragma mark
#pragma mark IBAction Methods
#pragma mark

-(void)cellEditBtnPressed:(id)sender
{
    UIButton *button=sender;
    NSArray *titleArray=[button.titleLabel.text componentsSeparatedByString:@","];
    
    int row=[[titleArray objectAtIndex:0] intValue];
    int section=[[titleArray objectAtIndex:1] intValue];
    
    selectedTextFieldIndexPath=[NSIndexPath indexPathForRow:row inSection:section];
    editedPickId=[NSString stringWithFormat:@"%@",[titleArray objectAtIndex:2]];
    editedPickMenuId=[NSString stringWithFormat:@"%@",[titleArray objectAtIndex:3]];
    
    SubCellPickList *cell = (SubCellPickList*)[self.pickListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    checkPreviousPickText=cell.subTextLabel.text; //store picktext before editing
    cell.subTextLabel.userInteractionEnabled=YES;
    [cell.subTextLabel becomeFirstResponder];
    
    
}

- (IBAction)backButton:(id)sender
{
    MainMenuFlag=NO;
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)saveButtonPressed:(id)sender
{
    
    SubCellPickList *cell = (SubCellPickList*)[self.pickListTableView cellForRowAtIndexPath:selectedTextFieldIndexPath];
    [cell.subTextLabel resignFirstResponder];
    
    //NSLog(@"Previous Text: %@",checkPreviousPickText);
    //NSLog(@"Edited Text: %@",cell.subTextLabel.text);
    //NSLog(@"Edited PickID: %@, PickMenuID: %@",editedPickId, editedPickMenuId);
    
    if(checkPreviousPickText.length>0 && cell.subTextLabel.text.length>0 && editedPickId.length>0)
    {
        if(![checkPreviousPickText isEqualToString:cell.subTextLabel.text])
        {
            [DBManager updatePickSubMenuWithPickId:editedPickId withTableColoum:@"pickText" withColoumValue:cell.subTextLabel.text];
            [DBManager updatePickSubMenuWithPickId:editedPickId withTableColoum:@"displayFlag" withColoumValue:@"0"];
        }
        editButton.hidden=NO;
        saveButton.hidden=YES;
        isEditEnabled=NO;
        self.editTextLabel.hidden=YES;
        tempPickList=[DBManager fetchAllPickFromListUpdated];
        [self.pickListTableView reloadData];
    }
    
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Please Enter a Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)editButtonPressed:(id)sender
{
    editButton.hidden=YES;
    saveButton.hidden=NO;
    isEditEnabled=YES;
    self.editTextLabel.hidden=NO;
    [self.pickListTableView reloadData];
}


#pragma mark
#pragma mark TextField Delegate Methods
#pragma mark

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.userInteractionEnabled=NO;
    return YES;
}
@end
