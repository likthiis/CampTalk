//
//  CTLoginViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/11.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTLoginViewController.h"
#import "FLAnimatedImage.h"
#import "AFNetworking.h"

#import <RGUIKit/RGUIKit.h>

@interface CTLoginViewController () <RGInputCellDelegate>

@property (nonatomic, strong) RGInputTableViewCell *accountId;
@property (nonatomic, strong) RGInputTableViewCell *password;

@property (nonatomic, strong) RGInputTableViewCell *login;

@property (nonatomic, strong) FLAnimatedImageView *gifView;

@property (nonatomic, strong) FLAnimatedImageView *fireView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIButton *resultButton;

@property (nonatomic, assign) BOOL autoCancelAnimate;

@end

typedef enum : NSUInteger {
    CTLoginResultButtonStateNone,
    CTLoginResultButtonStateOK,
    CTLoginResultButtonStateError,
    CTLoginResultButtonStateNeedRefresh,
} CTLoginResultButtonState;

@implementation CTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"yuru_camp_login" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    FLAnimatedImage *gif = [FLAnimatedImage animatedImageWithGIFData:data];
    _gifView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, gif.size.width, gif.size.height)];
    _gifView.contentMode = UIViewContentModeCenter;
    _gifView.animatedImage = gif;
    
    [self startAnimate];
    self.autoCancelAnimate = YES;
    
    self.tableView.tableHeaderView = _gifView;
    self.tableView.backgroundColor = [UIColor colorWithRed:146.f/255.f green:224.f/255.f blue:205.f/255.f alpha:1.f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
}

- (FLAnimatedImageView *)fireView {
    if (!_fireView) {
        NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"fire" withExtension:@"gif"]];
        FLAnimatedImage *gif = [FLAnimatedImage animatedImageWithGIFData:data];
        _fireView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, gif.size.width, gif.size.height)];
        _fireView.contentMode = UIViewContentModeCenter;
        _fireView.animatedImage = gif;
    }
    return _fireView;
}

- (void)startAnimate {
    if (!_gifView.isAnimating) {
        [_gifView startAnimating];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimating) object:nil];
    [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:3.f];
}

- (void)stopAnimating {
    if (!_autoCancelAnimate) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimating) object:nil];
    [_gifView stopAnimating];
}

- (void)setAutoCancelAnimate:(BOOL)autoCancelAnimate {
    
    if (_autoCancelAnimate == autoCancelAnimate) {
        return;
    }
    _autoCancelAnimate = autoCancelAnimate;
    
    if (_autoCancelAnimate) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimating) object:nil];
        [self performSelector:@selector(stopAnimating) withObject:nil afterDelay:3.f];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopAnimating) object:nil];
    }
}

- (RGInputTableViewCell *)accountId {
    if (!_accountId) {
        _accountId = [[RGInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RGInputTableViewCellID];
        _accountId.backgroundColor = [UIColor clearColor];
        _accountId.textFieldEdge = UIEdgeInsetsMake(0, 20, 0, 0);
        _accountId.rightViewEdge = UIEdgeInsetsMake(0, 0, 0, 20);
        _accountId.textField.tintColor = [UIColor blackColor];
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account"]];
        left.frame = CGRectMake(0, 0, 24, 40);
        left.contentMode = UIViewContentModeLeft;
        _accountId.textField.leftViewMode = UITextFieldViewModeAlways;
        _accountId.textField.leftView = left;
        _accountId.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountId.textField.returnKeyType = UIReturnKeyDone;
        _accountId.delegate = self;
        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_loadingView sizeToFit];
        
        UIView *wapper = [[UIView alloc] initWithFrame:_loadingView.bounds];
        
        _resultButton = [[UIButton alloc] initWithFrame:_loadingView.bounds];
        _resultButton.alpha = 0.f;
        [_resultButton addTarget:self action:@selector(checkUserId:) forControlEvents:UIControlEventTouchUpInside];
        
        [wapper addSubview:_resultButton];
        [wapper addSubview:_loadingView];
        
        _accountId.rightView = wapper;
    }
    return _accountId;
}

- (RGInputTableViewCell *)password {
    if (!_password) {
        _password = [[RGInputTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RGInputTableViewCellID];
        _password.backgroundColor = [UIColor clearColor];
        _password.textField.secureTextEntry = YES;
        _password.textFieldEdge = UIEdgeInsetsMake(0, 20, 0, 20);
        _password.textField.tintColor = [UIColor blackColor];
        UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
        left.frame = CGRectMake(0, 0, 24, 40);
        left.contentMode = UIViewContentModeLeft;
        _password.textField.leftViewMode = UITextFieldViewModeAlways;
        _password.textField.leftView = left;
        _password.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _password.textField.returnKeyType = UIReturnKeyDone;
        _password.delegate = self;
    }
    return _password;
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)rg_inputCellTextDidChange:(RGInputTableViewCell *)cell text:(NSString *)text {
    [self startAnimate];
    if (cell == self.accountId) {
        
        self.resultButton.alpha = 0.f;
        [self.loadingView startAnimating];
        self.tableView.tableFooterView = nil;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doCheckUser) object:nil];
        
        if (text.length) {
            [self performSelector:@selector(doCheckUser) withObject:nil afterDelay:2.f];
        } else {
            [self.loadingView stopAnimating];
            self.resultButton.alpha = 0.f;
        }
    }
}

- (void)checkUserId:(UIButton *)sender {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        sender.transform = CGAffineTransformMakeRotation(M_PI);
        sender.alpha = 0.7f;
        
    } completion:^(BOOL finished) {
        
        if (!self.accountId.inputText.length) {
            self.resultButton.alpha = 0.f;
            return;
        }
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            sender.alpha = 0.f;
            sender.transform = CGAffineTransformMakeRotation(0);
            [self.loadingView startAnimating];
            [self doCheckUser];
            
        } completion:nil];
    }];
}

- (void)doCheckUser {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doCheckUser) object:nil];
    
    [self startAnimate];
    self.autoCancelAnimate = NO;
    
    NSString *text = [self.accountId.inputText copy];
    
    // @"http:211.159.166.251:16233//query/query_existence"
    // @{@"uid":text}
    NSString *userCheckUrl = @"https://renged.xyz/user/check";
    
    [[AFHTTPSessionManager manager] GET:userCheckUrl parameters:@{@"username":text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (![self.accountId.inputText isEqualToString:text]) {
            return;
        }
        
        self.autoCancelAnimate = YES;
        [self.loadingView stopAnimating];
        
        self.resultButton.alpha = 1.f;
        self.resultButton.transform = CGAffineTransformMakeRotation(0);
        
        NSInteger code = [responseObject[@"code"] intValue];
        if (code == 1000) {
            [self setResultButtonState:CTLoginResultButtonStateOK];
        } else if (code == 1001) {
            [self setResultButtonState:CTLoginResultButtonStateError];
        } else {
            [self setResultButtonState:CTLoginResultButtonStateNeedRefresh];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (![self.accountId.inputText isEqualToString:text]) {
            return;
        }
        
        self.autoCancelAnimate = YES;
        [self.loadingView stopAnimating];
        
        self.resultButton.transform = CGAffineTransformMakeRotation(M_PI);
        self.resultButton.alpha = 0.f;
        [self setResultButtonState:CTLoginResultButtonStateNeedRefresh];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.resultButton.transform = CGAffineTransformMakeRotation(2 * M_PI);
            self.resultButton.alpha = 1.f;
            
        } completion:^(BOOL finished) {
            if (!self.accountId.inputText.length) {
                self.resultButton.alpha = 0.f;
            }
        }];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self startAnimate];
    return [textField resignFirstResponder];
}

- (void)setResultButtonState:(CTLoginResultButtonState)state {
    switch (state) {
        case CTLoginResultButtonStateError:
            [self.resultButton setBackgroundImage:[UIImage imageNamed:@"user_check_exist"] forState:UIControlStateNormal];
            self.resultButton.userInteractionEnabled = NO;
            break;
        case CTLoginResultButtonStateNeedRefresh:
            [self.resultButton setBackgroundImage:[UIImage imageNamed:@"user_check_refresh"] forState:UIControlStateNormal];
            self.resultButton.userInteractionEnabled = YES;
            break;
        case CTLoginResultButtonStateOK:
            [self.resultButton setBackgroundImage:[UIImage imageNamed:@"user_check_ok"] forState:UIControlStateNormal];
            self.resultButton.userInteractionEnabled = NO;
            break;
        default:
            [self.resultButton setImage:nil forState:UIControlStateNormal];
            self.resultButton.userInteractionEnabled = NO;
            break;
    }
    if (state == CTLoginResultButtonStateOK) {
        self.tableView.tableFooterView = self.fireView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

@end
