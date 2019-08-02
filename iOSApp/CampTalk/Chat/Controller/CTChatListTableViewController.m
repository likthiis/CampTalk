//
//  CTChatListTableViewController.m
//  CampTalk
//
//  Created by renge on 2018/10/31.
//  Copyright © 2018 yuru. All rights reserved.
//

#import "CTChatListTableViewController.h"
#import "CTChatTableViewController.h"

#import <RGUIKit/RGUIKit.h>

#import "CTStubbornView.h"

@interface CTChatListTableViewController ()

@property (nonatomic, strong) CTStubbornView *tableViewCover;

@end

@implementation CTChatListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    
    self.rg_navigationController.tintColor = [UIColor whiteColor];
    self.rg_navigationController.barBackgroundStyle = RGNavigationBackgroundStyleShadow;
    
    [RGIconCell setThemeColor:[UIColor colorWithRed:67.f/255.f green:51.f/255.f blue:130.f/255.f alpha:1.f]];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self configBgImageView:bgView];
    self.tableView.backgroundView = bgView;
    
    self.tableView.rowHeight = 64.f;
//    self.tableView.separatorColor = [UIColor colorWithRed:67.f/255.f green:51.f/255.f blue:130.f/255.f alpha:1.f];
    self.tableView.separatorEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    [self.tableView registerClass:RGIconCell.class forCellReuseIdentifier:RGCellID];
    
    [self.view addSubview:self.tableViewCover];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self __configStubbornViewLayout];
}

- (CTStubbornView *)tableViewCover {
    if (!_tableViewCover) {
        _tableViewCover = [[CTStubbornView alloc] initWithFrame:self.tableView.bounds];
        [self configBgImageView:_tableViewCover];
        [_tableViewCover setGradientDirection:YES];
        [self.tableView addSubview:_tableViewCover];
    }
    return _tableViewCover;
}

- (void)configBgImageView:(UIImageView *)bgImageView {
    [self backgroundImage:^(UIImage *image) {
        bgImageView.image = image;
    }];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIView *mask = [bgImageView viewWithTag:1];
    if (!mask) {
        mask = [[UIView alloc] initWithFrame:bgImageView.bounds];
        mask.tag = 1;
        mask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        mask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [bgImageView addSubview:mask];
    }
}

- (void)backgroundImage:(void(^)(UIImage *image))image {
    if (image) {
        image([UIImage rg_imageWithFullName:@"[Moozzi2] Yuru Camp - 05 (BD 1920x1080 x.264 Flac)-0002" extension:@"png"]);
    }
}

- (void)__configStubbornViewLayout {
    _tableViewCover.frame = self.tableView.bounds;
    [self __adjustTableViewCoverAlpha];
}

- (void)__adjustTableViewCoverAlpha {
    CGRect barFrame = self.navigationController.navigationBar.frame;
    
    CGFloat begain = (barFrame.origin.y + barFrame.size.height / 2.f) / _tableViewCover.bounds.size.height;
    
    CGFloat end = (barFrame.size.height + barFrame.origin.y + 10.f) / _tableViewCover.bounds.size.height;
    [_tableViewCover setGradientBegain:begain end:end];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RGIconCell *cell = [tableView dequeueReusableCellWithIdentifier:RGCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.iconSize = CGSizeMake(52, 52);
    cell.applyThemeColor = YES;
    cell.imageView.layer.cornerRadius = 26;
    cell.textLabel.text = @"伟大如名应援会";
    cell.detailTextLabel.text = @"叶舞枫: [图片]";
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.f];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    cell.imageView.image = [UIImage rg_imageWithFullName:@"miziha" extension:@"JPG"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CTChatTableViewController *vc = [CTChatTableViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
