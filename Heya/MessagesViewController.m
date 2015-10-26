//
//  MessagesViewController.m
//  Heya
//
//  Created by Jayanta Karmakar on 17/10/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//
#import <Social/Social.h>
#import "MessagesViewController.h"
#import "SettingsViewController.h"
#import "GroupViewController.h"
#import "AOTag.h"
#import "AppDelegate.h"
#import "SlideMenuView.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UIImage+HGViewRendering.h"
#import "FevoriteViewController.h"
#import "MessagesListViewController.h"
#import "ModelFevorite.h"
#import "ModelGroup.h"
#import "ModelGroupMembers.h"
#import "ModelUserProfile.h"
#import "ModelMessageSend.h"
#import "HeyWebService.h"
#import "InAppPurchaseHelper.h"
#import <AdSupport/AdSupport.h>


@interface MessagesViewController ()<MBProgressHUDDelegate>
{
    int fontSize;
    NSInteger emojiTag;
    MBProgressHUD *HUD;
    NSMutableArray *contactFavoriteOnlyArr,*contactGroupOnlyArr,*onlyGroupIdArr;
    NSMutableArray *tickImageGroupArray, *tickImageFavArray;
    NSMutableArray *peopleImageGroupArray, *peopleImageFavArray;
    NSMutableArray *multipleContactNoArray;
    NSUserDefaults *preferances;
    NSMutableDictionary *contactInfoDict;
    NSString *urlString, *imageURL, *contactNumString;
    NSString *shareHeyTextString, *shareHeyLink, *phoneTextString, *insertPhoneString;
    BOOL isReachable;
    NSData *imageData;
    
    
    NSString *afterMsgSendString;
    NSArray *afterMsgSendContactArr;
}
@property (retain) AOTagList *tag;
@property (nonatomic, strong) NSString *universalMobNumber;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation MessagesViewController

@synthesize contactsContainer,toPeopleImg, peopleNameLabel, closeButton;
@synthesize imageView,imagePicker;
@synthesize mainScrollView, messageTextView,getMessageStr,EMOJI_arr,buttonArray,arrFavData, feviratScroll, groupScrollView, quickContactsArray, arrGroupList, arrGroupMember , universalMobNumber, editingScrollView;

SlideMenuView *slideMenuView;
float contactsContainerX = 6.0f;
float editScrollViewContentHeight=72.0f;
unsigned long location;



#pragma mark
#pragma mark ViewController Initialization
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
    preferances=[NSUserDefaults standardUserDefaults];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.view bringSubviewToFront:self.contactsScroller];
    messageTextView.font = [UIFont fontWithName:@"Helvetica" size:15];
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    if(isIphone4)
    {
        fontSize=13;
         mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, self.view.frame.size.height+self.sendView.frame.size.height);
    }
    else if (isIphone5)
        fontSize=14;
    
    else if (isIphone6 || isIphone6Plus)
        fontSize=15;
    
    
    quickContactsArray = [[NSMutableArray alloc]init];
    contactFavoriteOnlyArr=[NSMutableArray array];
    contactGroupOnlyArr=[NSMutableArray array];
    onlyGroupIdArr=[NSMutableArray array];
    buttonArray = [[NSMutableArray alloc]init];

    self.editingScrollView.contentSize =CGSizeMake(320,79);
    feviratScroll.contentSize =CGSizeMake(537,79);
    
    [self showEMUJ];
    
    self.tag = [[AOTagList alloc] initWithFrame:CGRectMake(0.0f,246.0f,245.0f,32.0f)];
    
    [self.tag setTagFont:@"Helvetica-Light" withSize:12.0f];
    [self.tag setDelegate:self];
    [self.view addSubview:self.tag];
    
    shareHeyTextString=@"\nGet HEY Fever!";
    shareHeyLink=@"- http://www.getheyfever.com/";
    
    
    UIButton *bigFavBtn=[[UIButton alloc] initWithFrame:CGRectMake(6, 250, 114, 30)];
    bigFavBtn.backgroundColor=[UIColor clearColor];
    [bigFavBtn addTarget:self action:@selector(gotoFevoriteViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:bigFavBtn atIndex:9999];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    if (![preferances boolForKey:@"hasAlertedFirstTime"])
    {
        UIAlertView *alertFavoriteAdd = [[UIAlertView alloc] initWithTitle:nil message:@"You have no Favorites yet. Please add Favorites now." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Add Now",@"Later", nil];
        
        alertFavoriteAdd.tag=2;
        [alertFavoriteAdd show];
        [preferances setBool:YES forKey:@"hasAlertedFirstTime"];
        [preferances synchronize];
    }

    
    
    [self CheckSubscription];
    emojiTag=9999;
    
    tickImageGroupArray =[NSMutableArray array];
    tickImageFavArray =[NSMutableArray array];
    
    peopleImageFavArray =[NSMutableArray array];
    peopleImageGroupArray =[NSMutableArray array];
    
    //store only when Contact No exists
    if([preferances valueForKey:@"ProfileContactNo"])
    {
        phoneTextString=[preferances valueForKey:@"ProfileContactNo"];
        insertPhoneString=[NSString stringWithFormat:@"%@",phoneTextString];
    }
    else
        phoneTextString=@"";
    
    
    //Execute only whenever message comes from Homescreen
    if(getMessageStr.length>0)
    {
        if ([getMessageStr isEqualToString:@"HEY! "])
        {
            [messageTextView becomeFirstResponder];
        }
        messageHolderString=[NSString stringWithFormat:@"%@  ",getMessageStr];
        
        NSMutableAttributedString *wholeMsg=[[NSMutableAttributedString alloc] initWithString:messageHolderString];
        [wholeMsg addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,4)];
        
        messageTextView.attributedText=wholeMsg;
        
        BOOL check=[[preferances valueForKey:@"shareHey"] boolValue];
        if(check==1)
        {
            [self addRemoveHeyFeverText];
            [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon_over.png"] forState:UIControlStateNormal];
        }
        getMessageStr=@"";
    }
    else
    {
        NSMutableAttributedString *attributeMessageString = [[NSMutableAttributedString alloc] initWithString:messageHolderString];
        
        //NSLog(@"attributeMessageString: %@", [attributeMessageString string]);
        
        //Always Make "HEY!" Text Red if Exists
        if([[attributeMessageString string] containsString:@"HEY!"])
        {
            
            [attributeMessageString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,4)];
        }
        
        //Check "Get Hey Fever!" Exists or not
        if([[attributeMessageString string] containsString:shareHeyTextString])
        {
            
            if([[attributeMessageString string] containsString:phoneTextString] && [messageHolderString containsString:shareHeyTextString])
            {
                BOOL check=[[preferances valueForKey:@"shareHey"] boolValue];
                if(check==1)
                {
                    
                    //NSLog(@"1.Whole String Length: %ld", (long)[attributeMessageString length]);
                    //NSLog(@"1.Hey String Length with Contact No: %ld", (long)[shareHeyTextString length]+[phoneTextString length]);
                    //NSLog(@"1.Possible Position: %ld", (long)[attributeMessageString length]-[shareHeyTextString length]);
                    
                    [attributeMessageString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange([attributeMessageString length]-[shareHeyTextString length]-[phoneTextString length], [shareHeyTextString length])];
                    [attributeMessageString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange([attributeMessageString length]-[shareHeyTextString length]-[phoneTextString length],[shareHeyTextString length])];
                }
                else
                {
                    [self addRemoveHeyFeverText];
                }
                
            }
            
            else
            {
                //NSLog(@"2.Whole String Length: %ld", (long)[attributeMessageString length]);
                //NSLog(@"2.Hey String Length: %ld", (long)[shareHeyTextString length]);
                //NSLog(@"2.Possible Position: %ld", (long)[attributeMessageString length]-[shareHeyTextString length]);
                [attributeMessageString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange([attributeMessageString length]-[shareHeyTextString length], [shareHeyTextString length])];
                [attributeMessageString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange([attributeMessageString length]-[shareHeyTextString length],[shareHeyTextString length])];
            }
            messageTextView.attributedText=attributeMessageString;
        }
        else
        {
            messageTextView.attributedText=attributeMessageString;
        }
    }
    
    messageTextView.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    
    [self contentSizeRectForTextView:messageTextView];
    [messageTextView layoutIfNeeded];
    
    [self favouriteLoad];
    [self groupViewLoad];
    
    NSLog(@"On viewWillAppear: %@",quickContactsArray);
}

- (CGRect)contentSizeRectForTextView:(UITextView *)textView
{
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
    CGRect textBounds = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
    CGFloat width =  (CGFloat)ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right);
    CGFloat height = (CGFloat)ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom);
    return CGRectMake(0, 0, width, height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark
#pragma mark Favorite Contacts
#pragma mark

-(void) favouriteLoad
{
    arrFavData = [[NSMutableArray alloc]init];
    arrFavData = [DBManager fetchFavorite];
    int count=0;
    float imagx = 15.0f;
    
    //first remove existed subviews
    NSArray *viewsToRemove = [feviratScroll subviews];
    for (UIView *sub in viewsToRemove) {
        [sub removeFromSuperview];
    }

    
    //for (NSMutableDictionary *dic in arrFavData)
    for (int i=0; i<arrFavData.count; i++)
    {
        UIView *peopleContainer=[[UIView alloc] initWithFrame:CGRectMake(imagx,0.0f,54.0f,80.0f)];
        UIImageView *peopleImg=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,54.0f,54.0f)];
        peopleImg.layer.cornerRadius = peopleImg.frame.size.width / 2;
        peopleImg.clipsToBounds = YES;
        peopleImg.layer.borderColor=[UIColor clearColor].CGColor;
        peopleImg.layer.borderWidth=1.0f;
        
        [peopleImageFavArray addObject:peopleImg];
        
        ModelFevorite *favObj=[[ModelFevorite alloc] init];
        favObj=[arrFavData objectAtIndex:i];
        
        if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
        {
            peopleImg.image = [UIImage imageNamed:favObj.strProfileImage];
        }
        
        else
        {
            NSString *str = favObj.strProfileImage;
            NSLog(@"ImageURL: %@",str);
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
                            //UIMethod trigger...
                            peopleImg.image=image;
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
        
        
        UILabel *favConNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 60,54 ,21)];
        favConNameLabel.text = [NSString stringWithFormat:@"%@", favObj.strFirstName];
        favConNameLabel.textAlignment=NSTextAlignmentCenter;
        favConNameLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        UIButton *contactButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,54.0f ,80.0f)];
        //contactButton.backgroundColor=[UIColor redColor];
        [contactButton addTarget:self action:@selector(addFavoriteContactNumber:) forControlEvents:UIControlEventTouchUpInside];
        //contactButton.tag =[[dic objectForKey:@"mobileNumber"] integerValue];
        contactButton.titleLabel.text = favObj.strMobNumber;
        contactButton.titleLabel.hidden=YES;
        contactButton.tag=count;
        
        [peopleContainer addSubview:peopleImg];
        [peopleContainer addSubview:favConNameLabel];
        
        UIImageView *tickImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
        tickImage.image = [UIImage imageNamed:@"right_icon.png"];
        tickImage.hidden=YES;
        //pImg.layer.borderColor=[UIColor redColor].CGColor;
        [tickImageFavArray addObject:tickImage];
        [peopleContainer addSubview:tickImage];
        peopleContainer.tag=count;
        [peopleContainer insertSubview:contactButton aboveSubview:peopleImg];
        
        [feviratScroll addSubview:peopleContainer];
        imagx = imagx + peopleContainer.frame.size.width+15;
        
        count++;
    }
    
    [feviratScroll setContentSize:CGSizeMake(imagx, feviratScroll.frame.size.height)];
    
    
    [feviratScroll.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        if ([obj isKindOfClass:[UIView class]])
        {
            UIView *vw=(UIView*)obj;
            for (id bObj in vw.subviews)
            {
                if ([bObj isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton*)bObj;
                    
                    //NSLog(@"TitleLabel Contact: %@",btn.titleLabel.text);
                    
                    if ([quickContactsArray containsObject:btn.titleLabel.text])
                    {
                        NSLog(@"contactFavoriteOnlyArr: %@",contactFavoriteOnlyArr);
                        if ([contactFavoriteOnlyArr containsObject:btn.titleLabel.text])
                        {
                            //NSLog(@"Found: %ld",(long)idx);
                            UIImageView *tImg=[tickImageFavArray objectAtIndex:idx];
                            UIImageView *pImg=[peopleImageFavArray objectAtIndex:idx];
                            if(tImg.hidden==YES)
                            {
                                tImg.hidden=NO;
                                pImg.layer.borderColor=[UIColor redColor].CGColor;
                            }
                        }
                        
                    }
                }
            }
        }
    }];
    
}

- (void) addFavoriteContactNumber:(UIButton*)sender
{
    NSLog(@"tickImageFavArray: %@",tickImageFavArray);
    NSLog(@"Clicked On: %@",[tickImageFavArray objectAtIndex:sender.tag]);
    
    UIImageView *tImg=[tickImageFavArray objectAtIndex:sender.tag];
    UIImageView *pImg=[peopleImageFavArray objectAtIndex:sender.tag];
    
    if(tImg.hidden==YES)
    {
        tImg.hidden=NO;
        pImg.layer.borderColor=[UIColor redColor].CGColor;
    
        NSLog(@"Before Adding to Main Contacts array from Favorite: %@",quickContactsArray);
        universalMobNumber=sender.titleLabel.text;
        arrFavData = [[NSMutableArray alloc]init];
        arrFavData = [DBManager fetchFavoriteWithMobileNumber:universalMobNumber];
        
        //for (NSMutableDictionary *dic in arrFavData)
        for (int i=0; i<arrFavData.count; i++)
        {
            contactsContainer=[[UIView alloc] initWithFrame:CGRectMake(0.0f,4.0f,110.0f,22.0f)];
            contactsContainer.backgroundColor=[UIColor  colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
            contactsContainer.userInteractionEnabled=YES;
            contactsContainer.layer.cornerRadius = 11.0f;
            
            toPeopleImg=[[UIImageView alloc] initWithFrame:CGRectMake(2.0f,2.0f,18.0f,18.0f)];
            
            toPeopleImg.layer.cornerRadius = toPeopleImg.frame.size.width / 2;
            toPeopleImg.clipsToBounds = YES;
            
            ModelFevorite *favObj=[[ModelFevorite alloc] init];
            favObj=[arrFavData objectAtIndex:i];
            
            if([favObj.strProfileImage isEqualToString:@"man_icon.png"])
            {
                toPeopleImg.image = [UIImage imageNamed:favObj.strProfileImage];
            }
            
            else
            {
                NSString *str = favObj.strProfileImage;
                NSLog(@"ImageURL: %@",str);
                NSURL *myAssetUrl = [NSURL URLWithString:str];
                
                ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                {
                    ALAssetRepresentation *rep = [myasset defaultRepresentation];
                    @autoreleasepool {
                        CGImageRef iref = [rep fullScreenImage];
                        if (iref) {
                            UIImage *image = [UIImage imageWithCGImage:iref];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //UIMethod trigger...
                                toPeopleImg.image=image;
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
            
            peopleNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(27.0f,2.0f,70.0f,18.0f)];
            peopleNameLabel.font=[UIFont fontWithName:@"OpenSans" size:10];
            peopleNameLabel.textColor=[UIColor blackColor];
            peopleNameLabel.text=[NSString stringWithFormat:@"%@", favObj.strFirstName];
            
            closeButton = [[UIButton alloc] initWithFrame:CGRectMake(90.0f, 2.0f, 18.0f, 18.0f)];
            [closeButton setImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(removeFavouriteContact:) forControlEvents:UIControlEventTouchUpInside];
            
            closeButton.titleLabel.text=favObj.strMobNumber;
            closeButton.tag=sender.tag;

            closeButton.layer.cornerRadius = closeButton.frame.size.width / 2;
            closeButton.clipsToBounds = YES;

            [contactsContainer addSubview:toPeopleImg];
            [contactsContainer addSubview:peopleNameLabel];
            [contactsContainer addSubview:closeButton];
            [contactsContainer bringSubviewToFront:closeButton];
            
            NSArray *temparrMem=[sender.titleLabel.text componentsSeparatedByString:@","];

            for(int x=0; x<temparrMem.count;x++)
            {
                if (![quickContactsArray containsObject:[temparrMem objectAtIndex:x]])
                {
                    [quickContactsArray addObject:sender.titleLabel.text];
                    [contactFavoriteOnlyArr addObject:sender.titleLabel.text];
                }
            }
            
            contactsContainer.frame = CGRectMake(contactsContainerX, contactsContainer.frame.origin.y, contactsContainer.frame.size.width, contactsContainer.frame.size.height);
            
            [self.contactsScroller addSubview:contactsContainer];
            contactsContainerX = contactsContainer.frame.origin.x + contactsContainer.frame.size.width+6.0f;
            NSLog(@"contactsContainerX:  %f", contactsContainerX);
            self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
        }
        
        [self.view bringSubviewToFront:self.contactsScroller];
        self.contactsScroller.layer.zPosition=1;
        NSLog(@"After Adding to Main Contacts array from Favorite: %@",quickContactsArray);
    }
}

-(void) removeFavouriteContact: (UIButton *) sender
{
    if([quickContactsArray containsObject:sender.titleLabel.text] && ![contactGroupOnlyArr containsObject:sender.titleLabel.text])
    {
        NSLog(@"Matched in Favourite Contact: %@",sender.titleLabel.text);
        [quickContactsArray removeObject:sender.titleLabel.text];
    }
    if([contactFavoriteOnlyArr containsObject:sender.titleLabel.text])
        [contactFavoriteOnlyArr removeObject:sender.titleLabel.text];
    
    [sender.superview removeFromSuperview];
    contactsContainerX = 6.0f;
    
    for(UIView *cview in self.contactsScroller.subviews)
    {
        cview.frame = CGRectMake(contactsContainerX, cview.frame.origin.y, cview.frame.size.width, cview.frame.size.height);
        contactsContainerX = cview.frame.origin.x + cview.frame.size.width+6.0f;
        //NSLog(@"contactsContainerX:  %f", contactsContainerX);
        self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
        
    }
    UIImageView *tImg=[tickImageFavArray objectAtIndex:sender.tag];
    tImg.hidden=YES;
    UIImageView *pImg=[peopleImageFavArray objectAtIndex:sender.tag];
    pImg.layer.borderColor=[UIColor clearColor].CGColor;
    
    universalMobNumber = @"";
    NSLog(@"After Removing Favourite Contact: %@", quickContactsArray);

}

#pragma mark
#pragma mark Group Contacts
#pragma mark

-(void) groupViewLoad
{
    float imagx = 15.0f;
    int count=0;
    
    arrGroupList = [[NSMutableArray alloc]init];
    arrGroupList = [DBManager fetchDetailsFromGroup];
    
    
    //first remove existed subviews
    NSArray *viewsToRemove = [groupScrollView subviews];
    for (UIView *sub in viewsToRemove) {
        [sub removeFromSuperview];
    }
    
    
    for (int i=0; i<arrGroupList.count;i++)
    {
        
        ModelGroup *objGroup=[[ModelGroup alloc] init];
        objGroup=[arrGroupList objectAtIndex:i];
        
        arrGroupMember=[DBManager fetchGroupMembersWithGroupId:objGroup.strGroupId];
        
        NSMutableArray *fetchContact=[[NSMutableArray alloc] init];
        
        for (int j=0; j<arrGroupMember.count;j++)
        {
            ModelGroupMembers *objMember=[arrGroupMember objectAtIndex:j];
            [fetchContact addObject:objMember.strMobileNumber];
            
        }
        
        UIView *peopleContainer=[[UIView alloc] initWithFrame:CGRectMake(imagx,0.0f,54.0f,80.0f)];
        UIImageView *peopleImg=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,54.0f,54.0f)];
        peopleImg.layer.cornerRadius = peopleImg.frame.size.width / 2;
        peopleImg.clipsToBounds = YES;
        
        peopleImg.layer.borderColor=[UIColor clearColor].CGColor;
        peopleImg.layer.borderWidth=1.0f;
        
        
        [peopleImageGroupArray addObject:peopleImg];
        
        peopleImg.image = [UIImage imageNamed:@"man_group.png"];
        
        UILabel *groupConNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 60,54 ,21)];
        groupConNameLabel.text = [NSString stringWithFormat:@"%@", objGroup.strGroupName];
        groupConNameLabel.textAlignment=NSTextAlignmentCenter;
        groupConNameLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        UIButton *contactButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,54.0f ,80.0f)];
        [contactButton addTarget:self action:@selector(getContactFromGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        contactButton.titleLabel.text = objGroup.strGroupId;
        contactButton.titleLabel.hidden=YES;
        contactButton.tag=count;
        
        [peopleContainer addSubview:peopleImg];
        [peopleContainer addSubview:groupConNameLabel];
        
        UIImageView *tickImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,20.0f,20.0f)];
        tickImage.image = [UIImage imageNamed:@"right_icon.png"];
        tickImage.hidden=YES;
        [tickImageGroupArray addObject:tickImage];
        [peopleContainer addSubview:tickImage];
        
        [peopleContainer insertSubview:contactButton aboveSubview:peopleImg];
        [groupScrollView addSubview:peopleContainer];
        imagx = imagx + peopleContainer.frame.size.width+15;
        count++;
        
    }
    [groupScrollView setContentSize:CGSizeMake(imagx, groupScrollView.frame.size.height)];
    
    [groupScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[UIView class]])
        {
            UIView *vw=(UIView*)obj;
            for (id bObj in vw.subviews)
            {
                if ([bObj isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton*)bObj;
                    
                    NSLog(@"TitleLabel Contact: %@",btn.titleLabel.text);
                    
                    if ([onlyGroupIdArr containsObject:btn.titleLabel.text])
                    {
                
                        NSLog(@"Found: %ld",(long)idx);
                        UIImageView *tImg=[tickImageGroupArray objectAtIndex:idx];
                        UIImageView *pImg=[peopleImageGroupArray objectAtIndex:idx];
                        if(tImg.hidden==YES)
                        {
                            tImg.hidden=NO;
                            pImg.layer.borderColor=[UIColor redColor].CGColor;
                        }
                    }
                }
            }
        }
    }];
    
}

- (void) getContactFromGroup:(UIButton*)sender
{
    UIImageView *tImg=[tickImageGroupArray objectAtIndex:sender.tag];
    UIImageView *pImg=[peopleImageGroupArray objectAtIndex:sender.tag];
    
    if(tImg.hidden==YES)
    {
        NSLog(@"Before Adding to Main Contacts array from Group: %@",quickContactsArray);
        NSMutableArray *mainGroup = [[NSMutableArray alloc]init];
        mainGroup = [DBManager fetchDataFromGroupWithGroupId:sender.titleLabel.text];
        
        ModelGroup *objGroup=[mainGroup objectAtIndex:0];
        
        contactsContainer=[[UIView alloc] initWithFrame:CGRectMake(0.0f,4.0f,110.0f,22.0f)];
        contactsContainer.backgroundColor=[UIColor  colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
        contactsContainer.userInteractionEnabled=YES;
        contactsContainer.layer.cornerRadius = 11.0f;
        
        toPeopleImg=[[UIImageView alloc] initWithFrame:CGRectMake(2.0f,2.0f,18.0f,18.0f)];
        toPeopleImg.layer.cornerRadius = toPeopleImg.frame.size.width / 2;
        toPeopleImg.clipsToBounds = YES;
        
        toPeopleImg.image = [UIImage imageNamed:@"man_group.png"];
        
        /*if([[dic valueForKey:@"profileimage"]isEqualToString:@"man_icon.png"])
         {
         toPeopleImg.image = [UIImage imageNamed:[dic objectForKey:@"profileimage"]];
         }
         
         else
         {
         NSString *str = [dic objectForKey:@"profileimage"];
         NSLog(@"ImageURL: %@",str);
         NSURL *myAssetUrl = [NSURL URLWithString:str];
         
         ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
         {
         ALAssetRepresentation *rep = [myasset defaultRepresentation];
         @autoreleasepool {
         CGImageRef iref = [rep fullScreenImage];
         if (iref) {
         UIImage *image = [UIImage imageWithCGImage:iref];
         
         dispatch_async(dispatch_get_main_queue(), ^{
         //UIMethod trigger...
         toPeopleImg.image=image;
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
        
        peopleNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(27.0f,2.0f,70.0f,18.0f)];
        peopleNameLabel.font=[UIFont fontWithName:@"OpenSans" size:10];
        peopleNameLabel.textColor=[UIColor blackColor];
        peopleNameLabel.text=[NSString stringWithFormat:@"%@", objGroup.strGroupName];
        
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(90.0f, 2.0f, 18.0f, 18.0f)];
        [closeButton setImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(removeGroupContact:) forControlEvents:UIControlEventTouchUpInside];
        
        closeButton.titleLabel.text=sender.titleLabel.text;
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2;
        closeButton.clipsToBounds = YES;
        closeButton.tag=sender.tag;
        
        [contactsContainer addSubview:toPeopleImg];
        [contactsContainer addSubview:peopleNameLabel];
        [contactsContainer addSubview:closeButton];
        [contactsContainer bringSubviewToFront:closeButton];
        
        arrGroupMember=[[NSMutableArray alloc] init];
        arrGroupMember=[DBManager fetchGroupMembersWithGroupId:objGroup.strGroupId];
        NSMutableArray *fetchContact=[[NSMutableArray alloc] init];
        
        if (arrGroupMember.count>0)
        {
            //fetch contact no from group members
            for (int g=0; g<arrGroupMember.count; g++)
            {
                ModelGroupMembers *objGroupMem= [arrGroupMember objectAtIndex:g];
                [fetchContact addObject:objGroupMem.strMobileNumber];
            }
            
            //add group contacts to main contact array
            for(int x=0; x<fetchContact.count;x++)
            {
                if (![quickContactsArray containsObject:[fetchContact objectAtIndex:x]])
                {
                    [quickContactsArray addObject:[fetchContact objectAtIndex:x]];
                    [contactGroupOnlyArr addObject:[fetchContact objectAtIndex:x]];
                }
            }
            
            [onlyGroupIdArr addObject:objGroup.strGroupId];
            
            tImg.hidden=NO;
            pImg.layer.borderColor=[UIColor redColor].CGColor;
            contactsContainer.frame = CGRectMake(contactsContainerX, contactsContainer.frame.origin.y, contactsContainer.frame.size.width, contactsContainer.frame.size.height);
            
            [self.contactsScroller addSubview:contactsContainer];
            contactsContainerX = contactsContainer.frame.origin.x + contactsContainer.frame.size.width+6.0f;
            NSLog(@"contactsContainerX:  %f", contactsContainerX);
            self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
            
            NSLog(@"After Adding to Main Contacts array from Group: %@",quickContactsArray);
        }
        else
        {
            UIAlertView *errorDialog=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"No contacts exist in %@ group.",objGroup.strGroupName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorDialog show];
        }
        
    }
    
}

-(void) removeGroupContact: (UIButton *) sender
{
    arrGroupMember=[[NSMutableArray alloc] init];
    arrGroupMember=[DBManager fetchGroupMembersWithGroupId:sender.titleLabel.text];
    
    for (int i=0; i<arrGroupMember.count; i++)
    {
        ModelGroupMembers *objGrp=[arrGroupMember objectAtIndex:i];
        
        if([quickContactsArray containsObject:objGrp.strMobileNumber] && ![contactFavoriteOnlyArr containsObject:objGrp.strMobileNumber])
        {
            NSLog(@"Matched: %@",objGrp.strMobileNumber);
            [quickContactsArray removeObject:objGrp.strMobileNumber];
        }
        if([contactGroupOnlyArr containsObject:objGrp.strMobileNumber])
           [contactGroupOnlyArr removeObject:objGrp.strMobileNumber];
        
        if([onlyGroupIdArr containsObject:sender.titleLabel.text])
            [onlyGroupIdArr removeObject:sender.titleLabel.text];
    }
    
    [sender.superview removeFromSuperview];
    contactsContainerX = 6.0f;
    
    NSLog(@"After Removing: %@", quickContactsArray);
    
    for(UIView *cview in self.contactsScroller.subviews)
    {
        cview.frame = CGRectMake(contactsContainerX, cview.frame.origin.y, cview.frame.size.width, cview.frame.size.height);
        contactsContainerX = cview.frame.origin.x + cview.frame.size.width+6.0f;
        NSLog(@"contactsContainerX:  %f", contactsContainerX);
        self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
        
    }
    
    UIImageView *tImg=[tickImageGroupArray objectAtIndex:sender.tag];
    tImg.hidden=YES;
    
    UIImageView *pImg=[peopleImageGroupArray objectAtIndex:sender.tag];
    pImg.layer.borderColor=[UIColor clearColor].CGColor;
    
    NSLog(@"After Removing Group Contact: %@", quickContactsArray);
}


#pragma mark
#pragma mark Fetch Contacts Only from Phone
#pragma mark

- (IBAction)getcontacts:(id)sender
{
    
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}

-(void) removeSingleContact: (UIButton *) sender
{
    if([quickContactsArray containsObject:sender.titleLabel.text])
    {
        NSLog(@"Matched in Single Contact: %@",sender.titleLabel.text);
        [quickContactsArray removeObject:sender.titleLabel.text];
        
    }
    [sender.superview removeFromSuperview];
    contactsContainerX = 6.0f;
    
    for(UIView *cview in self.contactsScroller.subviews)
    {
        cview.frame = CGRectMake(contactsContainerX, cview.frame.origin.y, cview.frame.size.width, cview.frame.size.height);
        contactsContainerX = cview.frame.origin.x + cview.frame.size.width+6.0f;
        //NSLog(@"contactsContainerX:  %f", contactsContainerX);
        self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
        
    }
    NSLog(@"After Removing Single Contact: %@", quickContactsArray);
    
}


#pragma mark - ABPeoplePickerNavigationController Delegate method implementation

//Works from IOS 8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    multipleContactNoArray=[[NSMutableArray alloc] init];
    
    contactInfoDict = [[NSMutableDictionary alloc]
                       initWithObjects:@[@"", @"", @"", @"", @"", @"", @"", @"", @""]
                       forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber", @"homeEmail", @"workEmail", @"address", @"zipCode", @"city"]];
    
    // Use a general Core Foundation object.
    CFTypeRef generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    // Get the first name.
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    // Get the last name.
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    // Get the phone numbers as a multi-value property.
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phonesRef)
    {
        //NSLog(@"isFacebook %d", [self isPersonFacebookContact:person]);
        
        if([self isPersonFacebookContact:person])
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"This contact information synced from facebook to your addressbook. Contact picture may not appear in here." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        for (int i=0; i<ABMultiValueGetCount(phonesRef); i++)
        {
            CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
            CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
            
            
            if ([(NSString *)kABPersonPhoneMainLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            //If Phone Number doesn't exists in kABPersonPhoneMainLabel
            if ([(NSString *)kABPersonPhoneMobileLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            //If Phone Number doesn't exists in kABPersonPhoneMobileLabel
            if ([(NSString *)kABPersonPhoneIPhoneLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            
            //If Phone Number doesn't exists in kABPersonIPhoneLabel
            if ([(NSString *)kABHomeLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            //If Phone Number doesn't exists in kABHomeLabel
            if ([(NSString *)kABWorkLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            //If Phone Number doesn't exists in kABWorkLabel
            if ([(NSString *)kABOtherLabel rangeOfString:(__bridge NSString *)(currentPhoneLabel) options:NSCaseInsensitiveSearch].location  != NSNotFound)
            {
                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            else
            {
                NSString *localLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(currentPhoneLabel);
                NSLog(@"localLabel: %@",localLabel);

                [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
                [multipleContactNoArray addObject:(__bridge NSString *)currentPhoneValue];
            }
            
            CFRelease(currentPhoneLabel);
            CFRelease(currentPhoneValue);
        }
        
        CFRelease(phonesRef);
        
        // If the contact has an image then get it too.
        if (ABPersonHasImageData(person))
        {
            
            NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
            
            UIImage  *img = [UIImage imageWithData:contactImageData];
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:[img CGImage] orientation:(ALAssetOrientation)[img imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    NSLog(@"error");
                }
                else
                {
                    
                    urlString = [assetURL absoluteString];
                    NSLog(@"url %@", urlString);
                    [contactInfoDict setObject:urlString forKey:@"image"];
                }
            }];
            
            if (multipleContactNoArray.count>1)
            {
                UIAlertView *alertContactDialog=[[UIAlertView alloc] initWithTitle:@"Select Contact" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                
                for(NSString *buttonTitle in multipleContactNoArray)
                    [alertContactDialog addButtonWithTitle:buttonTitle];
                [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
                [alertContactDialog show];
            }
            else if(multipleContactNoArray.count!=0)
            {
                [self insertIntoToField];
            }
            
        }
        
        else
        {
            [contactInfoDict setObject:@"man_icon.png" forKey:@"image"];
            
            if (multipleContactNoArray.count>1)
            {
                UIAlertView *alertContactDialog=[[UIAlertView alloc] initWithTitle:@"Select Contact" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                
                for(NSString *buttonTitle in multipleContactNoArray)
                    [alertContactDialog addButtonWithTitle:buttonTitle];
                [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
                [alertContactDialog show];
            }
            else
                [self insertIntoToField];
        }
    }
    
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Sorry. Contact number doesn't exist." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

    //[self.addressBookController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self.addressBookController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isPersonFacebookContact:(ABRecordRef)person
{
    ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
    
    BOOL returnValue = NO;
    
    if (instantMessage)
    {
        for (NSInteger i=0 ; i < ABMultiValueGetCount(instantMessage); i++)
        {
            CFDictionaryRef instantMessageValue = ABMultiValueCopyValueAtIndex(instantMessage, i);
            CFStringRef instantMessageString = CFDictionaryGetValue(instantMessageValue, kABPersonInstantMessageServiceKey);
            
            if (CFStringCompare(instantMessageString, kABPersonInstantMessageServiceFacebook, 0) == kCFCompareEqualTo)
            {
                returnValue = YES;
            }
            
            CFRelease(instantMessageString);
            CFRelease(instantMessageValue);
        }
    }
    
    //CFRelease(instantMessage);
    
    return returnValue;
}


-(void) insertIntoToField
{
    contactsContainer=[[UIView alloc] initWithFrame:CGRectMake(0.0f,4.0f,110.0f,22.0f)];
    contactsContainer.backgroundColor=[UIColor  colorWithRed:213.0f/255.0f green:213.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    contactsContainer.userInteractionEnabled=YES;
    contactsContainer.layer.cornerRadius = 11.0f;
    
    toPeopleImg=[[UIImageView alloc] initWithFrame:CGRectMake(2.0f,2.0f,18.0f,18.0f)];
    toPeopleImg.layer.cornerRadius = toPeopleImg.frame.size.width / 2;
    toPeopleImg.clipsToBounds = YES;
    
    
    if([[contactInfoDict valueForKey:@"image"]isEqualToString:@"man_icon.png"])
    {
        toPeopleImg.image = [UIImage imageNamed:[contactInfoDict objectForKey:@"image"]];
    }
    
    else
    {
        NSString *str = [contactInfoDict objectForKey:@"image"];
        NSLog(@"ImageURL: %@",str);
        NSURL *myAssetUrl = [NSURL URLWithString:str];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            @autoreleasepool {
                CGImageRef iref = [rep fullScreenImage];
                if (iref) {
                    UIImage *image = [UIImage imageWithCGImage:iref];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //UIMethod trigger...
                        toPeopleImg.image=image;
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
    
    peopleNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(27.0f,2.0f,70.0f,18.0f)];
    peopleNameLabel.font=[UIFont fontWithName:@"OpenSans" size:10];
    peopleNameLabel.textColor=[UIColor blackColor];
    peopleNameLabel.text=[NSString stringWithFormat:@"%@", [contactInfoDict objectForKey:@"firstName"]];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(90.0f, 2.0f, 18.0f, 18.0f)];
    [closeButton setImage:[UIImage imageNamed:@"close_btn.png"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(removeSingleContact:) forControlEvents:UIControlEventTouchUpInside];
    
    closeButton.titleLabel.text=[contactInfoDict objectForKey:@"mobileNumber"];
    closeButton.layer.cornerRadius = closeButton.frame.size.width / 2;
    closeButton.clipsToBounds = YES;
    [contactsContainer addSubview:toPeopleImg];
    [contactsContainer addSubview:peopleNameLabel];
    [contactsContainer addSubview:closeButton];
    
    if (![quickContactsArray containsObject:[contactInfoDict objectForKey:@"mobileNumber"]])
    {
        [quickContactsArray addObject:[contactInfoDict objectForKey:@"mobileNumber"]];
        
        contactsContainer.frame = CGRectMake(contactsContainerX, contactsContainer.frame.origin.y, contactsContainer.frame.size.width, contactsContainer.frame.size.height);
        [self.contactsScroller addSubview:contactsContainer];
        
        contactsContainerX = contactsContainer.frame.origin.x + contactsContainer.frame.size.width+6.0f;
        //NSLog(@"contactsContainerX:  %f", contactsContainerX);
        self.contactsScroller.contentSize =CGSizeMake(contactsContainerX,self.contactsScroller.frame.size.height);
        
    }
}

#pragma mark
#pragma mark Emoticon Initialization and usage
#pragma mark
- (void) showEMUJ
{
    EMOJI_arr=[[NSArray alloc]initWithObjects:@"\U0001F60A",@"\U0001F60B",@"\U0001F60C",@"\U0001F60D",@"\U0001F60E",@"\U0001F60F",@"\U0001F61A",@"\U0001F61B",@"\U0001F61C",@"\U0001F61D",@"\U0001F61E",@"\U0001F61F",@"\U0001F62A",@"\U0001F62B",@"\U0001F62C",@"\U0001F62D",@"\U0001F62E",@"\U0001F62F",@"\U0001F600",@"\U0001F601",@"\U0001F602",@"\U0001F603",@"\U0001F604",@"\U0001F605",@"\U0001F606",@"\U0001F607",@"\U0001F608",@"\U0001F609",@"\U0001F610",@"\U0001F611",@"\U0001F612",@"\U0001F613",@"\U0001F614",@"\U0001F615",@"\U0001F616",@"\U0001F617",@"\U0001F618",@"\U0001F619",@"\U0001F620",@"\U0001F621",@"\U0001F622",@"\U0001F623",@"\U0001F624",@"\U0001F625",@"\U0001F626",@"\U0001F627",@"\U0001F628",@"\U0001F629",@"\U0001F630",@"\U0001F631",@"\U0001F632",@"\U0001F633",@"\U0001F634",@"\U0001F635",@"\U0001F636",@"\U0001F637",@"\U0001F638",@"\U0001F639",@"\U0001F63A" ,@"\U0001F63B" ,@"\U0001F63C" ,@"\U0001F63D" ,@"\U0001F63E" ,@"\U0001F63F" ,@"\U0001F466",@"\U0001F467" ,@"\U0001F468" ,@"\U0001F469" ,@"\U0001F470" ,@"\U0001F471" ,@"\U0001F472" ,@"\U0001F473" ,@"\U0001F474" ,@"\U0001F475" ,@"\U0001F476" ,@"\U0001F477" ,@"\U0001F478" ,@"\U0001F482" ,@"\U0001F46e" ,@"\U0001F481" ,@"\U0001F486" ,@"\U0001F487" ,@"\U0001F491" ,@"\U0001F645" ,@"\U0001F646" ,@"\U0001F647" ,@"\U0001F64E" ,@"\U0001F64D" ,@"\U0001F64B" ,@"\U0001F48F" ,@"\U0001F46E" ,@"\U0001F46A" ,@"\U0001F64B" ,@"\U0001F64C" ,@"\U0001F64D" ,@"\U0001F64F" ,@"\U0001F64F" ,@"\U0001F64C" ,@"\U0001F446",@"\U0001F447" ,@"\U0001F448" ,@"\U0001F449" ,@"\U0001F450" ,@"\U0000270A" ,@"\U0000270B" ,@"\U0000270C" ,@"\U0001F44A" ,@"\U0001F44B" ,@"\U0001F44C" ,@"\U0001F44D" ,@"\U0001F44E" ,@"\U0001F44F",@"\U0001F4AA" ,@"\U0001F55A" ,@"\U0001F55B" ,@"\U0001F55C" ,@"\U0001F55D" ,@"\U0001F55E" ,@"\U0001F55F" ,@"\U0001F550" ,@"\U0001F551" ,@"\U0001F552" ,@"\U0001F553" ,@"\U0001F554" ,@"\U0001F555" ,@"\U0001F556" ,@"\U0001F557" ,@"\U0001F558" ,@"\U0001F559" ,@"\U0001F560" ,@"\U0001F561" ,@"\U0001F562" ,@"\U0001F563" ,@"\U0001F564" ,@"\U0001F565" ,@"\U0001F566" ,@"\U0001F567" ,@"\U0001F520" ,@"\U0001F521" ,@"\U0001F522" ,@"\U0001F523" ,@"\U0001F524" ,@"\U0001F500" ,@"\U0001F501" ,@"\U0001F502" ,@"\U0001F504" ,@"\U0001F3A6" ,@"\U0001F192" ,@"\U0001F193" ,@"\U0001F195" ,@"\U0001F197" ,@"\U0001F197" ,@"\U0001F199" ,@"\U0001F201" ,@"\U0001F53C" ,@"\U0001F53D" ,@"\U0001F51D" ,@"\U0001F51F" ,@"\U0001F43D" ,@"\U0001F43E" ,@"\U0001FF45A" ,@"\U0001F45B" ,@"\U0001F45D" ,@"\U0001F45E" ,@"\U0001F45F" ,@"\U0001F47A" ,@"\U0001F47B" ,@"\U0001F47C" ,@"\U0001F47D" ,@"\U0001F47E" ,@"\U0001F47F" ,@"\U0001F48A" ,@"\U0001F48B" ,@"\U0001F48C" ,@"\U0001F48D" ,@"\U0001F48E" ,@"\U0001F49A" ,@"\U0001F49B" ,@"\U0001F49C" ,@"\U0001F49D" ,@"\U0001F49E" ,@"\U0001F49F" ,@"\U0001F50A" ,@"\U0001F50B" ,@"\U0001F50C" ,@"\U0001F50D" ,@"\U0001F50E" ,@"\U0001F50F" ,@"\U0001F51A" ,@"\U0001F51B" ,@"\U0001F51C" ,@"\U0001F52E" ,@"\U0001F52A" ,@"\U0001F52B" ,@"\U0001F52C" ,@"\U0001F52D" ,@"\U0001F52F" ,@"\U0001F53A" ,@"\U0001F53B" ,@"\U0001F64A" ,@"\U0001F68A" ,@"\U0001F68B" ,@"\U0001F68C" ,@"\U0001F68D" ,@"\U0001F68E" ,@"\U0001F68F1", nil];
    
    int x = 20.0f;
    
    
    for(int i=0; i< [EMOJI_arr count]; i++){
        
        UIImageView *emugeImg = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 30, 30)];
        emugeImg.image = [UIImage hg_imageFromString:[EMOJI_arr objectAtIndex:i]];
        
        [emugeImg setUserInteractionEnabled:TRUE];
        emugeImg.tag=i;
        
        if (emugeImg.tag==emojiTag)
        {
            emugeImg.layer.shadowColor = [UIColor redColor].CGColor;
            emugeImg.layer.shadowOffset = CGSizeMake(0, 0);
            emugeImg.layer.shadowOpacity = 1;
            emugeImg.layer.shadowRadius = 2.0;
            emugeImg.clipsToBounds = YES;
            NSLog(@"Shadow Imoji Tag: %ld",(long)emojiTag);
        }
        
        UIButton * ButtonOnImageView = [[UIButton alloc]init];
        [ButtonOnImageView setFrame:CGRectMake(0,0,40,40)];
        
        [ButtonOnImageView setTag:i];
        [ButtonOnImageView addTarget:self action:@selector(addEmoticon:) forControlEvents:UIControlEventTouchUpInside];
        
        [emugeImg addSubview:ButtonOnImageView];
        
        [buttonArray addObject:emugeImg];
    }
}

- (IBAction)smile:(id)sender
{
    UIButton *button = sender;
    
    [buttonArray removeAllObjects];
    [self showEMUJ];
    
    UIImageView *triangleImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [appDel.window bounds].size.width,7.0f)];
    triangleImageView.image=[UIImage imageNamed:@"line_arrow.png"];
    
    if(button.tag==1)
    {
        slideMenuView = [[SlideMenuView alloc] initWithFrameColorAndButtons:CGRectMake(0.0f, 118.0f, [appDel.window bounds].size.width,40.0f) backgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"view3.png"]]  buttons:buttonArray];
        UILabel *lineEnd=[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 40.0f, [appDel.window bounds].size.width,1.0f)];
        lineEnd.backgroundColor=[UIColor  colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1.0];
        [slideMenuView addSubview:lineEnd];
        [slideMenuView addSubview:triangleImageView];
    
        
        [self.view addSubview:slideMenuView];
        triangleImageView.layer.zPosition=1;
        triangleImageView.hidden=NO;
        
        slideMenuView.hidden = NO ;
        self.smile_btn.hidden=YES;
        self.smileButtonSelected.hidden=NO;
        
    }
    
    if(button.tag==2)
    {
        triangleImageView.hidden=YES;
        slideMenuView.hidden = YES ;
        [slideMenuView removeFromSuperview];
        self.smile_btn.hidden=NO;
        self.smileButtonSelected.hidden=YES;
    }
    
    [_take_photo_btn setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [_selectPhoto_btn setImage:[UIImage imageNamed:@"image_icon.png"] forState:UIControlStateNormal];
    [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
    [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon.png"] forState:UIControlStateNormal];
    
}

- (void) addEmoticon:(UIButton*)sender
{
    NSString *normalImageNameToPass = [NSString stringWithFormat:@"%@",[EMOJI_arr objectAtIndex:sender.tag]];
    
    emojiTag=sender.tag;
    NSLog(@"Selected Imoji Tag: %ld",(long)emojiTag);
    
    NSMutableAttributedString *imageNameToPass = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[EMOJI_arr objectAtIndex:sender.tag]]];
    NSLog(@"Emoticon Added: %@",imageNameToPass);
    
    
    if([[messageTextView.attributedText string] containsString:shareHeyTextString] && ![[messageTextView.attributedText string] containsString:phoneTextString])
    {
         NSMutableAttributedString *wholeMessageString = [[NSMutableAttributedString alloc] initWithAttributedString:messageTextView.attributedText];
        [wholeMessageString insertAttributedString:imageNameToPass atIndex:wholeMessageString.length-shareHeyTextString.length];
        messageTextView.attributedText = wholeMessageString;
        
    }
    else if (![[messageTextView.attributedText string] containsString:shareHeyTextString] && [[messageTextView.attributedText string] containsString:phoneTextString])
    {
         NSMutableAttributedString *wholeMessageString = [[NSMutableAttributedString alloc] initWithAttributedString:messageTextView.attributedText];
        [wholeMessageString insertAttributedString:imageNameToPass atIndex:wholeMessageString.length-phoneTextString.length];
        messageTextView.attributedText = wholeMessageString;
    }
    else if ([[messageTextView.attributedText string] containsString:shareHeyTextString] && [[messageTextView.attributedText string] containsString:phoneTextString])
    {
         NSMutableAttributedString *wholeMessageString = [[NSMutableAttributedString alloc] initWithAttributedString:messageTextView.attributedText];
        [wholeMessageString insertAttributedString:imageNameToPass atIndex:wholeMessageString.length-phoneTextString.length-shareHeyTextString.length-1];
        messageTextView.attributedText = wholeMessageString;
    }
    else
    {
        NSString *normalMessageString=messageTextView.text;
        [normalMessageString stringByReplacingOccurrencesOfString:@"}" withString:@""];
        [normalMessageString stringByReplacingOccurrencesOfString:@"}" withString:@""];
        messageTextView.attributedText=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", normalMessageString, normalImageNameToPass]];
    }
    messageTextView.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    

    self.smile_btn.hidden=NO;
    self.smileButtonSelected.hidden=YES;
    slideMenuView.hidden = YES ;
    [slideMenuView removeFromSuperview];
}

#pragma mark
#pragma mark Take Photo from Camera or Select from Libary
#pragma mark

- (IBAction)takePhoto:(id)sender
{
    
    slideMenuView.hidden = YES ;
    
    [_take_photo_btn setImage:[UIImage imageNamed:@"camera_icon_over.png"] forState:UIControlStateNormal];
    [_selectPhoto_btn setImage:[UIImage imageNamed:@"image_icon.png"] forState:UIControlStateNormal];
    [_smile_btn setImage:[UIImage imageNamed:@"smile_icon.png"] forState:UIControlStateNormal];
    [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
    [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon.png"] forState:UIControlStateNormal];
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Sorry! Camera Not Found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        //Open Camera
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
    
}


- (IBAction)selectPhoto:(id)sender
{

    slideMenuView.hidden = YES ;
    
    [_take_photo_btn setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [_selectPhoto_btn setImage:[UIImage imageNamed:@"image_icon_over.png"] forState:UIControlStateNormal];
    [_smile_btn setImage:[UIImage imageNamed:@"smile_icon.png"] forState:UIControlStateNormal];
    [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
    [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon.png"] forState:UIControlStateNormal];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark
#pragma mark ImagePicker Delegate Methods
#pragma mark

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    imageData=nil;
    imageData = UIImageJPEGRepresentation(chosenImage, 0.2);
    
    UIImage *image = [[UIImage alloc]initWithData:imageData];
    self.imageView.image =image;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark
#pragma mark Send SMS and Message Compose Delegate Methods
#pragma mark

- (IBAction)sendsms:(id)sender
{
    NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionExpirationDateKey];
    
    NSDate *today=[NSDate date];
    
    if ([expireDate compare:today] == NSOrderedAscending)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your subscription expired. Please subscribe to send message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        if([quickContactsArray containsObject:@""])
        {
            [quickContactsArray removeObject:@""];
        }
        
        NSArray *arrayOfContacts= (NSArray *)quickContactsArray;
        NSLog(@"Conatcts: %@",arrayOfContacts);
        
        __block NSString *finalMessage=messageTextView.text;
        
        //add hey fever link
        if ([messageTextView.text containsString:@"Get HEY Fever!"])
        {
            finalMessage = [NSString stringWithFormat: @"%@ %@", messageTextView.text, shareHeyLink];
        }
        
        if(arrayOfContacts.count>0)
        {
            if (imageData.length>0)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
                
                //Change the host name here to change the server you want to monitor.
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
                    [self.navigationController.view addSubview:HUD];
                    //[self.view addSubview:HUD];
                    
                    HUD.delegate = self;
                    HUD.labelText = @"Uploading";
                    [HUD show:YES];
                    
                    //NSString *strUDID=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
                    //NSString *advertisingUDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                    
                    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
                    userProfile=[DBManager fetchUserProfile];
                    ModelUserProfile *modObj=[userProfile objectAtIndex:0];
                    
                    [[HeyWebService service] callGenerateImageURL:imageData UDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg) {
                        
                        [HUD hide:YES];
                        [HUD removeFromSuperview];
                        if (isError)
                        {
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            
                        }
                        else
                        {
                            if ([result isKindOfClass:[NSString class]])
                            {
                                imageURL=(NSString*)result;
                                if(imageURL.length>0)
                                {
                                    //add Image link
                                    NSLog(@"Image URL: %@",imageURL);
                                    finalMessage = [NSString stringWithFormat: @"%@ \n\n%@", finalMessage, imageURL];
                                    [self prepareMessageWithContact:arrayOfContacts Message:finalMessage];
                                }
                            }
                        }
                    }];
                }
            }
            else
                [self prepareMessageWithContact:arrayOfContacts Message:finalMessage];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please select a contact to send a message." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }
        NSLog(@"finalMessage: %@ with length: %ld",finalMessage,(long)finalMessage.length);
        
    }

}


-(void) prepareMessageWithContact:(NSArray*)allContacts Message:(NSString*)finalMessage
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if(finalMessage.length>0)
    {
        //For Test
        
        /*NSMutableArray *msgArray=[[NSMutableArray alloc] init];
        NSMutableArray *userProfile=[[NSMutableArray alloc] init];
        ModelMessageSend *msgObj=[[ModelMessageSend alloc] init];
        
        userProfile=[DBManager fetchUserProfile];
        
        NSString *toPhoneNo=@"";
        
        ModelUserProfile *obj=[userProfile objectAtIndex:0];
        toPhoneNo=obj.strPhoneNo;
        
        msgObj.strDeviceId=obj.strDeviceUDID;
        msgObj.strtemplateId=@"1";
        msgObj.strMessageText=finalMessage;
        
        if (toPhoneNo.length>0 || ![toPhoneNo isEqualToString:@"0"])
            msgObj.strFrom=toPhoneNo;
        else
            msgObj.strFrom=@"";
        
        msgObj.strTo=[allContacts componentsJoinedByString:@","];
        
        NSDate *todayDate=[[NSDate alloc] init];
        NSDateFormatter *format=[[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        
        msgObj.strSendDate=[format stringFromDate:todayDate];
        
        [msgArray addObject:msgObj];
        
        long long msgInsertId=[DBManager insertMessageDetails:msgArray];
        
        if (msgInsertId!=0)
            NSLog(@"MessageDetails inserted.");
        else
            NSLog(@"MessageDetails not inserted.");*/
        
        //For Test
        if([MFMessageComposeViewController canSendText])
        {
            afterMsgSendString=finalMessage;
            afterMsgSendContactArr=[[NSArray alloc] initWithArray:allContacts];
            
            controller.body = finalMessage;
            NSLog(@"Sending Message :%@",controller.body);
            controller.recipients = allContacts;
            //controller.recipients=[NSArray arrayWithObjects:@"98736542635", @"9875463982", nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
  
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
    {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
            messageTextView.text=@"";
            imageData=nil;
            imageURL=@"";
			break;
		case MessageComposeResultSent:
        {
            NSLog(@"Message Sent");
            NSMutableArray *msgArray=[[NSMutableArray alloc] init];
            NSMutableArray *userProfile=[[NSMutableArray alloc] init];
            ModelMessageSend *msgObj=[[ModelMessageSend alloc] init];
            
            userProfile=[DBManager fetchUserProfile];
            
            NSString *toPhoneNo=@"";
    
            ModelUserProfile *obj=[userProfile objectAtIndex:0];
            toPhoneNo=obj.strPhoneNo;
            
            msgObj.strDeviceId=obj.strDeviceUDID;
            msgObj.strtemplateId=@"1";
            msgObj.strMessageText=afterMsgSendString;
            
            if (toPhoneNo.length>0 || ![toPhoneNo isEqualToString:@"0"])
                msgObj.strFrom=toPhoneNo;
            else
                msgObj.strFrom=@"";
            
            msgObj.strTo=[afterMsgSendContactArr componentsJoinedByString:@","];
            
            NSDate *todayDate=[[NSDate alloc] init];
            NSDateFormatter *format=[[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            
            msgObj.strSendDate=[format stringFromDate:todayDate];
            
            [msgArray addObject:msgObj];
            
            long long msgInsertId=[DBManager insertMessageDetails:msgArray];
            
            if (msgInsertId!=0)
                NSLog(@"MessageDetails inserted.");
            else
                NSLog(@"MessageDetails not inserted.");
            
            afterMsgSendString=@"";
            afterMsgSendContactArr=[NSArray array];
            messageTextView.text=@"";
            imageData=nil;
            imageURL=@"";
			break;
        }
		default:
			break;
	}
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)whatsApp:(id)sender
{
    __block NSString *finalMessage=messageTextView.text;
    
    //add hey fever link
    if ([messageTextView.text containsString:@"Get HEY Fever!"])
    {
        finalMessage = [NSString stringWithFormat: @"%@ - %@", messageTextView.text, @"http://www.n2nservices.com/hey/"];
    }
    
    if (imageData.length>0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //Change the host name here to change the server you want to monitor.
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
            [self.navigationController.view addSubview:HUD];
            //[self.view addSubview:HUD];
            
            HUD.delegate = self;
            HUD.labelText = @"Uploading";
            [HUD show:YES];

            //NSString *strUDID=[[[UIDevice currentDevice] identifierForVendor] UUIDString];
            
            NSMutableArray *userProfile=[[NSMutableArray alloc] init];
            userProfile=[DBManager fetchUserProfile];
            ModelUserProfile *modObj=[userProfile objectAtIndex:0];
            
            //NSString *advertisingUDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
            
            [[HeyWebService service] callGenerateImageURL:imageData UDID:[modObj.strDeviceUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg) {
                
                [HUD hide:YES];
                [HUD removeFromSuperview];
                if (isError)
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
                else
                {
                    if ([result isKindOfClass:[NSString class]])
                    {
                        imageURL=(NSString*)result;
                        if(imageURL.length>0)
                        {
                            //add Image link
                            NSLog(@"Image URL: %@",imageURL);
                            finalMessage = [NSString stringWithFormat: @"%@ \n\n%@", finalMessage, imageURL];
                            [self WhatsAppComposeMsg:finalMessage];
                        }
                    }
                }
            }];
        }
        else
            [self WhatsAppComposeMsg:finalMessage];
    }
    else
        [self WhatsAppComposeMsg:finalMessage];

}

-(void)WhatsAppComposeMsg:(NSString*)composeMsg
{
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",composeMsg];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
    {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your device has no WhatsApp installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark
#pragma mark Other IBAction Methods
#pragma mark

- (IBAction)settingsButtonTapped:(id)sender
{
    SettingsViewController *sVc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:sVc animated:YES];
    
}

- (IBAction)editGroupButtonTapped:(id)sender{
    GroupViewController *gVc = [[GroupViewController alloc] initWithNibName:@"GroupViewController" bundle:nil];
    [self.navigationController pushViewController:gVc animated:YES];
    
    
}

- (IBAction)gotoFevoriteViewController:(id)sender{
    
    [self goFavViewController];
}

-(void)goFavViewController
{
    FevoriteViewController *obj = [[FevoriteViewController alloc]initWithNibName:@"FevoriteViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}

- (IBAction)back:(id)sender
{
    [quickContactsArray removeAllObjects];
    [contactFavoriteOnlyArr removeAllObjects];
    [contactGroupOnlyArr removeAllObjects];
    [onlyGroupIdArr removeAllObjects];
    for (UIView *cView in self.contactsScroller.subviews)
    {
        [cView removeFromSuperview];
    }
    contactsContainerX = 6.0f;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhone:(id)sender
{

    slideMenuView.hidden = YES;
    
    [_take_photo_btn setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [_selectPhoto_btn setImage:[UIImage imageNamed:@"image_icon.png"] forState:UIControlStateNormal];
    [_smile_btn setImage:[UIImage imageNamed:@"smile_icon.png"] forState:UIControlStateNormal];
    //[_share_btn setImage:[UIImage imageNamed:@"hey_share_icon.png"] forState:UIControlStateNormal];
    [self addRemovePhone];
    
}

-(void) addRemovePhone
{
    NSMutableAttributedString *attributeHEYString = [[NSMutableAttributedString alloc] initWithString:shareHeyTextString];
    [attributeHEYString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0,[attributeHEYString length])];
    [attributeHEYString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[attributeHEYString length])];
    
    
    if(phoneTextString.length>0)
    {
        NSMutableAttributedString *newString =[[NSMutableAttributedString alloc] initWithAttributedString:messageTextView.attributedText];
        
        if(![messageTextView.text containsString:insertPhoneString])
        {
            if([[newString string] containsString:[attributeHEYString string]])
            {
                [[newString mutableString] replaceOccurrencesOfString:[NSString stringWithFormat:@"%@", [attributeHEYString string]] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newString.string.length)];
                
                
                [newString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", insertPhoneString]]];
                
                [newString appendAttributedString: attributeHEYString];
                
            }
            
            else
            {
                [newString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", insertPhoneString]]];
            }
            
            [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon_over.png"] forState:UIControlStateNormal];
            
            addPhoneClicked=1;
        }
        else
        {
            
            [[newString mutableString] replaceOccurrencesOfString:[NSString stringWithFormat:@" %@",insertPhoneString] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, newString.string.length)];
            
            [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
            
            addPhoneClicked=0;
        }
        messageTextView.attributedText = newString;
        messageTextView.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please add phone number to your profile under Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
    }
    
}

- (IBAction)shareHey:(id)sender
{
    slideMenuView.hidden = YES;
    
    [_take_photo_btn setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
    [_selectPhoto_btn setImage:[UIImage imageNamed:@"image_icon.png"] forState:UIControlStateNormal];
    [_smile_btn setImage:[UIImage imageNamed:@"smile_icon.png"] forState:UIControlStateNormal];
    [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
    
    [self addRemoveHeyFeverText];
}

-(void) addRemoveHeyFeverText
{
    NSMutableAttributedString *attributeHEYString = [[NSMutableAttributedString alloc] initWithString:shareHeyTextString];
    [attributeHEYString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0,[attributeHEYString length])];
    [attributeHEYString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[attributeHEYString length])];
    
    NSMutableAttributedString *textViewAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:messageTextView.attributedText];
    
    
    if ([[textViewAttrString string] containsString:[attributeHEYString string]])
    {

        if(phoneTextString.length>0 && [[textViewAttrString string] containsString:phoneTextString])
        {
            //if "get hey fever" and phoneTextString exists
            [[textViewAttrString mutableString] replaceOccurrencesOfString:[NSString stringWithFormat:@" %@", phoneTextString] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textViewAttrString.string.length)];
            
            [[textViewAttrString mutableString] replaceOccurrencesOfString:[NSString stringWithFormat:@"%@", [attributeHEYString string]] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textViewAttrString.string.length)];
            
            messageTextView.attributedText=textViewAttrString;
            //location=location-[attributeHEYString length]-[phoneTextString length]-1;
            [self.addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon.png"] forState:UIControlStateNormal];
            
            
            [textViewAttrString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", insertPhoneString]]];
            messageTextView.attributedText=textViewAttrString;
            
            
            [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon_over.png"] forState:UIControlStateNormal];
        }
        else
        {
            //if only get hey fever text exists
            [[textViewAttrString mutableString] replaceOccurrencesOfString:[attributeHEYString string] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textViewAttrString.string.length)];
            
            messageTextView.attributedText=textViewAttrString;
            //location=location-[attributeHEYString length];
            NSLog(@"AFTER REMOVING HEY TEXT: %@",messageTextView.text);
        }
        
        messageHolderString=messageTextView.text;
        [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon.png"] forState:UIControlStateNormal];
    }
    
    else
    {
        NSLog(@"HEY String Does Not Exists & Current Location: %lu",location);
        
        if(phoneTextString.length>0 && [[textViewAttrString string] containsString:phoneTextString])
        {
             [[textViewAttrString mutableString] replaceOccurrencesOfString:[NSString stringWithFormat:@" %@",insertPhoneString] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, textViewAttrString.string.length)];
            
            [textViewAttrString appendAttributedString: [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", insertPhoneString]]];
            
            [textViewAttrString appendAttributedString: attributeHEYString];
            
            messageTextView.attributedText = textViewAttrString;
            
            //location=location-[attributeHEYString length]-[phoneTextString length]-1;
            
            [_addPhone_btn setImage:[UIImage imageNamed:@"mobile_icon_over.png"] forState:UIControlStateNormal];
        }
        else
        {
            NSLog(@"LOC===================:%lu", (unsigned long) location);
            [textViewAttrString appendAttributedString: attributeHEYString];
            //[textViewAttrString insertAttributedString: attributeHEYString atIndex:location];
            messageTextView.attributedText = textViewAttrString;
        }
        [_share_btn setImage:[UIImage imageNamed:@"hey_share_icon_over.png"] forState:UIControlStateNormal];
        
        messageHolderString=messageTextView.text;
    }
    messageTextView.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
}


#pragma mark
#pragma mark TextView Delegate Methods
#pragma mark

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView==messageTextView) {
        if ([text isEqualToString:@"\n"])
        {
            [textView resignFirstResponder];
            return false;
        }
    }
    location=textView.text.length;
    return true;
    
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    editScrollViewContentHeight = textView.frame.size.height;
    [self.editingScrollView scrollRectToVisible:textView.frame animated:YES];
    self.imageView.frame = CGRectMake(imageView.frame.origin.x,textView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height);
    
    self.editingScrollView.contentSize =CGSizeMake(self.editingScrollView.frame.size.width,editScrollViewContentHeight);
    textView.editable = YES;
    location=textView.text.length;
    NSLog(@"Location: %ld",location);

    if ([textView.text containsString:shareHeyTextString] && ![textView.text containsString:phoneTextString])
    {
        textView.selectedRange = NSMakeRange([textView.text rangeOfString:shareHeyTextString].location, 0);
        
        NSLog(@"Cursor Position: %ld",(long)[textView.text rangeOfString:shareHeyTextString].location);
    }
    
    else if ([textView.text containsString:phoneTextString] && ![textView.text containsString:shareHeyTextString])
    {
        textView.selectedRange = NSMakeRange([textView.text rangeOfString:insertPhoneString].location-1, 0);
    }
    
    else if ([textView.text containsString:phoneTextString] && [textView.text containsString:shareHeyTextString])
    {
        textView.selectedRange = NSMakeRange([textView.text rangeOfString:[NSString stringWithFormat:@"%@%@",phoneTextString,shareHeyTextString]].location-1, 0);
    }

    
    messageHolderString=textView.text;
    NSLog(@"textViewDidChangeSelection-> Updated Message: %@", messageHolderString=textView.text);
}


-(void) textViewDidEndEditing:(UITextView *)textView
{
    messageHolderString=textView.text;
    NSLog(@"textViewDidEndEditing-> Last Updated Message: %@", messageHolderString);
}

#pragma mark
#pragma mark AlertView Delegate Methods
#pragma mark

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==2)
    {
        //Flash favorite alert.
        
        if (buttonIndex==0)
        {
            [self goFavViewController];
        }
        
    }
    else
    {
        //Contact selection from alertView.
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"] || ![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"])
        {
            NSLog(@"Selected Contact: %@", [alertView buttonTitleAtIndex:buttonIndex]);
            [contactInfoDict setObject:[alertView buttonTitleAtIndex:buttonIndex] forKey:@"mobileNumber"];
            [self insertIntoToField];
        }
    }
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
        //NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable)
        {
            isReachable=NO;
        }
        else
        {
            isReachable=YES;
        }
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is unavailable.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
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



-(void)CheckSubscription
{
    NSMutableArray *userProfile=[[NSMutableArray alloc] init];
    userProfile=[DBManager fetchUserProfile];
    ModelUserProfile *modObj=[userProfile objectAtIndex:0];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
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
    
    [[HeyWebService service] fetchSubscriptionDateWithUDID:modObj.strDeviceUDID WithCompletionHandler:^(id result, BOOL isError, NSString *strMsg)
     {
         if (isError)
         {
             NSLog(@"Subscription Fetch Failed: %@",strMsg);
         }
         else
         {
             NSDictionary *resultDict=(id)result;
             
             if ([[resultDict valueForKey:@"status"] boolValue]==true)
             {
                 
                 NSString *serverDateString=[NSString stringWithFormat:@"%@", [[resultDict valueForKey:@"error"] valueForKey:@"date"]];
                 
                 if (serverDateString && serverDateString.length>0)
                 {
                     NSDateFormatter *format=[[NSDateFormatter alloc] init];
                     [format setDateFormat:@"MM.dd.yyyy"];
                     NSDate * serverDate =[format dateFromString:serverDateString];
                     NSLog(@"Server Date: %@",serverDate);
                     
                     if (serverDate)
                     {
                         [[NSUserDefaults standardUserDefaults] setObject:serverDate forKey:kSubscriptionExpirationDateKey];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         
                         
                         NSDate *expireDate = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionExpirationDateKey];
                         
                         NSDate *today=[NSDate date];
                         
                         if ([expireDate compare:today] == NSOrderedAscending)
                         {
                             self.sendMsgBtn.enabled=NO;
                             //self.sendMsgBtn.backgroundColor=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.2];
                         }
                         else
                         {
                             self.sendMsgBtn.enabled=YES;
                             //self.sendMsgBtn.backgroundColor=[UIColor clearColor];
                         }
                     }
                 }
                 
            }
         }
     }];
    }
}

//Called by Reachability whenever status changes.

@end
