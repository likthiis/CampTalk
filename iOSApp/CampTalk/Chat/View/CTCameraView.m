//
//  CTCameraView.m
//  CampTalk
//
//  Created by renge on 2018/4/28.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTCameraView.h"
#import "UIImage+Tint.h"

NSString * const kRecordCenter = @"kRecordCenter";

static CGPoint __recordCenter; // [0,1]

@interface CTCameraView ()

@property (nonatomic, assign) BOOL didGetCenter;
@property (nonatomic, assign) CGPoint buttonCenter; // [0,1]

@property (nonatomic, assign) CGPoint moveCenter;

@property (nonatomic, assign) BOOL ignoreLayout;

@end

@implementation CTCameraView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.superview) {
        return;
    }
    if (_ignoreLayout) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *centerData = [[NSUserDefaults standardUserDefaults] dataForKey:kRecordCenter];
        [centerData getBytes:&__recordCenter length:sizeof(__recordCenter)];
    });
    
    if (!_didGetCenter) {
        _didGetCenter = YES;
        _buttonCenter = __recordCenter;
    }
    
    if (_buttonCenter.x == INFINITY) {
        _buttonCenter.x = 0;
    }
    if (_buttonCenter.y == INFINITY) {
        _buttonCenter.y = 0;
    }
    
    CGRect bounds = self.bounds;
    
    CGPoint center = CGPointMake(_buttonCenter.x * bounds.size.width, _buttonCenter.y * bounds.size.height);
    _cameraButton.center = center;
    
    CGFloat offSetX = 0.f;
    if (_cameraButton.frame.origin.x < bounds.origin.x) {
        offSetX = bounds.origin.x - _cameraButton.frame.origin.x;
    } else if (CGRectGetMaxX(_cameraButton.frame) > CGRectGetMaxX(bounds)) {
        offSetX = CGRectGetMaxX(bounds) - CGRectGetMaxX(_cameraButton.frame);
    }
    
    CGFloat offSetY = 0.f;
    if (_cameraButton.frame.origin.y < bounds.origin.y) {
        offSetY = bounds.origin.y - _cameraButton.frame.origin.y;
    } else if (CGRectGetMaxY(_cameraButton.frame) > CGRectGetMaxY(bounds)) {
        offSetY = CGRectGetMaxY(bounds) - CGRectGetMaxY(_cameraButton.frame);
    }
    
    center.x += offSetX;
    center.y += offSetY;
    _cameraButton.center = center;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [self createButton];
        self.tintColor = [UIColor blackColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        pan.delaysTouchesBegan = YES;
        [_cameraButton addGestureRecognizer:pan];
        
        [_cameraButton addTarget:self action:@selector(cameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)createButton {
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *icon = [[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cameraButton setBackgroundImage:icon forState:UIControlStateNormal];
    [cameraButton sizeToFit];
    return cameraButton;
}

- (void)cameraAction:(UIButton *)sender {
    [self showCameraButton];
    [self performSelector:@selector(hideCameraButton) withObject:nil afterDelay:1];
    if ([self.delegate respondsToSelector:@selector(cameraView:didTapButton:)]) {
        [self.delegate cameraView:self didTapButton:sender];
    }
}

- (void)hideCameraButton {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCameraButton) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCameraButton) object:nil];
    
    if (self.cameraButton.tag == 1) {
        return;
    }
    self.cameraButton.tag = 1;
    
    [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.cameraButton.alpha = 0.2f;
    } completion:nil];
}

- (void)showCameraButtonWithAnimate:(BOOL)animate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCameraButton) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCameraButton) object:nil];
    
    if (self.cameraButton.tag == 2) {
        return;
    }
    self.cameraButton.tag = 2;
    
    if (animate) {
        [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.cameraButton.alpha = 1.f;
        } completion:nil];
    } else {
        self.cameraButton.alpha = 1.f;
    }
}

- (void)showCameraButton {
    [self showCameraButtonWithAnimate:YES];
}

- (void)move:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self showCameraButton];
            _moveCenter = [recognizer translationInView:self];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recognizer translationInView:self];
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
            [recognizer setTranslation:CGPointZero inView:self];
            _moveCenter = recognizer.view.center;
            if ([_delegate respondsToSelector:@selector(cameraView:didDragButton:)]) {
                [_delegate cameraView:self didDragButton:self.cameraButton];
            }
            break;
        }
        default: {
            
            _ignoreLayout = YES;
            
            void(^layout)(BOOL recover) = ^(BOOL recover) {
                
                if (recover) {
                    [self.cameraButton sizeToFit];
                } else {
                    [self setCameraButtonCenterPoint:self.moveCenter];
                }
                
                self.ignoreLayout = NO;
                
                [UIView animateWithDuration:0.3 delay:0.5 options:0 animations:^{
                    [self setNeedsLayout];
                    [self layoutIfNeeded];
                } completion:nil];
                [self performSelector:@selector(hideCameraButton) withObject:nil afterDelay:1];
            };
            
            if ([_delegate respondsToSelector:@selector(cameraView:endDragButton:layoutBlock:)]) {
                [_delegate cameraView:self endDragButton:self.cameraButton layoutBlock:layout];
            } else {
                layout(NO);
            }
            break;
        }
    }
}

- (void)setCameraButtonCenterPoint:(CGPoint)center {
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        return;
    }
    self.buttonCenter = CGPointMake(center.x / self.bounds.size.width, center.y / self.bounds.size.height);
}

- (void)setButtonCenter:(CGPoint)buttonCenter {
    _buttonCenter = buttonCenter;
    __recordCenter = buttonCenter;
    
    NSData * centerData = [[NSData alloc] initWithBytes:&_buttonCenter length:sizeof(_buttonCenter)];
    [[NSUserDefaults standardUserDefaults] setObject:centerData forKey:kRecordCenter];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == _cameraButton) {
        return _cameraButton;
    }
    return nil;
}

- (UIButton *)copyCameraButton {
    return [self createButton];
}

- (void)showInView:(UIView *)superView {
    
    self.frame = superView.bounds;
    
    [self addSubview:self.cameraButton];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [superView addSubview:self];
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
