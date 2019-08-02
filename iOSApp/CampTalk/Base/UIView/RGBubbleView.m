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
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (void)setBubbleRightToLeft:(BOOL)bubbleRightToLeft {
    if (_bubbleRightToLeft == bubbleRightToLeft) {
        return;
    }
    _bubbleRightToLeft = bubbleRightToLeft;
    _recordSize = CGSizeZero;
    [self setNeedsLayout];
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
    [self sendSubviewToBack:self.contentView];
    [self sendSubviewToBack:self.backgroundView];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, [self contentViewEdge]);
}

- (UIBezierPath *)bubblePathWithSize:(CGSize)size {
    
    if (_bubbleRightToLeft) {
        
        CGFloat offSetX = size.width - 53.62;
        CGFloat offSetY = size.height - 19.34;
        
        UIBezierPath* bubble_path = UIBezierPath.bezierPath;
        [bubble_path moveToPoint:CGPointMake(43.47+offSetX, 0)];
        [bubble_path addCurveToPoint:CGPointMake(44.48+offSetX, 3.76) controlPoint1:CGPointMake(44.48+offSetX, 0) controlPoint2:CGPointMake(44.48+offSetX, 0.29)];
        [bubble_path addLineToPoint:CGPointMake(44.48+offSetX, 5.12+offSetY)];
        [bubble_path addLineToPoint:CGPointMake(45.51+offSetX, 5.8+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(53.36+offSetX, 11.57+offSetY) controlPoint1:CGPointMake(45.51+offSetX, 5.8+offSetY) controlPoint2:CGPointMake(45.51+offSetX, 5.8+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(53.36+offSetX, 11.9+offSetY) controlPoint1:CGPointMake(53.71+offSetX, 11.9+offSetY) controlPoint2:CGPointMake(53.71+offSetX, 11.9+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(51.66+offSetX, 11.9+offSetY) controlPoint1:CGPointMake(52.64+offSetX, 11.9+offSetY) controlPoint2:CGPointMake(51.66+offSetX, 11.9+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(45.21+offSetX, 11.9+offSetY) controlPoint1:CGPointMake(51.66+offSetX, 11.9+offSetY) controlPoint2:CGPointMake(45.48+offSetX, 11.9+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(44.48+offSetX, 13.05+offSetY) controlPoint1:CGPointMake(44.48+offSetX, 11.9+offSetY) controlPoint2:CGPointMake(44.48+offSetX, 11.9+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(44.48+offSetX, 16.58+offSetY) controlPoint1:CGPointMake(44.48+offSetX, 14.19+offSetY) controlPoint2:CGPointMake(44.48+offSetX, 16.08+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(42.9+offSetX, 19.34+offSetY) controlPoint1:CGPointMake(44.48+offSetX, 19.34+offSetY) controlPoint2:CGPointMake(44.45+offSetX, 19.34+offSetY)];
        [bubble_path addLineToPoint:CGPointMake(1.75, 19.34+offSetY)];
        [bubble_path addCurveToPoint:CGPointMake(0, 16.76+offSetY) controlPoint1:CGPointMake(0.21, 19.34+offSetY) controlPoint2:CGPointMake(0, 19.34+offSetY)];
        [bubble_path addLineToPoint:CGPointMake(0, 2.76)];
        [bubble_path addCurveToPoint:CGPointMake(2.18, 0) controlPoint1:CGPointMake(0, -0) controlPoint2:CGPointMake(0, 0)];
        [bubble_path addCurveToPoint:CGPointMake(43.47+offSetX, 0) controlPoint1:CGPointMake(2.18, 0) controlPoint2:CGPointMake(23.7+offSetX, 0)];
        [bubble_path closePath];
        return bubble_path;
    }
    
    CGFloat offSetX = size.width - 11.62;
    CGFloat offSetY = size.height - 20.34;
    
    //// bubble_clear_bg Drawing
    UIBezierPath *bubble_path = [UIBezierPath bezierPath];

    [bubble_path moveToPoint:CGPointMake(10.58, 0)];
    [bubble_path addCurveToPoint:CGPointMake(9, 2) controlPoint1:CGPointMake(9, 0) controlPoint2:CGPointMake(9, 0)];
    [bubble_path addLineToPoint:CGPointMake(9, 6+offSetY)];
    [bubble_path addLineToPoint:CGPointMake(0.26, 12.57+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(0.26, 12.9+offSetY) controlPoint1:CGPointMake(-0.09, 12.9+offSetY) controlPoint2:CGPointMake(-0.09, 12.9+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(1.96, 12.9+offSetY) controlPoint1:CGPointMake(0.98, 12.9+offSetY) controlPoint2:CGPointMake(1.96, 12.9+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(8.41, 12.9+offSetY) controlPoint1:CGPointMake(1.96, 12.9+offSetY) controlPoint2:CGPointMake(8.14, 12.9+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(9, 14.05+offSetY) controlPoint1:CGPointMake(9.14, 12.9+offSetY) controlPoint2:CGPointMake(9, 12.9+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(9, 17.58+offSetY) controlPoint1:CGPointMake(9, 15.19+offSetY) controlPoint2:CGPointMake(9, 17.08+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(10.58, 20.34+offSetY) controlPoint1:CGPointMake(9, 20.34+offSetY) controlPoint2:CGPointMake(9.04, 20.34+offSetY)];
    
    
    [bubble_path addLineToPoint:CGPointMake(10.44+offSetX, 20.34+offSetY)];
    [bubble_path addCurveToPoint:CGPointMake(11.62+offSetX, 17.76+offSetY) controlPoint1:CGPointMake(11.62+offSetX, 20.34+offSetY) controlPoint2:CGPointMake(11.62+offSetX, 20.34+offSetY)];
    
    [bubble_path addLineToPoint:CGPointMake(11.62+offSetX, 2)];
    [bubble_path addCurveToPoint:CGPointMake(10.44+offSetX, 0) controlPoint1:CGPointMake(11.62+offSetX, 0) controlPoint2:CGPointMake(11.62+offSetX, 0)];
    [bubble_path addLineToPoint:CGPointMake(10.58, 0)];
    [bubble_path closePath];

    
    return bubble_path;
}

- (UIEdgeInsets)contentViewEdge {
    if (_bubbleRightToLeft) {
        return UIEdgeInsetsMake(kBubbleLineWidth , kBubbleLineWidth, kBubbleLineWidth, kBubbleLineWidth+9);
    }
    return UIEdgeInsetsMake(kBubbleLineWidth , 9+kBubbleLineWidth, kBubbleLineWidth, kBubbleLineWidth);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
