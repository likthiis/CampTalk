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
#import "CTCameraView.h"
#import "CTMusicButton.h"

#import "UIImage+Read.h"
#import "UIImage+Tint.h"
#import "UINavigationController+ShouldPop.h"
#import "UIViewController+SafeArea.h"
#import "UIViewController+DragBarItem.h"
#import "UIView+PanGestureHelp.h"

#import "CTChatModel.h"

static CGFloat kMinInputViewHeight = 60.f;

static NSString * const kCTChatToolConfig = @"kCTChatToolConfig";
static NSMutableDictionary <NSString *, NSArray <NSNumber *> *> *__toolConfig;

typedef enum : NSUInteger {
    CTChatToolIconIdCamara = 100,
    CTChatToolIconIdMusic,
} CTChatToolIconId;

typedef enum : NSUInteger {
    CTChatToolIconUnknow = 0,
    CTChatToolIconPlaceNavigation,
    CTChatToolIconPlaceMainView,
    CTChatToolIconPlaceInputView,
    CTChatToolIconPlaceCount,
} CTChatToolIconPlace;

@interface CTChatTableViewController () <CTChatInputViewDelegate, UINavigationControllerShouldPopDelegate, CTCameraViewDelegate, CAAnimationDelegate>

@property (nonatomic, strong) CTStubbornView *stubbornView;
@property (nonatomic, strong) CTChatInputView *inputView;
@property (nonatomic, strong) CTCameraView *cameraView;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL needScrollToBottom;
@property (nonatomic, assign) BOOL viewControllerWillPop;

@property (nonatomic, strong) NSMutableArray <CTChatModel *> *data;

@property (nonatomic, strong) CTMusicButton *dragButton;

@end

@implementation CTChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"富士山烤肉场";
    
    _stubbornView = [[CTStubbornView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_stubbornView];
    
    [CTChatTableViewCell registerForTableView:self.tableView];
    
    UIImage *image = [UIImage imageWithFullName:@"chatBg" extension:@"png"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:image];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.tableView.backgroundView = bgView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.delaysContentTouches = NO;
    
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
    
    _cameraView = [[CTCameraView alloc] init];
    _cameraView.delegate = self;
    _cameraView.hidden = YES;
    [_cameraView showInView:_stubbornView];
    
    [self __configIconPlace];
    
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self __configStubbornViewLayout];
}

- (void)__configIconPlace {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kCTChatToolConfig];
        if (dic) {
            __toolConfig = [NSMutableDictionary dictionaryWithDictionary:dic];
        } else {
            NSDictionary *dic = @{
                                  @(CTChatToolIconPlaceNavigation).stringValue : @[@(CTChatToolIconIdMusic)],
                                  @(CTChatToolIconPlaceMainView).stringValue : @[@(CTChatToolIconIdCamara)],
                                };
            __toolConfig = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    });
    
    [_inputView removeAllToolBarItem];
    [self removeAllRightDragBarItem];
    
    NSArray <NSString *> *allkeys = [__toolConfig allKeys];
    for (NSString *placeNumber in allkeys) {
        CTChatToolIconPlace place = placeNumber.integerValue;
        
        NSArray <NSNumber *> *allIcon = __toolConfig[placeNumber];
        
        for (NSNumber *iconIdNumber in allIcon) {
            
            CTChatToolIconId iconId = iconIdNumber.integerValue;
            
            switch (place) {
                case CTChatToolIconPlaceInputView: {
                    UIView *icon = [self iconCopyWithIconId:iconId];
                    [_inputView addToolBarItem:[CTChatInputViewToolBarItem itemWithIcon:icon identifier:iconId]];
                    if (iconId == CTChatToolIconIdCamara) {
                        _cameraView.hidden = YES;
                    }
                    break;
                }
                case CTChatToolIconPlaceNavigation: {
                    UIView *icon = [self iconCopyWithIconId:iconId];
                    [self addRightDragBarItemWithIcon:icon itemId:iconId];
                    if (iconId == CTChatToolIconIdCamara) {
                        _cameraView.hidden = YES;
                    }
                    break;
                }
                case CTChatToolIconPlaceMainView: {
                    switch (iconId) {
                        case CTChatToolIconIdCamara:
                            _cameraView.hidden = NO;
                            break;
                        default:
                            break;
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)__updateIconConfig {
    
    NSMutableArray <NSNumber *> *icons = [NSMutableArray arrayWithArray:@[@(CTChatToolIconIdCamara), @(CTChatToolIconIdMusic)]];
    
    for (CTChatToolIconPlace place = CTChatToolIconPlaceNavigation; place < CTChatToolIconPlaceCount; place ++) {
        NSMutableArray *newArray = [NSMutableArray array];
        switch (place) {
            case CTChatToolIconPlaceMainView:{
                [icons enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.integerValue == CTChatToolIconIdCamara && !self.cameraView.isHidden) {
                        [newArray addObject:obj];
                        *stop = YES;
                    }
                }];
                break;
            }
            case CTChatToolIconPlaceInputView:{
                [self.inputView.toolBarItems enumerateObjectsUsingBlock:^(CTChatInputViewToolBarItem * _Nonnull items, NSUInteger idx, BOOL * _Nonnull stop) {
                    [icons enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (items.identifier == obj.integerValue) {
                            [newArray addObject:obj];
                        }
                    }];
                }];
                break;
            }
            case CTChatToolIconPlaceNavigation:{
                NSArray <NSNumber *> *items = self.rightDragBarItemIds;
                [items enumerateObjectsUsingBlock:^(NSNumber * _Nonnull itemId, NSUInteger idx, BOOL * _Nonnull stop) {
                    [icons enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (itemId.integerValue == obj.integerValue) {
                            [newArray addObject:obj];
                        }
                    }];
                }];
            }
            default:
                break;
        }
        if (newArray.count) {
            [__toolConfig setObject:newArray forKey:@(place).stringValue];
        } else {
            [__toolConfig removeObjectForKey:@(place).stringValue];
        }
        [icons removeObjectsInArray:newArray];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:__toolConfig forKey:kCTChatToolConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIView *)iconCopyWithIconId:(CTChatToolIconId)iconId {
    UIView *icon = nil;
    switch (iconId) {
        case CTChatToolIconIdCamara:
            _cameraView.hidden = YES;
            icon = [self createCameraButton];
            break;
        case CTChatToolIconIdMusic:
            icon = [self createMusicButton];
            break;
        default:
            break;
    }
    return icon;
}

- (void)__configStubbornViewLayout {
    CGRect bounds = self.view.bounds;
    _stubbornView.frame = UIEdgeInsetsInsetRect(bounds, self.viewSafeAreaInsets);
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
    
    [self __configStubbornViewLayout];
    
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
    
    CGRect bounds = _stubbornView.bounds;
    
    CGFloat inputHeight = MAX(kMinInputViewHeight, _inputView.contentHeight);
    _inputView.frame = CGRectMake(0, bounds.size.height - inputHeight - _keyboardHeight, bounds.size.width, inputHeight);
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    CGFloat bottomMargin = 10.f;
    CGFloat bottom = bounds.size.height - CGRectGetMinY(_inputView.frame) + bottomMargin;
    
    contentOffset.y += bottom - contentInset.bottom;
    contentInset.bottom = bottom;
    
    self.tableView.contentInset = contentInset;
    self.tableView.contentOffset = contentOffset;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = bottom - bottomMargin;
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)chatInputView:(CTChatInputView *)chatInputView willRemoveItem:(CTChatInputViewToolBarItem *)item syncAnimations:(void (^)(void))syncAnimations {
    
    __weak typeof(self) wSelf = self;
    
    UIView *icon = item.icon;
    
    CGPoint center = [chatInputView convertPoint:icon.center toView:self.stubbornView];
    [icon removeFromSuperview];
    icon.tintColor = chatInputView.tintColor;
    [self.stubbornView addSubview:icon];
    icon.center = center;
    
    [self addRightDragBarItemWithDragIcon:icon
                                   itmeId:item.identifier
                          ignoreIntersect:item.identifier == CTChatToolIconIdMusic
                                 copyIcon:^UIView *{
                                     return [wSelf iconCopyWithIconId:item.identifier];
                                 } syncAnimate:^(UIView *customView) {
                                     icon.tintColor = customView.tintColor;
                                     syncAnimations();
                                 } completion:^(BOOL added) {
                                     if (!added) {
                                         if (item.identifier == CTChatToolIconIdCamara) {
                                             wSelf.cameraView.hidden = NO;
                                             [wSelf.cameraView setCameraButtonCenterPoint:[icon.superview convertPoint:icon.center toView:wSelf.cameraView]];
                                             
                                             [wSelf.cameraView showCameraButtonWithAnimate:NO];
                                             [wSelf.cameraView performSelector:@selector(hideCameraButton) withObject:nil afterDelay:1];
                                             
                                             [UIView animateWithDuration:0.3 animations:^{
                                                 syncAnimations();
                                             } completion:^(BOOL finished) {
                                                 [wSelf __updateIconConfig];
                                             }];
                                         }
                                     }
                                     [icon removeFromSuperview];
                                 }];
}

#pragma mark - CTCameraViewDelegate

- (void)cameraView:(CTCameraView *)cameraView didDragButton:(UIButton *)cameraButton {
    [_inputView updateInputViewDragIcon:cameraButton toolId:CTChatToolIconIdCamara copyIconBlock:^UIView *{
        return [self createCameraButton];
    }];
}

- (void)cameraView:(CTCameraView *)cameraView endDragButton:(UIButton *)cameraButton layoutBlock:(void (^)(BOOL))layout {
    
    __weak typeof(self) wSelf = self;
    
    [_inputView addOrRemoveInputViewToolBarWithDragIcon:cameraButton toolId:CTChatToolIconIdCamara copyIconBlock:^UIView *{
        
        return [wSelf createCameraButton];
        
    } customAnimate:nil completion:^(BOOL added) {
        
        if (added) {
            cameraView.hidden = YES;
            layout(YES);
            [wSelf __updateIconConfig];
            return;
        }
        
        [wSelf addRightDragBarItemWithDragIcon:cameraButton itmeId:CTChatToolIconIdCamara ignoreIntersect:NO copyIcon:^UIView *{
            return [wSelf createCameraButton];
        } syncAnimate:^(UIView *customView) {
            cameraButton.tintColor = customView.tintColor;
        } completion:^(BOOL added) {
            cameraButton.tintColor = nil;
            if (added) {
                cameraView.hidden = YES;
                layout(YES);
                return;
            }
            layout(added);
        }];
    }];
}

- (void)cameraView:(CTCameraView *)cameraView didTapButton:(UIButton *)cameraButton {
    [self shareMedia:cameraButton];
}

- (UIButton *)createCameraButton {
    UIButton *button = _cameraView.copyCameraButton;
    [button addTarget:self action:@selector(shareMedia:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)shareMedia:(UIButton *)sender {
    NSLog(@"share media");
}

#pragma mark - CTMusicButton

- (CTMusicButton *)createMusicButton {
    CTMusicButton *music = [CTMusicButton new];
    [music sizeToFit];
    music.tintColor = [UIColor whiteColor];
    
    __weak typeof(self) wSelf = self;
    music.clickBlock = ^(CTMusicButton *button) {
        [wSelf playMusic:button];
    };
    music.isPlaying = YES;
    return music;
}

- (void)playMusic:(CTMusicButton *)sender {
    NSLog(@"play music");
    sender.isPlaying = !sender.isPlaying;
}

#pragma mark - UIViewController + DragBarItem

- (void)dragItem:(UIView *)icon didDrag:(NSInteger)itmeId {
    [_inputView updateInputViewDragIcon:icon toolId:itmeId copyIconBlock:^UIView *{
        return [self iconCopyWithIconId:itmeId];
    }];
}

- (BOOL)dragItemShouldRemove:(UIView *)icon endDrag:(NSInteger)itmeId {
    
    __weak typeof(self) wSelf = self;
    __block BOOL remove = YES;
    
    [_inputView addOrRemoveInputViewToolBarWithDragIcon:icon toolId:itmeId copyIconBlock:^UIView *{
        return [wSelf iconCopyWithIconId:itmeId];
    } customAnimate:nil completion:^(BOOL added) {
        remove = added;
        if (added) {
            [wSelf __updateIconConfig];
            return;
        }
        
        if (itmeId == CTChatToolIconIdCamara) {
            
            remove = YES;
            
            wSelf.cameraView.hidden = NO;
            [wSelf.cameraView setCameraButtonCenterPoint:[icon.superview convertPoint:icon.center toView:wSelf.cameraView]];
            
            [wSelf.cameraView showCameraButtonWithAnimate:NO];
            [wSelf.cameraView performSelector:@selector(hideCameraButton) withObject:nil afterDelay:1];
        }
    }];
    return remove;
}

- (void)dragItemDidDragAdd:(UIView *)icon didDrag:(NSInteger)itemId {
    [self __updateIconConfig];
}

- (void)dragItemDidDragRemove:(UIView *)icon didDrag:(NSInteger)itemId {
    [self __updateIconConfig];
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
