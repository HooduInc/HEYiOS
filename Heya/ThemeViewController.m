//
//  ThemeViewController.m
//  Heya
//
//  Created by jayantada on 02/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ThemeViewController.h"
#import "DBManager.h"
#import "ModelMenu.h"
#import "ModelSubMenu.h"
#import "AppDelegate.h"
#import "NSString+Emoticonizer.h"

@interface ThemeViewController ()
{
    NSMutableArray *arrAllPageValue,*arrDisplayTableOne,*arrDisplayTableTwo,*arrDisplayTableThree,*arrDisplayTableFour, *arrDisplayUponImageview;
}

@end

@implementation ThemeViewController
NSUserDefaults *preferances;
@synthesize carousel, label,selectTheme,selectThemeOnly4s, wrap, theme, themeName;
@synthesize generatedimage,generatedView, brightArray,standardArray, oneColorArray, outLineArray, mutedArray;

int globalIndex;

#pragma mark
#pragma mark UIViewController Initialization
#pragma mark


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //set up carousel data
        wrap = NO;
        theme = [[NSMutableArray alloc] init];
        themeName = [NSMutableArray arrayWithObjects:@"Bright", @"Standard", @"One Color",@"Outline",@"Muted", nil];
        
        brightArray=[NSArray arrayWithObjects:@"temp_blue.png", @"temp_pink.png",@"temp_red.png", @"temp_orange.png" ,@"temp_yellow.png",@"temp_green.png", @"temp_sky.png" , @"temp_white.png", @"temp_white.png", nil];
        
        standardArray= [NSArray arrayWithObjects:@"menu_btn1.png", @"menu_btn2.png",@"menu_btn4.png", @"menu_btn5.png" ,@"menu_btn6.png",@"menu_btn7.png", @"menu_btn8.png" , @"menu_btn9.png", @"menu_btn9.png", nil];
        
        oneColorArray=[NSArray arrayWithObjects:@"red1.png", @"red1.png",@"red1.png", @"red1.png" ,@"red1.png",@"red1.png", @"red1.png" , @"red1.png", @"red1.png", nil];
        
        outLineArray=[NSArray arrayWithObjects:@"bar_1.png", @"bar_2.png",@"bar_3.png", @"bar_4.png" ,@"bar_5.png",@"bar_6.png", @"bar_7.png" , @"bar_8.png", @"bar_8.png", nil];
        
        mutedArray=[NSArray arrayWithObjects:@"red1.png", @"menu_btn8.png",@"temp_orange.png", @"menu_btn5.png" ,@"muted_5.png",@"menu_btn9.png", @"muted_7.png" , @"muted_violet.png", @"muted_violet.png", nil];
        
        [theme addObject:brightArray];
        [theme addObject:standardArray];
        [theme addObject:oneColorArray];
        [theme addObject:outLineArray];
        [theme addObject:mutedArray];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    preferances=[NSUserDefaults standardUserDefaults];
    
    carousel.delegate = self;
    carousel.dataSource = self;
    carousel.pageControl = self.pageControl;
    carousel.minimumPageAlpha = 1.0f;
    carousel.minimumPageScale = 0.9;
    
    if(isIphone4)
    {
        selectTheme.hidden=YES;
        selectThemeOnly4s.hidden=NO;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    NSMutableArray *totalMenuArray=[[NSMutableArray alloc] init];
    arrDisplayUponImageview=[[NSMutableArray alloc] init];
    for (int i=1; i<=4; i++)
    {
        [totalMenuArray addObject:[DBManager fetchMenuForPageNo:i]];
    }
    globalIndex=0;
    arrDisplayUponImageview=[totalMenuArray objectAtIndex:0];
    [label setText:[NSString stringWithFormat:@"%@", [themeName objectAtIndex:globalIndex]]];
}

- (void)viewDidUnload
{
    [self setLabel:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    return CGSizeMake(180, 320);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"Scrolled to page # %ld", (long)index);
    
    //NSLog(@"Index = %lu",(long)carousel.currentPageIndex);
    //globalIndex=(int)carousel.currentPageIndex;
    globalIndex=(int)index;
    
    [self.pageControl setCurrentPage:globalIndex];
    [label setText:[NSString stringWithFormat:@"%@", [themeName objectAtIndex:globalIndex]]];
    
}
         
         

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    NSLog(@"Tapped on page # %ld", (long)index);
}

#pragma mark -
#pragma mark PagedFlowView Datasource
//View
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
    return 5;
}

//View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    UIView *bigView = (UIView *)[flowView dequeueReusableCell];
    if (!bigView)
        bigView = [[UIImageView alloc] init];
    
    switch (index)
    {
        case 0:
            bigView=[self createViewWithColorArray:brightArray];
            break;
        case 1:
            bigView=[self createViewWithColorArray:standardArray];
            break;
        case 2:
            bigView=[self createViewWithColorArray:oneColorArray];
            break;
        case 3:
            bigView=[self createViewWithColorArray:outLineArray];
            break;
        case 4:
            bigView=[self createViewWithColorArray:mutedArray];
            break;
            
            
        default:
            break;
    }
    
    
    return bigView;
    
}

- (IBAction)pageControlValueDidChange:(id)sender
{
    UIPageControl *pageControl = sender;
    [carousel scrollToPage:pageControl.currentPage];
    NSLog(@"pageControl.currentPage: %ld",(long)pageControl.currentPage);
    
    globalIndex=(int)pageControl.currentPage;
    [label setText:[NSString stringWithFormat:@"%@", [themeName objectAtIndex:globalIndex]]];
}

#pragma mark
#pragma mark iCarousel methods
#pragma mark

/*- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 5;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSMutableArray *totalMenuArray=[[NSMutableArray alloc] init];
    arrDisplayUponImageview=[[NSMutableArray alloc] init];
    for (int i=1; i<=4; i++) {
        [totalMenuArray addObject:[DBManager fetchMenuForPageNo:i]];
    }
    
    arrDisplayUponImageview=[totalMenuArray objectAtIndex:0];
    
    if (index==0)
    {
        [preferances setBool:NO forKey:@"outLineThemeActive"];
        [preferances synchronize];
        return [self createViewWithColorArray:brightArray];
    }
    
    else if (index==1)
    {
        return [self createViewWithColorArray:standardArray];
    }
    
    else if (index==2)
    {
        return [self createViewWithColorArray:oneColorArray];
    }
    
    else if (index==3)
    {
        return [self createViewWithColorArray:outLineArray];
    }
    
    else if (index==4)
    {
        return [self createViewWithColorArray:mutedArray];
    }
 
    else
        return nil;
    
}

- (NSInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}


- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return 180;
}



- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return wrap;
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 2.0f;
        }
        case iCarouselOptionFadeMax:
        {
            if (self.carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        case iCarouselOptionShowBackfaces:
        {
            return NO;
        }
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            return value;
        }
    }
}

- (CATransform3D)carousel:(__unused iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * self.carousel.itemWidth);
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)aCarousel

{
    NSLog(@"Index = %lu",(long)aCarousel.currentItemIndex);
    globalIndex=(int)aCarousel.currentItemIndex;
    
    [self.pageControl setCurrentPage:globalIndex];

    [label setText:[NSString stringWithFormat:@"%@", [themeName objectAtIndex:aCarousel.currentItemIndex]]];
}*/

#pragma mark
#pragma mark IBActions & Methods
#pragma mark

-(UIView *) createViewWithColorArray:(NSArray*)colorArr
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 320)];
    newView.backgroundColor=[UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0f];
    
    for(int i=0; i<colorArr.count-1; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 160, 32)];
        clImgView.image = [UIImage imageNamed:[colorArr objectAtIndex:i]];
        
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(15.0f, 0.0f, clImgView.frame.size.width-25, clImgView.frame.size.height)];
        ModelMenu *obj=[arrDisplayUponImageview objectAtIndex:i];
        titleLabel.text=[NSString emoticonizedString:obj.strMenuName];
        titleLabel.font=[UIFont boldSystemFontOfSize:12.0f];
        
        
        if ([[colorArr objectAtIndex:i] isEqualToString:@"temp_white.png"])
            titleLabel.textColor=[UIColor blackColor];
        else if (outLineArray==colorArr)
            titleLabel.textColor=[UIColor blackColor];
        else
            titleLabel.textColor=[UIColor whiteColor];
        
        titleLabel.textAlignment=NSTextAlignmentLeft;
        
        [clImgView addSubview:titleLabel];
        
        
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+4.0f;
    }
    return newView;
}

- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectThemeButton:(id)sender
{
    
    NSLog(@"OutLineThemeStatus: %d", [preferances boolForKey:@"outLineThemeActive"]);
    NSLog(@"Label Value: %@",self.label.text);
    NSLog(@"Index Position: %d", globalIndex);
    
    if([self.label.text isEqualToString:@"Outline"])
    {
        [preferances setBool:YES forKey:@"outLineThemeActive"];
        
    }
    else
    {
       [preferances setBool:NO forKey:@"outLineThemeActive"];
    }
    [preferances synchronize];
    
    NSMutableArray *colArray=[[NSMutableArray alloc] init];
    NSMutableArray *createMainArray=[[NSMutableArray alloc] init];
    colArray=[theme objectAtIndex:globalIndex];
    
    
    arrAllPageValue=[[NSMutableArray alloc] init];
    for (int i=1; i<=4; i++)
    {
        [arrAllPageValue addObject:[DBManager fetchMenuForPageNo:i]];
    }
    
    arrDisplayTableOne=[arrAllPageValue objectAtIndex:0];
    arrDisplayTableTwo=[arrAllPageValue objectAtIndex:1];
    arrDisplayTableThree=[arrAllPageValue objectAtIndex:2];
    arrDisplayTableFour=[arrAllPageValue objectAtIndex:3];
    
    
    for(int i=0; i<4; i++)
    {
        if (i==0)
        {
            for(int j=0; j<arrDisplayTableOne.count; j++)
            {
                [createMainArray addObject:[colArray objectAtIndex:j]];
            }
        }
        else
        {
            for(int j=0; j<8; j++)
            {
                [createMainArray addObject:[colArray objectAtIndex:j]];
            }
        }
    }
    NSLog(@"Color ArraY: %@", createMainArray);
    
    for(int m=0; m<arrDisplayTableOne.count; m++)
    {
        ModelMenu *obj=[arrDisplayTableOne objectAtIndex:m];
        [DBManager updatemenuWithMenuId:obj.strMenuId withTableColoum:@"menuColor" withColoumValue:[createMainArray objectAtIndex:m]];
        if (obj.arrSubMenu.count>0)
        {
            for (int n=0;n<obj.arrSubMenu.count; n++) {
                ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:n];
                [DBManager updateSubMenuColorWithMenuId:obj.strMenuId subMenuID:objSub.strSubMenuId withcolorName:[createMainArray objectAtIndex:m]];
            }
        }
    }
    
    for(int m=0; m<arrDisplayTableTwo.count; m++)
    {
        ModelMenu *obj=[arrDisplayTableTwo objectAtIndex:m];
        [DBManager updatemenuWithMenuId:obj.strMenuId withTableColoum:@"menuColor" withColoumValue:[createMainArray objectAtIndex:m]];
        if (obj.arrSubMenu.count>0)
        {
            for (int n=0;n<obj.arrSubMenu.count; n++) {
                ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:n];
                [DBManager updateSubMenuColorWithMenuId:obj.strMenuId subMenuID:objSub.strSubMenuId withcolorName:[createMainArray objectAtIndex:m]];
            }
        }
    }
    for(int m=0; m<arrDisplayTableThree.count; m++)
    {
        ModelMenu *obj=[arrDisplayTableThree objectAtIndex:m];
        [DBManager updatemenuWithMenuId:obj.strMenuId withTableColoum:@"menuColor" withColoumValue:[createMainArray objectAtIndex:m]];
        if (obj.arrSubMenu.count>0)
        {
            for (int n=0;n<obj.arrSubMenu.count; n++) {
                ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:n];
                [DBManager updateSubMenuColorWithMenuId:obj.strMenuId subMenuID:objSub.strSubMenuId withcolorName:[createMainArray objectAtIndex:m]];
            }
        }
    }
    for(int m=0; m<arrDisplayTableFour.count; m++)
    {
        ModelMenu *obj=[arrDisplayTableFour objectAtIndex:m];
        [DBManager updatemenuWithMenuId:obj.strMenuId withTableColoum:@"menuColor" withColoumValue:[createMainArray objectAtIndex:m]];
        if (obj.arrSubMenu.count>0)
        {
            for (int n=0;n<obj.arrSubMenu.count; n++) {
                ModelSubMenu *objSub=[obj.arrSubMenu objectAtIndex:n];
                [DBManager updateSubMenuColorWithMenuId:obj.strMenuId subMenuID:objSub.strSubMenuId withcolorName:[createMainArray objectAtIndex:m]];
            }
        }
    }
    
    
    //appDel.imageArray=[theme objectAtIndex:globalIndex];
    //[preferances setObject:[theme objectAtIndex:globalIndex] forKey:@"imageArrayList"];
    [preferances setObject:self.label.text forKey:@"themeName"];
    [preferances synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Theme applied successfully."
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
@end
