//
//  UIView+Radius.h
//  JusTalk
//
//  Created by 姜豪 on 2017/11/21.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Radius)

@property (strong, nonatomic) CALayer *borderLayer;

- (void)addBorderWithCornerRadious:(CGFloat)radius borderColor:(UIColor *)borderColor andBorderWidth:(CGFloat)borderWidth;

@end
