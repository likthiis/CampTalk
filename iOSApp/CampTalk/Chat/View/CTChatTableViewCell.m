//
//  CTChatTableViewCell.m
//  CampTalk
//
//  Created by kikilee on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatTableViewCell.h"
#import <RGUIKit/RGUIKit.h>
#import "RGBubbleView.h"
#import "UIImageView+RGGif.h"

static CGSize _maxIconSize = {40, 40};
static CGFloat _chatCelIIconWidth = 40;

static CGFloat _margin = 15;
static CGFloat _marginBubble = 4.f;

static CGFloat _marginTop = 20;

NSString * const CTChatTableViewCellId = @"kCTChatTableViewCellId";

@interface CTChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet RGBubbleView *thumbWapper;

@end

@implementation CTChatTableViewCell

+ (void)registerForTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CTChatTableViewCellId];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.chatBubbleLabel.layer.anchorPoint = CGPointMake(0, 1);
    self.thumbWapper.layer.anchorPoint = CGPointMake(0, 1);
}

- (void)setIconImage:(UIImage *)iconImage {
    if (_myDirection) {
        _iconImage = [iconImage rg_imageFlippedForRightToLeftLayoutDirection];
    } else {
        _iconImage = iconImage;
    }
    self.iconView.image = _iconImage;
}

- (void)setMyDirection:(BOOL)myDirection {
    if (_myDirection == myDirection) {
        return;
    }
    _myDirection = myDirection;
    self.chatBubbleLabel.bubbleRightToLeft = myDirection;
    self.thumbWapper.bubbleRightToLeft = myDirection;
    [self.contentView setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGFloat height = bounds.size.height;
    
    // 头像布局，头像宽不超出 _chatCelIIconWidth，高度不超出父视图的高度，否则按比例缩放头像至全部显示
    
    CGSize iconSize = [CTChatTableViewCell imageSizeThatFits:CGSizeMake(_chatCelIIconWidth, height) imageSize:self.iconView.image.rg_logicSize];
    
    self.iconView.frame =
    CGRectMake(
               _margin + (_chatCelIIconWidth - iconSize.width) / 2.f,
               bounds.size.height - iconSize.height,
               iconSize.width,
               iconSize.height
               );
    
    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, _chatCelIIconWidth + _margin + _marginBubble, 0, _margin));
    
    if (self.displayThumb) {
        //图片布局
        bounds.size = [CTChatTableViewCell imageSizeThatFits:CGSizeMake(bounds.size.width, height - _marginTop) imageSize:self.thumbView.image.rg_logicSize];
        
        UIEdgeInsets bubbleEdge = self.thumbWapper.contentViewEdge;
        if (self.thumbWapper.bubbleRightToLeft) {
            CGFloat left = bubbleEdge.left;
            bubbleEdge.left = bubbleEdge.right;
            bubbleEdge.right = left;
        }
        
        if (bubbleEdge.left * 4 <= self.thumbView.image.rg_logicSize.width) {
            [self.thumbWapper.backgroundView addSubview:self.thumbView];
            
            bounds.origin.y = self.bounds.size.height - bounds.size.height;
            self.thumbWapper.frame = bounds;
            self.thumbView.frame = self.thumbWapper.backgroundView.bounds;
            
        } else {
            [self.thumbWapper.contentView addSubview:self.thumbView];
            
            bounds.size.width += (bubbleEdge.left + bubbleEdge.right);
            bounds.size.height += (bubbleEdge.top + bubbleEdge.bottom);
            bounds.origin.y = self.bounds.size.height - bounds.size.height;
            
            self.thumbWapper.frame = bounds;
            self.thumbView.frame = self.thumbWapper.contentView.bounds;
        }
        
        self.chatBubbleLabel.hidden = YES;
        self.thumbWapper.hidden = NO;
        
    } else {
        
        //文字布局
        CGSize labelSize = [self.chatBubbleLabel sizeThatFits:bounds.size];
//        if (bounds.size.height - _maxIconSize.height - _marginTop < 1e-7) {
//            labelSize = [self.chatBubbleLabel sizeThatFits:bounds.size];
//        } else {
//            labelSize = bounds.size;
//            labelSize.height -= _marginTop;
//        }
        
        bounds.origin.y = bounds.size.height - labelSize.height;
        bounds.size = labelSize;
        self.chatBubbleLabel.frame = bounds;
        
        self.chatBubbleLabel.hidden = NO;
        self.thumbWapper.hidden = YES;
    }
    
    if (self.myDirection) {
        [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj rg_setFrameToFitRTL];
        }];
    }
}

- (BOOL)displayThumb {
    return self.thumbView.image != nil;
}

+ (CGSize)imageSizeThatFits:(CGSize)size imageSize:(CGSize)imageSize {
    
    CGFloat scale = size.width / imageSize.width;
    if (scale < 1.f) {
        if (imageSize.height * scale > size.height) {
            scale = size.height / imageSize.height;
        }
        imageSize.height *= scale;
        imageSize.width *= scale;
    } else {
        scale = size.height / imageSize.height;
        if (scale < 1.f) {
            if (imageSize.width * scale > size.width) {
                scale = size.width / imageSize.width;
            }
            imageSize.height *= scale;
            imageSize.width *= scale;
        }
    }
    return imageSize;
}

+ (CGFloat)heightWithText:(NSString *)string tableView:(UITableView *)tableView {
    
    CGSize size = CGSizeMake(tableView.frame.size.width, CGFLOAT_MAX);
    size.width -= (_maxIconSize.width + _margin * 2 + _marginBubble);
    
    CGFloat height = [CTChatBubbleLabel heightWithString:string fits:size].height;
    height = MAX(height, _maxIconSize.height);
    height += _marginTop;
    return height;
}

+ (CGFloat)estimatedHeightWithText:(NSString *)string tableView:(UITableView *)tableView {
    // Size 25 * 25
    return (string.length * 25.f) / (tableView.frame.size.width - _maxIconSize.width - _margin * 2 - _marginBubble) * 25;
}

+ (CGFloat)heightWithThumbSize:(CGSize)thumbSize tableView:(UITableView *)tableView {
    
    CGFloat scale = [UIScreen mainScreen].scale;
    thumbSize.height /= scale;
    thumbSize.width /= scale;
    
    CGSize fits = CGSizeMake((tableView.frame.size.width - _maxIconSize.width - _margin * 2 - _marginBubble), 200.f);
    fits.height = [self imageSizeThatFits:fits imageSize:thumbSize].height;
    fits.height = MAX(fits.height, _maxIconSize.height);
    return fits.height + _marginTop ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if ([self.chatBubbleLabel.layer animationForKey:@"transformAnimation"]) {
        return;
    }
    if ([self.thumbWapper.layer animationForKey:@"transformAnimation"]) {
        return;
    }
    if (!selected) {
        return;
    }
    
    UIView *animateView = self.displayThumb ? self.thumbWapper : self.chatBubbleLabel;
    
    CGRect frame = animateView.frame;
    CGFloat scale;
    if (frame.size.height < frame.size.width) {
        scale = MIN((frame.size.height + 5.f) / frame.size.height, 1.1f);
    } else {
        scale = MIN((frame.size.width + 5.f) / frame.size.width, 1.1f);
    }
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
    transformAnimation.beginTime = CACurrentMediaTime();
    transformAnimation.duration = 0.35f;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.autoreverses = YES;
    
    if (_myDirection) {
        CGPoint position = animateView.layer.position;
        position.x = CGRectGetMaxX(animateView.frame);
        animateView.layer.anchorPoint = CGPointMake(1, 1);
        animateView.layer.position = position;
    } else {
        CGPoint position = animateView.layer.position;
        position.x = CGRectGetMinX(animateView.frame);
        animateView.layer.anchorPoint = CGPointMake(0, 1);
        animateView.layer.position = position;
    }
    [animateView.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbView.image = nil;
    self.chatBubbleLabel.label.text = nil;
    [self setNeedsLayout];
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *hitView = [super hitTest:point withEvent:event];
//    if (hitView == self || hitView == self.contentView) {
//        return nil;
//    }
//    return hitView;
//}

@end
