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
    
    RGImagePickerCache *cache = [[RGImagePickerCache alloc] init];
    cache.pickResult = pickResult;
    
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

@end
