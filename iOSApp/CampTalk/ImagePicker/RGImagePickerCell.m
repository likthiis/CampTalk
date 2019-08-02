//
//  CTImagePickerCell.m
//  CampTalk
//
//  Created by renge on 2019/8/2.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "RGImagePickerCell.h"

static PHImageRequestOptions *__ctImagePickerOptions;

@implementation RGImagePickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2.f;
        self.clipsToBounds = YES;
        [self.contentView.layer addSublayer:self.selectedLayer];
    }
    return self;
}

- (CAShapeLayer *)checkMarkLayer {
    if (!_checkMarkLayer) {
        _checkMarkLayer = [CAShapeLayer layer];
        _checkMarkLayer.frame = CGRectMake(0, 0, 30, 30);
        
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        
        [bezier2Path moveToPoint: CGPointMake(6.f, 17.95)];
        [bezier2Path addLineToPoint: CGPointMake(12.3f, 24.02)];
        [bezier2Path addLineToPoint: CGPointMake(25.77, 9.4)];
        
        _checkMarkLayer.path = bezier2Path.CGPath;
        _checkMarkLayer.fillColor = [UIColor clearColor].CGColor;
        _checkMarkLayer.strokeColor = [UIColor blackColor].CGColor;
        _checkMarkLayer.lineWidth = 2.f;
        _checkMarkLayer.lineCap = kCALineCapRound;
        _checkMarkLayer.lineJoin = kCALineJoinRound;
        _checkMarkLayer.strokeEnd = 0.f;
        _checkMarkLayer.strokeStart = 0.f;
    }
    return _checkMarkLayer;
}

- (CAShapeLayer *)selectedLayer {
    if (!_selectedLayer) {
        _selectedLayer = [CAShapeLayer layer];
        _selectedLayer.frame = CGRectMake(0, 0, 30, 30);
        _selectedLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 30, 30) cornerRadius:15.f].CGPath;
        _selectedLayer.strokeColor = [UIColor whiteColor].CGColor;
        _selectedLayer.fillColor = [UIColor clearColor].CGColor;
        _selectedLayer.lineWidth = 2.f;
        
        [_selectedLayer addSublayer:self.checkMarkLayer];
    }
    return _selectedLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    [self.contentView sendSubviewToBack:_imageView];
    
    CGRect frame = _selectedLayer.frame;
    frame.origin.x = self.contentView.bounds.size.width - frame.size.width - 5.f;
    frame.origin.y = 5.f;
    _selectedLayer.frame = frame;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _selectedLayer.fillColor = [UIColor whiteColor].CGColor;
        _checkMarkLayer.strokeEnd = 1.f;
    } else {
        _selectedLayer.fillColor = [UIColor clearColor].CGColor;
        _checkMarkLayer.strokeEnd = 0.f;
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        
        self.imageViewMask.frame = _imageView.bounds;
        self.imageViewMask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadOriginal)];
        [self.imageViewMask addGestureRecognizer:tap];
        
        [_imageView addSubview:self.imageViewMask];
        
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UIView *)imageViewMask {
    if (!_imageViewMask) {
        _imageViewMask = [[UIView alloc] init];
    }
    return _imageViewMask;
}

- (void)setAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (_asset == asset || [_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __ctImagePickerOptions = [[PHImageRequestOptions alloc] init];
        __ctImagePickerOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    });
    
    _asset = asset;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:__ctImagePickerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (![self->_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
            return;
        }
        
        if ([self needLoadWithAsset:asset]) {
            self->_selectedLayer.strokeEnd = 0.f;
            self.imageViewMask.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6];
        } else {
            self->_selectedLayer.strokeEnd = 1.f;
            self.imageViewMask.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0];
        }
        
        if (self.asset == asset) {
            self.imageView.image = result;
        }
    }];
}

- (BOOL)needLoadWithAsset:(PHAsset *)asset {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = NO;
    options.synchronous = YES;
    
    CGSize orSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    
    __block BOOL needLoad = NO;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:orSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL isLoaded = ![info[PHImageResultIsDegradedKey] boolValue] && image;
        needLoad = !isLoaded;
    }];
    return needLoad;
}

- (void)loadOriginalWithAsset:(PHAsset *)asset {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self->_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                return;
            }
            self->_selectedLayer.strokeEnd = 1.f;
        });
    };
    
    CGSize orSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:orSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (![self->_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
            return;
        }
        
        BOOL isLoaded = ![info[PHImageResultIsDegradedKey] boolValue] && result;
        if (isLoaded) {
            self.imageViewMask.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0];
        } else {
            self.imageViewMask.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.6];
        }
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches allObjects].firstObject;
    if (@available(iOS 9.0, *)) {
        _lastTouchForce = touch.force;
        [self.delegate RGImagePickerCell:self touchForce:touch.force maximumPossibleForce:touch.maximumPossibleForce];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches allObjects].firstObject;
    if (@available(iOS 9.0, *)) {
        _lastTouchForce = 0;
        [self.delegate RGImagePickerCell:self touchForce:0 maximumPossibleForce:touch.maximumPossibleForce];
    }
}

@end
