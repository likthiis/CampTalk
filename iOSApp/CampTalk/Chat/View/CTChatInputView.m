//
//  CTChatInputView.m
//  CampTalk
//
//  Created by kikilee on 2018/4/22.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatInputView.h"

static UIEdgeInsets kCTChatInputInset = {8,5,5,5};

@interface CTChatInputView () <UITextViewDelegate>

@property (nonatomic, assign) CGFloat backgroundAlpha;
@property (nonatomic, strong) UIView *noBorderView;

@end

@implementation CTChatInputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __config];
    }
    return self;
}

- (void)__config {
//    _noBorderView = [UIView new];
//    _noBorderView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(4, 4, 4, 4));
//    _noBorderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self addSubview:_noBorderView];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;;
    _backgroundView.layer.borderWidth = 2.f;
    _backgroundView.layer.cornerRadius = 4.f;
    _backgroundView.clipsToBounds = YES;
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];
//    _backgroundView.image = [[UIImage imageNamed:@"chat_input_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(50, 300, 50, 300) resizingMode:UIImageResizingModeTile];
    [self addSubview:_backgroundView];
    
    _actionButton = [[UIButton alloc] init];
    [_actionButton setImage:[UIImage imageNamed:@"fuzi"] forState:UIControlStateNormal];
    [self addSubview:_actionButton];
    
    _textView = [[UITextView alloc] init];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.showsVerticalScrollIndicator = NO;
    _textView.showsHorizontalScrollIndicator = NO;
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor whiteColor];
//    shadow.shadowBlurRadius = 3.0;
//    shadow.shadowOffset = CGSizeMake(0, 0);
  
    _textView.typingAttributes =
    @{
      NSForegroundColorAttributeName : [UIColor whiteColor],
//      NSForegroundColorAttributeName : [UIColor blackColor],
//      NSShadowAttributeName : shadow,
//      NSStrokeColorAttributeName : [UIColor whiteColor],
//      NSStrokeWidthAttributeName : @(-5),
//      NSKernAttributeName : @(1),
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
      NSFontAttributeName : [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium],
#pragma clang diagnostic pop
      };
    if (@available(iOS 11.0, *)) {
        _textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _textView.tintColor = [UIColor whiteColor];
    _textView.delegate = self;
    [self addSubview:_textView];
    
    _maxContentHeight = 180.f;
    [self __configBackgroundAlphaWithAnimate:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGSize size = [_actionButton sizeThatFits:CGSizeMake(60, bounds.size.height - 10)];
    _actionButton.frame = CGRectMake(bounds.size.width - 18.f - size.width, (bounds.size.height - size.height) / 2.f, size.width, size.height);
    
    CGSize textSize = CGSizeMake(CGRectGetMinX(_actionButton.frame) - kCTChatInputInset.left - kCTChatInputInset.right, CGFLOAT_MAX);
    textSize.height = [_textView sizeThatFits:textSize].height;
    
    if (textSize.height >= _maxContentHeight - kCTChatInputInset.top - kCTChatInputInset.bottom) {
        textSize.height = _maxContentHeight - kCTChatInputInset.top - kCTChatInputInset.bottom;
    }
    _textView.frame = CGRectMake(kCTChatInputInset.left, (bounds.size.height - textSize.height) / 2.f, textSize.width, textSize.height);
    [self textViewDidChange:_textView];
    
    [_textView scrollRangeToVisible:NSMakeRange(0, _textView.text.length)];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    [self __configBackgroundAlphaWithAnimate:YES];
    
    CGFloat contentHeight = textView.contentSize.height + kCTChatInputInset.top + kCTChatInputInset.bottom;
    
    if (fabs(contentHeight - _contentHeight) < 1e-7) {
        return;
    }
    _contentHeight = MIN(contentHeight, _maxContentHeight);
    if ([self.delegate respondsToSelector:@selector(contentSizeDidChange:size:)]) {
        [self.delegate contentSizeDidChange:self size:CGSizeMake(self.bounds.size.width, _contentHeight)];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self __configBackgroundAlphaWithAnimate:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self __configBackgroundAlphaWithAnimate:YES];
}

- (void)__configBackgroundAlphaWithAnimate:(BOOL)animate {
    if (_textView.text.length || _textView.isFirstResponder) {
        if (_backgroundAlpha == 1.f) {
            return;
        }
        _backgroundAlpha = 1.f;
    } else {
        if (_backgroundAlpha == 0.1f) {
            return;
        }
        _backgroundAlpha = 0.1f;
    }
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_backgroundView.alpha = self->_backgroundAlpha;
        }];
    } else {
        _backgroundView.alpha = _backgroundAlpha;
    }
}

@end
