//
//  CTStubbornView.m
//  CampTalk
//
//  Created by RengeRenge on 2018/4/23.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTStubbornView.h"

@implementation CTStubbornView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self){
        return nil;
    }
    return hitView;
}

@end
