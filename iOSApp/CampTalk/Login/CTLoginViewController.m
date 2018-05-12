//
//  CTLoginViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/11.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTLoginViewController.h"
#import "FLAnimatedImage.h"

#import "CTInputTableViewCell.h"

@interface CTLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) CTInputTableViewCell *accountId;
@property (nonatomic, strong) CTInputTableViewCell *password;

@property (nonatomic, strong) CTInputTableViewCell *login;

@property (nonatomic, strong) FLAnimatedImageView *gitView;

@end

@implementation CTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"yuru_camp_login" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    FLAnimatedImage *gif = [FLAnimatedImage animatedImageWithGIFData:data];
    _gitView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, gif.size.width, gif.size.height)];
    _gitView.contentMode = UIViewContentModeCenter;
    _gitView.animatedImage = gif;
    
    [self startAnimate];
    
    self.tableView.tableHeaderView = _gitView;
    self.tableView.backgroundColor = [UIColor colorWithRed:146.f/255.f green:224.f/255.f blue:205.f/255.f alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
}

- (void)startAnimate {
    if (!_gitView.isAnimating) {
        [_gitView startAnimating];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:_gitView selector:@selector(stopAnimating) object:nil];
    [_gitView performSelector:@selector(stopAnimating) withObject:nil afterDelay:3.f];
}

- (CTInputTableViewCell *)accountId {
    if (!_accountId) {
        _accountId = [[CTInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CTInputTableViewCellId];
        _accountId.backgroundColor = [UIColor clearColor];
        _accountId.textFieldEdge = UIEdgeInsetsMake(0, 20, 0, 20);
        _accountId.textField.tintColor = [UIColor blackColor];
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account"]];
        left.frame = CGRectMake(0, 0, 24, 40);
        left.contentMode = UIViewContentModeLeft;
        _accountId.textField.leftViewMode = UITextFieldViewModeAlways;
        _accountId.textField.leftView = left;
        _accountId.textField.returnKeyType = UIReturnKeyDone;
        _accountId.textField.delegate = self;
    }
    return _accountId;
}

- (CTInputTableViewCell *)password {
    if (!_password) {
        _password = [[CTInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CTInputTableViewCellId];
        _password.backgroundColor = [UIColor clearColor];
        _password.textField.secureTextEntry = YES;
        _password.textFieldEdge = UIEdgeInsetsMake(0, 20, 0, 20);
        _password.textField.tintColor = [UIColor blackColor];
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
        left.frame = CGRectMake(0, 0, 24, 40);
        left.contentMode = UIViewContentModeLeft;
        _password.textField.leftViewMode = UITextFieldViewModeAlways;
        _password.textField.leftView = left;
        _password.textField.returnKeyType = UIReturnKeyDone;
        _password.textField.delegate = self;
    }
    return _password;
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return self.accountId;
        case 1:
            return self.password;
        case 2:
            return [UITableViewCell new];
        default:
            return [UITableViewCell new];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self startAnimate];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self startAnimate];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self startAnimate];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self startAnimate];
    return [textField resignFirstResponder];
}
@end
