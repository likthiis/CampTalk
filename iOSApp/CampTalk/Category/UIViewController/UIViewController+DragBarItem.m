//
//  UIViewController+DragBarItem.m
//  CampTalk
//
//  Created by renge on 2018/4/30.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "UIViewController+DragBarItem.h"
#import <RGUIKit/RGUIKit.h>
#import "UIView+PanGestureHelp.h"
#import <objc/runtime.h>

@implementation UIViewController (DragBarItem)

- (void)addRightDragBarItemWithDragIcon:(UIView *)dragIcon
                                 itmeId:(NSInteger)itemId
                        ignoreIntersect:(BOOL)ignoreIntersect
                               copyIcon:(NS_NOESCAPE UIView *(^)(void))copyIcon
                            syncAnimate:(void (^)(UIView *))syncAnimate
                             completion:(void (^)(BOOL))completion {
    if (!ignoreIntersect) {
        UINavigationBar *bar = self.rg_displayedNavigationBar ?  self.navigationController.navigationBar : nil;
        if (bar) {
            if (!CGRectIntersectsRect([bar convertRect:bar.bounds toView:dragIcon.superview], dragIcon.frame)) {
                if (completion) {
                    completion(NO);
                }
                return;
            }
        }
    }
    
    __block UIView *icon;
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == itemId) {
            [obj.customView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subView, NSUInteger idx, BOOL * _Nonnull stop) {
                if (subView.tag == itemId) {
                    icon = subView;
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    }];
    
    if (!icon) {
        icon = copyIcon();
        [self __addRightBarItemWithIcon:icon itemId:itemId alpha:0.f];
    }
    
    UIView *placeHolder = [[UIView alloc] initWithFrame:icon.frame];
    placeHolder.autoresizingMask = icon.autoresizingMask;
    placeHolder.tag = icon.tag;
    [icon.superview addSubview:placeHolder];
    
    UIView *transView = self.navigationController.view;
    
    icon.transform = dragIcon.transform;
    icon.frame = [dragIcon.superview convertRect:dragIcon.frame toView:transView];
    CGPoint recordCenter = icon.center;
    icon.alpha = 1.f;
    icon.tintColor = dragIcon.tintColor;
    [transView addSubview:icon];
    
    BOOL isHidden = dragIcon.isHidden;
    dragIcon.hidden = YES;
    
    [UIView animateWithDuration:0.8 animations:^{
        icon.transform = CGAffineTransformIdentity;
        icon.center = recordCenter;
    } completion:^(BOOL finished) {
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.6f animations:^{
            icon.frame = [placeHolder convertRect:placeHolder.bounds toView:icon.superview];
            icon.tintColor = placeHolder.superview.tintColor;
            if (syncAnimate) {
                syncAnimate(icon);
            }
        } completion:^(BOOL finished) {
            
            [placeHolder.superview addSubview:icon];
            [placeHolder removeFromSuperview];
            
            icon.transform = CGAffineTransformIdentity;
            icon.frame = placeHolder.frame;
            dragIcon.hidden = isHidden;
            
            if (completion) {
                completion(YES);
            }
            [self dragItemDidDragAdd:icon didDrag:icon.tag];
        }];
    });
}

- (BOOL)addRightDragBarItemWithIcon:(UIView *)icon itemId:(NSInteger)itemId {
    if ([self rightBarItemWithId:itemId]) {
        return NO;
    }
    [self __addRightBarItemWithIcon:icon itemId:itemId alpha:1.f];
    return YES;
}

- (void)__addRightBarItemWithIcon:(UIView *)icon itemId:(NSInteger)itemId alpha:(CGFloat)alpha {
    
    UIView *wapper = [[UIView alloc] initWithFrame:icon.bounds];
    icon.frame = UIEdgeInsetsInsetRect(wapper.bounds, UIEdgeInsetsMake(5, 5, 5, 5));
    
    icon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [wapper addSubview:icon];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:wapper];
    item.tag = itemId;
    wapper.tag = itemId;
    icon.tag = itemId;
    
    icon.alpha = alpha;
    
    NSMutableArray *itmes = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    [itmes addObject:item];
    self.navigationItem.rightBarButtonItems = itmes;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragBarItem_longPress:)];
    [icon addGestureRecognizer:longPress];
}

- (BOOL)iconIsIntersect:(UIView *)icon {
    UINavigationBar *bar = self.rg_displayedNavigationBar ?  self.navigationController.navigationBar : nil;
    if (bar) {
        if (CGRectIntersectsRect([bar convertRect:bar.bounds toView:icon.superview], icon.frame)) {
            return YES;
        }
    }
    return NO;
}

- (void)dragBarItem_longPress:(UILongPressGestureRecognizer *)recognizer {
    
    UIView *icon = recognizer.view;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
            UIView *placeHolder = [[UIView alloc] initWithFrame:icon.frame];
            placeHolder.autoresizingMask = icon.autoresizingMask;
            placeHolder.tag = icon.tag;
            [icon.superview addSubview:placeHolder];
            
            CGRect frame = [icon convertRect:icon.bounds toView:self.navigationController.view];
            icon.frame = frame;
            icon.tintColor = icon.superview.tintColor;

            [self.navigationController.view addSubview:icon];
            
            [icon startWithPoint:[recognizer locationInView:icon.superview]];
            [UIView animateWithDuration:0.3 animations:^{
                icon.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint newPoint = [recognizer locationInView:icon.superview];
            
            [icon updateCenterWithNewPoint:newPoint];
            if (![self iconIsIntersect:icon]) {
                [self dragItem:icon didDrag:icon.tag];
            }
            break;
        }
        default: {
            if ([self iconIsIntersect:icon] || ![self dragItemShouldRemove:icon endDrag:icon.tag]) {
                
                UIBarButtonItem *item = [self rightBarItemWithId:icon.tag];
                UIView *wapper = item.customView;
                
                __block UIView *placeHolder = nil;
                [[wapper subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.tag == icon.tag) {
                        placeHolder = obj;
                    }
                }];
                
                
                [UIView animateWithDuration:0.3 animations:^{
                    icon.transform = CGAffineTransformIdentity;
                    icon.frame = [placeHolder convertRect:placeHolder.bounds toView:icon.superview];
                } completion:^(BOOL finished) {
                    [placeHolder removeFromSuperview];
                    icon.frame = placeHolder.frame;
                    [wapper addSubview:icon];
                }];
            } else {
                [self removeRightDragBarItemWithId:icon.tag];
                [self dragItemDidDragRemove:icon didDrag:icon.tag];
                [icon removeFromSuperview];
            }
            break;
        }
    }
}

- (void)dragItem:(UIView *)icon didDrag:(NSInteger)itemId {
    
}

- (BOOL)dragItemShouldRemove:(UIView *)icon endDrag:(NSInteger)itemId {
    return NO;
}

- (void)dragItemDidDragAdd:(UIView *)icon didDrag:(NSInteger)itemId {
    
}

- (void)dragItemDidDragRemove:(UIView *)icon didDrag:(NSInteger)itemId {
    
}

- (UIBarButtonItem *)rightBarItemWithId:(NSInteger)itemId {
    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
        if (item.tag == itemId) {
            return item;
        }
    }
    return nil;
}

- (NSArray <NSNumber *> *)rightDragBarItemIds {
    NSMutableArray *items = [NSMutableArray array];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.customView && obj.tag == obj.customView.tag) {
            [items addObject:@(obj.tag)];
        }
    }];
    return items;
}

- (void)removeRightDragBarItemWithId:(NSInteger)itemId {
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == itemId) {
            NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
            [items removeObjectAtIndex:idx];
            self.navigationItem.rightBarButtonItems = items;
            *stop = YES;
        }
    }];
}

- (void)removeAllRightDragBarItem {
    NSMutableArray *temp = [NSMutableArray array];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.customView || obj.tag != obj.customView.tag) {
            [temp addObject:obj];
        }
    }];
    self.navigationItem.rightBarButtonItems = temp;
}

@end
