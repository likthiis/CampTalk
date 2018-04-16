//
//  UIImage+Tint.m
//  Batter
//
//  Created by Cathy on 12-8-15.
//  Copyright (c) 2012年 Juphoon.com. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

+ (UIImage *)coloredImage:(UIColor *)color size:(CGSize)imageSize
{
    if (imageSize.width == 0 || imageSize.height == 0) {
        return nil;
    }
    
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)circleImageWithColor:(UIColor *)color size:(CGSize)imageSize radius:(CGFloat)radius {
    
    if (imageSize.width == 0 || imageSize.height == 0 || radius == 0) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, radius, 0);
    CGContextAddLineToPoint(context, width - radius,0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 *M_PI,0.0,0);
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius,0.0,0.5 *M_PI,0);
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius,0.5 *M_PI,M_PI,0);
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius,M_PI,1.5 *M_PI,0);
    CGContextClosePath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context,kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)templateImageWithSize:(CGSize)imageSize {
    UIImage *image = [self coloredImage:[UIColor whiteColor] size:imageSize];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

+ (UIImage *)templateImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)templateCircleImageWithSize:(CGSize)imageSize radius:(CGFloat)radius {
    UIImage *image = [self circleImageWithColor:[UIColor whiteColor] size:imageSize radius:radius];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

- (UIImage *)imageWithColor:(UIColor *)tintColor
{
    CGSize size = self.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    [self drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageByApplyingAlphaWithImage:(UIImage *)image {
    
    CGFloat alpha = 0.3;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)drawImage:(UIImage *)image aboveAnotherImage:(UIImage *)anotherImage {
    
    CGImageRef imgRef = image.CGImage;
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat w = CGImageGetWidth(imgRef) / screenScale;
    CGFloat h = CGImageGetHeight(imgRef) / screenScale;
    
    CGImageRef anotehrImgRef = anotherImage.CGImage;
    CGFloat w1 = CGImageGetWidth(anotehrImgRef) / screenScale;
    CGFloat h1 = CGImageGetHeight(anotehrImgRef) / screenScale;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w1, h1), YES, screenScale);
    [anotherImage drawInRect:CGRectMake(0, 0, w1, h1)];
    [image drawInRect:CGRectMake((w1 - w) / 2.0f, (h1 - h) / 2.0f, w, h)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImg;
}

@end
