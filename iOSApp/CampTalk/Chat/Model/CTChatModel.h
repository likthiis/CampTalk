//
//  CTChatModel.h
//  CampTalk
//
//  Created by LD on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTChatModel : NSObject

// message
@property (nonatomic, copy) NSString *message;

// url
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;

// image
@property (nonatomic, assign) CGSize thumbSize; // "4.5,2"
@property (nonatomic, copy) NSString *thumbUrl;

@property (nonatomic, assign) CGSize originalImageSize; // "45,20"
@property (nonatomic, copy) NSString *originalImageUrl;

// userInfo
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userIconUrl;

// deviceInfo
@property (nonatomic, assign) NSInteger sendTime;
@property (nonatomic, assign) NSInteger version;

@end
