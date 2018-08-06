//
//  QLScalableContentScrollView.m
//  Carusel
//
//  Created by dima on 04.06.2018.
//  Copyright © 2018 Quilxcode. All rights reserved.
//

#import "QLScalableContentScrollView.h"

//MACRO_UTILS BEGIN

#define UIEdgeInsetsHorizontal(insets) (insets.left + insets.right)
#define UIEdgeInsetsVertical(insets) (insets.top + insets.bottom)

//MACRO_UTILS END

UIEdgeInsets const kContentInsetsDefault = {0.0, 20.f, 0.0, 20.f};
NSInteger const kNumberOfViewsDefault    = 0;
CGFloat const kScaleHeightDefault        = 30.f;
CGFloat const kOverlayAlphaDefault       = 0.5f;
CGFloat const kWidthProportionalDefault  = 0.5f;
CGFloat const kWidthProportionalMin      = 0.25f;

@interface QLScalableContentScrollView() <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray<QLScalableView *> *contentViews;

@property (assign, nonatomic) NSInteger currentIndexOfContentView;
@property (assign, nonatomic) CGFloat   aspectRatio;
@property (assign, nonatomic) CGFloat   previousX;
@property (assign, nonatomic) CGFloat scaleHeight;

@property (readonly, nonatomic) UIEdgeInsets contentInsets;
@property (readonly, nonatomic) NSInteger numberOfViews;
@property (readonly, nonatomic) CGFloat overlayAlpha;
@property (readonly, nonatomic) CGFloat widthProportional;

@property (assign, nonatomic) CGFloat currentNeededRatio;
@property (assign, nonatomic) CGFloat nextNeededRatio;
@property (assign, nonatomic) CGFloat nextNeededOpacity;
@property (assign, nonatomic) CGFloat previousNeededOpacity;


@end

@implementation QLScalableContentScrollView

#pragma mark - Initialize

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setClipsToBounds:YES];
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    self.previousX       =  0.f;
    self.contentViews    = [NSMutableArray array];
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
}

#pragma mark - Getters

- (UIEdgeInsets)contentInsets {
    if ([self.contentDelegate respondsToSelector:@selector(scalableContentScrollViewInsets)]) {
        return [self.contentDelegate scalableContentScrollViewInsets];
    }
    return kContentInsetsDefault;
}

- (CGFloat)overlayAlpha {
    if ([self.contentDelegate respondsToSelector:@selector(scalableContentScrollViewOverlayAlpha)]) {
        return [self.contentDelegate scalableContentScrollViewOverlayAlpha];
    }
    return kOverlayAlphaDefault;
}

- (NSInteger)numberOfViews {
    if ([self.contentDataSource respondsToSelector:@selector(numberOfViewsInContent)]) {
        return [self.contentDataSource numberOfViewsInContent];
    }
    return kNumberOfViewsDefault;
}

- (CGFloat)scaleHeight {
    if ([self.contentDelegate respondsToSelector:@selector(scalableContentScrollViewScaleHeight)]) {
        return [self.contentDelegate scalableContentScrollViewScaleHeight];
    }
    return kScaleHeightDefault;
}

- (CGFloat)widthProportional {
    if ([self.contentDelegate respondsToSelector:@selector(scalableContentScrollViewWidthProportional)]) {
        CGFloat proportional = [self.contentDelegate scalableContentScrollViewWidthProportional];
        return (proportional > 1) ? 1.f : (proportional < 0) ? kWidthProportionalMin : proportional;
    }
    return kWidthProportionalDefault;
}

#pragma mark - Lifecycle

- (void)scrollToContentViewAtIndex:(NSInteger)index {
    CGPoint offset = CGPointMake(index * self.frame.size.width / 2.0, 0);
    self.previousX = offset.x;

    self.contentOffset = offset;
    self.currentIndexOfContentView = index;

    [self configureViewAtIndex:self.currentIndexOfContentView scale: 1.0 opacity: self.overlayAlpha];
    [self configureViewAtIndex:self.currentIndexOfContentView scale: 1.0 + self.aspectRatio opacity:0.0];
    [self.contentDelegate scalableContentScrollView:self
                              didChangeContentIndex:self.currentIndexOfContentView];
}

- (void)reloadData {
    [self clear];
    [self layoutIfNeeded];
    
    self.scaleHeight -= self.contentInsets.top;
    
    CGFloat width  = CGRectGetWidth(self.frame) * self.widthProportional - UIEdgeInsetsHorizontal(self.contentInsets);
    CGFloat height = (CGRectGetHeight(self.frame) - 2 * self.scaleHeight - UIEdgeInsetsVertical(self.contentInsets));
    
    QLScalableView* view;
    for (int i = 0; i < self.numberOfViews; i++) {
        view = [self.contentDataSource scalableContentScrollView:self scalableContentViewAtIndex:i];
        view.frame = CGRectMake((CGRectGetWidth(self.frame) - width) / 2.0 + (UIEdgeInsetsHorizontal(self.contentInsets) + width) * i,
                                self.scaleHeight + self.contentInsets.top, width, height);
        
        [self addSubview:view];
        [self.contentViews addObject:view];
    }
    
    //???
    self.contentSize = CGSizeMake(view.frame.origin.x + view.frame.size.width + UIEdgeInsetsHorizontal(self.contentInsets)
                                  + width / 2.0, self.frame.size.height);
    
    self.currentIndexOfContentView = 0;
    self.aspectRatio = 2 * self.scaleHeight / view.frame.size.height;
    
    [self scaleContentViewAtIndex:self.currentIndexOfContentView withScale:1 + self.aspectRatio];
    self.contentViews[self.currentIndexOfContentView].overlay.alpha = 0.f;
}

- (void)configureViewAtIndex:(NSInteger)index scale:(CGFloat)scale opacity:(CGFloat)opacity {
    
    if (index >= 0 && index < self.contentViews.count) {
        [self scaleContentViewAtIndex:index withScale:scale];
        self.contentViews[index].overlay.alpha = opacity;
    }
    
}

- (void)configureNeighborsAfterScroll {
    
    [self configureViewAtIndex: self.currentIndexOfContentView - 1 scale: 1.0 opacity:self.overlayAlpha];
    [self configureViewAtIndex: self.currentIndexOfContentView + 1 scale: 1.0 opacity:self.overlayAlpha];
    
    [self configureViewAtIndex: self.currentIndexOfContentView + 2 scale: 1.0 opacity:self.overlayAlpha];
    [self configureViewAtIndex: self.currentIndexOfContentView + 3 scale: 1.0 opacity:self.overlayAlpha];
    [self configureViewAtIndex: self.currentIndexOfContentView + 4 scale: 1.0 opacity:self.overlayAlpha];
    
    [self configureViewAtIndex: self.currentIndexOfContentView - 2 scale: 1.0 opacity:self.overlayAlpha];
    [self configureViewAtIndex: self.currentIndexOfContentView - 3 scale: 1.0 opacity:self.overlayAlpha];
    [self configureViewAtIndex: self.currentIndexOfContentView - 4 scale: 1.0 opacity:self.overlayAlpha];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat width = scrollView.frame.size.width * self.widthProportional;
    CGFloat targetX = scrollView.contentOffset.x + velocity.x * width;
    
    CGFloat targetIndex = round(targetX / width);
    
    if (targetIndex < 0) targetIndex = 0;
    if (targetIndex >= self.numberOfViews) targetIndex = self.numberOfViews - 1;
    
    
    targetContentOffset->x = targetIndex * width;
    
    self.currentIndexOfContentView = targetIndex;
    self.previousX   = targetIndex * width;
    
    [self configureNeighborsAfterScroll];
    
    if ([self.contentDelegate respondsToSelector:@selector(scalableContentScrollView:didChangeContentIndex:)]) {
        [self.contentDelegate scalableContentScrollView:self didChangeContentIndex:self.currentIndexOfContentView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat stepSize                = self.frame.size.width * self.widthProportional;
    CGFloat currentOffset           = ABS(scrollView.contentOffset.x - self.currentIndexOfContentView * stepSize);
    CGFloat nextCompletion          = currentOffset / stepSize;
    CGFloat previousCompletion      = 1.f - currentOffset / stepSize;
    
    BOOL igonreScalingCurrentIndex = NO;
    
    if (nextCompletion > 1) {
        
        nextCompletion = 1 - (nextCompletion - 1);
        previousCompletion = 1 - nextCompletion;
        
        [self countCoefficientsWithPreviousCompletion:previousCompletion
                                    andNextCompletion:nextCompletion];
        
        if([self wasScrolledRight]) {
            [self configureViewAtIndex:self.currentIndexOfContentView + 2 scale:1 + self.nextNeededRatio
                               opacity:self.nextNeededOpacity];
        }
        else if([self wasScrolledLeft]) {
            [self configureViewAtIndex:self.currentIndexOfContentView - 2 scale:1 + self.nextNeededRatio
                               opacity:self.nextNeededOpacity];
        }
        
        [self configureViewAtIndex:self.currentIndexOfContentView scale:1.0
                           opacity:self.overlayAlpha];
   
        igonreScalingCurrentIndex = YES;
    }
    
    [self countCoefficientsWithPreviousCompletion:previousCompletion andNextCompletion:nextCompletion];

    
    if (!igonreScalingCurrentIndex) {
         [self configureViewAtIndex:self.currentIndexOfContentView scale:1 + self.nextNeededRatio
                            opacity:self.nextNeededOpacity];
    }
   
    
    if([self wasScrolledRight]) {
        [self configureViewAtIndex:self.currentIndexOfContentView + 1 scale:1 + self.currentNeededRatio
                           opacity:self.previousNeededOpacity];
    } else if([self wasScrolledLeft]) {
        [self configureViewAtIndex:self.currentIndexOfContentView - 1 scale:1 + self.currentNeededRatio
                           opacity:self.previousNeededOpacity];
    } else {
        [self configureViewAtIndex: self.currentIndexOfContentView - 1 scale: 1 + self.currentNeededRatio opacity: self.overlayAlpha];
        [self configureViewAtIndex: self.currentIndexOfContentView + 1 scale: 1 + self.currentNeededRatio opacity: self.overlayAlpha];
    }
}

#pragma mark - Helpers

- (BOOL)wasScrolledLeft {
    return self.previousX > self.contentOffset.x;
}


- (BOOL)wasScrolledRight {
    return self.previousX < self.contentOffset.x;
}


- (void)countCoefficientsWithPreviousCompletion:(CGFloat)previousCompletion
                              andNextCompletion:(CGFloat)nextCompletion {
    
     self.currentNeededRatio      = self.aspectRatio * nextCompletion;
     self.nextNeededRatio         = self.aspectRatio * previousCompletion;
     self.nextNeededOpacity       = self.overlayAlpha * nextCompletion;
     self.previousNeededOpacity   = self.overlayAlpha * previousCompletion;
}


- (void)scaleContentViewAtIndex:(NSInteger)index withScale:(CGFloat)scale {
    CGPoint center = self.contentViews[index].center;
    self.contentViews[index].transform = CGAffineTransformMakeScale(scale, scale);
    self.contentViews[index].center    = center;
}

- (void)clear {
    [self.contentViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentViews removeAllObjects];
}

- (void)setContentDataSource:(id<QLScalableContentScrollViewDataSource>)contentDataSource {
    _contentDataSource = contentDataSource;
    [self reloadData];
}
@end
