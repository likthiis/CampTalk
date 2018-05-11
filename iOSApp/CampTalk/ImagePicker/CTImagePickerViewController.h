//
//  CTImagePickerViewController.h
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class CTImagePickerViewController;

typedef void(^ImagePickResult)(NSArray <PHAsset *> *phassets, UIViewController *pickerViewController);

@interface CTImagePickerViewController : UIViewController

@property (nonatomic, strong) PHAssetCollection *collection;

+ (CTImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController pickResult:(ImagePickResult)pickResult;

@end
