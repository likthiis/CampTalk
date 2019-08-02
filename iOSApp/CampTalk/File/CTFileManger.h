//
//  CTFileManger.h
//  CampTalk
//
//  Created by renge on 2018/5/9.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTFileManger : NSObject

+ (NSString *)dirDoc;

+ (NSString *)pathWithFolderName:(NSString *)folderName;
+ (NSString *)createFolderWithName:(NSString *)folder;

+ (NSString *)pathWithFileName:(NSString *)fileName folderName:(NSString *)folderName;
+ (NSString *)fileExistedWithFileName:(NSString *)fileName folderName:(NSString *)folderName;

+ (NSString *)createFile:(NSString *)fileName atFolder:(NSString *)folderName data:(NSData *)data;
+ (NSString *)createFile:(NSString *)fileName extension:(NSString *)extension atFolder:(NSString *)folderName data:(NSData *)data;

@end
