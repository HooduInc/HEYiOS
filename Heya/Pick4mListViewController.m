//
//  Pick4mListViewController.m
//  Heya
//
//  Created by jayantada on 27/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "Pick4mListViewController.h"
#import "MBProgressHUD.h"
#import "DropDownCell.h"
#import "SubCellPickList.h"

#import "ModelPickListMenu.h"
#import "ModelPickListSubMenu.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"

@interface Pick4mListViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UITableView *pickListTableView;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *editButton;
    IBOutlet UILabel *editLabel;
    
    MBProgressHUD *HUD;
    NSInteger selectedSection;
    NSIndexPath *selectedIndexPath, *addPickListIndexPath;
    BOOL isEditEnabled;
    NSString *MenuID,*MenuName;
    NSString *SubMenuID, *MenuIDFromSub, *SubMenuName;
}

@end

@implementation Pick4mListViewController


@synthesize tempPickList;
@synthesize MainMenuDetailsFromPrevious,SubMenuDetailsFromPrevious;
@synthesize MainMenuFlag,FlagFromSettings;


#pragma mark
#pragma mark UIViewController Initalization
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    selectedSection=-1;
    
    if(FlagFromSettings==YES)
    {
        editButton.hidden=NO;
        saveButton.hidden=YES;
    }
    else
    {
        saveButton.hidden=YES;
        editButton.hidden=YES;
    }
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        
        //Mostly Coding Part
        [self.view addSubview:HUD];
        [HUD show:YES];
        [self generatePickListArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            
            //Mostly UI Updates
            [pickListTableView  reloadData];// 3
            [HUD hide:YES];
            [HUD removeFromSuperview];
        });
    });
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark
#pragma mark TableView Delegate Methods
#pragma mark


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"No Of Sections: %ld",(long)[tempPickList count]);
    return [tempPickList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 65.0f;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 4.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *DropDownCellIdentifier = @"DropDownCell";
    DropDownCell *cell = (DropDownCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
    
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"DropDownCell" owner:self options:nil] objectAtIndex:0];
    }
    
    ModelPickListMenu *objMenu = [tempPickList objectAtIndex:section];
    
    cell.mainImage.image = [UIImage imageNamed:objMenu.strPickImage];
    cell.textLabel.text = objMenu.strPickMenuName;
    
    [cell.btnHeader setUserInteractionEnabled:YES];
    [cell.btnHeader addTarget:self action:@selector(btnHeaderPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnHeader setTag:section];
    
    
    if (objMenu.arrPickSubMenu.count==0)
        cell.arrow_down.hidden=YES;

    
    if (objMenu.isSubMenuOpen)
    {
        cell.arrow_down.transform=CGAffineTransformMakeRotation(M_PI);
        
    }
    else
    {
        cell.arrow_down.transform=CGAffineTransformMakeRotation(M_PI*2);
    }
    
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedSection==-1)
    {
        return 0;
    }
    else
    {
        if (selectedSection==section)
        {
            ModelPickListMenu *objPickMenu=[tempPickList objectAtIndex:section];
            
            if (isEditEnabled==YES)
                return objPickMenu.arrPickSubMenu.count+1;
            
            else
                return objPickMenu.arrPickSubMenu.count;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"MyCell";
    ModelPickListMenu *objMenu = [tempPickList objectAtIndex:[indexPath section]];
    
    if (indexPath.row==[self tableView:tableView numberOfRowsInSection:indexPath.section]-1 && isEditEnabled==YES)
    {
        //This is for Last Row.Enter your message here is disabled but will generate new sub message bubble by clicking it.
        SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:self options:nil] objectAtIndex:0];
        }
        
        cell.fullBtn.userInteractionEnabled=YES;
        cell.fullBtn.hidden=NO;
         [cell.fullBtn addTarget:self action:@selector(cellAddPickTextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Add to Pick List" attributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] }];
        cell.subTextLabel.attributedPlaceholder = str;
        [cell.subTextLabel setUserInteractionEnabled:YES];
        cell.subTextLabel.delegate=self;
        cell.subTextLabel.tag=[objMenu.strPickMenuId integerValue];
        cell.cellEditBtn.hidden=YES;
        
        
        return cell;
        
    }
    else
    {
        
        SubCellPickList *cell = (SubCellPickList*) [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"SubCellPickList" owner:self options:nil] objectAtIndex:0];
        }
        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:indexPath.row];

        cell.fullBtn.userInteractionEnabled=NO;
        cell.fullBtn.hidden=YES;
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
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            longPress.minimumPressDuration = 0.7; //seconds
            longPress.delegate = self;
            [cell addGestureRecognizer:longPress];
        }
        else
        {
            [cell.cellEditBtn setHidden:YES];
        }
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (FlagFromSettings==NO)
    {
        selectedIndexPath=indexPath;
        UIAlertView *confirmDialog=[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Are you sure you want to update the message from Pick List?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
        confirmDialog.tag=1;
        [confirmDialog show];
    }
    
}


#pragma mark
#pragma mark IBActions & Methods
#pragma mark


-(void)btnHeaderPressed:(id)sender
{
    
    if (selectedSection==[sender tag])
    {
        selectedSection=-1;
    }
    else
    {
        selectedSection=[sender tag];
    }
    
    ModelPickListMenu *obj=[tempPickList objectAtIndex:[sender tag]];
    if (obj.arrPickSubMenu.count>0)
    {
        
        if (obj.isSubMenuOpen)
        {
            obj.isSubMenuOpen=NO;
        }
        else
            obj.isSubMenuOpen=YES;
        
        [pickListTableView reloadData];
    }
}

-(void) cellEditBtnPressed:(id)sender
{
    SubCellPickList *cell=(SubCellPickList*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[pickListTableView indexPathForCell:cell];
    //NSLog(@"Selected IndexPath: %@",indexPath);
    
    selectedIndexPath=indexPath;
    addPickListIndexPath=nil;
    [cell.subTextLabel setUserInteractionEnabled:YES];
    [cell.subTextLabel becomeFirstResponder];
    NSLog(@"Selected Value: %@",cell.subTextLabel.text);
    
}

-(void) cellAddPickTextBtnPressed:(id)sender
{
    SubCellPickList *cell=(SubCellPickList*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[pickListTableView indexPathForCell:cell];
    //NSLog(@"Selected IndexPath: %@",indexPath);
    
    addPickListIndexPath=indexPath;
    selectedIndexPath=nil;
    
    cell.fullBtn.hidden=YES;
    cell.fullBtn.userInteractionEnabled=NO;
    [cell.subTextLabel setUserInteractionEnabled:YES];
    [cell.subTextLabel becomeFirstResponder];
    
}


-(IBAction)saveBtnPressed:(id)sender
{
    NSLog(@"selectedIndexPath: %@",selectedIndexPath);
    NSLog(@"addPickListIndexPath: %@",addPickListIndexPath);
    if (selectedIndexPath!=nil)
    {
        SubCellPickList *subCell=(SubCellPickList*)[pickListTableView cellForRowAtIndexPath:selectedIndexPath];
        
        
        ModelPickListMenu *objMenu=[tempPickList objectAtIndex:[selectedIndexPath section]];
        ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:selectedIndexPath.row];
        
        NSLog(@"Needs to Update: %@",objSub.strPickSubMenuName);
        NSLog(@"Updated PickList Value: %@",subCell.subTextLabel.text);
        NSLog(@"PickID: %@",objSub.strPickMenuId);
        NSLog(@"Sub PickID: %@",objSub.strPickSubMenuId);
        
        
        if (subCell.subTextLabel.text.length>0)
        {
            if(![objSub.strPickSubMenuName isEqualToString:subCell.subTextLabel.text])
            {
                [DBManager updatePickSubMenuWithPickId:objSub.strPickSubMenuId withTableColoum:@"pickText" withColoumValue:subCell.subTextLabel.text];
                [DBManager updatePickSubMenuWithPickId:objSub.strPickMenuId withTableColoum:@"displayFlag" withColoumValue:@"0"];
                selectedIndexPath=nil;
                [self generatePickListArray];
                [pickListTableView reloadData];
            }
           
            [subCell.subTextLabel resignFirstResponder];
            [subCell.subTextLabel setUserInteractionEnabled:NO];
        }
    }
    else if(addPickListIndexPath!=nil)
    {
        SubCellPickList *subCell=(SubCellPickList*)[pickListTableView cellForRowAtIndexPath:addPickListIndexPath];
        
        if (subCell.subTextLabel.text.length>0)
        {
            NSLog(@"Cell Text: %@",subCell.subTextLabel.text);
            NSLog(@"Cell PickeMenuID: %@",[NSString stringWithFormat:@"%ld",(long)subCell.tag]);
            NSLog(@"TextField Tag: %ld",(long)subCell.subTextLabel.tag);
            
            ModelPickListSubMenu *objSub=[[ModelPickListSubMenu alloc] init];
            
            objSub.strPickMenuId=[NSString stringWithFormat:@"%ld",(long)subCell.subTextLabel.tag];
            objSub.strPickSubMenuName=subCell.subTextLabel.text;
            objSub.strPickSubMenuFlag=@"0";
            
            NSLog(@"PickMenuID: %@",objSub.strPickMenuId);
            
            NSMutableArray *createArray=[[NSMutableArray alloc] init];
            [createArray addObject:objSub];
            
            long long insertId=[DBManager insertPickSubMenu:createArray];
            
            if (insertId!=0)
            {
                addPickListIndexPath=nil;
                [self generatePickListArray];
                [pickListTableView reloadData];
            }
            subCell.fullBtn.hidden=NO;
            subCell.fullBtn.userInteractionEnabled=YES;
            [subCell.subTextLabel resignFirstResponder];
            [subCell.subTextLabel setUserInteractionEnabled:NO];
            
        }
        
        
    }
}


-(void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if ( gesture.state == UIGestureRecognizerStateEnded )
    {
        
        SubCellPickList *cellLongPressed = (SubCellPickList *) gesture.view;
        NSIndexPath *indexPath = [pickListTableView indexPathForCell:cellLongPressed];
        NSLog(@"IndexPath: %@",indexPath);
        selectedIndexPath=indexPath;
        
        UIAlertView *confirmDialog=[[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Are you sure you want to delete this item from the Pick List?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
        confirmDialog.tag=2;
        [confirmDialog show];
    }
}

-(IBAction)editBtnPressed:(id)sender
{
    saveButton.hidden=NO;
    editButton.hidden=YES;
    editLabel.hidden=NO;
    isEditEnabled=YES;
    [pickListTableView reloadData];
}

-(IBAction)backBtnPressed:(id)sender
{
    MainMenuFlag=NO;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark UITextField Delegate Methods
#pragma mark

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    SubCellPickList *cell=(SubCellPickList*)[self getSuperviewOfType:[UITableViewCell class] fromView:textField];
    NSIndexPath *indexPath=[pickListTableView indexPathForCell:cell];
    
    //NSLog(@"textFieldDidBeginEditing ->Section=%ld Row=%ld",(long)indexPath.section,(long)indexPath.row);
    
    CGRect cellRect=[pickListTableView rectForRowAtIndexPath:indexPath];
    
   [pickListTableView setContentOffset:CGPointMake(cellRect.origin.x, cellRect.origin.y) animated:YES];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [pickListTableView setContentOffset:CGPointZero animated:YES];
    [textField resignFirstResponder];
}


#pragma mark
#pragma mark UIAlertView Delegate Methods
#pragma mark

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked on : %ld",(long)buttonIndex);
    NSLog(@"AltertView Tag: %ld",(long)alertView.tag);
    
    if (buttonIndex==1 && alertView.tag==1)
    {
        if (selectedIndexPath!=nil && FlagFromSettings==NO)
        {
            ModelPickListMenu *objMenu=[tempPickList objectAtIndex:[selectedIndexPath section]];
            SubCellPickList *cell = (SubCellPickList*) [pickListTableView cellForRowAtIndexPath:selectedIndexPath];
            
            NSLog(@"Text: %@",cell.subTextLabel.text);
            NSLog(@"No Of Items: %ld",(unsigned long)(long)objMenu.arrPickSubMenu.count);
            
            BOOL recordExistsForMenu= [DBManager checkmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"menuname"];
            
            BOOL recordExistsForSubMenu= [DBManager checkSubmenuWithMenuText:cell.subTextLabel.text withTableColoum:@"submenuname"];
            
            ModelPickListSubMenu *objSub=[objMenu.arrPickSubMenu objectAtIndex:selectedIndexPath.row];
            cell.subTextLabel.text =objSub.strPickSubMenuName;
                
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
                selectedIndexPath=nil;
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Already selected."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }

    }
    else if (buttonIndex==1 && alertView.tag==2)
    {
        if (selectedIndexPath!=nil && FlagFromSettings==YES)
        {
            ModelPickListMenu *obj=[tempPickList objectAtIndex:[selectedIndexPath section]];
            ModelPickListSubMenu *objSub=[obj.arrPickSubMenu objectAtIndex:selectedIndexPath.row];
            
            if (objSub.strPickSubMenuId.length>0)
            {
                NSLog(@"SubPickID: %@",objSub.strPickSubMenuId);
                
                BOOL isDeleted =[DBManager deletePickTextWithSubPickId:objSub.strPickSubMenuId];
                
                if (isDeleted)
                {
                    [self generatePickListArray];
                    [pickListTableView reloadData];
                    UIAlertView *confirmDialog=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Deleted successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [confirmDialog show];
                }
            }
        }
    }
    
}


#pragma mark
#pragma mark Helper Method
#pragma mark


-(id)getSuperviewOfType:(id)superview fromView:(id)myView
{
    if ([myView isKindOfClass:[superview class]])
    {
        return myView;
    }
    else
    {
        id temp=[myView superview];
        
        while (1)
        {
            //NSLog(@"tempClass=%@",[temp class]);
            if ([temp isKindOfClass:[superview class]]) {
                return temp;
            }
            temp=[temp superview];
        }
    }
    return nil;
}


-(void) generatePickListArray
{
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
    
    tempPickList=[DBManager fetchAllPickFromListUpdated];
}

@end
