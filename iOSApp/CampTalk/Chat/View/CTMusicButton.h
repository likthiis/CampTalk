//
//  CTMusicButton.h
//  CampTalk
//
//  Created by renge on 2018/4/30.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTMusicButton : UIView

@property (nonatomic, strong) UIButton *musicButton;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) UIEdgeInsets edge;

@property (nonatomic, copy) void(^clickBlock)(CTMusicButton *button);

@end
