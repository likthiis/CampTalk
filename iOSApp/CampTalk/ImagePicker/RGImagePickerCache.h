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

@interface PHAsset (RGLoaded)

@property (nonatomic, assign) BOOL rgIsLoaded;

@end

@interface RGImagePickerCache : NSObject

@property (nonatomic, strong) NSMutableArray <PHAsset *> *pickPhotos;

@property (nonatomic, assign) NSUInteger maxCount;

@property (nonatomic, strong) NSMutableArray <NSDictionary <NSString *, UIImage *> *> *cachePhotos;

@property (nonatomic, copy) RGImagePickResult pickResult;

- (void)addCachePhoto:(UIImage *)photo forAsset:(PHAsset *)asset;
- (void)removeCachePhotoForAsset:(NSArray <PHAsset *> *)assets;
- (UIImage * _Nullable)imageForAsset:(PHAsset *)asset;

//- (void)addCacheLoadedStatusForAsset:(PHAsset *)asset;
//- (BOOL)isLoadedStatusForAsset:(PHAsset *)asset;

- (void)setPhotos:(NSArray <PHAsset *> *)phassets;
- (void)addPhotos:(NSArray <PHAsset *> *)phassets;
- (void)removePhotos:(NSArray <PHAsset *> *)phassets;
- (BOOL)contain:(PHAsset *)phassets;

- (BOOL)isFull;

- (void)callBack:(UIViewController *)viewController;

@end

@interface RGImagePickerViewController ()

@property (nonatomic, strong) PHAssetCollection *collection;

@property (nonatomic, strong) RGImagePickerCache *cache;

@end

NS_ASSUME_NONNULL_END
