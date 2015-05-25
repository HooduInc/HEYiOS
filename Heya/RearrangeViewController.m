//  RearrangeViewController.m
//  Heya
//  Created by jayantada on 09/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.

#import "RearrangeViewController.h"
#import "EditViewController.h"
#import "ButtonCell.h"
#import "MenuListTableViewCell.h"
#import "MenuListSelectedTableViewCell.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"
#import "EditMsgTableViewCell.h"
#import "NSString+Emoticonizer.h"

#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface RearrangeViewController ()
{
    IBOutlet UITableView *tblView;
    NSString *saveEditValue;
    NSUserDefaults *preferances;
    int sendIDToDB, sendSubMenuIDToDB, menuflag, submenuInsertionFlag, rearrangeFlag;
}

@end

@implementation RearrangeViewController
@synthesize editMainMenuMsgArray,pageNumber;

#pragma mark
#pragma mark Initialization
#pragma mark




- (void)viewDidLoad {
    
    [super viewDidLoad];
    preferances=[NSUserDefaults standardUserDefaults];
    
}
-(void) viewWillAppear:(BOOL)animated
{
    pageNumber=pageNumber+1;
    editMainMenuMsgArray=[DBManager fetchMenuForPageNo:pageNumber];
    [self setEditing:YES animated:YES];
    [tblView setEditing:YES animated:YES];
    rearrangeFlag=1;
    [tblView reloadData];
    
    NSLog(@"PageNumber : %ld", (long)pageNumber);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark TableViewDelegate
#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(pageNumber==1)
        return [editMainMenuMsgArray count]-1;
    
    else if([editMainMenuMsgArray count]>0)
        return [editMainMenuMsgArray count];
    
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DropDownCellIdentifier = @"EditMsgTableViewCell";
    
    switch ([indexPath section])
    {
        case 0:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                        
                    }
                    
                    
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    
                    NSString *emoString=@"\U00002764";
                    NSString *loveyouString=@"Love You";
                    /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    
                    cell.msgTextField.enabled=NO;

                    
                    return cell;
                    break;
                }
                default:
                {
                   return nil;
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
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    //NSString *emoString=@"\U00002764";
                    //NSString *loveyouString=@"Love You";
                    /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 2:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    //NSString *emoString=@"\U00002764";
                    //NSString *loveyouString=@"Love You";
                    /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 3:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    //NSString *emoString=@"\U00002764";
                    //NSString *loveyouString=@"Love You";
                    /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 4:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    /*NSString *emoString=@"\U00002764";
                    NSString *loveyouString=@"Love You";
                    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 5:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    /*NSString *emoString=@"\U00002764";
                    NSString *loveyouString=@"Love You";
                    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 6:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    /*NSString *emoString=@"\U00002764";
                    NSString *loveyouString=@"Love You";
                    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
                    break;
                }
                    
            }
            break;
        }
        case 7:
        {
            
            switch ([indexPath row])
            {
                case 0:
                {
                    
                    EditMsgTableViewCell *cell = (EditMsgTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
                    
                    if (cell == nil)
                    {
                        
                        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditMsgTableViewCell" owner:nil options:nil];
                        
                        cell=[topLevelObjects objectAtIndex:0];
                    }
                    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:indexPath.section];
                    cell.cellBgImageView.image = [UIImage imageNamed:obj.strMenuColor];
                    /*NSString *emoString=@"\U00002764";
                    NSString *loveyouString=@"Love You";
                    if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
                    {
                        cell.msgTextField.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
                    }
                    else*/
                        cell.msgTextField.text=[NSString emoticonizedString:obj.strMenuName];
                    
                    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
                        cell.msgTextField.textColor = [UIColor grayColor];
                    else
                        cell.msgTextField.textColor = [UIColor whiteColor];
                    cell.msgTextField.enabled=NO;
                    
                    return cell;
                    break;
                }
                default:
                {
                    return nil;
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


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    ModelMenu *obj=[editMainMenuMsgArray objectAtIndex:sourceIndexPath.section];
    NSString *stringToMove = obj.strMenuName;
    NSLog(@"stringToMove: %@", stringToMove);
    
   
    ModelMenu *objRemove=[editMainMenuMsgArray objectAtIndex:destinationIndexPath.section];
    NSString *stringToRemove = objRemove.strMenuName;
    NSLog(@"stringToRemove: %@", stringToRemove);
    
    [editMainMenuMsgArray removeObjectAtIndex:sourceIndexPath.section];
    [editMainMenuMsgArray insertObject:stringToMove atIndex:destinationIndexPath.section];
    
    
    [DBManager updateMenuOrderWithMenuId:obj.strMenuId withMenuOrder:objRemove.strMenuOrder];
    [DBManager updateMenuOrderWithMenuId:objRemove.strMenuId withMenuOrder:obj.strMenuOrder];
    
    editMainMenuMsgArray=[DBManager fetchMenuForPageNo:pageNumber];
    [tblView reloadData];
    
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

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    for(UIView* view in tableView.subviews)
    {
        if([[[view class] description] isEqualToString:@"UITableViewWrapperView"])
        {
            for(UIView* viewTwo in view.subviews)
            {
                if ([viewTwo isKindOfClass:NSClassFromString(@"UITableViewCell")])
                {
                    for(UIView* viewThree in viewTwo.subviews)
                    {
                        //NSLog(@"viewThree: %@",viewThree);
                        if ([viewThree isKindOfClass:NSClassFromString(@"UITableViewCellReorderControl")])
                        {
                            [self moveReorderControl:cell subviewCell:viewThree];
                        }
                    }
                }
            }
        }
    }
}

- (void)moveReorderControl:(UITableViewCell *)cell subviewCell:(UIView *)subviewCell
{
    static int TRANSLATION_REORDER_CONTROL_Y = 0;
    //Code to move the reorder control, you change change it for your code, this works for me
    UIView* resizedGripView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetMaxX(subviewCell.frame), CGRectGetMaxY(subviewCell.frame))];
    [resizedGripView addSubview:subviewCell];
    [cell addSubview:resizedGripView];
    
    //  Original transform
    const CGAffineTransform transform = CGAffineTransformMakeTranslation(subviewCell.frame.size.width - cell.frame.size.width, TRANSLATION_REORDER_CONTROL_Y);
    //  Move custom view so the grip's top left aligns with the cell's top left
    
    [resizedGripView setTransform:transform];
}


- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
