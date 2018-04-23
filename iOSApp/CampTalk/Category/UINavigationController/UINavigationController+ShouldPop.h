//
//  UINavigationController+ShouldPop.h
//  JusTalk
//
//  Created by juphoon on 2018/3/21.
//  Copyright © 2018年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIViewController implement this delegate
 */
@protocol UINavigationControllerShouldPopDelegate <NSObject>

- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigationController isInteractive:(BOOL)isInteractive;

- (void)navigationController:(UINavigationController *)navigationController interactivePopResult:(BOOL)finished;

@end

@interface UINavigationController (ShouldPop)

@end
