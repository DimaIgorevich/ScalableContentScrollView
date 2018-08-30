//
//  QLScalableView.m
//  Carusel
//
//  Created by dima on 04.06.2018.
//  Copyright © 2018 Quilxcode. All rights reserved.
//

#import "QLScalableView.h"

CGFloat const kOverlayAlphaChannel = 0.5;

@interface QLScalableView()

@end

@implementation QLScalableView

#pragma mark - Initialize

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self addContentView];
    
    self.overlay = [[UIView alloc] initWithFrame:self.bounds];
    self.overlay.alpha = kOverlayAlphaChannel;
    self.overlay.backgroundColor = UIColor.blackColor;
    [self addSubview:self.overlay];
    [self addConstraintsToView:self.overlay];
}

- (void)addContentView {
    self.contentView = [[UIView alloc] initWithFrame:self.frame];
    self.contentView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.contentView];
    [self addConstraintsToView:self.contentView];
}

#pragma mark - Helpers

- (void)addConstraintsToView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *trailing =[NSLayoutConstraint
                                   constraintWithItem:view
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1.0f
                                   constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:view
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    NSLayoutConstraint *bottom =[NSLayoutConstraint
                                 constraintWithItem:view
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:1.0f
                                 constant:0.f];
    NSLayoutConstraint *top =[NSLayoutConstraint
                                 constraintWithItem:view
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self
                                 attribute:NSLayoutAttributeTop
                                 multiplier:1.0f
                                 constant:0.f];
    [self addConstraint:top];
    [self addConstraint:bottom];
    [self addConstraint:trailing];
    [self addConstraint:leading];
}

@end

