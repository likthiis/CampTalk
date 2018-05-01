//
//  UINavigationController+BarFrame.m
//  JusTalk
//
//  Created by juphoon on 2017/11/2.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIViewController+BarFrame.h"

@implementation UIViewController (BarFrame)

- (UINavigationBar *)_navigationBar {
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self navigationBar];
    }
    return self.navigationController.navigationBar;
}

- (BOOL)displayedNavigationBar {
    return (self._navigationBar && !self._navigationBar.isHidden);
}

- (CGFloat)layoutOriginY {
    if (self.displayedNavigationBar) {
        if (self._navigationBar.translucent) {
            return [self barHeight];
        } else {
            return 0.f;
        }
    } else {
        if (@available(iOS 11.0, *)) {
            return self.view.safeAreaInsets.top;
        } else {
            return self.statusBarHeightIfNeed;
        }
    }
}

- (CGFloat)barHeight {
    
    CGFloat searchBarHeight = 0.f;
    
    if (@available(iOS 11.0, *)) {
        if (self.navigationItem.searchController) {
            UISearchBar *searchBar = self.navigationItem.searchController.searchBar;
            if (searchBar) {
                searchBarHeight = searchBar.isHidden ? 0.f : CGRectGetHeight(searchBar.frame);
            }
        }
    }
    return self._navigationBar.frame.size.height + self._navigationBar.frame.origin.y + searchBarHeight;
}

- (CGFloat)statusBarHeightIfNeed {
    if (self.needAddStatusBarHeight) {
        return self.statusBarHeight;
    }
    return 0.f;
}

- (BOOL)needAddStatusBarHeight {
    UIModalPresentationStyle style = self.navigationController ? self.navigationController.modalPresentationStyle : self.modalPresentationStyle;
    switch (style) {
        case UIModalPresentationPageSheet:
        case UIModalPresentationFormSheet:
        case UIModalPresentationPopover: {
            return NO;
        }
        default: {
            return YES;
        }
    }
}

- (CGFloat)statusBarHeight {
    if (self.prefersStatusBarHidden) {
        return 0.f;
    }
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
