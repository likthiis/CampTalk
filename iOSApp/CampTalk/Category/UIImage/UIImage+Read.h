//
//  UIImage+Read.h
//  JusTalk
//
//  Created by Jori on 2017/3/8.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Read)

+ (UIImage *)imageWithName:(NSString *)name;    // default extensionName png
+ (UIImage *)imageWithFullName:(NSString *)fullName extension:(NSString *)extension;

@end
