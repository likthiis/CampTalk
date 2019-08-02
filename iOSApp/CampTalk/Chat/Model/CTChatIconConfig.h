//
//  CTChatIconConfig.h
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CTChatToolIconIdCamara = 100,
    CTChatToolIconIdMusic,
} CTChatToolIconId;

typedef enum : NSUInteger {
    CTChatToolIconUnknow = 0,
    CTChatToolIconPlaceNavigation,
    CTChatToolIconPlaceMainView,
    CTChatToolIconPlaceInputView,
    CTChatToolIconPlaceCount,
} CTChatToolIconPlace;

@interface CTChatIconConfig : NSObject

+ (NSMutableDictionary <NSString *, NSArray <NSNumber *> *> *)toolConfig;
+ (void)updateConfig:(NSMutableDictionary <NSString *, NSArray <NSNumber *> *> *)config;

@end

NS_ASSUME_NONNULL_END
