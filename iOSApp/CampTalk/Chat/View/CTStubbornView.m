//
//  CTStubbornView.m
//  CampTalk
//
//  Created by RengeRenge on 2018/4/23.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTStubbornView.h"

@interface CTStubbornView ()

@property (nonatomic, strong) CAGradientLayer *gradLayer;

@property (nonatomic, assign) CGFloat begain;
@property (nonatomic, assign) CGFloat end;

@end

@implementation CTStubbornView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CAGradientLayer *)gradLayer {
    if (!_gradLayer) {
        _gradLayer = [CAGradientLayer layer];
        [_gradLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
        [_gradLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
        [_gradLayer setFrame:self.bounds];
    }
    return _gradLayer;
}

- (void)setGradientBegain:(CGFloat)begain end:(CGFloat)end {
    if (_begain == begain && _end == end) {
        return;
    }
    if (!_gradLayer) {
        NSArray *colors = @[
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            ];
        [self.gradLayer setColors:colors];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.gradLayer.locations = @[@(0.0), @(begain), @(end),  @(1.0)];
    [self.layer setMask:self.gradLayer];
    [CATransaction commit];
    
    _begain = begain;
    _end = end;
}

- (void)setGradientDirection:(BOOL)up {
    if (up) {
        NSArray *colors = @[
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            ];
        [self.gradLayer setColors:colors];
    } else {
        NSArray *colors = @[
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                            ];
        [self.gradLayer setColors:colors];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_gradLayer setFrame:self.bounds];
    [CATransaction commit];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
//        __block BOOL hasLongTap = NO;
//        [event.allTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
//            [obj.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if([obj isKindOfClass:UILongPressGestureRecognizer.class]){
//                    hasLongTap = YES;
//                    *stop = YES;
//                }
//            }];
//            if (hasLongTap) {
//                *stop = YES;
//            }
//        }];
//        if (hasLongTap) {
//            NSLog(@"response");
//            return self;
//        }
//        NSLog(@"no response");
        return nil;
    }
    return hitView;
}

@end
