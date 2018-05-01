//
//  CTChatInputView.m
//  CampTalk
//
//  Created by kikilee on 2018/4/22.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatInputView.h"
#import "UIView+PanGestureHelp.h"

@implementation CTChatInputViewToolBarItem

+ (CTChatInputViewToolBarItem *)itemWithIcon:(UIView *)icon identifier:(NSInteger)identifier {
    CTChatInputViewToolBarItem *item = [[CTChatInputViewToolBarItem alloc] init];
    item.icon = icon;
    item.identifier = identifier;
    return item;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[self class]]) {
        CTChatInputViewToolBarItem *other = (CTChatInputViewToolBarItem *)object;
        if (self.identifier == other.identifier) {
            return YES;
        }
    }
    return [super isEqual:object];
}

@end

static UIEdgeInsets kCTChatInputInset = {8,5,5,5};
static CGFloat kToolBarHeight = 40.f;
static CGFloat kSendButtonSide = 50.f;

@interface CTChatInputView () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat backgroundAlpha;
@property (nonatomic, strong) UIView *noBorderView;

@property (nonatomic, assign) BOOL ignoreToolBarLayout;

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

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *view = [super hitTest:point withEvent:event];
//    if (view == self) {
//        return self;
//    }
//    return <#expression#>
//}

- (NSMutableArray<CTChatInputViewToolBarItem *> *)toolBarItems {
    if (!_toolBarItems) {
        _toolBarItems = [NSMutableArray array];
    }
    return _toolBarItems;
}

- (void)__config {
//    _noBorderView = [UIView new];
//    _noBorderView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(4, 4, 4, 4));
//    _noBorderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self addSubview:_noBorderView];
    
    self.userInteractionEnabled = YES;
    self.tintColor = [UIColor whiteColor];
    
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
    _actionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
    
    _actionButton.frame = CGRectMake(bounds.size.width - 18.f - kSendButtonSide, (bounds.size.height - self.__toolBarHeight - kSendButtonSide) / 2.f, kSendButtonSide, kSendButtonSide);
    _actionButton.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize textSize = CGSizeMake(CGRectGetMinX(_actionButton.frame) - kCTChatInputInset.left - kCTChatInputInset.right, CGFLOAT_MAX);
    textSize.height = [_textView sizeThatFits:textSize].height;
    
    textSize.height =
    MIN(textSize.height,
        _maxContentHeight - kCTChatInputInset.top - kCTChatInputInset.bottom - self.__toolBarHeight
        );
    
    _textView.frame = CGRectMake(kCTChatInputInset.left, (bounds.size.height - self.__toolBarHeight - textSize.height) / 2.f, textSize.width, textSize.height);
    
    [self textViewDidChange:_textView];
    [_textView scrollRangeToVisible:NSMakeRange(0, _textView.text.length)];
    
    if (!_ignoreToolBarLayout && self.toolBarItems.count) {
        __block CGFloat layoutX = kCTChatInputInset.left;
        CGFloat layoutY = CGRectGetMaxY(_textView.frame);
        
        [self.toolBarItems enumerateObjectsUsingBlock:^(CTChatInputViewToolBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.icon.superview == self) {
                obj.icon.frame = CGRectMake(layoutX, layoutY, kToolBarHeight, kToolBarHeight);
            }
            layoutX += kToolBarHeight + 5.f;
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self __configBackgroundAlphaWithAnimate:YES];
    [self updateContentHeight];
}

- (void)updateContentHeight {
    CGFloat contentHeight = self.textView.contentSize.height + kCTChatInputInset.top + kCTChatInputInset.bottom + self.__toolBarHeight;
    contentHeight = MIN(contentHeight, _maxContentHeight);
    contentHeight = MAX(contentHeight, kSendButtonSide);
    
    if (fabs(contentHeight - _contentHeight) < 1e-7) {
        return;
    }
    _contentHeight = contentHeight;
    if ([self.delegate respondsToSelector:@selector(contentSizeDidChange:size:)]) {
        [self.delegate contentSizeDidChange:self size:CGSizeMake(self.bounds.size.width, _contentHeight)];
    }
    [self setNeedsLayout];
}

- (CGFloat)__toolBarHeight {
    return _toolBarItems.count > 0 ? kToolBarHeight : 0;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self __configBackgroundAlphaWithAnimate:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self __configBackgroundAlphaWithAnimate:YES];
}

- (void)__configBackgroundAlphaWithAnimate:(BOOL)animate {
    
    UIColor *tintColor = nil;
    if (_textView.text.length || _textView.isFirstResponder) {
        if (_backgroundAlpha == 1.f) {
            return;
        }
        _backgroundAlpha = 1.f;
        tintColor = [UIColor whiteColor];
    } else {
        if (_backgroundAlpha == 0.1f) {
            return;
        }
        _backgroundAlpha = 0.1f;
        tintColor = [UIColor blackColor];
    }
    
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_backgroundView.alpha = self->_backgroundAlpha;
            self.tintColor = tintColor;
        }];
    } else {
        _backgroundView.alpha = _backgroundAlpha;
        self.tintColor = tintColor;
    }
}

#pragma mark - tool bar

- (void)addToolBarItem:(CTChatInputViewToolBarItem *)item {
    if (![self.toolBarItems containsObject:item]) {
        [self.toolBarItems addObject:item];
        [self addSubview:item.icon];
        [self setNeedsLayout];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.delegate = self;
        [item.icon addGestureRecognizer:longPress];
        
        item.icon.tintColor = nil;
    }
}

- (void)removeToolBarItemWithId:(NSInteger)identifier {
    NSInteger index = [self containToolBarItemWithId:identifier];
    if (index != NSNotFound) {
        CTChatInputViewToolBarItem *item = [self.toolBarItems objectAtIndex:index];
        if (item.icon.superview == self) {
            [item.icon removeFromSuperview];
        }
        [self.toolBarItems removeObjectAtIndex:index];
        [self setNeedsLayout];
    }
}

- (void)removeAllToolBarItem {
    [self.toolBarItems enumerateObjectsUsingBlock:^(CTChatInputViewToolBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.icon removeFromSuperview];
    }];
    [self.toolBarItems removeAllObjects];
    [self setNeedsLayout];
}

- (NSInteger)containToolBarItemWithId:(NSInteger)identifier {
    __block NSInteger index = NSNotFound;
    [self.toolBarItems enumerateObjectsUsingBlock:^(CTChatInputViewToolBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.identifier == identifier) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)updateInputViewDragIcon:(UIView *)dragIcon toolId:(NSInteger)toolId copyIconBlock:(UIView *(^)(void))copyIconBlock {
    CGRect frame = [dragIcon convertRect:dragIcon.bounds toView:self.superview];
    BOOL add = CGRectIntersectsRect(frame, self.frame);
    if (add) {
        if ([self containToolBarItemWithId:toolId] == NSNotFound) {
            CTChatInputViewToolBarItem *item = [CTChatInputViewToolBarItem itemWithIcon:copyIconBlock() identifier:toolId];
            item.icon.alpha = 0.f;
            [self addToolBarItem:item];
        }
    } else {
        [self removeToolBarItemWithId:toolId];
    }
}

- (void)addOrRemoveInputViewToolBarWithDragIcon:(UIView *)dragIcon toolId:(NSInteger)toolId copyIconBlock:(UIView *(^)(void))copyIconBlock customAnimate:(void(^)(void))customAnimate completion:(void(^)(BOOL added))completion {
    
    CGRect frame = [dragIcon convertRect:dragIcon.bounds toView:self.superview];
    BOOL add = CGRectIntersectsRect(frame, self.frame);
    if (add) {
        if ([self containToolBarItemWithId:toolId] == NSNotFound) {
            CTChatInputViewToolBarItem *item = [CTChatInputViewToolBarItem itemWithIcon:copyIconBlock() identifier:toolId];
            [self addToolBarItem:item];
        }
        
        NSInteger index = [self containToolBarItemWithId:toolId];
        CTChatInputViewToolBarItem *item = self.toolBarItems[index];
        
        CGRect frame = [dragIcon convertRect:dragIcon.bounds toView:self];
        item.icon.frame = frame;
        item.icon.tintColor = dragIcon.tintColor;
        item.icon.alpha = 1.f;
        
        BOOL recordHide = dragIcon.hidden;
        dragIcon.hidden = YES;
        
        [UIView animateWithDuration:0.6 animations:^{
            
            item.icon.tintColor = nil;
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            if (customAnimate) {
                customAnimate();
            }
            
        } completion:^(BOOL finished) {
            dragIcon.hidden = recordHide;
            if (completion) {
                completion(YES);
            }
        }];
    } else {
        [self removeToolBarItemWithId:toolId];
        if (completion) {
            completion(NO);
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    UIView *icon = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _ignoreToolBarLayout = YES;
            [icon startWithPoint:[recognizer locationInView:icon.superview]];
            
            [UIView animateWithDuration:0.3 animations:^{
                [icon centerScale:1.2f];
            }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint newPoint = [recognizer locationInView:icon.superview];
            [icon updateCenterWithNewPoint:newPoint];
            break;
        }
        default: {
            _ignoreToolBarLayout = NO;
            
            __block CTChatInputViewToolBarItem *item = nil;
            [self.toolBarItems enumerateObjectsUsingBlock:^(CTChatInputViewToolBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (icon == obj.icon) {
                    item = obj;
                    *stop = YES;
                }
            }];
            
            if (!item) {
                return;
            }
            
            CGRect frame = [icon convertRect:icon.bounds toView:self.superview];
            BOOL add = CGRectIntersectsRect(frame, self.frame);
            
            if (add) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                }];
            } else {
                
                void(^syncAnimations)(void) = ^{
                    [self removeToolBarItemWithId:item.identifier];
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                };
                
                if ([self.delegate respondsToSelector:@selector(chatInputView:willRemoveItem:syncAnimations:)]) {
                    [self.delegate chatInputView:self willRemoveItem:item syncAnimations:syncAnimations];
                } else {
                    [UIView animateWithDuration:0.3 animations:^{
                        syncAnimations();
                    }];
                }
            }
            break;
        }
    }
}

@end
