//
//  UIImage+Tint.h
//  JusTel
//
//  Created by Cathy on 12-8-15.
//  Copyright (c) 2012年 Juphoon.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

+ (UIImage *)coloredImage:(UIColor *)color size:(CGSize)imageSize;
+ (UIImage *)circleImageWithColor:(UIColor *)color size:(CGSize)imageSize radius:(CGFloat)radius;
+ (UIImage *)templateImageWithSize:(CGSize)imageSize;
+ (UIImage *)templateImageNamed:(NSString *)name;
+ (UIImage *)templateCircleImageWithSize:(CGSize)imageSize radius:(CGFloat)radius;
- (UIImage *)imageWithColor:(UIColor *)tintColor;
+ (UIImage *)imageByApplyingAlphaWithImage:(UIImage *)image;
+ (UIImage *)drawImage:(UIImage *)image aboveAnotherImage:(UIImage *)anotherImage;

@end
