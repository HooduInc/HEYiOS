//
//  GroupViewController.m
//  Heya
//
//  Created by jayantada on 30/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "GroupViewController.h"
#import "MBProgressHUD.h"
#import "GroupMemberViewController.h"
#import "RearrangeGroupViewController.h"
#import "GroupTableViewCell.h"
#import "ModelGroup.h"


@interface GroupViewController ()<GroupTableViewCellDelegate,UITextFieldDelegate>
{
    MBProgressHUD *HUD;
    NSIndexPath *selectedIndexPath;
    BOOL cellEditingStatus, cellDeleteStatus;
}

@end

@implementation GroupViewController
@synthesize addGroupView, doneButton, saveButton, groupListArray, groupTableView;


#pragma mark
#pragma  mark ViewController Initialization
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    selectedIndexPath=nil;
    [groupTableView setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
    
    dispatch_queue_t myQueue = dispatch_queue_create("hey_main_group", NULL);
    
    dispatch_async(myQueue, ^{
        //stuffs to do in background thread
        [self.view addSubview:HUD];
        [HUD show:YES];
        groupListArray = [DBManager fetchDetailsFromGroup];
        NSLog(@"Total No of Groups: %ld",(long)groupListArray.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            //stuffs to do in foreground thread, mostly UI updates
            [groupTableView reloadData];
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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupListArray count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentfier = @"GroupTableCell";
    GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableIdentfier];
    
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"GroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    ModelGroup *objGroup = [groupListArray objectAtIndex:indexPath.row];
    cell.delegate=self;
    cell.groupNameLabel.text = objGroup.strGroupName;
    cell.groupNameLabel.tag=[objGroup.strGroupId intValue];
    cell.groupNameLabel.delegate=self;
    cell.profileImg.image=[UIImage imageNamed:@"group_friends_pic.png"];
    cell.groupIdString =objGroup.strGroupId;
    cell.groupOrderString =objGroup.strGroupOrder;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModelGroup *objGroup = [groupListArray objectAtIndex:indexPath.row];
    NSLog(@"Seleted GroupName with GroupID: %@ -> %@",objGroup.strGroupName,objGroup.strGroupId);
    
    GroupMemberViewController *gController = [[GroupMemberViewController alloc] initWithNibName:@"GroupMemberViewController" bundle:nil];
    gController.isNewGroup=NO;
    gController.clickedGroupId = objGroup.strGroupId;
    
    [self.navigationController pushViewController:gController animated:YES];
}




#pragma mark
#pragma mark - SwipeableCellDelegate
#pragma mark

- (void)groupButtonChangeActionForItemText:(id)sender
{
    GroupTableViewCell *cell=(GroupTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[groupTableView indexPathForCell:cell];
    
    cell.groupNameLabel.userInteractionEnabled=YES;
    [cell.groupNameLabel becomeFirstResponder];
    selectedIndexPath=indexPath;
    cellEditingStatus=YES;
    cellDeleteStatus=NO;
    
    NSLog(@"In the delegate, Clicked buttonChange-> Before Updating->Name: %@",cell.groupNameLabel.text);
    
    
    CGRect rectOfCellInTableView = [groupTableView rectForRowAtIndexPath:indexPath];
    NSLog(@"TextField Origin: %f",rectOfCellInTableView.origin.y+120);
    
    if(isIphone4 || isIphone5)
    {
        if(rectOfCellInTableView.origin.y+120>253)
            [groupTableView setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6)
    {
        if(rectOfCellInTableView.origin.y+120>258)
            [groupTableView setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6Plus)
    {
        if(rectOfCellInTableView.origin.y+120>271)
            [groupTableView setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
}

- (void)buttonDeleteActionForItemText:(id)sender
{
    GroupTableViewCell *cell=(GroupTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[groupTableView indexPathForCell:cell];
    selectedIndexPath=indexPath;
    
    cellEditingStatus=NO;
    cellDeleteStatus=YES;
    selectedIndexPath=nil;
    
    NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cell.groupNameLabel.text);
    BOOL isDeleted=[DBManager deleteGroupWithGroupId:[NSString stringWithFormat:@"%ld",(long)cell.groupNameLabel.tag]];
    
    if(isDeleted)
    {
        groupListArray= [DBManager fetchDetailsFromGroup];
        [groupTableView reloadData];
    }
    
}


#pragma mark
#pragma mark IBActions Methods
#pragma mark

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addGroupButtonTapped:(id)sender
{
    GroupMemberViewController *gVc = [[GroupMemberViewController alloc] initWithNibName:@"GroupMemberViewController" bundle:nil];
    gVc.isNewGroup=YES;
    gVc.clickedGroupId=@"";
    [self.navigationController pushViewController:gVc animated:YES];
}

- (IBAction)rearrangeButtonTapped:(id)sender
{
    RearrangeGroupViewController *rVc = [[RearrangeGroupViewController alloc] initWithNibName:@"RearrangeGroupViewController" bundle:nil];
    rVc.groupArray=groupListArray;
    
    [self.navigationController pushViewController:rVc animated:YES];
}

-(IBAction)saveBtnPressed:(id)sender
{
    if (cellEditingStatus==YES && cellDeleteStatus==NO && selectedIndexPath!=nil)
    {
        
        GroupTableViewCell *cell=(GroupTableViewCell*)[groupTableView cellForRowAtIndexPath:selectedIndexPath];
        
        if (cell.groupNameLabel.text.length>0)
        {
            NSLog(@"Updated Name: %@",cell.groupNameLabel.text);
            NSLog(@"GROUP ID: %ld",(long)cell.groupNameLabel.tag);
            
            if (![DBManager checkGroupNameExistsinGroupTable:cell.groupNameLabel.text])
            {
            
                BOOL isUpdated=[DBManager updateGroupNameWithGroupId:[NSString stringWithFormat:@"%ld",(long)cell.groupNameLabel.tag] withGroupName:cell.groupNameLabel.text];
                
                if (isUpdated)
                {
                    cellEditingStatus=NO;
                    cellDeleteStatus=YES;
                    selectedIndexPath=nil;
                    
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    groupListArray= [DBManager fetchDetailsFromGroup];
                    [groupTableView reloadData];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Group name already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }
    }
}

#pragma mark
#pragma mark TextField Delegate Methods
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
     [groupTableView setContentOffset:CGPointZero animated:YES];
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


@end
