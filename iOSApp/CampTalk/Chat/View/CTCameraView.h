//
//  CTCameraView.h
//  CampTalk
//
//  Created by renge on 2018/4/28.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTCameraView;

@protocol CTCameraViewDelegate <NSObject>

@optional

- (void)cameraView:(CTCameraView *)cameraView didDragButton:(UIButton *)cameraButton;

- (void)cameraView:(CTCameraView *)cameraView endDragButton:(UIButton *)cameraButton layoutBlock:(void(^)(BOOL recover))layout;

- (void)cameraView:(CTCameraView *)cameraView didTapButton:(UIButton *)cameraButton;

@end

@interface CTCameraView : UIView

@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIView *tintColorEffectView;

@property (nonatomic, weak) id <CTCameraViewDelegate> delegate;

- (void)setCameraButtonCenterPoint:(CGPoint)center;

- (UIButton *)copyCameraButton;

- (void)showInView:(UIView *)superView tintColorEffectView:(UIView *)view;

- (void)showCameraButtonWithAnimate:(BOOL)animate;
- (void)hideCameraButton;
- (void)adjustTintColor;

- (void)shadow:(BOOL)show;

@end
