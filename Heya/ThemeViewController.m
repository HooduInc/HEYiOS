//
//  ThemeViewController.m
//  Heya
//
//  Created by jayantada on 02/01/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ThemeViewController.h"
#import "DBManager.h"
#import "AppDelegate.h"

@interface ThemeViewController ()


@end

@implementation ThemeViewController
NSUserDefaults *preferances;
@synthesize carousel, label, wrap, theme, themeName, selectThemeButton;
@synthesize generatedimage,generatedView, brightArray,standardArray, oneColorArray, outLineArray, mutedArray,msglist_arr,subMenuMsgArray;

int globalIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    carousel.type = iCarouselTypeCoverFlow2;
    carousel.scrollSpeed=0.1f;
    
    msglist_arr=[[NSMutableArray alloc] init];
    subMenuMsgArray = [[NSMutableArray alloc] init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //set up carousel data
        wrap = NO;
        theme = [[NSMutableArray alloc] init];
        themeName = [NSMutableArray arrayWithObjects:@"Bright", @"Standard", @"One Color",@"Outline",@"Muted", nil];
        
        brightArray=[NSArray arrayWithObjects:@"temp_blue.png", @"temp_pink.png",@"temp_red.png", @"temp_orange.png" ,@"temp_yellow.png",@"temp_green.png", @"temp_sky.png" , @"temp_white.png", nil];
        
        standardArray= [NSArray arrayWithObjects:@"menu_btn1.png", @"menu_btn2.png",@"menu_btn4.png", @"menu_btn5.png" ,@"menu_btn6.png",@"menu_btn7.png", @"menu_btn8.png" , @"menu_btn9.png", nil];
        
        oneColorArray=[NSArray arrayWithObjects:@"red1.png", @"red2.png",@"red3.png", @"red4.png" ,@"red5.png",@"red6.png", @"red7.png" , @"red7.png", nil];
        
        outLineArray=[NSArray arrayWithObjects:@"bar_1.png", @"bar_2.png",@"bar_3.png", @"bar_4.png" ,@"bar_5.png",@"bar_6.png", @"bar_7.png" , @"bar_8.png", nil];
        
        mutedArray=[NSArray arrayWithObjects:@"red1.png", @"menu_btn8.png",@"temp_orange.png", @"menu_btn5.png" ,@"muted_5.png",@"menu_btn9.png", @"muted_7.png" , @"temp_pink.png", nil];
        
        [theme addObject:brightArray];
        [theme addObject:standardArray];
        [theme addObject:oneColorArray];
        [theme addObject:outLineArray];
        [theme addObject:mutedArray];
    }
    return self;
}
- (void)viewDidUnload
{
    [self setLabel:nil];
    [super viewDidUnload];
    preferances=[NSUserDefaults standardUserDefaults];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 5;
}

- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    if (index==0)
    {
        [preferances setBool:NO forKey:@"outLineThemeActive"];
        return [self createThemeViewWithImagesBright];
    }
    
    else if (index==1)
    {
        return [self createThemeViewWithImagesStandard];
    }
    
    else if (index==2)
    {
        return [self createThemeViewWithImagesOneColor];
    }
    
    else if (index==3)
    {
        return [self createThemeViewWithImagesOutLine];
    }
    
    else if (index==4)
    {
        return [self createThemeViewWithImagesMuted];
    }
 
    else
        return nil;
    
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}


- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return 240;
}


- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return wrap;
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)aCarousel

{
    NSLog(@"Index = %lu",(long)aCarousel.currentItemIndex);
    globalIndex=(int)aCarousel.currentItemIndex;
    
    [self.pageControl setCurrentPage:globalIndex];

    [label setText:[NSString stringWithFormat:@"%@", [themeName objectAtIndex:aCarousel.currentItemIndex]]];
}

-(UIView *) createThemeViewWithImagesBright
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 327)];
    newView.backgroundColor=[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    newView.layer.borderWidth=1.0f;
    newView.layer.borderColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    newView.layer.shadowColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    
    for(int i=0; i<brightArray.count; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 183, 27)];
        clImgView.image = [UIImage imageNamed:[brightArray objectAtIndex:i]];
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+12.0f;
    }
    [preferances setBool:NO forKey:@"outLineThemeActive"];
    return newView;
}


-(UIView *) createThemeViewWithImagesStandard
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 327)];
    newView.backgroundColor=[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    newView.layer.borderWidth=1.0f;
    newView.layer.borderColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    newView.layer.shadowColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    
    for(int i=0; i<brightArray.count; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 183, 27)];
        clImgView.image = [UIImage imageNamed:[standardArray objectAtIndex:i]];
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+12.0f;
    }
    
    return newView;
}


-(UIView *) createThemeViewWithImagesOneColor
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 327)];
    newView.backgroundColor=[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    newView.layer.borderWidth=1.0f;
    newView.layer.borderColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    newView.layer.shadowColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    
    for(int i=0; i<brightArray.count; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 183, 27)];
        clImgView.image = [UIImage imageNamed:[oneColorArray objectAtIndex:i]];
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+12.0f;
    }
    return newView;
}

-(UIView *) createThemeViewWithImagesOutLine
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 327)];
    newView.backgroundColor=[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    newView.layer.borderWidth=1.0f;
    newView.layer.borderColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    newView.layer.shadowColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    
    for(int i=0; i<brightArray.count; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 183, 27)];
        clImgView.image = [UIImage imageNamed:[outLineArray objectAtIndex:i]];
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+12.0f;
    }
    
    return newView;
}

-(UIView *) createThemeViewWithImagesMuted
{
    float imageY=15.0f;
    UIView *newView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 204, 327)];
    newView.backgroundColor=[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0f];
    newView.layer.borderWidth=1.0f;
    newView.layer.borderColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    newView.layer.shadowColor=([UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f]).CGColor;
    
    for(int i=0; i<brightArray.count; i++)
    {
        UIImageView *clImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.5f, imageY, 183, 27)];
        clImgView.image = [UIImage imageNamed:[mutedArray objectAtIndex:i]];
        [newView addSubview:clImgView];
        imageY=imageY+clImgView.frame.size.height+12.0f;
    }
    return newView;
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
    
    NSMutableArray *colArray=[[NSMutableArray alloc] init];
    NSMutableArray *createMainArray=[[NSMutableArray alloc] init];
    colArray=[theme objectAtIndex:globalIndex];
    
    msglist_arr = [DBManager fetchmenu:0 noOfRows:32];
    for(int i=0; i<4; i++)
    {
        for(int j=0; j<8; j++)
        {
            [createMainArray addObject:[colArray objectAtIndex:j]];
        }
    }
    NSLog(@"Color ArraY: %@", createMainArray);
    
    for(int i=0; i< [msglist_arr count]; i++)
    {
        NSMutableDictionary *menuMsgListDic = [[NSMutableDictionary alloc] init];
        menuMsgListDic = [msglist_arr objectAtIndex:i];
        NSString * MenuId=[menuMsgListDic valueForKey:@"MenuId"];
        [DBManager updatemenuWithMenuId:MenuId withTableColoum:@"menuColor" withColoumValue:[createMainArray objectAtIndex:i]];
    }
    
    
    //appDel.imageArray=[theme objectAtIndex:globalIndex];
    //[preferances setObject:[theme objectAtIndex:globalIndex] forKey:@"imageArrayList"];
    [preferances setObject:self.label.text forKey:@"themeName"];
    [preferances synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Theme has been saved successfully."
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
@end
