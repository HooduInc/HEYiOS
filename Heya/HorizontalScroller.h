//
//  HorizontalScroller.h
//  AdaptivePattern
//
//  Created by Kaustav Shee on 3/20/15.
//  Copyright (c) 2015 AppsBee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalScroller;

@protocol HorizontalScrollerDelegate <NSObject>

@required
// ask the delegate how many views he wants to present inside the horizontal scroller
- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller;

// ask the delegate to return the view that should appear at <index>
- (UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index;

@optional
// ask the delegate for the index of the initial view to display. this method is optional
// and defaults to 0 if it's not implemented by the delegate
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller*)scroller;
-(BOOL)setPaggingEnableForHorizontalScroller:(HorizontalScroller*)scroller;
-(CGFloat)setPaddingForHorizontalScroller:(HorizontalScroller*)scroller;

// inform the delegate what the view at <index> has been clicked
- (void)horizontalScroller:(HorizontalScroller*)scroller clickedViewAtIndex:(int)index;

-(void)beforeZeroPressed;
-(void)afterMaximumPressed;

@end

@interface HorizontalScroller : UIView

@property(weak,nonatomic) IBOutlet id <HorizontalScrollerDelegate> delegate;

-(void)moveToIndex:(int)index;

-(void)reloadData;

@end





