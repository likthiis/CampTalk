//
//  CTImagePickerCell.h
//  CampTalk
//
//  Created by renge on 2019/8/2.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGImagePickerConst.h"

NS_ASSUME_NONNULL_BEGIN

@class RGImagePickerCell;

@protocol RGImagePickerCellDelegate <NSObject>

- (void)RGImagePickerCell:(RGImagePickerCell *)cell touchForce:(CGFloat)force maximumPossibleForce:(CGFloat)maximumPossibleForce;

@end

@interface RGImagePickerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageViewMask;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) CAShapeLayer *checkMarkLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;

@property (nonatomic, weak) id <RGImagePickerCellDelegate> delegate;
@property (nonatomic, assign) CGFloat lastTouchForce;

- (void)setAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;
- (BOOL)needLoadWithAsset:(PHAsset *)asset;
- (void)loadOriginalWithAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
