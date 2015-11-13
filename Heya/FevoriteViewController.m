//
//  FevoriteViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 12/11/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "FevoriteViewController.h"
#import "RearrangeFevoriteViewController.h"
#import "FevretTableViewCell.h"
#import "ModelFevorite.h"
#import "MBProgressHUD.h"

#import "KBContactsSelectionViewController.h"
#import "APContact.h"
#import "APPhoneWithLabel.h"

@import Photos;

@interface FevoriteViewController ()<FevretTableViewCellDelegate,UITextFieldDelegate, UIAlertViewDelegate,KBContactsSelectionViewControllerDelegate>
{
    MBProgressHUD *HUD;
    NSIndexPath *selectedIndexPath;
    BOOL cellEditingStatus, cellDeleteStatus;
    UIAlertView *saveAlert;
    NSMutableArray *multipleContactNoArray, *arrDisplay;
    UIImage *contactImageFromAddressBook;
}

@property (weak) KBContactsSelectionViewController* presentedCSVC;
@end

@implementation FevoriteViewController

@synthesize fevoriteList_table,fevoritelist_array,number_arr,alphabetArray, testingImage, arrContactsData;


#pragma mark
#pragma mark - UIViewController Initilization
#pragma mark

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
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    alphabetArray = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3", nil];
    saveAlert=[[UIAlertView alloc] initWithTitle:nil message:@"Saved Successfully." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [self setEditing:YES animated:YES];// 3
    [fevoriteList_table setEditing:YES animated:YES];
    
    
    //Request Access to Photos
    int photolibaryAccessStatus = [self AssetLibraryAuthStatus];
    
    if (photolibaryAccessStatus==0 || photolibaryAccessStatus==1 || photolibaryAccessStatus==4)
    {
        [self showMessageWithTitle:@"Privacy Warning!" withMessage:@"Permission was not granted for photos.\nTip: Go to settings->Hey and allow photos." withButtonTittle:@"OK"];
    }
    [self PHAssetAuthStatus];

}

-(void) viewWillAppear:(BOOL)animated
{
    selectedIndexPath=nil;
    
    [fevoriteList_table setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
    
    
    [self.view addSubview:HUD];
    [HUD show:YES];
    [self fetchAndRefresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - Tableview Delegate
#pragma mark


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count=0;
    if (arrDisplay && arrDisplay.count>0)
    {
        count = arrDisplay.count;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=0;
    if (arrDisplay && arrDisplay.count>0) {
        count=[(NSMutableArray*)[arrDisplay objectAtIndex:section] count];
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self tableView:tableView heightForHeaderInSection:section]-5)];
    bg.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(8, 2, self.view.frame.size.width, 15.0f)];
    titleLabel.font=[UIFont boldSystemFontOfSize:14.0f];
    titleLabel.textColor=[UIColor colorWithRed:114/255.0f green:114/255.0f blue:114/255.0f alpha:1];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    
    if (section==0)
         titleLabel.text=@"Top 5";
    
    else
    {
        long prefix=5*section;
        long suffix=5*(section+1);
        titleLabel.text=[NSString stringWithFormat:@"%ld-%ld",prefix,suffix];
    }
    
    [bg addSubview:titleLabel];
    
    return bg;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"cell1";
    FevretTableViewCell *cell = (FevretTableViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    
    
    if (cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"FevretTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    ModelFevorite *favObj = [[arrDisplay objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.itemText = [NSString stringWithFormat:@"%@ %@", favObj.strFirstName,favObj.strLastName];
    cell.nameLabelText.tag=[favObj.strFevoriteId intValue];
    cell.nameLabelText.delegate=self;
    
    if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
    {
        cell.itemImage = [UIImage imageNamed:favObj.strProfileImage];
    }
    else
    {
          NSString *str = favObj.strProfileImage;
          //NSLog(@"ImageURL: %@",str);
        
        //ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        NSURL *myAssetUrl = [NSURL URLWithString:str];

        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            @autoreleasepool {
                CGImageRef iref = [rep fullScreenImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.itemImage=image;
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
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark
#pragma mark - SwipeableCellDelegate
#pragma mark
- (void)buttonChangeActionForItemText:(id)sender
{
    self.saveBtn.hidden=NO;
    FevretTableViewCell *cell=(FevretTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[fevoriteList_table indexPathForCell:cell];
    
    cell.nameLabelText.userInteractionEnabled=YES;
    [cell.nameLabelText becomeFirstResponder];
    selectedIndexPath=indexPath;
    cellEditingStatus=YES;
    cellDeleteStatus=NO;
    
    //NSLog(@"In the delegate, Clicked buttonChange-> Before Updating->Name: %@",cell.nameLabelText.text);
    
    
    CGRect rectOfCellInTableView = [fevoriteList_table rectForRowAtIndexPath:indexPath];
    //NSLog(@"TextField Origin: %f",rectOfCellInTableView.origin.y+120);
    
    if(isIphone4 || isIphone5)
    {
        if(rectOfCellInTableView.origin.y+120>253)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6)
    {
        if(rectOfCellInTableView.origin.y+120>258)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
    
    else if (isIphone6)
    {
        if(rectOfCellInTableView.origin.y+120>271)
            [fevoriteList_table setContentOffset:CGPointMake(0,rectOfCellInTableView.origin.y-120) animated:YES];
    }
        
}

- (void)buttonDeleteActionForItemText:(id)sender
{
    FevretTableViewCell *cell=(FevretTableViewCell*)[self getSuperviewOfType:[UITableViewCell class] fromView:sender];
    NSIndexPath *indexPath=[fevoriteList_table indexPathForCell:cell];
    //selectedIndexPath=indexPath;
    
    cellEditingStatus=NO;
    cellDeleteStatus=YES;
    selectedIndexPath=nil;

    ModelFevorite *selectedFavObj = [[arrDisplay objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (selectedFavObj)
    {
        NSLog(@"ProfileImage URL:%@",selectedFavObj.strProfileImage);
        
        if([selectedFavObj.strProfileImage containsString:@"assets-library:"])
        {
            float currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            NSLog(@"currentVersion: %f",currentVersion);
            
            NSURL *photosUrl=[NSURL URLWithString:selectedFavObj.strProfileImage];
            __block NSArray *arrphotosUrl=[NSArray arrayWithObjects:photosUrl, nil];
            
            if (currentVersion>=8.0)
            {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    
                     PHFetchResult *assetsToBeDeleted = [PHAsset fetchAssetsWithALAssetURLs:arrphotosUrl options:nil];
                    [PHAssetChangeRequest deleteAssets:assetsToBeDeleted];
                } completionHandler:^(BOOL success, NSError *error) {
                    
                    
                    if (success)
                    {
                       NSLog(@"Deleted from assets library.");
                    }
                    else
                    {
                        NSLog(@"Problem in deleting asset. %@", error);
                    }
                    BOOL isDeleted=[DBManager deleteFavoriteDetailsWithFavoriteId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]];
                    
                    if(isDeleted)
                        [self fetchAndRefresh];
                }];

            }
            else
            {
                BOOL isDeleted=[DBManager deleteFavoriteDetailsWithFavoriteId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]];
                if(isDeleted)
                    [self fetchAndRefresh];
            }
        }
        else
        {
            //NSLog(@"In the delegate, Clicked buttonDelete-> Name: %@",cell.nameLabelText.text);
            BOOL isDeleted=[DBManager deleteFavoriteDetailsWithFavoriteId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]];
            if(isDeleted)
                [self fetchAndRefresh];
        }
    }
    
}

#pragma mark
#pragma mark - IBActions and Methods
#pragma mark


- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)getcontacts:(id)sender
{
    __block KBContactsSelectionViewController *vc = [KBContactsSelectionViewController contactsSelectionViewControllerWithConfiguration:^(KBContactsSelectionConfiguration *configuration) {
        configuration.shouldShowNavigationBar = YES;
        configuration.tintColor = [UIColor colorWithRed:11.0/255 green:211.0/255 blue:24.0/255 alpha:1];
        configuration.title = @"All Contacts";
        configuration.selectButtonTitle = @"";
        
        //configuration.mode = KBContactsSelectionModeMessages | KBContactsSelectionModeEmail;
        configuration.mode = KBContactsSelectionModeMessages;
        configuration.skipUnnamedContacts = YES;
        configuration.customSelectButtonHandler = ^(NSArray * contacts) {
            //NSLog(@"%@", contacts);
        };
        /*configuration.contactEnabledValidation = ^(id contact) {
         APContact * _c = contact;
         if ([_c phonesWithLabels].count > 0) {
         
         NSString * phone = ((APPhoneWithLabel*) _c.phonesWithLabels[0]).phone;
         if ([phone containsString:@"888"]) {
         return NO;
         }
         }
         return YES;
         };*/
    }];
    [vc setDelegate:self];
    [self presentViewController:vc animated:YES completion:NULL];
    //[self.navigationController pushViewController:vc animated:YES];
    
    self.presentedCSVC = vc;
    
    __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 24)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Select people you want to text";
    
    vc.additionalInfoView = label;
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /*self.addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [self.addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:self.addressBookController animated:YES completion:nil];*/
}

-(IBAction)rearrangeBtnTapped:(id)sender
{
    if (arrContactsData.count>0)
    {
        RearrangeFevoriteViewController *rearrangeController=[[RearrangeFevoriteViewController alloc] initWithNibName:@"RearrangeFevoriteViewController" bundle:nil];
        [self.navigationController pushViewController:rearrangeController animated:YES];
    }
}

-(IBAction)saveBtnTapped:(id)sender
{
    if (cellEditingStatus==YES && cellDeleteStatus==NO && selectedIndexPath!=nil)
    {
        
        FevretTableViewCell *cell=(FevretTableViewCell*)[fevoriteList_table cellForRowAtIndexPath:selectedIndexPath];
        
        if (cell.nameLabelText.text.length>0)
        {
            NSLog(@"Updated Name: %@",cell.nameLabelText.text);
            NSLog(@"Favorite ID: %ld",(long)cell.nameLabelText.tag);
           BOOL isUpdated=[DBManager UpdateFavoriteWithId:[NSString stringWithFormat:@"%ld",(long)cell.nameLabelText.tag]  withColoumValue:cell.nameLabelText.text];
            
            if (isUpdated)
            {
                cellEditingStatus=NO;
                cellDeleteStatus=YES;
                selectedIndexPath=nil;
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Saved successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                self.saveBtn.hidden=YES;
                
                [self fetchAndRefresh];

            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }

        }
    }

}



#pragma mark - KBContactsSelectionViewControllerDelegate
- (void) contactsSelection:(KBContactsSelectionViewController*)selection didSelectContact:(APContact *)contact {
    
    __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@ Selected", @(self.presentedCSVC.selectedContacts.count)];
    
    self.presentedCSVC.additionalInfoView = label;
    
    NSLog(@"Selected Contact: %@", self.presentedCSVC.selectedContacts);
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (self.presentedCSVC.selectedContacts.count>0)
    {
        APContact *selectedContact =[self.presentedCSVC.selectedContacts firstObject];
        multipleContactNoArray=[NSMutableArray array];
        
        if (selectedContact)
        {
            
                ModelFevorite *favObj=[[ModelFevorite alloc] init];
                
                if(selectedContact.firstName)
                    favObj.strFirstName=selectedContact.firstName;
                else
                    favObj.strFirstName=@"";
                if(selectedContact.lastName)
                    favObj.strLastName=selectedContact.lastName;
                else
                    favObj.strLastName=@"";
                
                favObj.strMobNumber=[[selectedContact.phonesWithLabels firstObject] phone];
                favObj.strHomeNumber=[[selectedContact.phonesWithLabels firstObject] phone];
                
                __block NSString *imageURL =@"";
                
                
                [self.view addSubview:HUD];
                [HUD show:YES];
                if (selectedContact.thumbnail)
                {
                    int photolibaryAccessStatus = [self AssetLibraryAuthStatus];
                    if (photolibaryAccessStatus==3)
                    {
                        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                        [library writeImageToSavedPhotosAlbum:[selectedContact.thumbnail CGImage] orientation:(ALAssetOrientation)[selectedContact.thumbnail imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
                         {
                             if (error)
                             {
                                 [HUD hide:YES];
                                 [HUD removeFromSuperview];
                                 NSLog(@"Fetch Error: %@",error);
                                 favObj.strProfileImage=@"man_icon.png";
                             }
                             else
                             {
                                 imageURL = [assetURL absoluteString];
                                 //NSLog(@"imageURL url %@", imageURL);
                                 favObj.strProfileImage=imageURL;
                             }
                             [self insertFavoriteWith:favObj];
                         }];
                    }
                    else
                    {
                        favObj.strProfileImage=@"man_icon.png";
                        [self insertFavoriteWith:favObj];
                    }
                }
                else
                {
                    favObj.strProfileImage=@"man_icon.png";
                    [self insertFavoriteWith:favObj];
                }
        }
        else
        {
           [self showMessageWithTitle:nil withMessage:@"Failed to fetch the contact details. Please try again." withButtonTittle:@"OK"];
        }
    }
    
    else
    {
        [self showMessageWithTitle:nil withMessage:@"Failed to fetch the contact details. Please try again." withButtonTittle:@"OK"];
       
    }
    
}

- (void) contactsSelection:(KBContactsSelectionViewController*)selection didRemoveContact:(APContact *)contact
{
    __block UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 36)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@ Selected", @(self.presentedCSVC.selectedContacts.count)];
    self.presentedCSVC.additionalInfoView = label;
    
    NSLog(@"%@", self.presentedCSVC.selectedContacts);
}

- (void)contactsSelectionWillLoadContacts:(KBContactsSelectionViewController *)csvc
{
//    HUD.labelText = @"Loading Contacts";
//    [self.view addSubview:HUD];
//    [HUD show:YES];
}
- (void)contactsSelectionDidLoadContacts:(KBContactsSelectionViewController *)csvc
{
//   [HUD hide:YES];
//   [HUD removeFromSuperview];
}

#pragma mark
#pragma mark TextField Delegate Methods
#pragma mark


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}


-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [fevoriteList_table setContentOffset:CGPointZero animated:YES];
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

-(void) hideAlertView
{
    [saveAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void) fetchAndRefresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //Mostly Coding Part
        arrDisplay=[NSMutableArray array];
        arrContactsData=[NSMutableArray array];
        arrContactsData = [DBManager fetchFavorite];
        NSLog(@"No of Elements: %ld",(long)arrContactsData.count);
        [self updateSortedArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{ // 2
            
            //Mostly UI Updates
            [HUD hide:YES];
            [HUD removeFromSuperview];
            [fevoriteList_table reloadData];
        });
    });
    
    
    /*[self updateSortedArray:^(BOOL finished) {
        //NSLog(@"Sections in arrDisplay: %ld",(long)arrDisplay.count);
        //NSLog(@"ArrDisplay Contents: %@",arrDisplay);
        [fevoriteList_table reloadData];
    }];*/
    
}

-(void)updateSortedArray //:(void(^)(BOOL finished))myBlock
{
    if (arrContactsData.count>0)
    {
        int j=0;
        BOOL flag=NO;
        NSMutableArray *arrTemp=[NSMutableArray array];
        for (int i=0; i<arrContactsData.count; i++)
        {
            [arrTemp addObject:arrContactsData[i]];
            if (arrTemp.count==5)
            {
                flag=YES;
                [arrDisplay insertObject:[NSMutableArray arrayWithArray:(NSArray*)arrTemp] atIndex:j++];
                arrTemp=nil;
                arrTemp=[NSMutableArray array];
            }
            else
            {
                flag=NO;
                continue;
            }
        }
        if (!flag) {
            [arrDisplay insertObject:arrTemp atIndex:j];
            
        }
    }
    //myBlock(YES);
}

-(void) insertFavoriteWith:(ModelFevorite*)favObj
{
        if(![DBManager checkMobileNumExistsinFavoriteTable:favObj.strMobNumber])
        {
            NSMutableArray *favInsertArray=[[NSMutableArray alloc] init];
            [favInsertArray addObject:favObj];
            
            //insert to database
            [DBManager insertToFavoriteTable:favInsertArray];
            
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
            [self fetchAndRefresh];
            
            [saveAlert show];
            [self performSelector:@selector(hideAlertView)  withObject:nil afterDelay:0.75];
        }
        else
        {
            [HUD hide:YES];
            [HUD removeFromSuperview];
            
            [self showMessageWithTitle:nil withMessage:@"Already exists." withButtonTittle:@"OK"];
        }
}

-(void)showMessageWithTitle:(NSString*)strTitle withMessage:(NSString*)strMessage withButtonTittle:(NSString*)strButtonTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMessage delegate:nil cancelButtonTitle:strButtonTitle otherButtonTitles: nil];
    [alert show];
}

#pragma mark AssetLibrary Authorization Status

-(int)AssetLibraryAuthStatus
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status)
    {
        case ALAuthorizationStatusRestricted:
            return 0;
            
        case ALAuthorizationStatusDenied:
            return 1;
            
        case ALAuthorizationStatusNotDetermined:
            return 2;
            
        case ALAuthorizationStatusAuthorized:
            return 3;

            
        default:
            return 4;
    }
}

#pragma mark PHAsset Authorization Status

-(void)PHAssetAuthStatus

{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        // Access has been granted.
    }
    
    else if (status == PHAuthorizationStatusDenied) {
        // Access has been denied.
    }
    
    else if (status == PHAuthorizationStatusNotDetermined)
    {
        
        // Access has not been determined.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                // Access has been granted.
            }
            
            else {
                // Access has been denied.
            }
        }];
    }
    
    else if (status == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}

@end
