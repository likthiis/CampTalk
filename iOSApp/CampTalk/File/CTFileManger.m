//
//  CTFileManger.m
//  CampTalk
//
//  Created by renge on 2018/5/9.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTFileManger.h"

@implementation CTFileManger

//获取Documents目录
+ (NSString *)dirDoc {
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString *)pathWithFolderName:(NSString *)folderName {
    NSString *documentsPath = [self dirDoc];
    NSString *directory = [documentsPath stringByAppendingPathComponent:folderName];
    return directory;
}

+ (NSString *)createFolderWithName:(NSString *)folder {
    
    NSString *directory = [self pathWithFolderName:folder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res = [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    if (res) {
        NSLog(@"succeed");
    } else {
        NSLog(@"failed");
    }
    return res ? directory : nil;
}

+ (NSString *)pathWithFileName:(NSString *)fileName folderName:(NSString *)folderName {
    NSString *directory = [self pathWithFolderName:folderName];
    NSString *path = [directory stringByAppendingPathComponent:fileName];
    return path;
}

+ (NSString *)createFile:(NSString *)fileName atFolder:(NSString *)folderName data:(NSData *)data {
    
    [self createFolderWithName:folderName];
    
    NSString *path = [self pathWithFileName:fileName folderName:folderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res = [fileManager createFileAtPath:path contents:data attributes:nil];
    if (res) {
        NSLog(@"succeed");
    } else {
        NSLog(@"failed");
    }
    return res ? path : nil;
}

@end
