//
//  UIViewController+SafeArea.m
//  JusTalk
//
//  Created by juphoon on 2017/11/7.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIViewController+SafeArea.h"

@implementation UIViewController (SafeArea)

- (UIEdgeInsets)insetWhenAdjustNever {
    
    CGFloat topInset = self.layoutOriginY;
    if (self.tabBarController) {
        return UIEdgeInsetsMake(topInset, 0, self.tabBarController.tabBar.frame.size.height, 0);
    }
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

- (UIEdgeInsets)viewSafeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    } else {
        return UIEdgeInsetsMake(self.layoutOriginY, 0, self.tabBarHeight, 0);
    }
}

- (CGFloat)tabBarHeight {
    if (self.__displayTabbar) {
        return self.tabBarController.tabBar.frame.size.height;
    } else {
        return 0.f;
    }
}

- (BOOL)__displayTabbar {
    return self.tabBarController ? !self.tabBarController.tabBar.isHidden : NO;
}

- (CGRect)safeBounds {
    return [self safeAreaFix:self.view.bounds];
}

- (CGRect)safeAreaFix:(CGRect)rect {
    
    rect = [self safeAreaFixVertical:rect];
    rect = [self safeAreaFixHorizontal:rect];
    return rect;
}

- (CGRect)safeAreaFixVertical:(CGRect)rect {
    rect = [self safeAreaFixTop:rect stretch:NO];
    rect = [self safeAreaFixHeight:rect];
    return rect;
}

- (CGRect)safeAreaFixHorizontal:(CGRect)rect {
    rect = [self safeAreaFixLeft:rect stretch:NO];
    rect = [self safeAreaFixWidth:rect];
    return rect;
}

- (CGRect)safeAreaFixTop:(CGRect)rect {
    return [self safeAreaFixTop:rect stretch:NO];
}

- (CGRect)safeAreaFixTop:(CGRect)rect stretch:(BOOL)stretch {
    CGFloat top = self.layoutOriginY;;
    
    if (stretch) {
        rect.size.height += top;
    } else {
        rect.origin.y += top;
    }
    return rect;
}

- (CGRect)safeAreaFixBottom:(CGRect)rect {
    return [self safeAreaFixBottom:rect stretch:NO];
}

- (CGRect)safeAreaFixBottom:(CGRect)rect stretch:(BOOL)stretch {
    CGFloat bottom = self.viewSafeAreaInsets.bottom;
    rect.origin.y -= bottom;
    if (stretch) {
        rect.size.height += bottom;
    }
    return rect;
}

- (CGRect)safeAreaFixLeft:(CGRect)rect {
    return [self safeAreaFixLeft:rect stretch:NO];
}

- (CGRect)safeAreaFixLeft:(CGRect)rect stretch:(BOOL)stretch {
    CGFloat left = self.viewSafeAreaInsets.left;
    if (stretch) {
        rect.size.width += left;
    } else {
        rect.origin.x += self.viewSafeAreaInsets.left;
    }
    return rect;
}

- (CGRect)safeAreaFixRight:(CGRect)rect {
    return [self safeAreaFixRight:rect stretch:NO];
}

- (CGRect)safeAreaFixRight:(CGRect)rect stretch:(BOOL)stretch {
    CGFloat right = self.viewSafeAreaInsets.right;
    rect.origin.x -= right;
    if (stretch) {
        rect.size.width += right;
    }
    return rect;
}

- (CGRect)safeAreaFixWidth:(CGRect)rect {
    rect.size.width -= (self.viewSafeAreaInsets.left + self.viewSafeAreaInsets.right);
    return rect;
}

- (CGRect)safeAreaFixHeight:(CGRect)rect {
    if (self.navigationController) {
        rect.size.height -= self.viewSafeAreaInsets.bottom;
    } else {
        rect.size.height -= (self.viewSafeAreaInsets.top + self.viewSafeAreaInsets.bottom);
    }
    return rect;
}

- (CGRect)safeAreaFixTop:(CGRect)rect originalTop:(CGFloat)top stretch:(BOOL)stretch {
    rect.origin.y = top;
    return [self safeAreaFixTop:rect stretch:stretch];
}

- (CGRect)safeAreaFixLeft:(CGRect)rect originalLeft:(CGFloat)left stretch:(BOOL)stretch {
    rect.origin.x = left;
    return [self safeAreaFixLeft:rect stretch:stretch];
}

- (CGRect)safeAreaFixBottom:(CGRect)rect originalBottom:(CGFloat)bottom superViewHeight:(CGFloat)superHeight stretch:(BOOL)stretch {
    rect.origin.y = superHeight - bottom;
    return [self safeAreaFixBottom:rect stretch:stretch];
}

- (CGRect)safeAreaFixRight:(CGRect)rect originalRight:(CGFloat)right superViewWidth:(CGFloat)superWidth stretch:(BOOL)stretch {
    rect.origin.x = superWidth - right;
    return [self safeAreaFixRight:rect stretch:stretch];
}

//- (CGFloat)safeAreaTopY:(CGFloat)topY {
//    return self.viewSafeAreaInsets.top + topY;
//}
//
//- (CGFloat)safeAreaBottomY:(CGFloat)bottomY {
//    return bottomY - self.viewSafeAreaInsets.bottom;
//}
//
//- (CGFloat)safeAreaHeight:(CGFloat)height {
//    return height - self.viewSafeAreaInsets.bottom - self.viewSafeAreaInsets.top;
//}
//
//- (CGFloat)safeAreaLeftX:(CGFloat)leftX {
//    return self.viewSafeAreaInsets.left + leftX;
//}
//
//- (CGFloat)safeAreaRightX:(CGFloat)rightX {
//    return rightX - self.viewSafeAreaInsets.right;
//}
//
//- (CGFloat)safeAreaWidth:(CGFloat)width {
//    return width - self.viewSafeAreaInsets.left - self.viewSafeAreaInsets.right;
//}

@end
