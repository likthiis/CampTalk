//
//  UIView+Layout.m
//  JusTalk
//
//  Created by juphoon on 2017/12/22.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIView+LayoutHelp.h"

@implementation UIView (LayoutHelp)

- (BOOL)layoutLeftToRight {
    if (([[[UIDevice currentDevice] systemVersion] compare:@("9") options:NSNumericSearch] == NSOrderedAscending)) {
        return ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight);
    } else {
        return ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionLeftToRight);
    }
}

@end
