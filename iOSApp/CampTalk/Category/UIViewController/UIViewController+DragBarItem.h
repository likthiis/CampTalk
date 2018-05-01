//
//  UIViewController+DragBarItem.h
//  CampTalk
//
//  Created by renge on 2018/4/30.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DragBarItem)

- (void)addRightDragBarItemWithDragIcon:(UIView *)dragIcon
                                    itmeId:(NSInteger)itemId
                           ignoreIntersect:(BOOL)ignoreIntersect
                                  copyIcon:(NS_NOESCAPE UIView *(^)(void))copyIcon
                               syncAnimate:(void(^)(UIView *customView))syncAnimate
                                completion:(void(^)(BOOL added))completion;

- (BOOL)addRightDragBarItemWithIcon:(UIView *)icon itemId:(NSInteger)itemId;
- (void)removeRightDragBarItemWithId:(NSInteger)itemId;
- (void)removeAllRightDragBarItem;

- (UIBarButtonItem *)rightBarItemWithId:(NSInteger)itemId;
- (NSArray <NSNumber *> *)rightDragBarItemIds;


/**
 override and do some animate
 */
- (void)dragItem:(UIView *)icon didDrag:(NSInteger)itemId;

/**
 override and do some animate
 */
- (BOOL)dragItemShouldRemove:(UIView *)icon endDrag:(NSInteger)itemId;

- (void)dragItemDidDragRemove:(UIView *)icon didDrag:(NSInteger)itemId;
- (void)dragItemDidDragAdd:(UIView *)icon didDrag:(NSInteger)itemId;

@end
