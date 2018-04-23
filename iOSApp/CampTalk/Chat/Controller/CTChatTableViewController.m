//
//  CTChatTableViewController.m
//  CampTalk
//
//  Created by renge on 2018/4/19.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTChatTableViewController.h"

#import "CTChatTableViewCell.h"
#import "CTChatInputView.h"
#import "CTStubbornView.h"

#import "UIImage+Read.h"
#import "UINavigationController+ShouldPop.h"

#import "CTChatModel.h"

static CGFloat kMinInputViewHeight = 60.f;

@interface CTChatTableViewController () <CTChatInputViewDelegate, UINavigationControllerShouldPopDelegate>

@property (nonatomic, strong) CTStubbornView *stubbornView;
@property (nonatomic, strong) CTChatInputView *inputView;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL needScrollToBottom;
@property (nonatomic, assign) BOOL viewControllerWillPop;

@property (nonatomic, strong) NSMutableArray <CTChatModel *> *data;

@end

@implementation CTChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"富士山烤肉场";
    
    _stubbornView = [[CTStubbornView alloc] initWithFrame:self.view.bounds];
    _stubbornView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_stubbornView];
    
    [CTChatTableViewCell registerForTableView:self.tableView];
    
    UIImage *image = [UIImage imageWithFullName:@"chatBg" extension:@"png"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:image];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nvgbar_music"] style:UIBarButtonItemStylePlain target:self action:nil];
    
    _data = [NSMutableArray array];
    int i = 100;
    NSMutableString *string = [[NSMutableString alloc] init];
    while (i--) {
        [string appendString:@"啊"];
        CTChatModel *model = [CTChatModel new];
        model.message = string;
        [_data addObject:model];
    }
    _needScrollToBottom = YES;
    
    _inputView = [[CTChatInputView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kMinInputViewHeight, self.view.bounds.size.width, kMinInputViewHeight)];
    _inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _inputView.delegate = self;
    [self __configInputViewLayout];
    [_stubbornView addSubview:_inputView];
    
    [self __addKeyboardNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_needScrollToBottom) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self->_data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self->_data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
        _needScrollToBottom = NO;
    }
}

- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigationController isInteractive:(BOOL)isInteractive {
    _viewControllerWillPop = YES;
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController interactivePopResult:(BOOL)finished {
    _viewControllerWillPop = finished;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CTChatTableViewCell estimatedHeightWithText:_data[indexPath.row].message tableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [CTChatTableViewCell heightWithText:_data[indexPath.row].message tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CTChatTableViewCellId forIndexPath:indexPath];
    cell.iconView.image = [UIImage imageNamed:@"zhimalin"];
    cell.chatBubbleLabel.label.text = _data[indexPath.row].message;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self adjustCellAlphaForIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect bounds = self.view.bounds;
    _stubbornView.frame = bounds;
    
    [[self.tableView indexPathsForVisibleRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull visibleIndexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        [self adjustCellAlphaForIndexPath:visibleIndexPath];
    }];
}

- (void)adjustCellAlphaForIndexPath:(NSIndexPath *)indexPath {
    CTChatTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return;
    }
    
    CGFloat offset = self.tableView.contentOffset.y;
    
    CGRect barFrame = self.navigationController.navigationBar.frame;
    barFrame.size.height += barFrame.origin.y;
    barFrame.origin.y = offset;
  
    barFrame.size.height += 20.f;
    CGFloat coverd = CGRectGetMaxY(barFrame) - cell.frame.origin.y;

    if (coverd > 0.f) {
        
        CGFloat gradientSpace = MIN(35.f, coverd);
        CGFloat percent = (coverd - gradientSpace)/cell.frame.size.height;
        CGFloat gradientPercent = coverd / cell.frame.size.height;
        
        [cell setGradientBegain:percent end:gradientPercent];
        
    } else {
        [cell setGradientBegain:0 end:0];
    }
}

#pragma mark - CTChatInputViewDelegate

- (void)contentSizeDidChange:(CTChatInputView *)chatInputView size:(CGSize)size {
    [self __configInputViewLayout];
}

- (void)__configInputViewLayout {
    if (_viewControllerWillPop) {
        return;
    }
    
    CGFloat inputHeight = MAX(kMinInputViewHeight, _inputView.contentHeight);
    _inputView.frame = CGRectMake(0, self.view.frame.size.height - inputHeight - _keyboardHeight, self.view.bounds.size.width, inputHeight);
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    CGFloat bottom = self.view.frame.size.height - CGRectGetMinY(_inputView.frame) + 10.f;
    
    contentOffset.y += bottom - contentInset.bottom;
    contentInset.bottom = bottom;
    
    self.tableView.contentInset = contentInset;
    self.tableView.contentOffset = contentOffset;
}

#pragma mark - Keyboard

- (void)__addKeyboardNotification {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect selfFrame = [self.view convertRect:self.view.bounds toView:nil];
    
    _keyboardHeight = (selfFrame.origin.y + selfFrame.size.height) - kbFrame.origin.y;
    if (_keyboardHeight < 0) {
        _keyboardHeight = 0;
    } else {
        CGFloat markKeyBoardHeight = _keyboardHeight;
        CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGFloat delay = (kbFrame.size.height - _keyboardHeight) / kbFrame.size.height * duration;
        [UIView animateWithDuration:duration - delay delay:delay options:0 animations:^{
            [self __configInputViewLayout];
        } completion:^(BOOL finished) {
            if (self->_keyboardHeight != markKeyBoardHeight) {
                [UIView animateWithDuration:0.1 animations:^{
                    [self __configInputViewLayout];
                }];
            }
        }];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect selfFrame = [self.view convertRect:self.view.bounds toView:nil];
    _keyboardHeight = (selfFrame.origin.y + selfFrame.size.height) - kbFrame.origin.y;
    if (_keyboardHeight < 0) {
        _keyboardHeight = 0;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (_keyboardHeight != 0) {
        CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        duration = _keyboardHeight / kbFrame.size.height * duration;
        
        _keyboardHeight = 0;
        
        [UIView animateWithDuration:duration animations:^{
            [self __configInputViewLayout];
        } completion:^(BOOL finished) {
            
        }];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
