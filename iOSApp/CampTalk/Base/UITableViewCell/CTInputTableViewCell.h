//
//  CTInputTableViewCell.h
//  CampTalk
//
//  Created by renge on 2018/5/12.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const CTInputTableViewCellId;

@interface CTInputTableViewCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) UIEdgeInsets textFieldEdge;

@property (nonatomic, assign) BOOL hideLine;
@property (nonatomic, strong) UIColor *lineColor; // default textField.tintColor
@property (nonatomic, assign) UIEdgeInsets lineEdge;

@end
