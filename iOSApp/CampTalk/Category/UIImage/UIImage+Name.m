//
//  UIImage+name.m
//  JusTalk
//
//  Created by jiang  hao on 2017/5/10.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIImage+Name.h"

@implementation UIImage (Name)

+ (NSString *)imageFullNameWithName:(NSString *)name extension:(NSString **)extension {
    NSString *fullName = nil;
    NSString *nameExtension = [name pathExtension];
    if (!nameExtension || nameExtension.length == 0) {
        int scale = (int)[UIScreen mainScreen].scale;
        if (scale == 1) {
            scale = 2;
        }
        fullName =[NSString stringWithFormat:@"%@@%dx", name, scale];
        nameExtension = @"png";
    } else {
        fullName = name;
        nameExtension = nil;
    }
    *extension = nameExtension;
    return fullName;
}

@end
