//
//  CTMusicButton.m
//  CampTalk
//
//  Created by renge on 2018/4/30.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTMusicButton.h"

NSString *CTMusicAnimationKey = @"CTMusicAnimationKey";

@interface CTMusicButton () <CAAnimationDelegate>

@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) CFTimeInterval startTime;

@end

@implementation CTMusicButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)new {
    return [[CTMusicButton alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIButton *music = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *icon = [[UIImage imageNamed:@"music"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [music setBackgroundImage:icon forState:UIControlStateNormal];
        
        [music addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        music.autoresizingMask = UIViewAutoresizingNone;
        _musicButton = music;
        [self addSubview:music];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateButtonFrame:^(UIButton *music) {
        CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self->_edge);
        CGFloat side = MIN(frame.size.height, frame.size.width);
        frame.size = CGSizeMake(side, side);
        music.frame = frame;
        music.center = CGPointMake(self.bounds.size.width / 2.f, self.bounds.size.height / 2.f);
    }];
}

- (void)setEdge:(UIEdgeInsets)edge {
    _edge = edge;
    [self setNeedsLayout];
}

- (void)click:(UIButton *)sender {
    if (_clickBlock) {
        _clickBlock(self);
    }
}

- (void)sizeToFit {
    [self updateButtonFrame:^(UIButton *music) {
        [music sizeToFit];
        CGRect frame = self.frame;
        frame.size = music.bounds.size;
        self.frame = frame;
    }];
}

- (void)updateButtonFrame:(void(^)(UIButton *music))update {
    if (!update) {
        return;
    }
    
    CATransform3D caRecord = _musicButton.layer.transform;
    _musicButton.layer.transform = CATransform3DIdentity;
    update(_musicButton);
    _musicButton.layer.transform = caRecord;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    [self starAnimationIfNeed];
}

- (void)didMoveToSuperview {
    [self delayStarAnimationIfNeed];
}

- (void)didMoveToWindow {
    [self delayStarAnimationIfNeed];
}

- (void)starAnimationIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(starAnimationIfNeed) object:nil];
    if (!_isPlaying) {
        [self stopAnimation];
        return;
    }
    
    if (!self.superview) {
        [self stopAnimation];
        return;
    }
    
    if (!self.window) {
        [self stopAnimation];
        return;
    }
    
    if (_isAnimating) {
        return;
    }

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.byValue = @(2 * M_PI);
    animation.duration = 3;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = 0;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    
    _isAnimating = YES;
    [_musicButton.layer addAnimation:animation forKey:CTMusicAnimationKey];
}

- (void)stopAnimation {
    if ([_musicButton.layer animationForKey:CTMusicAnimationKey]) {
        [_musicButton.layer removeAnimationForKey:CTMusicAnimationKey];
    }
    _isAnimating = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (![anim isKindOfClass:[CABasicAnimation class]]) {
        return;
    }
    
    [self stopAnimation];
    
    if (!flag) {
        if (_startTime > 0) {
            CFTimeInterval endTime = [_musicButton.layer convertTime:CACurrentMediaTime() fromLayer:nil];
            CGFloat offSet = endTime - _startTime;
            if (offSet > 0) {
                CGFloat progress = (endTime - _startTime) / 3.f;
                if (fabs(1 - progress) < 1e-4) {
                    progress = 1.f;
                }
                CATransform3D transform = _musicButton.layer.transform;
                _musicButton.layer.transform = CATransform3DRotate(transform, progress * 2 * M_PI, 0, 0, 1);
            }
        }
        NSLog(@"music animate stop");
        [self delayStarAnimationIfNeed];
    } else {
        [self starAnimationIfNeed];
    }
}

- (void)delayStarAnimationIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(starAnimationIfNeed) object:nil];
    [self performSelector:@selector(starAnimationIfNeed) withObject:nil afterDelay:0.2f inModes:@[NSRunLoopCommonModes]];
}

- (void)animationDidStart:(CAAnimation *)anim {
    _startTime = [_musicButton.layer convertTime:CACurrentMediaTime() fromLayer:nil];
}

- (void)dealloc {
    NSLog(@"CTMusic Dealloc");
}

@end
