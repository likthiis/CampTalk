//
//  CTChatModel.m
//  CampTalk
//
//  Created by LD on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatModel.h"

@implementation CTChatModel

+ (NSMutableArray<CTChatModel *> *)fakeList {
    NSMutableArray *data = [NSMutableArray array];
    int i = 10;
    NSMutableString *string = [[NSMutableString alloc] init];
    while (i--) {
        [string appendString:@"啊"];
        CTChatModel *model = [CTChatModel new];
        [data addObject:model];
        
        if (i > 0 && i <= 3) {
            NSString *size = [NSString stringWithFormat:@"@{%f,%f}", powf(15, i), powf(15, i)];
            model.thumbSize = CGSizeFromString(size);
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"chatBg_1" ofType:@"jpg"];
            model.thumbUrl = [NSURL fileURLWithPath:filePath].absoluteString;
        } else {
            model.message = string;
        }
        model.userId = @"lin";
    }
    data = [NSMutableArray arrayWithArray:[[data reverseObjectEnumerator] allObjects]];
    
    CTChatModel *model = [CTChatModel new];
    model.message = @"请、请让我分15期付款";
    
    [data insertObject:model atIndex:data.count - 3];
    return data;
}

@end
