//
//  RGBubbleView.m
//  CampTalk
//
//  Created by renge on 2018/5/4.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "RGBubbleView.h"

static CGFloat kBubbleLineWidth = 2.f;

@interface RGBubbleView ()

@property (nonatomic, assign) CGSize recordSize;

@end

@implementation RGBubbleView

- (CAShapeLayer *)bubbleMask {
    if (!_bubbleMask) {
        _bubbleMask = [CAShapeLayer layer];
    }
    return _bubbleMask;
}

- (CAShapeLayer *)bubbleBorder {
    if (!_bubbleBorder) {
        _bubbleBorder = [CAShapeLayer layer];
        _bubbleBorder.fillColor = [UIColor clearColor].CGColor;
        _bubbleBorder.strokeColor = [UIColor whiteColor].CGColor;
        _bubbleBorder.lineWidth = kBubbleLineWidth * 2.f;
        _bubbleBorder.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:_bubbleBorder];
    }
    return _bubbleBorder;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(_recordSize, self.bounds.size)) {
        _recordSize = self.bounds.size;
        self.bubbleMask.path = [self bubblePathWithSize:_recordSize].CGPath;
        self.layer.mask = self.bubbleMask;
        
        self.bubbleBorder.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 0, 0));
        UIBezierPath *path = [self bubblePathWithSize:self.bubbleBorder.frame.size];
        self.bubbleBorder.path = path.CGPath;
    }
    [self bringSubviewToFront:_contentView];
    _contentView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(kBubbleLineWidth , 9 + kBubbleLineWidth, kBubbleLineWidth, kBubbleLineWidth));
}

- (UIBezierPath *)bubblePathWithSize:(CGSize)size {
    
    CGFloat offSetX = size.width - 11.62;
    CGFloat offSetY = size.height - 20.34;
    
    //// bubble_clear_bg Drawing
    UIBezierPath *bubble_clear_bgPath = [UIBezierPath bezierPath];

    [bubble_clear_bgPath moveToPoint: CGPointMake(10.58, 0)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(9, 2) controlPoint1: CGPointMake(9, 0) controlPoint2: CGPointMake(9, 0)];
    [bubble_clear_bgPath addLineToPoint: CGPointMake(9, 6 + offSetY)];
    [bubble_clear_bgPath addLineToPoint: CGPointMake(0.26, 12.57 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(0.26, 12.9 + offSetY) controlPoint1: CGPointMake(-0.09, 12.9 + offSetY) controlPoint2: CGPointMake(-0.09, 12.9 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(1.96, 12.9 + offSetY) controlPoint1: CGPointMake(0.98, 12.9 + offSetY) controlPoint2: CGPointMake(1.96, 12.9 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(8.41, 12.9 + offSetY) controlPoint1: CGPointMake(1.96, 12.9 + offSetY) controlPoint2: CGPointMake(8.14, 12.9 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(9, 14.05 + offSetY) controlPoint1: CGPointMake(9.14, 12.9 + offSetY) controlPoint2: CGPointMake(9, 12.9 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(9, 17.58 + offSetY) controlPoint1: CGPointMake(9, 15.19 + offSetY) controlPoint2: CGPointMake(9, 17.08 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(10.58, 20.34 + offSetY) controlPoint1: CGPointMake(9, 20.34 + offSetY) controlPoint2: CGPointMake(9.04, 20.34 + offSetY)];
    
    
    [bubble_clear_bgPath addLineToPoint: CGPointMake(10.44 + offSetX, 20.34 + offSetY)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(11.62 + offSetX, 17.76 + offSetY) controlPoint1: CGPointMake(11.62 + offSetX, 20.34 + offSetY) controlPoint2: CGPointMake(11.62 + offSetX, 20.34 + offSetY)];
    
    [bubble_clear_bgPath addLineToPoint: CGPointMake(11.62 + offSetX, 2)];
    [bubble_clear_bgPath addCurveToPoint: CGPointMake(10.44 + offSetX, 0) controlPoint1: CGPointMake(11.62 + offSetX, 0) controlPoint2: CGPointMake(11.62 + offSetX, 0)];
    [bubble_clear_bgPath addLineToPoint: CGPointMake(10.58, 0)];
    [bubble_clear_bgPath closePath];

    
    return bubble_clear_bgPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
