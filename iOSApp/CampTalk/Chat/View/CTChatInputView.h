//
//  CTChatInputView.h
//  CampTalk
//
//  Created by kikilee on 2018/4/22.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const CTChatInputToolBarHeight;

@interface CTChatInputViewToolBarItem : NSObject

@property (nonatomic, strong) UIView *icon;
@property (nonatomic, assign) NSInteger identifier;

+ (CTChatInputViewToolBarItem *)itemWithIcon:(UIView *)icon identifier:(NSInteger)identifier;

@end

@protocol CTChatInputViewDelegate;

@interface CTChatInputView : UIView

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat maxContentHeight;

@property (nonatomic, assign) id <CTChatInputViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray <CTChatInputViewToolBarItem *> *toolBarItems;

- (NSString *)text;
- (void)setText:(NSString *)text;

- (void)addToolBarItem:(CTChatInputViewToolBarItem *)item;
- (void)removeToolBarItemWithId:(NSInteger)identifier;
- (void)removeAllToolBarItem;

- (CGRect)toolBarFrame;

- (void)updateNormalTintColorWithBackgroundImage:(UIImage *)image;
- (void)updateNormalTintColorWithBackgroundView:(UIView *)view frame:(CGRect)rect;

- (NSInteger)containToolBarItemWithId:(NSInteger)identifier;
- (void)updateContentHeight;

/**
 add or remove a CTChatInputViewToolBarItem but alpha is 0.f
 */
- (void)updateInputViewDragIcon:(UIView *)toolIcon toolId:(NSInteger)toolId copyIconBlock:(NS_NOESCAPE UIView *(^)(void))copyIconBlock;

/**
 add or remove CTChatInputViewToolBarItem and display with animation
 @param completion succeed is NO if removed
 */
- (void)addOrRemoveInputViewToolBarWithDragIcon:(UIView *)toolIcon toolId:(NSInteger)toolId copyIconBlock:(NS_NOESCAPE UIView *(^)(void))copyIconBlock customAnimate:(void(^)(void))customAnimate completion:(void(^)(BOOL added))completion;

@end

@protocol CTChatInputViewDelegate <NSObject>

- (void)chatInputView:(CTChatInputView *)chatInputView didTapActionButton:(UIButton *)button;

- (void)contentSizeDidChange:(CTChatInputView *)chatInputView size:(CGSize)size;

- (void)chatInputView:(CTChatInputView *)chatInputView willRemoveItem:(CTChatInputViewToolBarItem *)item syncAnimations:(void(^)(void))syncAnimations;

- (void)chatInputView:(CTChatInputView *)chatInputView didAddItem:(CTChatInputViewToolBarItem *)item;

@end
