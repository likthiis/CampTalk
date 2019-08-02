//
//  RGImagePickerCache.h
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGImagePickerConst.h"
#import "RGImageAlbumListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class RGImageAlbumListViewController;

@interface RGImagePickerCache : NSObject

@property (nonatomic, strong) NSMutableArray <PHAsset *> *pickPhotos;

@property (nonatomic, copy) RGImagePickResult pickResult;

- (void)setPhotos:(NSArray <PHAsset *> *)phassets;
- (void)addPhotos:(NSArray <PHAsset *> *)phassets;
- (void)removePhotos:(NSArray <PHAsset *> *)phassets;
- (BOOL)contain:(PHAsset *)phassets;

- (void)callBack:(UIViewController *)viewController;

@end

@interface RGImagePickerViewController ()

@property (nonatomic, strong) RGImagePickerCache *cache;

@end

NS_ASSUME_NONNULL_END
