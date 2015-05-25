//
//  RearrangeFevoriteViewController.m
//  Heya
//
//  Created by jayantada on 24/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "RearrangeFevoriteViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "RearrangeFavTableViewCell.h"
#import "ModelFevorite.h"

@interface RearrangeFevoriteViewController ()<UITableViewDataSource,UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UITableView *tblView;
}

@end


@implementation RearrangeFevoriteViewController

@synthesize fevoriteArray;

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
    fevoriteArray=[[NSMutableArray alloc] init];
    fevoriteArray=[DBManager fetchFavorite];
    NSLog(@"fevoriteArray: %@",fevoriteArray);
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
    
    if(fevoriteArray.count>0)
    {
        NSLog(@"Fav Count: %ld",(long)[fevoriteArray count]);
        return [fevoriteArray count];
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
    static NSString *DropDownCellIdentifier = @"RearrangeFavTableCell";
    
    
    RearrangeFavTableViewCell *cell = (RearrangeFavTableViewCell*) [tableView dequeueReusableCellWithIdentifier:DropDownCellIdentifier];
    
    if (cell == nil)
    {
        
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RearrangeFavTableViewCell" owner:nil options:nil];
        
        cell=[topLevelObjects objectAtIndex:0];
        
    }
    ModelFevorite *favObj = [[ModelFevorite alloc] init];
    favObj=[fevoriteArray objectAtIndex:indexPath.row];
    
    
    NSLog(@"favObj: %@",favObj);
    
    
    //cell.favoriteId=favObj.strFevoriteId;
    //cell.favoriteOrder=favObj.strFavouriteOrder;
    
    NSLog(@"FirstName: %@",favObj.strFirstName);
    NSLog(@"LastName: %@",favObj.strLastName);
    cell.name_lbl.text=[NSString stringWithFormat:@"%@ %@", favObj.strFirstName,favObj.strLastName];
    
    if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
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
        
    }
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
    ModelFevorite *obj=[fevoriteArray objectAtIndex:sourceIndexPath.row];
    NSString *stringToMove = obj.strFirstName;
    NSLog(@"stringToMove: %@", stringToMove);
    
    
    ModelFevorite *objRemove=[fevoriteArray objectAtIndex:destinationIndexPath.row];
    NSString *stringToRemove = objRemove.strFirstName;
    NSLog(@"stringToRemove: %@", stringToRemove);
    
    [fevoriteArray removeObjectAtIndex:sourceIndexPath.row];
    [fevoriteArray insertObject:stringToMove atIndex:destinationIndexPath.row];
    
    [DBManager UpdateFavoriteWithId:obj.strFevoriteId withTableColoum:@"favouriteOrder" withColoumValue:objRemove.strFavouriteOrder];
    
    [DBManager UpdateFavoriteWithId:objRemove.strFevoriteId withTableColoum:@"favouriteOrder" withColoumValue:obj.strFavouriteOrder];
    
    fevoriteArray=[DBManager fetchFavorite];
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

-(IBAction)doneBtnTapped:(id)sender
{
    
}

-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
