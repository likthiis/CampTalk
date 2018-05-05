//
//  CTStubbornView.h
//  CampTalk
//
//  Created by RengeRenge on 2018/4/23.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTStubbornView : UIImageView


/**
 gradient mask, alpha 0 -> 0 -> 1 -> 1

 @param begain percent of center 0
 @param end percent of center 1
 */
- (void)setGradientBegain:(CGFloat)begain end:(CGFloat)end;


/**
 change gradient mask direction

 @param up YES : alpha 1 -> 1 -> 0 -> 0; NO : alpha 0 -> 0 -> 1 -> 1;
 */
- (void)setGradientDirection:(BOOL)up;

@end
