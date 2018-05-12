//
//  CTInputTableViewCell.m
//  CampTalk
//
//  Created by renge on 2018/5/12.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTInputTableViewCell.h"

NSString * const CTInputTableViewCellId = @"CTInputTableViewCellId";

@implementation CTInputTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawLine:rect];
}

- (void)drawLine:(CGRect)rect {
    if (_hideLine) {
        return;
    }
    //  1.在此方法中系统已经创建一个与view相关联的上下文(layer上下文), 只要获取上下文就行;(获取和创建上下文都是UIGraphics开头)
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //2.绘制路径(一条路径可以描述多条线)
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //    2.1 设置起点
    CGRect line =
    CGRectMake(_textFieldEdge.left,
               rect.size.height - 0.5,
               rect.size.width - _textFieldEdge.right - _textFieldEdge.left,
               0.5);
    line = UIEdgeInsetsInsetRect(line, _lineEdge);
    
    [path moveToPoint:CGPointMake(line.origin.x, line.origin.y)];
    [path addLineToPoint:CGPointMake(line.origin.x + line.size.width, line.origin.y)];
    
    //设置线的粗细
    CGContextSetLineWidth(ctx, line.size.height);
    
    //设置两根线的连接样式, 第二个参数是枚举
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    //设置两根线各组尾部的样式, 第二个参数是枚举
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //    setStroke还是setFill看最终设定的渲染方式
    if (_lineColor) {
        [_lineColor setStroke];
    } else {
        [_textField.tintColor setStroke];
    }
    
    //3.把绘制的内容添加到上下文中
    //UIBezierPath是UIKit框架  第二个参数, CGPathRef是coreGraphic框架
    CGContextAddPath(ctx, path.CGPath);
    
    //4.把上下文渲染到view的layer上(stroke或fill的方式)
    CGContextStrokePath(ctx);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textField.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, _textFieldEdge);
}

- (void)setTextFieldEdge:(UIEdgeInsets)textFieldEdge {
    if (UIEdgeInsetsEqualToEdgeInsets(textFieldEdge, _textFieldEdge)) {
        return;
    }
    _textFieldEdge = textFieldEdge;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setHideLine:(BOOL)hideLine {
    if (_hideLine == hideLine) {
        return;
    }
    _hideLine = hideLine;
    [self setNeedsDisplay];
}

- (void)setLineEdge:(UIEdgeInsets)lineEdge {
    if (UIEdgeInsetsEqualToEdgeInsets(lineEdge, _lineEdge)) {
        return;
    }
    _lineEdge = lineEdge;
    [self setNeedsDisplay];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
