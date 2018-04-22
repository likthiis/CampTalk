//
//  CTChatTableViewCell.m
//  CampTalk
//
//  Created by kikilee on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatTableViewCell.h"

static CGSize _maxIconSize = {40, 40};
static CGFloat _chatCelIIconWidth = 40;

static CGFloat _margin = 15;

static CGFloat _marginTop = 20;

NSString * const CTChatTableViewCellId = @"kCTChatTableViewCellId";

@interface CTChatTableViewCell ()

@property (nonatomic, strong) CAGradientLayer *gradLayer;

@end

@implementation CTChatTableViewCell

+ (void)registerForTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CTChatTableViewCellId];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.chatBubbleLabel.layer.anchorPoint = CGPointMake(0, 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat height = bounds.size.height;
    
    // 头像布局，头像宽不超出 _chatCelIIconWidth，高度不超出父视图的高度，否则按比例缩放头像至全部显示
    UIImage *icon = self.iconView.image;
    CGSize iconSize = icon.size;
    if (icon.scale != [UIScreen mainScreen].scale) {
        CGFloat scale = icon.scale / [UIScreen mainScreen].scale;
        iconSize.height *= scale;
        iconSize.width *= scale;
    }
    
    CGFloat scale = _chatCelIIconWidth / iconSize.width;
    if (scale < 1.f) {
        if (iconSize.height * scale > height) {
            scale = height / iconSize.height;
        }
        iconSize.height *= scale;
        iconSize.width *= scale;
    } else {
        scale = height / iconSize.height;
        if (scale < 1.f) {
            if (iconSize.width * scale > _chatCelIIconWidth) {
                scale = _chatCelIIconWidth / iconSize.width;
            }
            iconSize.height *= scale;
            iconSize.width *= scale;
        }
    }
    
    self.iconView.frame =
    CGRectMake(
               _margin + (_chatCelIIconWidth - iconSize.width) / 2.f,
               bounds.size.height - iconSize.height,
               iconSize.width,
               iconSize.height
               );
    // 文字布局
    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, _chatCelIIconWidth + _margin, 0, _margin));
    
    CGSize labelSize;
    if (bounds.size.height - _maxIconSize.height - _marginTop < 1e-7) {
        labelSize = [self.chatBubbleLabel sizeThatFits:bounds.size];
    } else {
        labelSize = bounds.size;
        labelSize.height -= _marginTop;
    }
    
    bounds.origin.y = bounds.size.height - labelSize.height;
    bounds.size = labelSize;
    self.chatBubbleLabel.frame = bounds;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_gradLayer setFrame:self.bounds];
    [CATransaction commit];
}

+ (CGFloat)heightWithText:(NSString *)string tableView:(UITableView *)tableView {
    
    CGSize size = CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX);
    size.width -= (_maxIconSize.width + _margin * 2);
    
    CGFloat height = [CTChatBubbleLabel heightWithString:string fits:size].height;
    height = MAX(height, _maxIconSize.height);
    height += _marginTop;
    return height;
}

+ (CGFloat)estimatedHeightWithText:(NSString *)string tableView:(UITableView *)tableView {
    // Size 25 * 25
    return (string.length * 25.f) / (tableView.frame.size.width - _maxIconSize.width - _margin * 2) * 25;
}

+ (CGFloat)heightWithAttributeString:(NSAttributedString *)string iconSize:(CGSize)iconSize tableView:(UITableView *)tableView {
    CGFloat height = [string boundingRectWithSize:CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX) options:0 context:nil].size.height;
    height += 12.f;
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if ([self.chatBubbleLabel.layer animationForKey:@"transformAnimation"]) {
        return;
    }
    if (!selected) {
        return;
    }
    
    CGRect frame = self.chatBubbleLabel.frame;
    CGFloat scale;
    if (frame.size.height < frame.size.width) {
        scale = MIN((frame.size.height + 5.f) / frame.size.height, 1.1f);
    } else {
        scale = MIN((frame.size.width + 5.f) / frame.size.width, 1.1f);
    }
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DTranslate(CATransform3DMakeScale(1.2, 1.1, 1.0), 10, -4, 0)];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
    transformAnimation.beginTime = CACurrentMediaTime();
    transformAnimation.duration = 0.35f;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.autoreverses = YES;
    
    [self.chatBubbleLabel.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
}

- (CAGradientLayer *)gradLayer {
    if (!_gradLayer) {
        _gradLayer = [CAGradientLayer layer];
        [_gradLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
        [_gradLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
        [_gradLayer setFrame:self.bounds];
        
        NSArray *colors = @[
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor]
                            ];
        [_gradLayer setColors:colors];
    }
    return _gradLayer;
}

- (void)setGradientBegain:(CGFloat)begain end:(CGFloat)end {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradLayer.locations = @[@(0.0), @(begain), @(end),  @(1.0)];
    [self.layer setMask:self.gradLayer];
    [CATransaction commit];
}

@end
