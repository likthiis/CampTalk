//
//  CTChatInputView.h
//  CampTalk
//
//  Created by kikilee on 2018/4/22.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTChatInputViewDelegate;

@interface CTChatInputView : UIView

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat maxContentHeight;

@property (nonatomic, assign) id <CTChatInputViewDelegate> delegate;

@end

@protocol CTChatInputViewDelegate <NSObject>

- (void)contentSizeDidChange:(CTChatInputView *)chatInputView size:(CGSize)size;

@end
