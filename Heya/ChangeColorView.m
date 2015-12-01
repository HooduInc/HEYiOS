//
//  ChangeColorView.m
//  Heya
//
//  Created by jayantada on 16/12/14.
//  Copyright (c) 2014 Jayanta Karmakar. All rights reserved.
//

#import "ChangeColorView.h"
#import "EditViewController.h"
#import "AppDelegate.h"
#import "SettingsViewController.h"


@interface ChangeColorView ()<UIAlertViewDelegate>
@property (nonatomic,assign) NSInteger *seletedRow;
@end

@implementation ChangeColorView
@synthesize changeIndex, seletedRow, submenuIndex, flag;
@synthesize imageList,theme,themeName,brightArray,standardArray, oneColorArray, outLineArray, mutedArray;

NSUserDefaults *preferances;
long int seletRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    preferances=[NSUserDefaults standardUserDefaults];
    appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    //imageList=[NSArray arrayWithObjects:@"menu_btn1.png", @"menu_btn2.png",@"menu_btn4.png", @"menu_btn5.png" ,@"menu_btn6.png" ,@"menu_btn7.png" ,@"menu_btn8.png", @"menu_btn9.png" , nil];
    
    imageList = [[NSMutableArray alloc] init];
    theme = [[NSMutableArray alloc] init];
    themeName = [NSMutableArray arrayWithObjects:@"Bright", @"Standard", @"One Color",@"Outline",@"Muted", nil];
    
    brightArray=[NSArray arrayWithObjects:@"temp_blue.png", @"temp_pink.png",@"temp_red.png", @"temp_orange.png" ,@"temp_yellow.png",@"temp_green.png", @"temp_sky.png" , @"temp_white.png", @"temp_white.png", nil];
    
    standardArray= [NSArray arrayWithObjects:@"menu_btn1.png", @"menu_btn2.png",@"menu_btn4.png", @"menu_btn5.png" ,@"menu_btn6.png",@"menu_btn7.png", @"menu_btn8.png" , @"menu_btn9.png", @"menu_btn9.png", nil];
    
    oneColorArray=[NSArray arrayWithObjects:@"red1.png", @"red1.png",@"red1.png", @"red1.png" ,@"red1.png",@"red1.png", @"red1.png" , @"red1.png",@"red1.png", nil];
    
    outLineArray=[NSArray arrayWithObjects:@"bar_1.png", @"bar_2.png",@"bar_3.png", @"bar_4.png" ,@"bar_5.png",@"bar_6.png", @"bar_7.png" , @"bar_8.png", @"bar_8.png", nil];
    
    mutedArray=[NSArray arrayWithObjects:@"red1.png", @"menu_btn8.png",@"temp_orange.png", @"menu_btn5.png" ,@"muted_5.png",@"menu_btn9.png", @"muted_7.png" , @"temp_pink.png", @"temp_pink.png", nil];
    
    [theme addObject:brightArray];
    [theme addObject:standardArray];
    [theme addObject:oneColorArray];
    [theme addObject:outLineArray];
    [theme addObject:mutedArray];
}

-(void) viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
    for(int i=0; i<[themeName count];i++)
    {
        if([[themeName objectAtIndex:i] isEqual:[preferances valueForKey:@"themeName"]])
        {
            imageList = [theme objectAtIndex:i];
            break;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"Executing numberOfRowsInSection: %ld",[contactList count]);
    return [imageList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Executing cellForRowAtIndexPath");
    static NSString *simpleTableIdentifier = @"SimpleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    //Adding Custom Image
    UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 300, 40)];
    //img.center = CGPointMake(cell.contentView.bounds.size.width/2,cell.contentView.bounds.size.height/2);
    img.image = [UIImage imageNamed:[imageList objectAtIndex:indexPath.row]];
    
    img.tag=indexPath.row;
    [cell addSubview:img];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Seleted Row: %ld", (long)indexPath.row);
    NSLog(@"Clicked Cell of Previous ViewController: %ld",(long)changeIndex);
    NSLog(@"Seleted Image Name: %@",[imageList objectAtIndex:indexPath.row]);
    
    seletRow=indexPath.row;
    
    UIAlertView *confirmDialog=[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to update the color?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
    
    [confirmDialog show];
}

- (IBAction)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButton:(id)sender
{}


-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index: %ld",(long)buttonIndex);
    
    if (buttonIndex==1)
    {
        NSLog(@"Seleted row in saveButton: %lu",seletRow);
        NSLog(@"ChangeIndex: %ld",(long)changeIndex);
        
        if (seletRow!=99999)
        {
            [DBManager updatemenuWithMenuId:[NSString stringWithFormat:@"%ld", (long)changeIndex] withTableColoum:@"menuColor" withColoumValue:[imageList objectAtIndex:(NSUInteger)seletRow]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
