//
//  QLScalableContentScrollView.h
//  Carusel
//
//  Created by dima on 04.06.2018.
//  Copyright © 2018 Quilxcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLScalableView.h"

@class QLScalableContentScrollView;

@protocol QLScalableContentScrollViewDelegate <NSObject>

@optional

- (CGFloat)scalableContentScrollViewWidthProportional;

- (CGFloat)scalableContentScrollViewOverlayAlpha;

- (UIEdgeInsets)scalableContentScrollViewInsets;

- (CGFloat)scalableContentScrollViewScaleHeight;

- (void)scalableContentScrollView:(QLScalableContentScrollView *)scalableContentScrollView didChangeContentIndex:(NSInteger)index;

@end

@protocol QLScalableContentScrollViewDataSource <NSObject>

@required

- (NSInteger)numberOfViewsInContent;

- (QLScalableView *)scalableContentScrollView:(QLScalableContentScrollView *)scalableContentScrollView scalableContentViewAtIndex:(NSInteger)index;

@end

@interface QLScalableContentScrollView : UIScrollView

@property (assign, nonatomic) id<QLScalableContentScrollViewDelegate> contentDelegate;

@property (assign, nonatomic) id<QLScalableContentScrollViewDataSource> contentDataSource;

- (void)reloadData;

- (void)scrollToContentViewAtIndex:(NSInteger)index;

- (void)clear;

@end
