//
//  1stViewController.m
//  Heya
//
//  Created by jayantada on 06/05/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "SplashViewController.h"
#import "MessagesListViewController.h"
#import "HorizontalScroller.h"

@interface SplashViewController ()<HorizontalScrollerDelegate>
{
    HorizontalScroller *myScroller;
    
    IBOutlet NSLayoutConstraint *consPosTopFirst;
    IBOutlet NSLayoutConstraint *conSecondPageViewAlignY;
    IBOutlet NSLayoutConstraint *conFifthPageViewAlignY;
    IBOutlet NSLayoutConstraint *conSixthPageViewAlignY;
    IBOutlet NSLayoutConstraint *conEightPageViewAlignY;
    IBOutlet NSLayoutConstraint *conNinthPageViewAlignY;
    
    IBOutlet UIButton *navLeftBtn;
    IBOutlet UIButton *navRightBtn;
    
    IBOutlet UIView *vwContainer;
    IBOutlet UIView *vw1;
    IBOutlet UIView *vw2;
    IBOutlet UIView *vw3;
    IBOutlet UIView *vw4;
    IBOutlet UIView *vw5;
    IBOutlet UIView *vw6;
    IBOutlet UIView *vw7;
    IBOutlet UIView *vw8;
    IBOutlet UIView *vw9;
    
    IBOutlet UILabel *superEasyWriting;
    IBOutlet UILabel *simplerFasterLabel;
    IBOutlet UIWebView *eulawebView;
    IBOutlet UIButton *eightCloseBtn;
    IBOutlet UIButton *acceptBtn;
    
    int pageCounter;
    
}

@end

@implementation SplashViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    superEasyWriting.text=@"Super Easy\nEditing";
    superEasyWriting.numberOfLines=2;
    simplerFasterLabel.text=@"Simpler\n\nFaster\n\nError-free\n\nand Funner!";
    
    NSString *htmlFile=[[NSBundle mainBundle] pathForResource:@"terms_services_preview" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [eulawebView loadHTMLString:htmlString baseURL:nil];
    
    if (isIphone4)
    {
        consPosTopFirst.constant=-60.0f;
        conSecondPageViewAlignY.constant=40.0f;
        conFifthPageViewAlignY.constant=-30.0f;
        conSixthPageViewAlignY.constant=40.0f;
        conEightPageViewAlignY.constant=-10.0f;
        conNinthPageViewAlignY.constant=-10.0f;
    }
    else
    {
        consPosTopFirst.constant=-20.0f;
    }
    
    //NSLog(@"%@",NSStringFromCGRect(vwContainer.frame));
    
    myScroller=[[HorizontalScroller alloc] initWithFrame:CGRectMake(0, 0, vwContainer.frame.size.width, vwContainer.frame.size.height)];
    [myScroller setDelegate:self];
    [vwContainer addSubview:myScroller];
}


- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    pageCounter=0;
    
    if (self.comeFromOtherSettings==NO)
    {
        navLeftBtn.hidden=YES;
        NSLog(@"");
        
        //[self registerDevice];
    }
    else
        navLeftBtn.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller *)scroller
{
    return 8;
}

-(UIView*)horizontalScroller:(HorizontalScroller *)scroller viewAtIndex:(int)index
{
    UIView *myView=nil;
    switch (index) {
        case 0:
            myView=vw1;
            break;
        case 1:
            myView=vw2;
            break;
        case 2:
            myView=vw3;
            break;
        case 3:
            myView=vw4;
            break;
        case 4:
            myView=vw5;
            break;
        case 5:
            myView=vw6;
            break;
        case 6:
            myView=vw7;
            break;
            
        case 7:
            myView=vw9;
            break;
        /*case 7:
            myView=vw8;
            break;
            
        case 8:
            myView=vw9;
            break;*/
        default:
            break;
    }
    return myView;
}

-(IBAction)leftNavigationTapped:(id)sender
{
    [self hideLeftNavigationBtn];
    
    [myScroller moveToIndex:--pageCounter];
    
    [self hideLeftNavigationBtn];
}

-(IBAction)rightNavigationTapped:(id)sender
{
    [self hideLeftNavigationBtn];
    
    [myScroller moveToIndex:++pageCounter];
    
    [self hideLeftNavigationBtn];
}

-(IBAction)closeBtnTapped:(id)sender
{
    if (self.comeFromOtherSettings==NO)
    {
        MessagesListViewController *msgController=[[MessagesListViewController alloc] initWithNibName:@"MessagesListViewController" bundle:nil];
        [self.navigationController pushViewController:msgController animated:YES];
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(IBAction)acceptBtnTapped:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"acceptedEULA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    navRightBtn.hidden=NO;
    [myScroller moveToIndex:++pageCounter];
}

-(IBAction)finalBtnTapped:(id)sender
{
    [self afterMaximumPressed];
}

-(void)beforeZeroPressed
{
    NSLog(@"%s",__FUNCTION__);
    pageCounter=0;
    
    if (self.comeFromOtherSettings==YES)
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)afterMaximumPressed
{
    //NSLog(@"%s",__FUNCTION__);
    
    if (self.comeFromOtherSettings==NO)
    {
        MessagesListViewController *msgController=[[MessagesListViewController alloc] initWithNibName:@"MessagesListViewController" bundle:nil];
        [self.navigationController pushViewController:msgController animated:YES];
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)hideLeftNavigationBtn
{
    if (pageCounter==0 && self.comeFromOtherSettings==NO)
        navLeftBtn.hidden=YES;
    else
        navLeftBtn.hidden=NO;
}


-(BOOL)setPaggingEnableForHorizontalScroller:(HorizontalScroller*)scroller
{
    return YES;
}
-(CGFloat)setPaddingForHorizontalScroller:(HorizontalScroller*)scroller
{
    return 0.0f;
}

@end
