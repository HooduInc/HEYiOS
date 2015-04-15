//
//  SectionView.m
//  CustomTableTest
//
//  Created by Punit Sindhwani on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SectionView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SectionView

@synthesize section;
@synthesize sectionTitle;
@synthesize discButton;
@synthesize delegate;


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame WithTitle: (NSString *) title Section:(NSInteger)sectionNumber delegate: (id <SectionView>) Delegate
{
    self = [super initWithFrame:frame];
    if (self) {
   
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(discButtonPressed:)];
        [self addGestureRecognizer:tapGesture];
        
        self.userInteractionEnabled = YES;

        self.section = sectionNumber;
        self.delegate = Delegate;

        CGRect LabelFrame = self.bounds;
        LabelFrame.size.width -= 50;
        CGRectInset(LabelFrame, 0.0, 5.0);
        
        UILabel *label = [[UILabel alloc] initWithFrame:LabelFrame];
        label.text = title;
        label.font = [UIFont boldSystemFontOfSize:16.0];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:label];
        self.sectionTitle = label;
        
        CGRect buttonFrame = CGRectMake(LabelFrame.size.width, 0, 50, LabelFrame.size.height);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        [button setImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"arrow_up.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(discButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.discButton = button;
        
        //Create Transparent Button
        /*CGRect fullButtonFrame = CGRectMake(15, 0, 300, 40);
        UIButton *fullButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fullButton.frame = fullButtonFrame;
        fullButton.backgroundColor=[UIColor yellowColor];
        fullButton.hidden=YES;
        [fullButton addTarget:self action:@selector(discButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullButton];
        self.discButton = fullButton;*/
    }
    return self;
}

- (void) discButtonPressed : (id) sender
{
   // [self toggleButtonPressed:TRUE];
    [self toggleButtonPressed:TRUE sender:sender];
}

- (void) toggleButtonPressed : (BOOL) flag sender:(id) sender
{
    self.discButton.selected = !self.discButton.selected;
    if(flag)
    {
        if (self.discButton.selected) 
        {
//            if ([self.delegate respondsToSelector:@selector(sectionOpened:)]) 
//            {
//                [self.delegate sectionOpened:self.section];
//            }
            
            if ([self.delegate respondsToSelector:@selector(sectionOpened:sender:)])
            {
                [self.delegate sectionOpened:self.section sender:sender];
            }
        } else
        {
            if ([self.delegate respondsToSelector:@selector(sectionClosed:sender:)])
            {
                [self.delegate sectionClosed:self.section sender:sender];
            }
        }
    }
}

@end
