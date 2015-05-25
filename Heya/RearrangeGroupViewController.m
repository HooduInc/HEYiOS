//
//  RearrangeGroupViewController.m
//  Heya
//
//  Created by jayantada on 03/04/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "RearrangeGroupViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RearrangeGroupTableViewCell.h"
#import "ModelGroup.h"


@interface RearrangeGroupViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UITableView *tblView;
}

@end

@implementation RearrangeGroupViewController

@synthesize groupArray;

#pragma mark
#pragma mark UIViewControllerInitialization
#pragma mark


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEditing:YES animated:YES];
    [tblView setEditing:YES animated:YES];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    groupArray=[[NSMutableArray alloc] init];
    groupArray = [DBManager fetchDetailsFromGroup];
    [tblView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark UITableView Delegate
#pragma mark

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 1;
    
    if(groupArray.count>0)
    {
        NSLog(@"Fav Count: %ld",(long)[groupArray count]);
        return [groupArray count];
    }
    else
        return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DropDownCellIdentifier = @"RearrangeGroupTableViewCell";
    RearrangeGroupTableViewCell *cell = (RearrangeGroupTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
    
    if (cell == nil)
    {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RearrangeGroupTableViewCell" owner:nil options:nil];
        
        cell=[topLevelObjects objectAtIndex:0];
        
    }
    
    
    ModelGroup *objGroup=[[ModelGroup alloc] init];
    objGroup=[groupArray objectAtIndex:indexPath.row];
    
    cell.strGroupId=objGroup.strGroupId;
    cell.strGroupOrder=objGroup.strGroupOrder;
    cell.nameLabel.text=objGroup.strGroupName;
    
    cell.profileImg.image=[UIImage imageNamed:@"group_friends_pic.png"];
    
    /*if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
    {
        cell.profileImg.image = [UIImage imageNamed:favObj.strProfileImage];
    }
    else
    {
        NSString *str = favObj.strProfileImage;
        //NSLog(@"ImageURL: %@",str);
        NSURL *myAssetUrl = [NSURL URLWithString:str];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            @autoreleasepool {
                CGImageRef iref = [rep fullScreenImage];
                if (iref)
                {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        cell.profileImg.image=image;
                        
                    });
                    iref = nil;
                }
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:myAssetUrl resultBlock:resultblock failureBlock:failureblock];
        
    }*/
    cell.consLeadSpace.constant=40.0f;
    cell.backgroundColor=[UIColor whiteColor];
    
    return  cell;
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
    ModelGroup *obj=[groupArray objectAtIndex:sourceIndexPath.row];
    NSString *stringToMove = obj.strGroupName;
    NSLog(@"stringToMove: %@", stringToMove);
    
    
    ModelGroup *objRemove=[groupArray objectAtIndex:destinationIndexPath.row];
    NSString *stringToRemove = objRemove.strGroupName;
    NSLog(@"stringToRemove: %@", stringToRemove);
    
    [groupArray removeObjectAtIndex:sourceIndexPath.row];
    [groupArray insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    [DBManager updateGroupWithId:obj.strGroupId withTableColoum:@"groupOrder" withColoumValue:objRemove.strGroupOrder];
    
    [DBManager updateGroupWithId:objRemove.strGroupId withTableColoum:@"groupOrder" withColoumValue:obj.strGroupOrder];
    
    groupArray = [DBManager fetchDetailsFromGroup];
    [tblView reloadData];

}


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



#pragma mark
#pragma mark IB Action & Methods
#pragma mark


-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
