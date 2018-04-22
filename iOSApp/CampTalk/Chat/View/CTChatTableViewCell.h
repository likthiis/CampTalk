//
//  CTChatTableViewCell.h
//  CampTalk
//
//  Created by kikilee on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTChatBubbleLabel.h"

extern NSString *const CTChatTableViewCellId;

@interface CTChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet CTChatBubbleLabel *chatBubbleLabel;

+ (void)registerForTableView:(UITableView *)tableView;

+ (CGFloat)heightWithText:(NSString *)string tableView:(UITableView *)tableView;
+ (CGFloat)estimatedHeightWithText:(NSString *)string tableView:(UITableView *)tableView;

+ (CGFloat)heightWithAttributeString:(NSAttributedString *)string iconSize:(CGSize)iconSize tableView:(UITableView *)tableView;

- (void)setGradientBegain:(CGFloat)begain end:(CGFloat)end;
@end
