//
//  UIView+Radius.m
//  JusTalk
//
//  Created by 姜豪 on 2017/11/21.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIView+Radius.h"
#import <objc/runtime.h>

static const char *borderLayerKey = "borderLayerKey";

@implementation UIView (Radius)

- (void)addBorderWithCornerRadious:(CGFloat)radius borderColor:(UIColor *)borderColor andBorderWidth:(CGFloat)borderWidth
{
    CGRect rect = self.bounds;
    
    //Make round
    // Create the path for to make circle
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = rect;
    maskLayer.path  = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.layer.mask = maskLayer;
    
    //Give Border
    //Create path for border
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                     byRoundingCorners:UIRectCornerAllCorners
                                                           cornerRadii:CGSizeMake(radius, radius)];
    
    [self.borderLayer removeFromSuperlayer];
    self.borderLayer = nil;
    // Create the shape layer and set its path
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    
    borderLayer.frame       = rect;
    borderLayer.path        = borderPath.CGPath;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;
    borderLayer.fillColor   = [UIColor clearColor].CGColor;
    borderLayer.lineWidth   = borderWidth;
    self.borderLayer = borderLayer;
    
    //Add this layer to give border.
    [[self layer] addSublayer:self.borderLayer];
}

- (void)setBorderLayer:(CALayer *)borderLayer {
    objc_setAssociatedObject(self, borderLayerKey, borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)borderLayer {
    return objc_getAssociatedObject(self, borderLayerKey);
}

@end
