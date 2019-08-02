//
//  CTChatBubbleLabel.h
//  CampTalk
//
//  Created by LD on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGBorderLabel.h"

@interface CTChatBubbleLabel : UIView

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) RGBorderLabel *label;
@property (nonatomic, assign) BOOL bubbleRightToLeft;

+ (CGSize)heightWithString:(NSString *)string fits:(CGSize)size;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;

@end
