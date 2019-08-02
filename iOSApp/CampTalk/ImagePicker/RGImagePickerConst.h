//
//  RGImagePickerConst.h
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "RGImagePickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RGImagePickResult)(NSArray <PHAsset *> *phassets, UIViewController *pickerViewController);

NS_ASSUME_NONNULL_END
