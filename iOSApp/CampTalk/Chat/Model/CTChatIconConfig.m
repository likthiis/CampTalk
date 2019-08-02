//
//  CTChatIconConfig.m
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "CTChatIconConfig.h"

static NSString * const kCTChatToolConfig = @"kCTChatToolConfig";
static NSMutableDictionary <NSString *, NSArray <NSNumber *> *> *__toolConfig;

@implementation CTChatIconConfig

+ (NSMutableDictionary *)toolConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kCTChatToolConfig];
        if (dic) {
            __toolConfig = [NSMutableDictionary dictionaryWithDictionary:dic];
        } else {
            NSDictionary *dic = @{
                                  @(CTChatToolIconPlaceNavigation).stringValue : @[@(CTChatToolIconIdMusic),@(CTChatToolIconIdCamara)],
//                                  @(CTChatToolIconPlaceMainView).stringValue : @[@(CTChatToolIconIdCamara)],
                                  };
            __toolConfig = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    });
    return [NSMutableDictionary dictionaryWithDictionary:__toolConfig];
}

+ (void)updateConfig:(NSMutableDictionary<NSString *,NSArray<NSNumber *> *> *)config {
    __toolConfig = [NSMutableDictionary dictionaryWithDictionary:config];
    [[NSUserDefaults standardUserDefaults] setObject:config forKey:kCTChatToolConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
