//
//  CTNavigationController.h
//  CampTalk
//
//  Created by kikilee on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CTNavigationBackgroundTypeShadow,
    CTNavigationBackgroundTypeAllTranslucent,
    CTNavigationBackgroundTypeNormal,
} CTNavigationBackgroundType;

@interface CTNavigationController : UINavigationController

@property (nonatomic, assign) CTNavigationBackgroundType type;

+ (CTNavigationController *)navigationWithRoot:(UIViewController *)root;

@end
