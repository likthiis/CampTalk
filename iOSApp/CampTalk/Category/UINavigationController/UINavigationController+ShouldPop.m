//
//  UINavigationController+ShouldPop.m
//  JusTalk
//
//  Created by juphoon on 2018/3/21.
//  Copyright © 2018年 juphoon. All rights reserved.
//

#import "UINavigationController+ShouldPop.h"
#import <objc/runtime.h>

NSString *kOriginalDelegate = @"kOriginalDelegate";
NSString *kInteractiveViewController = @"kInteractiveViewController";

@interface UINavigationController () <UIGestureRecognizerDelegate>

@end

@implementation UINavigationController (ShouldPop)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSel = @selector(navigationBar:shouldPopItem:);
        SEL swizzledSel = @selector(jt_navigationBar:shouldPopItem:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSel);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSel);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSel,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSel,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    objc_setAssociatedObject(self, kOriginalDelegate.UTF8String, self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
    self.interactivePopGestureRecognizer.delegate = self;
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(__interactivePopState:)];
}

- (void)__interactivePopState:(UIScreenEdgePanGestureRecognizer *)interactivePopGestureRecognizer {
    
    NSInteger result = -1;
    
    switch (interactivePopGestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:
            result = 1;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            result = 0;
            break;
        default:
            break;
    }
    
    if (result >= 0) {
        
        UIViewController *vc = objc_getAssociatedObject(self, kInteractiveViewController.UTF8String);
        objc_setAssociatedObject(self, kInteractiveViewController.UTF8String, 0, OBJC_ASSOCIATION_ASSIGN);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIView *animateView = vc.view;
            while (animateView.layer.animationKeys.count == 0) {
                animateView = animateView.superview;
            }
            __block CGFloat duration = 0.f;
            [animateView.layer.animationKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CAAnimation *animation = [animateView.layer animationForKey:obj];
                duration = MAX(animation.duration, duration);
            }];
            duration += 0.05f;
            
            void(^callBack)(void) = ^{
                if (vc && [vc conformsToProtocol:@protocol(UINavigationControllerShouldPopDelegate)]) {
                    if ([vc respondsToSelector:@selector(navigationController:interactivePopResult:)]) {
                        [(id <UINavigationControllerShouldPopDelegate>)vc navigationController:self interactivePopResult:self.topViewController != vc];
                    }
                }
            };
            
            if (duration == 0.f) {
                callBack();
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    callBack();
                });
            }
        });
    }
}

- (BOOL)jt_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *vc = self.topViewController;
    if (item != vc.navigationItem) {
        return YES;
    }
    
    if ([vc conformsToProtocol:@protocol(UINavigationControllerShouldPopDelegate)]) {
        if ([vc respondsToSelector:@selector(navigationControllerShouldPop:isInteractive:)]) {
            if ([(id <UINavigationControllerShouldPopDelegate>)vc navigationControllerShouldPop:self isInteractive:NO]) {
                return [self jt_navigationBar:navigationBar shouldPopItem:item];
            } else {
                return NO;
            }
        }
    }
    return [self jt_navigationBar:navigationBar shouldPopItem:item];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        
        UIViewController *vc = self.topViewController;
        
        if ([vc conformsToProtocol:@protocol(UINavigationControllerShouldPopDelegate)]) {
            if ([vc respondsToSelector:@selector(navigationControllerShouldPop:isInteractive:)]) {
                if (![(id <UINavigationControllerShouldPopDelegate>)vc navigationControllerShouldPop:self isInteractive:YES]) {
                    return NO;
                }
            }
        }
        objc_setAssociatedObject(self, kInteractiveViewController.UTF8String, vc, OBJC_ASSOCIATION_ASSIGN);
        id<UIGestureRecognizerDelegate> originalDelegate = objc_getAssociatedObject(self, kOriginalDelegate.UTF8String);
        return [originalDelegate gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originalDelegate = objc_getAssociatedObject(self, kOriginalDelegate.UTF8String);
        return [originalDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate> originalDelegate = objc_getAssociatedObject(self, kOriginalDelegate.UTF8String);
        return [originalDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return YES;
}

@end
