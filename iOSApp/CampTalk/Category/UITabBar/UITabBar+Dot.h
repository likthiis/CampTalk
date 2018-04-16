//
//  UITabBar+Dot.h
//  JusTalk
//
//  Created by jiang  hao on 2017/7/6.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UITabbarDotType) {
    UITabbarDotTypeNormal,
    UITabbarDotTypeWarning
};

@interface UITabBar (Dot)

- (void)showDotWithType:(UITabbarDotType)type atIndex:(NSInteger)index;
- (void)hideDotOnItemAtIndex:(NSInteger)index;

@end
