//
//  QLScalableView.h
//  Carusel
//
//  Created by dima on 04.06.2018.
//  Copyright © 2018 Quilxcode. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_SWIFT_NAME(ScalableView)

@interface QLScalableView : UIView

@property (strong, nonatomic) UIView *overlay;

@property (strong, nonatomic) UIView *contentView;

@end

