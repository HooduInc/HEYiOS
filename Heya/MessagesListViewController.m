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
#import "NSString+Emoticonizer.h"
#import "AppDelegate.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"
#import "ModelMessageSend.h"
#import "ModelUserProfile.h"
#import "MenuListTableViewCell.h"
#import "Reachability.h"
#import "HeyWebService.h"

@interface MessagesListViewController ()
{
    BOOL isReachable;
    NSMutableArray *arrAllPageValue;
    NSMutableArray *arrDisplayTableOne, *arrDisplayTableTwo, *arrDisplayTableThree, *arrDisplayTableFour;
    NSInteger pageNumber;
    NSInteger selectedSection;
    
    NSString *emoString;
    NSString *loveyouString;
}

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
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
    //messagelistController=self;
    emoString=@"\U00002764";
    loveyouString=@"Love You";
    
    CGFloat occupiedHeight=self.pageControl.frame.origin.y+self.pageControl.frame.size.height;
    
    if (isIphone4)
        messageListScrollView.frame=CGRectMake(0, occupiedHeight, self.view.frame.size.width, self.view.frame.size.height-occupiedHeight-70);
    
    else
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
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("hey_push_account_details_to_server", NULL);
    
    dispatch_async(myQueue, ^{
        //stuffs to do in background thread
        [self sendUnSyncDataToServer];
        dispatch_async(dispatch_get_main_queue(), ^{
            //stuffs to do in foreground thread, mostly UI updates

        });
    });
    
    
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
    
    /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
    {
        cell.txtFiled.text=[NSString stringWithFormat:@"%@ %@",obj.strMenuName, emoString];
    }
    else*/
        cell.txtFiled.text=[NSString emoticonizedString:obj.strMenuName];
    
    cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
    [cell.btnHeader setTag:section];
    [cell.btnHeader addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnArrow addTarget:self action:@selector(btnHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnArrow setTag:section];
    [cell.btnSave setHidden:YES];
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
    
    [cell.contentView bringSubviewToFront:cell.btnArrow];
    
    if (obj.isSubMenuOpen)
    {
        cell.btnArrow.transform=CGAffineTransformMakeRotation(M_PI);

    }
    else
    {
        cell.btnArrow.transform=CGAffineTransformMakeRotation(M_PI*2);
    }
    
    
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
    cell.txtFiled.text=[NSString emoticonizedString:objSub.strSubMenuName];
    cell.imgBackground.image=[UIImage imageNamed:obj.strMenuColor];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
        cell.txtFiled.textColor = [UIColor grayColor];
    else
        cell.txtFiled.textColor = [UIColor whiteColor];
    
    [cell.txtFiled setUserInteractionEnabled:NO];
    cell.btnHeader.hidden=YES;
    cell.btnSave.hidden=YES;
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
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"outLineThemeActive"] || [obj.strMenuColor isEqualToString:@"temp_white.png"])
        cell.txtFiled.textColor = [UIColor grayColor];
    else
        cell.txtFiled.textColor = [UIColor whiteColor];
    
    if([cell.txtFiled.text containsString:@"custom message"])
    {
        messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@ ",[NSString emoticonizedString:obj.strMenuName]];
    }
    /*else if([[cell.txtFiled.text lowercaseString] containsString:[loveyouString lowercaseString]])
    {
        messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",cell.txtFiled.text, emoString];
    }*/
    else
    {
        messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@ %@",[NSString emoticonizedString:obj.strMenuName],[NSString emoticonizedString:cell.txtFiled.text]];
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
        
    }
    
    if (pageNumber==0)
    {
        ModelMenu *obj=[arrDisplayTableOne objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {

            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            
            if([obj.strMenuName containsString:@"[ Custom Message ]"])
            {
               messagesView_obj.getMessageStr =@"HEY! ";
            }
            
            /*else if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }*/
            
            else
            {
                messagesView_obj.getMessageStr =[NSString stringWithFormat:@"HEY! %@",[NSString emoticonizedString:obj.strMenuName]];
            }
            
            messagesView_obj.quickContactsArray=[[NSMutableArray alloc] init];
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
        {
            if (obj.isSubMenuOpen) {
                obj.isSubMenuOpen=NO;
            }
            else
                obj.isSubMenuOpen=YES;
            
            [menulistTable reloadData];
        }
    }
    else if (pageNumber==1)
    {
        ModelMenu *obj=[arrDisplayTableTwo objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr =[NSString stringWithFormat:@"HEY! %@",[NSString emoticonizedString:obj.strMenuName]];
            
            /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }*/
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
        {
            if (obj.isSubMenuOpen) {
                obj.isSubMenuOpen=NO;
            }
            else
                obj.isSubMenuOpen=YES;
            [menulistTableTwo reloadData];
        }
    }
    
    else if (pageNumber==2)
    {
        ModelMenu *obj=[arrDisplayTableThree objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@",[NSString emoticonizedString:obj.strMenuName]];
            
            /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }*/
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
        {
            if (obj.isSubMenuOpen) {
                obj.isSubMenuOpen=NO;
            }
            else
                obj.isSubMenuOpen=YES;
            [menulistTableThree reloadData];
        }
    }
    
    else if (pageNumber==3)
    {
        ModelMenu *obj=[arrDisplayTableFour objectAtIndex:[sender tag]];
        if (obj.arrSubMenu.count==0)
        {
            MessagesViewController *messagesView_obj = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
            messagesView_obj.getMessageStr = [NSString stringWithFormat:@"HEY! %@",[NSString emoticonizedString:obj.strMenuName]];
            
            /*if([[obj.strMenuName lowercaseString] containsString:[loveyouString lowercaseString]])
            {
                messagesView_obj.getMessageStr=[NSString stringWithFormat:@"HEY! %@ %@",obj.strMenuName, emoString];
            }*/
            
            if(![messagesView_obj.getMessageStr containsString:@"Write or pick message using edit"])
                [self.navigationController pushViewController:messagesView_obj animated:YES];
        }
        else
        {
            if (obj.isSubMenuOpen) {
                obj.isSubMenuOpen=NO;
            }
            else
                obj.isSubMenuOpen=YES;
            [menulistTableFour reloadData];
        }
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


#pragma mark
#pragma mark Reachability Method Implementation
#pragma mark

//Called by Reachability whenever status changes.

-(BOOL)isNetworkAvailable
{
    return isReachable;
}
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NSString* baseLabelText = @"";
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable)
        {
            isReachable=NO;
            baseLabelText = NSLocalizedString(@"Cellular data network is unavailable.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            isReachable=YES;
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        NSLog(@"Reachability Message: %@", baseLabelText);
    }
    
    if (reachability == self.internetReachability)
    {
        NSLog(@"internetReachability is possible");
    }
    
    if (reachability == self.wifiReachability)
    {
        NSLog(@"wifiReachability is possible");
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


#pragma mark
#pragma mark Helper Method
#pragma mark

-(id)getSuperviewOfType:(id)superview fromView:(id)myView
{
    NSLog(@"superviewClass=%@",[superview class]);
    if ([myView isKindOfClass:[superview class]]) {
        return myView;
    }
    else
    {
        id temp=[myView superview];
        
        while (1) {
            NSLog(@"tempClass=%@",[temp class]);
            if ([temp isKindOfClass:[superview class]]) {
                return temp;
            }
            temp=[temp superview];
        }
    }
    return nil;
}

-(void)sendUnSyncDataToServer
{
    NSMutableArray *unSyncArray=[[NSMutableArray alloc] init];
    unSyncArray=[DBManager fetchUnSyncMessageDetailsWithisPushedToServer:0];
    
    if (unSyncArray.count>0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        NSString *remoteHostName =HeyBaseURL;
        
        self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
        [self updateInterfaceWithReachability:self.hostReachability];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [self updateInterfaceWithReachability:self.internetReachability];
        
        self.wifiReachability = [Reachability reachabilityForLocalWiFi];
        [self.wifiReachability startNotifier];
        [self updateInterfaceWithReachability:self.wifiReachability];
        
        if([self isNetworkAvailable])
        {
            
            NSMutableArray *userProfile=[[NSMutableArray alloc] init];
            userProfile=[DBManager fetchUserProfile];
            ModelUserProfile *modObj=[userProfile objectAtIndex:0];
            
            NSLog(@"Device UDID: %@",modObj.strDeviceUDID);
            
            NSString *accountCreationDateStr=@"";
            if (modObj.strAccountCreated && modObj.strAccountCreated.length>0)
            {
                NSLog(@"Account Creation Date: %@",modObj.strAccountCreated);
                accountCreationDateStr=[NSString stringWithFormat:@"%@",modObj.strAccountCreated];
                NSLog(@"Account Creation Date After Formatting: %@",accountCreationDateStr);
                
            }
            NSString *FullName=@"";
            if (modObj.strFirstName && modObj.strFirstName.length>0)
            {
                FullName=[NSString stringWithFormat:@"%@",modObj.strFirstName];
            }
            if (modObj.strLastName && modObj.strLastName.length>0)
            {
                FullName=[NSString stringWithFormat:@"%@ %@",FullName, modObj.strLastName];
            }
            NSString *ContactNumber=@"";
            if (modObj.strPhoneNo && modObj.strPhoneNo.length>0)
            {
                ContactNumber=[NSString stringWithFormat:@"%@",modObj.strPhoneNo];
            }
            
            
            NSDate *today=[NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd-MM-yyyy"];
            NSString *timeStamp = [formatter stringFromDate:today];
            
            NSLog(@"timeStamp: %@",timeStamp);
            
            NSLog(@"isSendToServer Status: %d",modObj.isRegistered);
            if (modObj.isRegistered==0)
            {
                [[HeyWebService service] registerWithUDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] FullName:[FullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ContactNumber:[ContactNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] TimeStamp:timeStamp AccountCreated:accountCreationDateStr WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                 {
                     if (isError)
                     {
                         NSLog(@"Resigartion Error Message: %@",strMsg);
                         
                         if ([strMsg isEqualToString:@"This Mobile UDID already exists. Try with another!"])
                         {
                             UIAlertView *showDialog=[[UIAlertView alloc] initWithTitle:nil message:@"Already Registerd." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                             
                             [showDialog show];
                             
                             [DBManager updatedToServerForUserWithFlag:1];
                             [DBManager isRegistrationSuccessful:1];
                             
                         }
                     }
                     
                     else
                     {   [DBManager updatedToServerForUserWithFlag:1];
                         [DBManager isRegistrationSuccessful:1];
                         
                         if (pushDeviceTokenId && pushDeviceTokenId.length>0)
                         {
                             [[HeyWebService service] fetchPushNotificationFromServerWithPushToken:[pushDeviceTokenId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] UDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                              {
                                  NSLog(@"Push Message: %@",strMsg);
                              }];
                         }
                         
                         
                         NSLog(@"Resigartion Success Message: %@",strMsg);
                         for (ModelMessageSend *objSend in unSyncArray)
                         {
                             NSString *strTimeStamp=@"";
                             if (objSend.strSendDate && objSend.strSendDate.length>0)
                             {
                                 strTimeStamp=[NSString stringWithFormat:@"%@",objSend.strSendDate];
                                 NSLog(@"Message Send Timestamp: %@",strTimeStamp);
                                 
                             }
                             
                             [[HeyWebService service] sendMessageDetailsToServerWithUDID:[objSend.strDeviceId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]   TemplateId:objSend.strtemplateId MsgText:objSend.strMessageText TimeStamp:strTimeStamp From:objSend.strTo To:objSend.strFrom WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                              {
                                  if(isError)
                                  {
                                      NSLog(@"Error: %@",strMsg);
                                  }
                                  else
                                  {
                                      NSLog(@"Success: %@",strMsg);
                                      
                                      [DBManager updateMessageDetailsIsPushedToServer:1 withMessageId:[NSString stringWithFormat:@"%@",objSend.strMessageInsertId]];
                                  }
                              }];
                         }
                     }
                     
                 }];
                
            }
            else
            {
                for (ModelMessageSend *objSend in unSyncArray)
                {
                    NSString *strTimeStamp=@"";
                    if (objSend.strSendDate && objSend.strSendDate.length>0)
                    {
                        strTimeStamp=[NSString stringWithFormat:@"%@",objSend.strSendDate];
                        NSLog(@"Message Send Timestamp: %@",strTimeStamp);
                        
                    }
                    
                    [[HeyWebService service] sendMessageDetailsToServerWithUDID:[objSend.strDeviceId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  TemplateId:objSend.strtemplateId MsgText:objSend.strMessageText TimeStamp:strTimeStamp From:objSend.strTo To:objSend.strFrom WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
                     {
                         if(isError)
                         {
                             NSLog(@"Error: %@",strMsg);
                         }
                         else
                         {
                             NSLog(@"Success: %@",strMsg);
                             
                             [DBManager updateMessageDetailsIsPushedToServer:1 withMessageId:[NSString stringWithFormat:@"%@",objSend.strMessageInsertId]];
                         }
                     }];
                }
            }

        }
    }
}

@end
