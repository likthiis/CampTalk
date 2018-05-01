//
//  UIView+PanGestureHelp.h
//  CampTalk
//
//  Created by renge on 2018/4/28.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PanGestureHelp)

@property (nonatomic, assign) CGPoint originCenter;
@property (nonatomic, assign) CGSize originSize;
@property (nonatomic, assign) CGPoint startPoint;

- (void)startWithPoint:(CGPoint)startPoint;

- (void)updateCenterWithNewPoint:(CGPoint)newPoint;

- (void)centerScale:(CGFloat)scale;

@end
