//
//  CTImagePickerCell.h
//  CampTalk
//
//  Created by renge on 2019/8/2.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGImagePickerConst.h"
#import "RGImagePickerCache.h"

NS_ASSUME_NONNULL_BEGIN

@class RGImagePickerCell;

@protocol RGImagePickerCellDelegate <NSObject>

- (void)imagePickerCell:(RGImagePickerCell *)cell touchForce:(CGFloat)force maximumPossibleForce:(CGFloat)maximumPossibleForce;

- (void)didCheckForImagePickerCell:(RGImagePickerCell *)cell;

@end

@interface RGImagePickerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageViewMask;

@property (nonatomic, strong) RGImagePickerCache *cache;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, assign) PHImageRequestID lastRequestId;

@property (nonatomic, strong) CAShapeLayer *checkMarkLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, weak) id <RGImagePickerCellDelegate> delegate;
@property (nonatomic, assign) CGFloat lastTouchForce;

- (void)setAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
+ (void)needLoadWithAsset:(PHAsset *)asset result:(void(^)(BOOL needLoad))result;

- (BOOL)isCurrentAsset:(PHAsset *)asset;
+ (void)loadOriginalWithAsset:(PHAsset *)asset updateCell:(RGImagePickerCell *)cell;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
