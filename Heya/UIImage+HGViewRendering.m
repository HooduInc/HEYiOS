//
//  UIImage+HGViewRendering.m
//  EmugeTest
//
//  Created by Jayanta Karmakar on 20/10/14.
//  Copyright (c) 2014 susanta. All rights reserved.
//

#import "UIImage+HGViewRendering.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (HGViewRendering)


+ (UIImage *) hg_imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *) hg_imageFromString:(NSString *)str
{
    UILabel *label = [[UILabel alloc] init];
    label.text = str;
    label.opaque = NO;
    label.backgroundColor = UIColor.clearColor;
    CGSize measuredSize = [str sizeWithAttributes:@{NSFontAttributeName:label.font}];
    label.frame = CGRectMake(0, 0, measuredSize.width, measuredSize.height);
    return [UIImage hg_imageFromView:label];
}

+ (UIImage *) hg_cachedImageFromString:(NSString *)str
{
    static NSMutableDictionary *cache = nil;
    if (cache == nil)
        cache = [NSMutableDictionary dictionary];
    UIImage *image = [cache objectForKey:str];
    if (image != nil)
        return image;
    image = [UIImage hg_imageFromString:str];
    [cache setObject:image forKey:str];
    return image;
}

@end
