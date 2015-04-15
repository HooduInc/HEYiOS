//
//  EditViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 14/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "EditViewController.h"
#import "PickFromListController.h"
#import "RearrangeViewController.h"
#import "ButtonCell.h"
#import "ChangeColorView.h"

#import "MenuListTableViewCell.h"
#import "MenuListSelectedTableViewCell.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"



@interface EditViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *tblView;
    NSIndexPath *selectedIndexPath;
    BOOL isAddDelPressed;
    NSMutableArray *arrButtonStatus;
    CGPoint currentPoint;
    NSIndexPath *lastEditedIndexPath;
    NSIndexPath *selectedsubmenuIndexPath;
    
    NSString *strTemp;
    BOOL isButtonSavePressed;
    
    //for menu editing and saving
    BOOL isMenuEditingEnabled;
    BOOL isSubMenuEditingEnabled;
    NSIndexPath *menuEditingIndexPath;
    UIAlertView *saveAlert;
    int keyboardHeight;
}

@end

@implementation EditViewController

@synthesize arrDisplay,pageNumber;

#pragma mark
#pragma mark UIViewController ;
#pragma mark

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    saveAlert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Saved Successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    keyboardHeight=200;
    
    selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    arrButtonStatus=[[NSMutableArray alloc] init];
    for (int i=0; i<arrDisplay.count; i++)
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setValue:[NSNumber numberWithBool:NO] forKey:@"AddDel"];
        [dict setValue:[NSNumber numberWithBool:NO] forKey:@"ChangeColor"];
        [dict setValue:[NSNumber numberWithBool:NO] forKey:@"PickList"];
        [dict setValue:[NSNumber numberWithBool:NO] forKey:@"ChangeMessage"];
        [arrButtonStatus insertObject:dict atIndex:i];
    }
    
    isAddDelPressed=NO;
    isButtonSavePressed=NO;
    
    //Dismiss any Keyborad if background is tapped
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
    [tblView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark TableViewDelegate
#pragma mark

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(pageNumber==0)
    {
        return arrDisplay.count-1;
    }
    else
        return arrDisplay.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *str=@"MyCell";
    
    MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    [cell.btnClose setHidden:YES];
    
    ModelMenu *obj;
    obj=[arrDisplay objectAtIndex:section];
    
    
    NSString *emoString=@"\U00002764";
    NSString *loveyouString=@"Love You";
    
    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
        cell.txtFiled.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
    
    else if ([obj.strMenuName containsString:@"Write or pick message using edit"])
        cell.txtFiled.text=@"";
    else
        cell.txtFiled.text=obj.strMenuName;
    
    cell.txtFiled.tag=400+section;
    cell.txtFiled.delegate=self;
    cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
    [cell.btnHeader setTag:section];
    [cell.btnHeader addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnArrow setTag:section];
    [cell.btnArrow addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.txtFiled setUserInteractionEnabled:NO];
    [cell.txtFiled setEnabled:NO];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
        cell.txtFiled.textColor = [UIColor grayColor];
    else
        cell.txtFiled.textColor = [UIColor whiteColor];
    
    cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=0.0f;
    cell.constraintBgImgBottomSpace.constant=cell.constraintBgImgBottomSpace.constant+8;
    
    if (obj.arrSubMenu.count==0)
    {
        cell.btnArrow.hidden=YES;
    }

    UIView *headerView = [[UIView alloc] initWithFrame:[cell frame]];
    [headerView addSubview:cell];
    
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ModelMenu *obj=[arrDisplay objectAtIndex:section];
    if (selectedIndexPath==nil) {
        //NSLog(@"%ld = 0",(long)section);
        return 0;
    }else{
        if (selectedIndexPath.section==section) {
            if (obj.arrSubMenu.count==0 && isAddDelPressed==NO) {
                //NSLog(@"%ld = 1",(long)section);
                return 1;
            }
            else if (obj.arrSubMenu.count==0 && isAddDelPressed==YES){
                return 3;
            }
            else{
                //NSLog(@"%ld = %ld",(long)section,obj.arrSubMenu.count);
                return obj.arrSubMenu.count+3;
            }
        }
    }
    //NSLog(@"%ld = %ld",(long)section,obj.arrSubMenu.count);
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 54.0f;
    }
    else if (indexPath==selectedsubmenuIndexPath){
        return 80.0f;
    }
    return 44.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"MyCell";
    //NSLog(@"Section=%ld Row=%ld",(long)indexPath.section,indexPath.row);
    UITableViewCell *myCell;
    
    if (indexPath.row==0)
    {
        //This is for First Row.
        ButtonCell *cell=(ButtonCell*)[tableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"ButtonCell" owner:selectedIndexPath options:nil] objectAtIndex:0];
        }
        cell.indexPath=indexPath;
        
        [cell.msg_btn addTarget:self action:@selector(btnChangeMenuText:) forControlEvents:UIControlEventTouchUpInside];
        [cell.picklist_btn addTarget:self action:@selector(btnPickFromList:) forControlEvents:UIControlEventTouchUpInside];
        [cell.changecolor_btn addTarget:self action:@selector(btnChangeMenuCOlor:) forControlEvents:UIControlEventTouchUpInside];
        [cell.adddelsubmenu_btn addTarget:self action:@selector(btnAddDelSubMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.adddelsubmenu_btn.tag=cell.msg_btn.tag=cell.changecolor_btn.tag=cell.picklist_btn.tag=[indexPath section];
        
        
        NSMutableDictionary *dict=[arrButtonStatus objectAtIndex:indexPath.section];
        
        cell.dictButtonStatus=dict;
        if ([[dict objectForKey:@"AddDel"] boolValue])
        {
            [cell.adddelsubmenu_btn setSelected:YES];
        }
        else
        {
            [cell.adddelsubmenu_btn setSelected:NO];
        }
        
        myCell=cell;
    }
    else if (indexPath.row==[self tableView:tableView numberOfRowsInSection:indexPath.section]-1)
    {
        
        //This is for Last Row.
        MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        
        cell.constraintLeadingSpace.constant=cell.constraintTrailingSpace.constant+20.0f;
        
        if (indexPath.row==0) {
            cell.constraintBgImgTopSpace.constant=2.0f;
        }
        cell.btnArrow.hidden=YES;
        
        cell.txtFiled.text=@"Add More";
        cell.txtFiled.font=[UIFont boldSystemFontOfSize:16.0f];
        [cell.txtFiled setUserInteractionEnabled:NO];
        
        ModelMenu *obj=[arrDisplay objectAtIndex:indexPath.section];
        cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
        
        cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=0.0f;
        
        [cell.btnHeader addTarget:self action:@selector(btnAddMorePressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnHeader.hidden=NO;
        
        myCell=cell;
        
    }
    else if (indexPath.row==[self tableView:tableView numberOfRowsInSection:indexPath.section]-2)
    {
        
        //This is for 2nd Last Row.
        MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        
        cell.constraintLeadingSpace.constant=cell.constraintTrailingSpace.constant+20.0f;
        
        if (indexPath.row==0) {
            cell.constraintBgImgTopSpace.constant=2.0f;
        }
        cell.btnArrow.hidden=YES;
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Enter your message here" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
        cell.txtFiled.attributedPlaceholder = str;
        
        [cell.txtFiled setUserInteractionEnabled:YES];
        
        ModelMenu *obj=[arrDisplay objectAtIndex:indexPath.section];
        cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];

        cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=0.0f;
        
        cell.txtFiled.delegate=self;
        cell.txtFiled.returnKeyType=UIReturnKeyDone;
        
        if (indexPath.section==lastEditedIndexPath.section && indexPath.row==lastEditedIndexPath.row) {
            cell.txtFiled.text=strTemp;
        }

        myCell=cell;
        
    }
    else
    {
        ModelMenu *obj=[arrDisplay objectAtIndex:indexPath.section];
        ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:indexPath.row-1];
        if (selectedsubmenuIndexPath==indexPath)
        {
            MenuListSelectedTableViewCell *cell=(MenuListSelectedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
            if (cell==nil) {
                cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListSelectedTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            [cell.btnClose addTarget:self action:@selector(btnClosePressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnSubMenu addTarget:self action:@selector(btnSubMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btnChangeMessage addTarget:self action:@selector(btnChangeSubMenuText:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnPickFromList addTarget:self action:@selector(btnPickFromListSubMenu:) forControlEvents:UIControlEventTouchUpInside];
            
            //cell.btnPickFromList.tag=obj.strMenuId
            
            cell.txtField.delegate=self;
            cell.txtField.text=objSub.strSubMenuName;
            cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
            [cell.txtField setUserInteractionEnabled:NO];
            
            cell.constraintLeadingImage.constant=20.0f;
            //cell.constraintTrailingImage.constant=20.0f;
            
            myCell=cell;
        }
        else
        {
            MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
            if (cell==nil)
            {
                cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            
            cell.txtFiled.text=objSub.strSubMenuName;
            cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
            [cell.txtFiled setUserInteractionEnabled:NO];
            cell.btnHeader.hidden=NO;
            [cell.btnHeader addTarget:self action:@selector(btnSubMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.constraintLeadingSpace.constant=cell.constraintTrailingSpace.constant+20.0f;
            
            if (indexPath.row==0) {
                cell.constraintBgImgTopSpace.constant=2.0f;
            }
            cell.btnArrow.hidden=YES;
            
            [cell.btnClose addTarget:self action:@selector(btnClosePressed:) forControlEvents:UIControlEventTouchUpInside];
            
            if (indexPath.section==lastEditedIndexPath.section && indexPath.row==lastEditedIndexPath.row) {
                cell.txtFiled.text=strTemp;
            }
            
            cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=23.0f;
            
            [cell.contentView bringSubviewToFront:cell.btnClose];
            
            [cell.btnHeader addTarget:self action:@selector(btnSubMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            myCell=cell;
        }
    }
    
    
    return myCell;
}



#pragma mark
#pragma mark Helper Method
#pragma mark

-(id)getSuperviewOfType:(id)superview fromView:(id)myView
{
    if ([myView isKindOfClass:[superview class]]) {
        return myView;
    }
    else
    {
        id temp=[myView superview];
        while (1) {
            if ([temp isKindOfClass:[superview class]]) {
                return temp;
            }
            temp=[temp superview];
        }
    }
    return nil;
}

-(void) removeAllSubMenu:(NSString *)strmenuID
{
    [DBManager deleteAllSubMenuWithMenuId:strmenuID];
}

-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
    isMenuEditingEnabled=NO;
    isSubMenuEditingEnabled=NO;
    [tblView setContentOffset:CGPointZero animated:YES];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
}


-(void) hideAlertView
{
    [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark
#pragma mark IBAction
#pragma mark

-(void)btnSubMenuTapped:(id)sender
{
    MenuListTableViewCell *cell=(MenuListTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    if (indexPath!=selectedsubmenuIndexPath) {
        selectedsubmenuIndexPath=indexPath;
    }else{
        selectedsubmenuIndexPath=nil;
    }
    [tblView reloadData];
}

-(void)btnHeaderTapped:(id)sender
{
    if (isAddDelPressed) {
        isAddDelPressed=NO;
    }
    NSLog(@"sender tag = %ld",(long)[sender tag]);
    if (selectedIndexPath==nil)
    {
        selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:[sender tag]];
    }
    else
    {
        for (int i=0; i<arrButtonStatus.count; i++) {
            NSMutableDictionary *dict=[arrButtonStatus objectAtIndex:i];
            [dict removeObjectForKey:@"AddDel"];
            [dict setObject:[NSNumber numberWithBool:NO] forKey:@"AddDel"];
            [arrButtonStatus removeObjectAtIndex:i];
            [arrButtonStatus insertObject:dict atIndex:i];
        }
        if (selectedIndexPath.section==[sender tag]) {
            
            selectedIndexPath=nil;
        }else{
            selectedIndexPath=[NSIndexPath indexPathForRow:0 inSection:[sender tag]];
        }
    }
    [tblView reloadData];
}

-(void)btnClosePressed:(id)sender
{
    UITableViewCell *cell=(UITableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    
    ModelMenu *objMenu=[arrDisplay objectAtIndex:indexPath.section];
    ModelSubMenu *objSubMenu=[objMenu.arrSubMenu objectAtIndex:indexPath.row-1];
    
    NSLog(@"Index Path %ld %ld",(long)indexPath.section,(long)indexPath.row);
    [DBManager deleteSubMenuWithMenuId:objMenu.strMenuId withSubMenuId:objSubMenu.strSubMenuId];
    NSLog(@"Page Number = %ld",(long)pageNumber);
    arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
    [tblView reloadData];
}

-(void)btnAddMorePressed:(id)sender
{
    if (lastEditedIndexPath) {
        MenuListTableViewCell *cell=(MenuListTableViewCell*)[tblView cellForRowAtIndexPath:lastEditedIndexPath];
        cell.txtFiled.text=@"";
        [cell.txtFiled becomeFirstResponder];
    }
}

//Add or Del Submenu
-(void) btnAddDelSubMenu:(id)sender
{
    ButtonCell *cell=(ButtonCell*)[self getSuperviewOfType:[ButtonCell class] fromView:sender];
    
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    
    ModelMenu *obj=[arrDisplay objectAtIndex:[sender tag]];
    
    if([DBManager checkSubmenuWithMenuText:obj.strMenuId withTableColoum:@"menuId"])
    {
        UIAlertView *warning= [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Do You Want to Delete All Sub Messages of This Menu?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        warning.tag=[obj.strMenuId intValue];
        [warning show];
    }
    
    NSMutableDictionary *dict=[arrButtonStatus objectAtIndex:indexPath.section];
    [dict removeObjectForKey:@"AddDel"];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"AddDel"];
    [arrButtonStatus removeObjectAtIndex:indexPath.section];
    [arrButtonStatus insertObject:dict atIndex:indexPath.section];
    NSLog(@"Section = %ld row= %ld",(long)indexPath.section,(long)indexPath.row);
    selectedIndexPath=indexPath;
    isAddDelPressed=YES;
    [tblView reloadData];
}

//Change Menu Color
-(void)btnChangeMenuCOlor:(id)sender
{
    ModelMenu *obj=[arrDisplay objectAtIndex:[sender tag]];
    ChangeColorView *colorController = [[ChangeColorView alloc] initWithNibName:@"ChangeColorView" bundle:nil];
    colorController.changeIndex = [obj.strMenuId integerValue];
    [self.navigationController pushViewController:colorController animated:YES];
}

//Pick From List for Menu
-(void)btnPickFromList:(id)sender
{
    
    ModelMenu *obj=[arrDisplay objectAtIndex:[sender tag]];
    NSString *menuDetails=[NSString stringWithFormat:@"%@,%@",obj.strMenuId,obj.strMenuName];
    NSLog(@"MenuDetails sent to PickFromListController: %@",menuDetails);
    
    PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
    pickListController.MainMenuDetailsFromPrevious=menuDetails;
    pickListController.MainMenuFlag=YES;
    pickListController.FlagFromSettings=NO;
    [self.navigationController pushViewController:pickListController animated:YES];
    
}

//Pick From List for SubMenu
-(void)btnPickFromListSubMenu:(id)sender
{
    UITableViewCell *cell=(UITableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];

    ModelMenu *obj=[arrDisplay objectAtIndex:indexPath.section];
    ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:indexPath.row-1];
    
    NSString *subMenuDetails=[NSString stringWithFormat:@"%@,%@,%@",obj.strMenuId,objSub.strSubMenuId,objSub.strSubMenuName];
    NSLog(@"submenuDetails sent to PickFromListController %@",subMenuDetails);
    
    PickFromListController *pickListController = [[PickFromListController alloc] initWithNibName:@"PickFromListController" bundle:nil];
    pickListController.SubMenuDetailsFromPrevious=subMenuDetails;
    pickListController.FlagFromSettings=NO;
    [self.navigationController pushViewController:pickListController animated:YES];
    
}

//Change Message for Menu
-(void)btnChangeMenuText:(id)sender
{
    ButtonCell *cell=(ButtonCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    //NSLog(@"Section Clicked: %ld",(long)indexPath.section);
    
    UITextField *menuTextField=(UITextField *)[self.view viewWithTag:400+indexPath.section];
    //NSLog(@"Text: %@",menuTextField.text);
    
    [menuTextField setEnabled:YES];
    [menuTextField becomeFirstResponder];
    
    menuEditingIndexPath=indexPath;
    isMenuEditingEnabled=YES;
    isSubMenuEditingEnabled=NO;
    
    
    CGRect rectOfCellInTableView = [tblView rectForSection:indexPath.section];
    CGPoint point=tblView.contentOffset;
    CGRect textFieldRect=menuTextField.frame;
    UIButton *buttonChangeMsg=(UIButton*)sender;
    CGRect buttonFieldRect=buttonChangeMsg.frame;
    
    NSLog(@"KeyBoardHeight: %d", keyboardHeight);
    
    if (rectOfCellInTableView.origin.y+textFieldRect.origin.y+textFieldRect.size.height+buttonFieldRect.size.height>keyboardHeight)
    {
        [tblView setContentOffset:CGPointMake(point.x, rectOfCellInTableView.origin.y-textFieldRect.size.height- textFieldRect.origin.y-buttonFieldRect.size.height-buttonFieldRect.origin.y) animated:YES];
    }

}

//Change Message for Menu
-(void)btnChangeSubMenuText:(id)sender
{
    UITableViewCell *cell=(UITableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    
    NSLog(@"Row Clicked for Section: %ld, %ld",(long)indexPath.section,(long)indexPath.row);
    
    MenuListSelectedTableViewCell *subMmenuCell=(MenuListSelectedTableViewCell*)[tblView cellForRowAtIndexPath:indexPath];
    [subMmenuCell.txtField setUserInteractionEnabled:YES];
    [subMmenuCell.txtField becomeFirstResponder];
    
    menuEditingIndexPath=indexPath;
    isMenuEditingEnabled=NO;
    isSubMenuEditingEnabled=YES;
}

-(IBAction)btnRearrangedPressed:(id)sender
{
    RearrangeViewController *rearrangeController = [[RearrangeViewController alloc] initWithNibName:@"RearrangeViewController" bundle:nil];
    
    rearrangeController.editMainMenuMsgArray=[[NSMutableArray alloc] init];
    rearrangeController.editMainMenuMsgArray=arrDisplay;
    rearrangeController.pageNumber=pageNumber;
    
    [self.navigationController pushViewController:rearrangeController animated:YES];
}

-(IBAction)saveButtonPressed:(id)sender
{
    
    NSLog(@"Section=%ld Row=%ld",(long)lastEditedIndexPath.section,(long)lastEditedIndexPath.row);
    isButtonSavePressed=YES;
    
    if (lastEditedIndexPath && isMenuEditingEnabled==NO && isSubMenuEditingEnabled==NO)
    {
        MenuListTableViewCell *cell=(MenuListTableViewCell*)[tblView cellForRowAtIndexPath:lastEditedIndexPath];
        if ([cell.txtFiled isFirstResponder])
        {
            [cell.txtFiled resignFirstResponder];
        }
        ModelMenu *obj=[arrDisplay objectAtIndex:lastEditedIndexPath.section];
        [DBManager addSubMenuWithMenuId:obj.strMenuId withSubMenuText:strTemp];
        lastEditedIndexPath=nil;
        arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
        [tblView reloadData];
        
        [saveAlert show];
        
        [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
    }
    
    else if(menuEditingIndexPath && isMenuEditingEnabled)
    {
        ModelMenu *obj=[arrDisplay objectAtIndex:menuEditingIndexPath.section];
        UITextField *menuTextField=(UITextField *)[self.view viewWithTag:400+menuEditingIndexPath.section];
        NSLog(@"MenuID: %@",obj.strMenuId);
        NSLog(@"Updated MenuText: %@",menuTextField.text);
        
        if(menuTextField.text.length>0)
         [DBManager updatemenuWithMenuId:obj.strMenuId withMenuTitle:menuTextField.text];
        
        isMenuEditingEnabled=NO;
        menuEditingIndexPath=nil;
        arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
        [tblView reloadData];
        
        [saveAlert show];
        
        [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
    }
    
    else if(menuEditingIndexPath && isSubMenuEditingEnabled)
    {
        MenuListSelectedTableViewCell *cell = (MenuListSelectedTableViewCell*)[tblView cellForRowAtIndexPath:menuEditingIndexPath];

        ModelMenu *obj=[arrDisplay objectAtIndex:menuEditingIndexPath.section];
        ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:menuEditingIndexPath.row-1];
        NSLog(@"MenuID: %@",obj.strMenuId);
        NSLog(@"SubMenuID: %@",objSub.strSubMenuId);
        NSLog(@"Updated SubMenu: %@",cell.txtField.text);
        
        if(cell.txtField.text.length>0)
            [DBManager updatesubnemuWithMenuId:[NSString stringWithFormat:@"%@,%@",obj.strMenuId,objSub.strSubMenuId] withsubmenutitle:cell.txtField.text];
        
        
        isSubMenuEditingEnabled=NO;
        menuEditingIndexPath=nil;
        arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
        [tblView reloadData];
        
        [saveAlert show];
        
        [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
    }
}

-(IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark
#pragma mark UITextFieldDelegate
#pragma mark

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    isButtonSavePressed=NO;
    MenuListTableViewCell *cell=(MenuListTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:textField];
    NSIndexPath *indexPath=[tblView indexPathForCell:cell];
    //NSLog(@"textFieldDidBeginEditing ->Section=%ld Row=%ld",(long)indexPath.section,(long)indexPath.row);
    
    CGRect cellRect=[tblView rectForRowAtIndexPath:indexPath];
    CGRect textFieldRect=textField.frame;
     NSLog(@"KeyBoardHeight: %d", keyboardHeight);
    if (cellRect.origin.y+textFieldRect.origin.y>keyboardHeight)
    {
        currentPoint=tblView.contentOffset;
        [tblView setContentOffset:CGPointMake(currentPoint.x, cellRect.origin.y-textFieldRect.origin.y-20) animated:YES];
    }
    lastEditedIndexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    strTemp=[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [tblView setContentOffset:currentPoint animated:YES];
    if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length>0)
    {
        /*if (!isButtonSavePressed)
         {
         [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Press Save Button to Save the Message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         }*/
    }
    
    [tblView setContentOffset:CGPointZero animated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark
#pragma mark AlertView Delegate Methods
#pragma mark

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        NSLog(@"Delete submenu of menuID: %ld", (long)alertView.tag);
        [self removeAllSubMenu:[NSString stringWithFormat:@"%ld",(long)alertView.tag]];
        arrDisplay=[DBManager fetchMenuForPageNo:pageNumber+1];
        [tblView reloadData];
    }
    
}

@end
