//
//  UIImage+Read.m
//  JusTalk
//
//  Created by Jori on 2017/3/8.
//  Copyright © 2017年 juphoon. All rights reserved.
//

#import "UIImage+Read.h"
#import "UIImage+Name.h"

@implementation UIImage (Read)

+ (UIImage *)imageWithName:(NSString *)name {
    if (!name || name.length == 0) {
        return nil;
    }
    
    NSString *extension = nil;
    NSString *fullName = [self imageFullNameWithName:name extension:&extension];
    return [self imageWithFullName:fullName extension:extension];
}

+ (UIImage *)imageWithFullName:(NSString *)fullName extension:(NSString *)extension {
    if (!fullName || fullName.length == 0) {
        return nil;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fullName ofType:extension];
    return [UIImage imageWithContentsOfFile:filePath];
}

@end
