//
//  CustomUITextFieldType1.m
//  Chosen
//
//  Created by Kaustav Shee on 3/6/15.
//  Copyright (c) 2015 appsbee. All rights reserved.
//

#import "CustomUITextFieldType.h"

@interface CustomUITextFieldType ()
{
    UIEdgeInsets edgeInsets;
}

@end

@implementation CustomUITextFieldType

-(id)init
{
    if (self=[super init]) {
        [self initialization];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

-(void)initialization
{
    edgeInsets = UIEdgeInsetsMake(0, 10, 0, 5);//(top,left,bottom,right)
    
}

-(CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, edgeInsets)];
}
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, edgeInsets)];
}

@end
