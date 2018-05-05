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

static CGFloat _chatLabelVerticalMargin = 5.f;
static CGFloat _chatLabelVerticalMargin_2 = 10.f;

static CGFloat _chatLabelHorizontalMargin = 5.f;
static CGFloat _chatLabelHorticalMargin_2 = 10.f;

static UIEdgeInsets _boundsInsets = {kChatLabelBubbleBorder, kChatLabelBubbleBorder + kChatLabelTriangleWidth, kChatLabelBubbleBorder, kChatLabelBubbleBorder};
static UIEdgeInsets _bubbleInsets;

static UIFont *_chatBubbleLabelFont;

@implementation CTChatBubbleLabel

+ (void)load {
    [super load];
    
    CGFloat top = _chatLabelVerticalMargin;
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 9) { // iOS 8.1 上 文字显示不正确，多给些空间
        _chatLabelVerticalMargin += 1.f;
        _chatLabelVerticalMargin_2 += 2.f;
    }
    _bubbleInsets = UIEdgeInsetsMake(top, _chatLabelHorizontalMargin - 1, top, _chatLabelHorizontalMargin + 1); // 切图没切好，需要手动将label向左移动1个像素
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunguarded-availability"
    _chatBubbleLabelFont = [UIFont systemFontOfSize:16.f weight:UIFontWeightThin];
    #pragma clang diagnostic pop
}

+ (CGSize)heightWithString:(NSString *)string fits:(CGSize)size {
    
    CGSize changedSize = size;
    changedSize = [CTChatBubbleLabel adjustSize:changedSize addtion:NO];
    changedSize = [string boundingRectWithSize:changedSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _chatBubbleLabelFont} context:nil].size;
    changedSize = [CTChatBubbleLabel adjustSize:changedSize addtion:YES];
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
    CGSize size = [CTChatBubbleLabel adjustSize:self.label.frame.size addtion:YES];
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize changedSize = [CTChatBubbleLabel adjustSize:size addtion:NO];
    
    if (changedSize.height < 0 || changedSize.width < 0) {
        return size;
    }
    
    changedSize = [self.label sizeThatFits:changedSize];
    changedSize = [CTChatBubbleLabel adjustSize:changedSize addtion:YES];
    return changedSize;
}

+ (CGSize)adjustSize:(CGSize)changedSize addtion:(BOOL)addtion {
    if (addtion) {
        changedSize.height += _boundsInsets.top + _boundsInsets.bottom + _chatLabelVerticalMargin_2;
        changedSize.width += _boundsInsets.left + _boundsInsets.right + _chatLabelHorticalMargin_2;
    } else {
        changedSize.height -= _boundsInsets.top + _boundsInsets.bottom + _chatLabelVerticalMargin_2;
        changedSize.width -= _boundsInsets.left + _boundsInsets.right + _chatLabelHorticalMargin_2;
    }
    return changedSize;
}

@end
