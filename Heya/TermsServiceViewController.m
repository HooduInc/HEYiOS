//
//  TermsServiceViewController.m
//  Hey
//
//  Created by jayantada on 13/05/15.
//  Copyright (c) 2015 Palash Das. All rights reserved.
//

#import "TermsServiceViewController.h"

@interface TermsServiceViewController ()<UIWebViewDelegate>
{
    IBOutlet UIWebView *EulaText;
}

@end

@implementation TermsServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *htmlFile=[[NSBundle mainBundle] pathForResource:@"terms_services" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [EulaText loadHTMLString:htmlString baseURL:nil];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)closeBtnTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqual:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
