//
//  ImproveHeyController.m
//  Heya
//
//  Created by jayantada on 02/02/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import "ImproveHeyController.h"
#import "Reachability.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ImproveHeyController ()<MFMailComposeViewControllerDelegate>
{
    IBOutlet UIScrollView *myScrollView;
    IBOutlet UIImageView *suggestionTick;
    IBOutlet UIImageView *problemTick;
    IBOutlet UIImageView *praiseTick;
    IBOutlet UIButton *sendBtn;
    IBOutlet UIView *sendView;
    CGFloat animatedDistance;
    NSString *emailSubject;
    NSString* emailBody;
    
    NSString* ReachabilityLabelText;
    BOOL isRechable;
}


@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;
@end

@implementation ImproveHeyController
@synthesize emailID,emailContent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    suggestionTick.hidden=NO;
    problemTick.hidden=YES;
    emailSubject=@"Suggestion";
    
    myScrollView.frame=CGRectMake(myScrollView.frame.origin.x, myScrollView.frame.origin.y, myScrollView.frame.size.width, myScrollView.frame.size.height);
    
    if (isIphone4)
    {
        [sendView setFrame:CGRectMake(sendView.frame.origin.x, sendView.frame.origin.y-55, sendView.frame.size.width, sendView.frame.size.height)];
        myScrollView.contentSize=CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.height-55);
    }
    else if (isIphone5)
    {
        [sendView setFrame:CGRectMake(sendView.frame.origin.x, sendView.frame.origin.y-20, sendView.frame.size.width, sendView.frame.size.height)];
        
        myScrollView.contentSize=CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.height-20);
    }
    else
    {
        myScrollView.contentSize=CGSizeMake(myScrollView.frame.size.width, myScrollView.frame.size.height);
    }
    
    
    //Dismiss any Keyborad if background is tapped
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)suggestionButton:(id)sender
{
    suggestionTick.hidden=NO;
    problemTick.hidden=YES;
    praiseTick.hidden=YES;
    emailSubject=@"Suggestion";
    
}

-(IBAction)problemButton:(id)sender
{
    suggestionTick.hidden=YES;
    praiseTick.hidden=YES;
    problemTick.hidden=NO;
    emailSubject=@"Problem or Question";
}

-(IBAction)praiseButton:(id)sender
{
    
    praiseTick.hidden=NO;
    suggestionTick.hidden=YES;
    problemTick.hidden=YES;
    emailSubject=@"Praise or Adoration";
}

-(IBAction)sendMail:(id)sender
{
    [emailContent resignFirstResponder];
    [emailID resignFirstResponder];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName =@"http://www.google.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
    
    if ([self isNetworkAvailable])
    {
        emailSubject = @"Improve Hey";
        BOOL isValidate=YES;
        
        if(emailID.text.length>0)
        {
            if([self NSStringIsValidEmail:[emailID text]])
            {
                emailBody= [emailContent.text stringByAppendingString:[NSString stringWithFormat:@"\r\n\r\nRegards,\r\n%@", emailID.text]];
                NSLog(@"EmailBody: %@",emailBody);
                isValidate=YES;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email id." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show ];
                isValidate=NO;
            }
        }
        else
        {
            emailBody=emailContent.text;
            NSLog(@"EmailBody: %@",emailBody);
            isValidate=YES;
        }
        
        if(isValidate)
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                
                if([emailSubject isKindOfClass:[NSString class]])
                    [mailViewController setSubject:emailSubject];
                
                
                if(emailBody.length>0)
                    [mailViewController setMessageBody:emailBody isHTML:NO];
                
                else
                    [mailViewController setMessageBody:@"" isHTML:NO];
                
                 //[mailViewController setToRecipients:[NSArray arrayWithObjects:@"patpartridge1248@gmail.com", @"tlanpher@msn.com", nil]];
                
                [mailViewController setToRecipients:[NSArray arrayWithObjects:@"support@getheyfever.com", nil]];
                
                
                [mailViewController.navigationBar setTintColor:[UIColor greenColor]];
                [self presentViewController:mailViewController animated:YES completion:nil];
            }
        }
    }
    else
    {
        [self showNetworkErrorMessage];
    }

}


-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result)
    {
        switch (result)
        {
            case MFMailComposeResultCancelled:
                NSLog(@"Mail cancelled");
                [self alertStatus:nil :@"Email has been cancelled."];
                break;
            case MFMailComposeResultSaved:
                NSLog(@"Mail saved");
                [self alertStatus:nil :@"Email has been saved."];
                break;
            case MFMailComposeResultSent:
            {
                [self alertStatus:nil :@"Email has been sent successfully."];
                NSLog(@"Mail sent");
                break;
            }
            case MFMailComposeResultFailed:
                NSLog(@"Mail sent failure: %@", [error localizedDescription]);
                [self alertStatus:nil :@"Failed to send the email."];
                break;
            default:
                break;
        }
    }
    if (error)
    {
        NSLog(@"Error : %@",error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



// EmailID Validation method
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


//AlerView genertor method
- (void) alertStatus:(NSString *)title :(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark
#pragma mark UITextField Delegate Methods
#pragma mark


static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 180;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 140;

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [myScrollView.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [myScrollView.window convertRect:myScrollView.bounds fromView:myScrollView];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = myScrollView.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [myScrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self endAnimation];
}


#pragma mark
#pragma mark TextView Delegate Methods
#pragma mark
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    CGRect textViewRect = [myScrollView.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [myScrollView.window convertRect:myScrollView.bounds fromView:myScrollView];
    CGFloat midline = textViewRect.origin.y + 0.5 * textViewRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction+40);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = myScrollView.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [myScrollView setFrame:viewFrame];
    [UIView commitAnimations];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [self endAnimation];
}


-(void) endAnimation
{
    CGRect viewFrame = myScrollView.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [myScrollView setFrame:viewFrame];
    [UIView commitAnimations];
}


#pragma mark
#pragma mark Reachability Method Implementation
#pragma mark

//Called by Reachability whenever status changes.

-(BOOL)isNetworkAvailable
{
    return isRechable;
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
        
        //NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        
        if (networkStatus == NotReachable)
        {
            isRechable=NO;
        }
        else
        {
            isRechable=YES;
        }
        
        if (connectionRequired)
        {
            ReachabilityLabelText = NSLocalizedString(@"Cellular data network is unavailable.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            ReachabilityLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        //NSLog(@"Reachability Message: %@", ReachabilityLabelText);
    }
    
    if (reachability == self.internetReachability)
    {
        //NSLog(@"internetReachability is possible");
        NSLog(@"Reachability Message: %@", ReachabilityLabelText);
    }
    
    if (reachability == self.wifiReachability)
    {
        //NSLog(@"wifiReachability is possible");
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

//Called by Reachability whenever status changes.
#pragma mark

-(void)showNetworkErrorMessage
{
    [[[UIAlertView alloc] initWithTitle:nil message:kNetworkErrorMessage delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

-(void) dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
    [myScrollView setContentOffset:CGPointZero animated:YES];
}

@end
