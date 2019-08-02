//
//  RGBubbleView.h
//  CampTalk
//
//  Created by renge on 2018/5/4.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGBubbleView : UIView

@property (nonatomic, strong) CAShapeLayer *bubbleMask;
@property (nonatomic, strong) CAShapeLayer *bubbleBorder;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) BOOL bubbleRightToLeft;

- (UIEdgeInsets)contentViewEdge;

@end
