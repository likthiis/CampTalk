//
//  UIView+PanGestureHelp.m
//  CampTalk
//
//  Created by renge on 2018/4/28.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "UIView+PanGestureHelp.h"
#import <objc/runtime.h>

char *kOriginCenter = "kOriginCenter";
char *kStartPoint = "kStartPoint";
char *kOriginSize = "kOriginSize";

@implementation UIView (PanGestureHelp)

- (void)setOriginCenter:(CGPoint)originCenter {
    objc_setAssociatedObject(self, kOriginCenter, [NSNumber valueWithCGPoint:originCenter], OBJC_ASSOCIATION_RETAIN);
}

- (CGPoint)originCenter {
    return [objc_getAssociatedObject(self, kOriginCenter) CGPointValue];
}

- (void)setOriginSize:(CGSize)originSize {
    objc_setAssociatedObject(self, kOriginSize, [NSNumber valueWithCGSize:originSize], OBJC_ASSOCIATION_RETAIN);
}

- (CGSize)originSize {
    return [objc_getAssociatedObject(self, kOriginSize) CGSizeValue];
}

- (void)setStartPoint:(CGPoint)startPoint {
    objc_setAssociatedObject(self, kStartPoint, [NSNumber valueWithCGPoint:startPoint], OBJC_ASSOCIATION_RETAIN);
}

- (CGPoint)startPoint {
    return [objc_getAssociatedObject(self, kStartPoint) CGPointValue];
}

- (void)startWithPoint:(CGPoint)startPoint {
    self.originCenter = self.center;
    self.startPoint = startPoint;
}

- (void)updateCenterWithNewPoint:(CGPoint)newPoint {
    CGPoint startPoint = self.startPoint;
    CGFloat deltaX = newPoint.x - startPoint.x;
    CGFloat deltaY = newPoint.y - startPoint.y;
    self.center = CGPointMake(self.originCenter.x + deltaX, self.originCenter.y + deltaY);
}

- (void)centerScale:(CGFloat)scale {
    CGSize size = self.frame.size;
    
    CGRect frame = self.frame;
    
    CGFloat temp = size.height * scale;
    frame.origin.y -=  (temp - size.height) / 2.f;
    frame.size.height = temp;
    
    temp = size.width * scale;
    frame.origin.x -= (temp - size.width) / 2.f;
    frame.size.width = temp;
    self.frame = frame;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
