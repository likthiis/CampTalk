//
//  UIImage+JCPictureEdit.h
//  PictureEditor
//
//  Created by young on 2018/2/23.
//  Copyright © 2018年 young. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JCPictureEdit)

+ (UIImage *)convertViewToImage:(UIView *)view;

/**
 *  @brief 把view转换成image
 *  @param view view的对象
 *  @param size 转换成image的大小，传CGSizeZero则转换后的image大小为view的大小。
 *  @return UIImage对象
 */
+ (UIImage *)convertViewToImage:(UIView *)view size:(CGSize)size;

/**
 *  @brief 在图片中截取某一区域
 *  @param rect 被截取的区域
 *  @return UIImage对象
 */
- (UIImage *)cropInRect:(CGRect)rect;


+ (UIImage *)cropView:(UIView *)view inRect:(CGRect)rect scale:(CGFloat)scale;


/**
 *  @brief 把两张图合成一张，作为参数的图放在下面
 *  @param image 被覆盖的图
 *  @return UIImage对象
 */
- (UIImage *)coverWithImage:(UIImage *)image;

/**
 *  @brief 把图片的方向调正
 *  @return UIImage对象
 */
- (UIImage *)fixOrientation;

@end
