//
//  RGImagePicker.m
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "RGImagePicker.h"
#import "RGImagePickerCache.h"
#import "RGImageAlbumListViewController.h"
#import <RGUIKit/RGUIKit.h>

@implementation RGImagePicker

+ (RGImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController pickResult:(RGImagePickResult)pickResult {
    return [self presentByViewController:presentingViewController maxCount:1 pickResult:pickResult];
}

+ (RGImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController maxCount:(NSUInteger)maxCount pickResult:(RGImagePickResult)pickResult {
    RGImagePickerCache *cache = [[RGImagePickerCache alloc] init];
    cache.pickResult = pickResult;
    cache.maxCount = maxCount;
    
    RGImagePickerViewController *vc = [[RGImagePickerViewController alloc] init];
    vc.cache = cache;
    
    void(^loadData)(void) = ^{
        vc.collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    };
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    loadData();
                });
            }
        }];
    } else {
        loadData();
    }
    
    RGImageAlbumListViewController *list = [[RGImageAlbumListViewController alloc] initWithStyle:UITableViewStylePlain];
    list.pickResult = pickResult;
    list.cache = cache;
    list.title = @"相册";
    
    RGNavigationController *nvg = [RGNavigationController navigationWithRoot:list style:RGNavigationBackgroundStyleNormal];
    //    UINavigationController *nvg = [[UINavigationController alloc] initWithRootViewController:list];
    [nvg setViewControllers:@[list, vc] animated:NO];
    nvg.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nvg.tintColor = [UIColor blackColor];
    [presentingViewController presentViewController:nvg animated:YES completion:nil];
    return vc;
}

+ (void)loadResourceFromAssets:(NSArray<PHAsset *> *)assets completion:(nonnull void (^)(NSArray<NSData *> * _Nonnull, NSError * _Nullable))completion {
    if (assets.count == 0) {
        if (completion) {
            completion(@[], nil);
        }
    }
    
    NSMutableArray <NSData *> *array = [NSMutableArray arrayWithCapacity:assets.count];
    for (int i = 0; i < assets.count; i++) {
        [array addObject:NSData.new];
    }

    __block NSInteger count = assets.count;
    
    void(^callBackIfNeed)(NSError *error) = ^(NSError *error) {
        count--;
        if ((count == 0 || error)&& completion) {
            count = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array, error);
            });
        }
    };
    
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self loadResourceFromAsset:obj progressHandler:nil completion:^(NSData * _Nullable imageData, NSError * _Nullable error) {
            if (imageData) {
                [array replaceObjectAtIndex:idx withObject:imageData];
            }
            callBackIfNeed(error);
        }];
    }];
}

+ (void)loadResourceFromAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double))progressHandler completion:(void (^ _Nullable)(NSData * _Nullable, NSError * _Nullable))completion {
    
    void(^callBackIfNeed)(NSData *data, NSError *error) = ^(NSData *data, NSError *error) {
        if (completion && (data || error)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    asset.rgIsLoaded = YES;
                }
                completion(data, error);
            });
        }
    };
    
    if (@available(iOS 9.0, *)) {
        NSArray<PHAssetResource *> * resources = [PHAssetResource assetResourcesForAsset:asset];
        for (NSInteger i = resources.count - 1; i >= 0; i--) {
            PHAssetResource *obj = resources[i];
            if (![self isPhoto:obj]) {
                continue;
            }
            
            PHAssetResourceRequestOptions *option = [[PHAssetResourceRequestOptions alloc] init];
            option.networkAccessAllowed = YES;
            
            option.progressHandler = ^(double progress) {
                if (progressHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressHandler(progress);
                    });
                }
            };
            
            NSMutableData *imageData = [NSMutableData data];
            [[PHAssetResourceManager defaultManager] requestDataForAssetResource:obj options:option dataReceivedHandler:^(NSData * _Nonnull data) {
                [imageData appendData:data];
            } completionHandler:^(NSError * _Nullable error) {
                callBackIfNeed(imageData, error);
            }];
            break;
        }
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            if (progressHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressHandler(progress);
                });
            }
            callBackIfNeed(nil, error);
        };
        
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (!imageData) {
                return;
            }
            callBackIfNeed(imageData, nil);
        }];
    }
}

+ (BOOL)isPhoto:(PHAssetResource *)resource  API_AVAILABLE(ios(9.0)) {
    switch (resource.type) {
        case PHAssetResourceTypeFullSizePhoto:
        case PHAssetResourceTypePhoto:
        case PHAssetResourceTypeAlternatePhoto:
        case PHAssetResourceTypeAdjustmentBasePhoto:
            return YES;
        default:
            return NO;
    }
}

+ (BOOL)isGIF:(PHAssetResource *)resource  API_AVAILABLE(ios(9.0)) {
    if ([resource.uniformTypeIdentifier hasSuffix:@".gif"] || [resource.uniformTypeIdentifier hasSuffix:@".GIF"]) {
        return YES;
    }
    
    if ([resource.originalFilename hasSuffix:@".gif"] || [resource.originalFilename hasSuffix:@".GIF"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isPNG:(PHAssetResource *)resource  API_AVAILABLE(ios(9.0)) {
    if ([resource.uniformTypeIdentifier hasSuffix:@".png"] || [resource.uniformTypeIdentifier hasSuffix:@".PNG"]) {
        return YES;
    }
    
    if ([resource.originalFilename hasSuffix:@".png"] || [resource.originalFilename hasSuffix:@".PNG"]) {
        return YES;
    }
    return NO;
}

@end
