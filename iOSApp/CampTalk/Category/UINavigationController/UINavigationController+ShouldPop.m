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
}

- (BOOL)jt_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *vc = self.topViewController;
    if (item != vc.navigationItem) {
        return YES;
    }
    
    if ([vc conformsToProtocol:@protocol(UINavigationControllerShouldPopDelegate)]) {
        if ([vc respondsToSelector:@selector(navigationControllerControllerShouldPop:)]) {
            if ([(id <UINavigationControllerShouldPopDelegate>)vc navigationControllerControllerShouldPop:self]) {
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
            if ([vc respondsToSelector:@selector(navigationControllerControllerShouldInteractivePop:)]) {
                if (![(id <UINavigationControllerShouldPopDelegate>)vc navigationControllerControllerShouldInteractivePop:self]) {
                    return NO;
                }
            }
        }
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
