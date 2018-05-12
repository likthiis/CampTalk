//
//  RGBorderLabel.m
//  CampTalk
//
//  Created by LD on 2018/4/19.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "RGBorderLabel.h"

@implementation RGBorderLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = [UIColor whiteColor];
        self.borderWidth = 3.f;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.borderColor = [UIColor whiteColor];
    self.borderWidth = 3.f;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
}

- (void)drawTextInRect:(CGRect)rect {
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, _borderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    //画外边
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.borderColor;
    [super drawTextInRect:rect];
    
    //画内文字
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
