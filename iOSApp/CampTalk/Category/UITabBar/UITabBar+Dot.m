//
//  UITabBar+Dot.m
//  JusTalk
//
//  Created by jiang  hao on 2017/7/6.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UITabBar+Dot.h"
#import "UIImage+Tint.h"
#import "UIView+LayoutHelp.h"
#import <objc/runtime.h>

#define kUITabbarCustomDotTag 1000
#define kUITabbarCustomNormalDotWidth 10
#define kUITabbarCustomWarningDotWidth 18

static const void *kTabBarDotMap = "tabBarDotMap";

@interface UITabBar ()

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIButton *> *tabBarDotMap;

@end

@implementation UITabBar (Dot)

- (NSMutableDictionary <NSNumber *, UIButton *> *)tabBarDotMap {
    return objc_getAssociatedObject(self, kTabBarDotMap);
}

- (void)setTabBarDotMap:(NSMutableDictionary <NSNumber *, UIButton *> *)tabBarDotMap {
    objc_setAssociatedObject(self, kTabBarDotMap, tabBarDotMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showDotWithType:(UITabbarDotType)type atIndex:(NSInteger)index {
    if (!self.items.count) {
        return;
    }
    [self removeBadgeOnItemIndex:index];
    UIButton *badgeView = [[UIButton alloc] init];
    badgeView.tag = kUITabbarCustomDotTag + index;
    badgeView.userInteractionEnabled = NO;
    CGFloat width = kUITabbarCustomNormalDotWidth;
    switch (type) {
        case UITabbarDotTypeNormal:
            break;
        case UITabbarDotTypeWarning:
            width = kUITabbarCustomWarningDotWidth;
            [badgeView setTitle:@"!" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    badgeView.layer.cornerRadius = width / 2;
    badgeView.layer.masksToBounds = YES;
    badgeView.tintColor = [UIColor redColor];
    [badgeView setBackgroundImage:[UIImage templateImageWithSize:CGSizeMake(width, width)] forState:UIControlStateNormal];
    badgeView.titleLabel.textAlignment = NSTextAlignmentCenter;
    badgeView.titleLabel.font = [UIFont systemFontOfSize:13];
    badgeView.adjustsImageWhenHighlighted = NO;
    badgeView.clipsToBounds = YES;
    badgeView.frame = CGRectMake(0, 0, width, width);
    
    if (!self.tabBarDotMap) {
        self.tabBarDotMap = [[NSMutableDictionary alloc] init];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.tabBarDotMap setObject:badgeView forKey:@(index)];
    [self addBadgeView:badgeView atIndex:index];
}

- (BOOL)addBadgeView:(UIButton *)badgeView atIndex:(NSInteger)index {
    
    BOOL didFind = NO;
    
    BOOL layoutLeftToRight = self.layoutLeftToRight;
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            CGFloat tabWidth = subView.frame.size.width;
            NSInteger i = (subView.frame.origin.x + tabWidth / 2.0f) / tabWidth;
            if (!layoutLeftToRight) {
                i = self.items.count - 1 - i;
            }
            if (i == index) {
                [[subView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[UIImageView class]]) {
                        CGFloat x = 0;
                        CGFloat width = badgeView.frame.size.width;
                        
                        if (layoutLeftToRight) {
                            x = CGRectGetWidth(obj.frame) - width / 2;
                        } else {
                            x =  - width / 2;
                        }
                        badgeView.frame = CGRectIntegral(CGRectMake(x, 0, width, width));
                        badgeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                        [obj addSubview:badgeView];
                        *stop = YES;
                    }
                }];
                didFind = YES;
                break;
            }
        }
    }
    return didFind;
}

- (void)hideDotOnItemAtIndex:(NSInteger)index {
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(NSInteger)index {
    NSNumber *key = @(index);
    UIView *badgeView = [self.tabBarDotMap objectForKey:key];
    [badgeView removeFromSuperview];
    [self.tabBarDotMap removeObjectForKey:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"] && object == self) {
        if (self.tabBarDotMap.allKeys.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.tabBarDotMap.allKeys.count > 0) {
                    [self.tabBarDotMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIButton * _Nonnull badgeView, BOOL * _Nonnull stop) {
                        [badgeView removeFromSuperview];
                        [self addBadgeView:badgeView atIndex:key.integerValue];
                    }];
                }
            });
        }
    }
}

- (void)dealloc {
    if (self.tabBarDotMap) {
        [self removeObserver:self forKeyPath:@"frame"];
    }
}

@end
