//
//  MessagesListViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 13/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.

#import "MessagesListViewController.h"
#import "EditViewController.h"
#import "SettingsViewController.h"
#import "MessagesViewController.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"
#import "MenuListTableViewCell.h"

@interface MessagesListViewController (){
    NSMutableArray *arrAllPageValue;
    NSMutableArray *arrDisplayTableOne, *arrDisplayTableTwo, *arrDisplayTableThree, *arrDisplayTableFour;
    NSInteger pageNumber;
    NSInteger selectedSection;
    
    NSString *emoString;
    NSString *loveyouString;
}
@end

@implementation MessagesListViewController

@synthesize messageListScrollView, menulistTable, menulistTableTwo, menulistTableThree, menulistTableFour, pageControl;
NSUserDefaults *preferances;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    emoString=@"\U00002764";
    loveyouString=@"Love You";
    
    CGFloat occupiedHeight=self.pageControl.frame.origin.y+self.pageControl.frame.size.height;
    
    messageListScrollView.frame=CGRectMake(0, occupiedHeight, self.view.frame.size.width, self.view.frame.size.height-occupiedHeight);
    
    messageListScrollView.contentSize = CGSizeMake(self.view.frame.size.width*4, self.messageListScrollView.frame.size.height);
    
    pageNumber=0;
    
    menulistTable.frame=CGRectMake(0, 0, messageListScrollView.frame.size.width, messageListScrollView.frame.size.height);
    [messageListScrollView addSubview:menulistTable];
    //NSLog(@"%@",NSStringFromCGRect(menulistTable.frame));
    
    menulistTableTwo.frame=CGRectMake(menulistTable.frame.origin.x+menulistTable.frame.size.width, 0, messageListScrollView.frame.size.width, messageListScrollView.frame.size.height);
    [messageListScrollView addSubview:menulistTableTwo];
    //NSLog(@"%@",NSStringFromCGRect(menulistTableTwo.frame));
    
    menulistTableThree.frame=CGRectMake(menulistTableTwo.frame.origin.x+menulistTableTwo.frame.size.width, 0, messageListScrollView.frame.size.width, messageListScrollView.frame.size.height);
    [messageListScrollView addSubview:menulistTableThree];
    //NSLog(@"%@",NSStringFromCGRect(menulistTableThree.frame));
    
    menulistTableFour.frame=CGRectMake(menulistTableThree.frame.origin.x+menulistTableThree.frame.size.width+1, 0, messageListScrollView.frame.size.width, messageListScrollView.frame.size.height);
    [messageListScrollView addSubview:menulistTableFour];
    //NSLog(@"%@",NSStringFromCGRect(menulistTableFour.frame));
    
    
    
}
- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    //Always make 0
    [preferances setBool:0 forKey:@"addPhoneClicked"];
    [preferances synchronize];
    
    arrAllPageValue=[[NSMutableArray alloc] init];
    for (int i=1; i<=4; i++) {
        [arrAllPageValue addObject:[DBManager fetchMenuForPageNo:i]];
    }
    
    arrDisplayTableOne=[arrAllPageValue objectAtIndex:0];
    arrDisplayTableTwo=[arrAllPageValue objectAtIndex:1];
    arrDisplayTableThree=[arrAllPageValue objectAtIndex:2];
    arrDisplayTableFour=[arrAllPageValue objectAtIndex:3];
    
    selectedSection=-1;
    
    [menulistTable reloadData];
    [menulistTableTwo reloadData];
    [menulistTableThree reloadData];
    [menulistTableFour reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark
#pragma mark ScrollViewDelegate
#pragma mark


-(void)scrollViewDidScroll:(UIScrollView *)sender {
    if ([sender isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView=(UIScrollView*)sender;
        if (scrollView==messageListScrollView)
        {
            // Update the page when more than 50% of the previous/next page is visible
            CGFloat pageWidth = self.messageListScrollView.frame.size.width;
            int page = floor((self.messageListScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            self.pageControl.currentPage = page;
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==messageListScrollView)
    {
        pageNumber=(int)(self.messageListScrollView.contentOffset.x / self.messageListScrollView.frame.size.width);
        NSLog(@"Page Number = %ld",(long)pageNumber);
        [pageControl setCurrentPage:pageNumber];
    }
}
#pragma mark
#pragma mark TableViewDelegate
#pragma mark

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==menulistTable)
        return arrDisplayTableOne.count;
    
    if(tableView==menulistTableTwo)
        return arrDisplayTableTwo.count;
    
    if(tableView==menulistTableThree)
        return arrDisplayTableThree.count;
    
    if(tableView==menulistTableFour)
        return arrDisplayTableFour.count;
    
    else
        return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *str=@"MyCell";
    MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    [cell.btnClose setHidden:YES];
    ModelMenu *obj;
    
    if (tableView==menulistTable)
        obj=[arrDisplayTableOne objectAtIndex:section];
    
    if (tableView==menulistTableTwo)
        obj=[arrDisplayTableTwo objectAtIndex:section];
    
    if (tableView==menulistTableThree)
        obj=[arrDisplayTableThree objectAtIndex:section];
    
    if (tableView==menulistTableFour)
        obj=[arrDisplayTableFour objectAtIndex:section];
    
    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
    {
        cell.txtFiled.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
    }
    else
        cell.txtFiled.text=obj.strMenuName;
    
    cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
    [cell.btnHeader setTag:section];
    [cell.btnHeader addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnArrow setTag:section];
    [cell.btnArrow addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.txtFiled setUserInteractionEnabled:NO];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
        cell.txtFiled.textColor = [UIColor grayColor];
    else
        cell.txtFiled.textColor = [UIColor whiteColor];
    
    cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=0.0f;
    cell.constraintBgImgBottomSpace.constant=cell.constraintBgImgBottomSpace.constant+8;
    
    if (obj.arrSubMenu.count==0) {
        cell.btnArrow.hidden=YES;
        if (tableView==menulistTable) {
            //NSLog(@"menulistTable=%ld",(long)section);
        }
    }
    
    //NSLog(@"btnArrow Frame = %@",NSStringFromCGRect(cell.btnArrow.frame));
    [cell.contentView bringSubviewToFront:cell.btnArrow];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedSection==-1) {
        return 0;
    }
    else
    {
        if(tableView==menulistTable)
        {
            if (selectedSection==section)
            {
                ModelMenu *obj=[arrDisplayTableOne objectAtIndex:section];
                return obj.arrSubMenu.count;
            }
        }
        if(tableView==menulistTableTwo)
        {
            if (selectedSection==section)
            {
                ModelMenu *obj=[arrDisplayTableTwo objectAtIndex:section];
                return obj.arrSubMenu.count;
            }
        }
        
        if(tableView==menulistTableThree)
        {
            if (selectedSection==section)
            {
                ModelMenu *obj=[arrDisplayTableThree objectAtIndex:section];
                return obj.arrSubMenu.count;
            }
        }
        
        if(tableView==menulistTableFour)
        {
            if (selectedSection==section)
            {
                ModelMenu *obj=[arrDisplayTableFour objectAtIndex:section];
                return obj.arrSubMenu.count;
            }
        }
        else
        {
            return 0;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        return 54.0f;
    }
    return 44.0f;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str=@"MyCell";
    MenuListTableViewCell *cell=(MenuListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"MenuListTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    ModelMenu *obj;
    if (tableView==menulistTable)
        obj=[arrDisplayTableOne objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableTwo)
        obj=[arrDisplayTableTwo objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableThree)
        obj=[arrDisplayTableThree objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableFour)
        obj=[arrDisplayTableFour objectAtIndex:indexPath.section];
    

    ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:indexPath.row];
    cell.txtFiled.text=objSub.strSubMenuName;
    cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
    [cell.txtFiled setUserInteractionEnabled:NO];
    cell.btnHeader.hidden=YES;
    cell.constraintLeadingSpace.constant=cell.constraintTrailingSpace.constant+20.0f;
    
    if (indexPath.row==0) {
        cell.constraintBgImgTopSpace.constant=2.0f;
    }
    cell.constraintBtnCloseHeight.constant=cell.constraintBtnCloseWidth.constant=0.0f;
    
    
    cell.btnArrow.hidden=YES;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelMenu *obj;
    if (tableView==menulistTable)
        obj=[arrDisplayTableOne objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableTwo)
        obj=[arrDisplayTableTwo objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableThree)
        obj=[arrDisplayTableThree objectAtIndex:indexPath.section];
    
    if (tableView==menulistTableFour)
        obj=[arrDisplayTableFour objectAtIndex:indexPath.section];
    
    
    MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
    
    MenuListTableViewCell *cell = (MenuListTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    //NSLog(@"Menu Value: %@", obj.strMenuName);
    //NSLog(@"Sub Menu Value: %@", cell.txtFiled.text);
    
    if([cell.txtFiled.text containsString:@"custom message"])
    {
        messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@  ",obj.strMenuName];
    }
    else if([[cell.txtFiled.text lowercaseString] containsString:[loveyouString lowercaseString]])
    {
        messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",cell.txtFiled.text, emoString];
    }
    else
    {
        messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@  %@",obj.strMenuName,cell.txtFiled.text];
    }
    
    
    messagesView_obj.quickContactsArray=[[NSMutableArray alloc] init];
    
    if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
        [self.navigationController pushViewController:messagesView_obj animated:YES];
}

#pragma mark
#pragma mark IBActions
#pragma mark

-(IBAction)btnHeaderTapped:(id)sender
{
    if (selectedSection==[sender tag])
    {
        selectedSection=-1;
    }
    else
    {
        selectedSection=[sender tag];
        
        UIButton *btnArrow=(UIButton*)sender;
        btnArrow.transform=CGAffineTransformMakeRotation(M_PI);
        
    }
    
    if (pageNumber==0)
    {
        ModelMenu *obj=[arrDisplayTableOne objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {

            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            
            if([obj.strMenuName containsString:@"[ Custom Message ]"])
            {
               messagesView_obj.getMessageStr =@"HEY!";
            }
            
            else if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }
            
            else
            {
                messagesView_obj.getMessageStr =[NSString stringWithFormat:@"HEY! %@",obj.strMenuName];
            }
            
            messagesView_obj.quickContactsArray=[[NSMutableArray alloc] init];
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
            [menulistTable reloadData];
    }
    else if (pageNumber==1)
    {
        ModelMenu *obj=[arrDisplayTableTwo objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr =[NSString stringWithFormat:@"HEY! %@",obj.strMenuName];
            
            if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
            [menulistTableTwo reloadData];
    }
    
    else if (pageNumber==2)
    {
        ModelMenu *obj=[arrDisplayTableThree objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@",obj.strMenuName];;
            
            if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
            [menulistTableThree reloadData];
    }
    
    else if (pageNumber==3)
    {
        ModelMenu *obj=[arrDisplayTableFour objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@",obj.strMenuName];
            
            if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
            [menulistTableFour reloadData];
    }
}

- (IBAction)settingsButtonTapped:(id)sender
{
    SettingsViewController *sVc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:sVc animated:YES];
}

- (IBAction) editMessageButtonTapped:(UIButton*)sender
{
    
    EditViewController *editController = [[EditViewController alloc]initWithNibName:@"EditViewController" bundle:nil];
    switch (pageNumber) {
        case 0:
            editController.arrDisplay=arrDisplayTableOne;
            break;
        case 1:
            editController.arrDisplay=arrDisplayTableTwo;
            break;
        case 2:
            editController.arrDisplay=arrDisplayTableThree;
            break;
        case 3:
            editController.arrDisplay=arrDisplayTableFour;
            break;
        default:
            break;
    }
    editController.pageNumber=pageNumber;
    [self.navigationController pushViewController:editController animated:YES];
}

-(IBAction)pageControllerTapped:(id)sender
{
    pageNumber=[pageControl currentPage];
    [messageListScrollView setContentOffset:CGPointMake(pageNumber*messageListScrollView.frame.size.width, 0) animated:YES];
}

@end
