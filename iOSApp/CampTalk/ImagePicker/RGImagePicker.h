//
//  RGImagePicker.h
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGImagePickerConst.h"
#import "RGImagePickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RGImagePicker : NSObject

+ (RGImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController pickResult:(RGImagePickResult)pickResult;

+ (RGImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController maxCount:(NSUInteger)maxCount pickResult:(RGImagePickResult)pickResult;

+ (void)loadResourceFromAsset:(PHAsset *)asset progressHandler:(void(^_Nullable)(double progress))progressHandler completion:(void (^_Nullable)(NSData *_Nullable imageData, NSError *_Nullable error))completion;

+ (void)loadResourceFromAssets:(NSArray <PHAsset *> *)assets completion:(void(^)(NSArray <NSData *> *imageData, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
