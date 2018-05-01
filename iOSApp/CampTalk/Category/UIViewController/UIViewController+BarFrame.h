//
//  UIViewController+BarFrame.h
//  JusTalk
//
//  Created by juphoon on 2017/11/2.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BarFrame)

- (CGFloat)layoutOriginY;

- (CGFloat)barHeight;

- (CGFloat)statusBarHeight;

- (BOOL)displayedNavigationBar;

@end
