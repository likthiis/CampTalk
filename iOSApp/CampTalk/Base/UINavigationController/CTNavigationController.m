//
//  CTNavigationController.m
//  CampTalk
//
//  Created by kikilee on 2018/4/20.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTNavigationController.h"

@interface CTNavigationController ()

@end

@implementation CTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationBar setTranslucent:YES];
    
    UIImage *barBg = nil;
    if ([UIApplication sharedApplication].statusBarFrame.size.height > 20.f) {
        barBg = [UIImage imageNamed:@"gradientBarBg_fringe"];
    } else {
        barBg = [UIImage imageNamed:@"gradientBarBg"];
    }
    [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsDefault];
    
    barBg = [UIImage imageNamed:@"gradientBarBg_landscape"];
    [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsCompact];
    
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
