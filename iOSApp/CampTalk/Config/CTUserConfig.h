//
//  CTUserConfig.h
//  CampTalk
//
//  Created by renge on 2018/5/9.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UCChatBackgroundImagePathChangedNotification;
extern NSString * const UCChatDataFolderName;

@interface CTUserConfig : NSObject

+ (NSString *)chatBackgroundImagePath;
+ (void)setChatBackgroundImageData:(NSData *)imageData;

@end
