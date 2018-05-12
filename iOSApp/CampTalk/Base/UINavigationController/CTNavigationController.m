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

+ (CTNavigationController *)navigationWithRoot:(UIViewController *)root {
    CTNavigationController *ngv = [[CTNavigationController alloc] initWithRootViewController:root];
    return ngv;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(configBar) object:nil];
    [self performSelector:@selector(configBar) withObject:nil afterDelay:0.f inModes:@[NSRunLoopCommonModes]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setType:(CTNavigationBackgroundType)type {
    _type = type;
    if (self.isViewLoaded) {
        [self configBar];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(configBar) object:nil];
        [self performSelector:@selector(configBar) withObject:nil afterDelay:0.f inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)configBar {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(configBar) object:nil];
    switch (_type) {
        case CTNavigationBackgroundTypeNormal:
            [self.navigationBar setTranslucent:YES];
            [self.navigationBar setShadowImage:nil];
            [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
            [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompactPrompt];
            break;
        case CTNavigationBackgroundTypeAllTranslucent: {
            [self.navigationBar setTranslucent:YES];
            UIImage *barBg = [UIImage new];
            [self.navigationBar setShadowImage:barBg];
            [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsCompact];
            [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsCompactPrompt];
            break;
        }
        case CTNavigationBackgroundTypeShadow: {
            [self.navigationBar setTranslucent:YES];
            [self.navigationBar setShadowImage:[UIImage new]];
            UIImage *barBg = nil;
            if ([UIApplication sharedApplication].statusBarFrame.size.height > 20.f) {
                barBg = [UIImage imageNamed:@"gradientBarBg_fringe"];
            } else {
                barBg = [UIImage imageNamed:@"gradientBarBg"];
            }
            [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsDefault];
            
            barBg = [UIImage imageNamed:@"gradientBarBg_landscape"];
            [self.navigationBar setBackgroundImage:barBg forBarMetrics:UIBarMetricsCompact];
            [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompactPrompt];
            break;
        }
        default:
            break;
    }
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
