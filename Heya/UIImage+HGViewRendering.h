//
//  UIImage+HGViewRendering.h
//  EmugeTest
//
//  Created by Jayanta Karmakar on 20/10/14.
//  Copyright (c) 2014 susanta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HGViewRendering)

+ (UIImage *) hg_imageFromView:(UIView *)view;
+ (UIImage *) hg_imageFromString:(NSString *)str;
+ (UIImage *) hg_cachedImageFromString:(NSString *)str;

@end
