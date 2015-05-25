//
//  HorizontalScroller.m
//  AdaptivePattern
//
//  Created by Kaustav Shee on 3/20/15.
//  Copyright (c) 2015 AppsBee. All rights reserved.
//

#import "HorizontalScroller.h"

//#define VIEW_PADDING 10
//#define VIEW_DIMENSIONS 100
//#define VIEWS_OFFSET 100

@interface UIScrollView (CurrentPage)
-(int) currentPage;
@end
@implementation UIScrollView (CurrentPage)
-(int) currentPage{
    CGFloat pageWidth = self.frame.size.width;
    return floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}
@end


@interface HorizontalScroller ()<UIScrollViewDelegate>
{
    CGRect myFrame;
}

@end

@implementation HorizontalScroller
{
    UIScrollView *scroller;
}


-(id)initWithFrame:(CGRect)frame
{
    //NSLog(@"frame = %@",NSStringFromCGRect(frame));
    myFrame=frame;
    if (self=[super initWithFrame:frame]) {
        scroller = [[UIScrollView alloc] initWithFrame:frame];
        scroller.delegate = self;
        [self addSubview:scroller];
        /*UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollerTapped:)];
        [scroller addGestureRecognizer:tapRecognizer];*/
        [scroller setBounces:NO];
        [scroller setShowsHorizontalScrollIndicator:NO];
        [scroller setShowsVerticalScrollIndicator:NO];
        scroller.scrollEnabled=NO;
    }
    return self;
}

/*- (void)scrollerTapped:(UITapGestureRecognizer*)gesture
{
    CGPoint location = [gesture locationInView:gesture.view];
    // we can't use an enumerator here, because we don't want to enumerate over ALL of the UIScrollView subviews.
    // we want to enumerate only the subviews that we added
    for (int index=0; index<[self.delegate numberOfViewsForHorizontalScroller:self]; index++)
    {
        UIView *view = scroller.subviews[index];
        if (CGRectContainsPoint(view.frame, location))
        {
            [self.delegate horizontalScroller:self clickedViewAtIndex:index];
            [scroller setContentOffset:CGPointMake(view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}*/

-(void)reloadData
{
    // 1 - nothing to load if there's no delegate
    if (self.delegate == nil) return;
    
    if ([self.delegate respondsToSelector:@selector(setPaggingEnableForHorizontalScroller:)]) {
        [scroller setPagingEnabled:[self.delegate setPaggingEnableForHorizontalScroller:self]];
    }
    
    // 2 - remove all subviews
    [scroller.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    // 3 - xValue is the starting point of the views inside the scroller
    CGFloat padding=0.0f;
    
    for (int i=0; i<[self.delegate numberOfViewsForHorizontalScroller:self]; i++)
    {
        // 4 - add a view at the right position
        UIView *view = [self.delegate horizontalScroller:self viewAtIndex:i];
        view.frame = CGRectMake(myFrame.size.width*i+padding, 0, myFrame.size.width, myFrame.size.height);
        NSLog(@"%d Frame = %@",i,NSStringFromCGRect(view.frame));
        [scroller addSubview:view];
        [scroller setBackgroundColor:[UIColor redColor]];
        if (i==0) {
            if ([self.delegate respondsToSelector:@selector(setPaddingForHorizontalScroller:)]) {
                padding=[self.delegate setPaddingForHorizontalScroller:self];
            }
        }
    }
    
    // 5
    [scroller setContentSize:CGSizeMake([self.delegate numberOfViewsForHorizontalScroller:self]*self.frame.size.width, self.frame.size.height)];
    
    // 6 - if an initial view is defined, center the scroller on it
    if ([self.delegate respondsToSelector:@selector(initialViewIndexForHorizontalScroller:)])
    {
        NSUInteger initialView = [self.delegate initialViewIndexForHorizontalScroller:self];
        [scroller setContentOffset:CGPointMake(initialView*(self.frame.size.width+(2*0)), 0) animated:YES];
    }
}
- (void)didMoveToSuperview
{
    [self reloadData];
}
- (void)centerCurrentView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        NSLog(@"current page = %d",[scrollView currentPage]);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"current page = %d",[scrollView currentPage]);
}

-(void)moveToIndex:(int)index
{
    if ([scroller currentPage]==index) {
        
    }else{
        if (index<0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(beforeZeroPressed)]) {
                [self.delegate beforeZeroPressed];
            }
        }
        else if (index>[self.delegate numberOfViewsForHorizontalScroller:self]-1){
            if (self.delegate && [self.delegate respondsToSelector:@selector(afterMaximumPressed)]) {
                [self.delegate afterMaximumPressed];
            }
        }
        else{
            [scroller setContentOffset:CGPointMake(index*self.frame.size.width, scroller.contentOffset.y) animated:YES];
        }
    }
}




@end
