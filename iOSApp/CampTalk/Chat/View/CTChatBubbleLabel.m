//
//  CTChatBubbleLabel.m
//  CampTalk
//
//  Created by LD on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatBubbleLabel.h"

#define kChatLabelTriangleWidth (12)
#define kChatLabelBubbleBorder (3)

static CGFloat _chatLabelMargin = 5.f;
static CGFloat _chatLabelMargin_2 = 10.f;

static UIEdgeInsets _boundsInsets = {kChatLabelBubbleBorder, kChatLabelBubbleBorder + kChatLabelTriangleWidth, kChatLabelBubbleBorder, kChatLabelBubbleBorder};
static UIEdgeInsets _bubbleInsets;

static UIFont *_chatBubbleLabelFont;

@implementation CTChatBubbleLabel

+ (void)load {
    [super load];
    
    _bubbleInsets = UIEdgeInsetsMake(_chatLabelMargin, _chatLabelMargin - 1, _chatLabelMargin, _chatLabelMargin + 1); // 切图没切好，需要手动将label向左移动1个像素
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunguarded-availability"
    _chatBubbleLabelFont = [UIFont systemFontOfSize:16.f weight:UIFontWeightThin];
    #pragma clang diagnostic pop
}

+ (CGSize)heightWithString:(NSString *)string fits:(CGSize)size {
    
    CGSize changedSize = size;
    
    changedSize.height -= _boundsInsets.top + _boundsInsets.bottom + _chatLabelMargin_2;
    changedSize.width -= _boundsInsets.left + _boundsInsets.right + _chatLabelMargin_2;
    
    changedSize = [string boundingRectWithSize:changedSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _chatBubbleLabelFont} context:nil].size;
    
    changedSize.height += _boundsInsets.top + _boundsInsets.bottom + _chatLabelMargin_2;
    changedSize.width += _boundsInsets.left + _boundsInsets.right + _chatLabelMargin_2;
    
    return changedSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configBubbleView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configBubbleView];
}

- (void)configBubbleView {
    
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *bubble = [UIImage imageNamed:@"bubble_bg"];
    
    UIEdgeInsets cap = UIEdgeInsetsMake(kChatLabelBubbleBorder, kChatLabelTriangleWidth, bubble.size.height - kChatLabelBubbleBorder, kChatLabelBubbleBorder);
    
    bubble = [bubble resizableImageWithCapInsets:cap resizingMode:UIImageResizingModeTile];
    
    _bubbleView = [[UIImageView alloc] initWithImage:bubble highlightedImage:bubble];
    _bubbleView.frame = self.bounds;
    _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_bubbleView];
    
    _label = [[RGBorderLabel alloc] init];
    _label.numberOfLines = 0;
    _label.font = _chatBubbleLabelFont;
    [self addSubview:_label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    bounds = UIEdgeInsetsInsetRect(bounds, _boundsInsets);
    bounds = UIEdgeInsetsInsetRect(bounds, _bubbleInsets);
    self.label.frame = bounds;
}

- (void)sizeToFit {
    [self.label sizeToFit];
    CGSize size = self.label.frame.size;
    size.height += _boundsInsets.top + _boundsInsets.bottom + _chatLabelMargin_2;
    size.width += _boundsInsets.left + _boundsInsets.right + _chatLabelMargin_2;
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize changedSize = size;
    changedSize.height -= _boundsInsets.top + _boundsInsets.bottom + _chatLabelMargin_2;
    changedSize.width -= _boundsInsets.left + _boundsInsets.right + _chatLabelMargin_2;
    
    if (changedSize.height < 0 || changedSize.width < 0) {
        return size;
    }
    
    changedSize = [self.label sizeThatFits:changedSize];
    
    changedSize.height += _boundsInsets.top + _boundsInsets.bottom + _chatLabelMargin_2;
    changedSize.width += _boundsInsets.left + _boundsInsets.right + _chatLabelMargin_2;
    
    return changedSize;
}

@end
