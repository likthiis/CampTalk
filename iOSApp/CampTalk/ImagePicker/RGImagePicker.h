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

@end

NS_ASSUME_NONNULL_END
