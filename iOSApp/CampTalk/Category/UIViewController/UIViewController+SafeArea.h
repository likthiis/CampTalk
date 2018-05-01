//
//  UIViewController+SafeArea.h
//  JusTalk
//
//  Created by juphoon on 2017/11/7.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+BarFrame.h"

@interface UIViewController (SafeArea)

- (UIEdgeInsets)insetWhenAdjustNever;

- (UIEdgeInsets)viewSafeAreaInsets;

- (CGRect)safeBounds;

- (CGRect)safeAreaFix:(CGRect)rect;
- (CGRect)safeAreaFixVertical:(CGRect)rect; // 在 (0, 0) 开始布局，之后使用此方法
- (CGRect)safeAreaFixHorizontal:(CGRect)rect;

- (CGRect)safeAreaFixTop:(CGRect)rect; // 默认 stretch:NO; 移动位置 不拉伸
- (CGRect)safeAreaFixTop:(CGRect)rect stretch:(BOOL)stretch;

- (CGRect)safeAreaFixBottom:(CGRect)rect;
- (CGRect)safeAreaFixBottom:(CGRect)rect stretch:(BOOL)stretch;

- (CGRect)safeAreaFixLeft:(CGRect)rect;
- (CGRect)safeAreaFixLeft:(CGRect)rect stretch:(BOOL)stretch;

- (CGRect)safeAreaFixRight:(CGRect)rect;
- (CGRect)safeAreaFixRight:(CGRect)rect stretch:(BOOL)stretch;

- (CGRect)safeAreaFixWidth:(CGRect)rect;
- (CGRect)safeAreaFixHeight:(CGRect)rect;

- (CGRect)safeAreaFixTop:(CGRect)rect originalTop:(CGFloat)top stretch:(BOOL)stretch;
- (CGRect)safeAreaFixLeft:(CGRect)rect originalLeft:(CGFloat)left stretch:(BOOL)stretch;
- (CGRect)safeAreaFixBottom:(CGRect)rect originalBottom:(CGFloat)bottom superViewHeight:(CGFloat)superHeight stretch:(BOOL)stretch;
- (CGRect)safeAreaFixRight:(CGRect)rect originalRight:(CGFloat)right superViewWidth:(CGFloat)superWidth stretch:(BOOL)stretch;

//- (CGFloat)safeAreaTopY:(CGFloat)topY;
//- (CGFloat)safeAreaBottomY:(CGFloat)bottomY;
//- (CGFloat)safeAreaHeight:(CGFloat)height;
//
//- (CGFloat)safeAreaLeftX:(CGFloat)leftX;
//- (CGFloat)safeAreaRightX:(CGFloat)rightX;
//- (CGFloat)safeAreaWidth:(CGFloat)width;

@end
