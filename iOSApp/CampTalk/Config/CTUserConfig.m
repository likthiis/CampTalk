//
//  CTUserConfig.m
//  CampTalk
//
//  Created by renge on 2018/5/9.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTUserConfig.h"
#import "CTFileManger.h"

NSString * const UCChatBackgroundImagePathChangedNotification = @"UCChatBackgroundImagePathChangedNotification";

NSString * const UCChatDataFolderName = @"chat";
NSString * const UCChatDataBackgroundFileName = @"chat_bg";

#define kChatBackgroundImageName @"kChatBackgroundImageName"

@implementation CTUserConfig

+ (NSString *)chatBackgroundImagePath {
    NSString *imageName = [[NSUserDefaults standardUserDefaults] stringForKey:kChatBackgroundImageName];
    if (imageName.length) {
        return [CTFileManger pathWithFileName:imageName folderName:UCChatDataFolderName];
    } else {
        return [[NSBundle mainBundle] pathForResource:@"chat_list_bg" ofType:@"png"];
    }
}

+ (void)setChatBackgroundImageData:(NSData *)imageData {
    NSString *path = [CTFileManger createFile:UCChatDataBackgroundFileName atFolder:UCChatDataFolderName data:imageData];
    if (path.length) {
        [[NSUserDefaults standardUserDefaults] setObject:UCChatDataBackgroundFileName forKey:kChatBackgroundImageName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self postNotifactionOnMainQueue:UCChatBackgroundImagePathChangedNotification withUserInfo:nil];
    }
}

+ (void)postNotifactionOnMainQueue:(NSString *)notification withUserInfo:(NSDictionary *)userInfo {
    
    void(^mainBlock)(void) = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    };
    
    if ([NSThread isMainThread]) {
        mainBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            mainBlock();
        });
    }
}

@end
