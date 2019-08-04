//
//  ImageGallery.m
//  yb
//
//  Created by LD on 16/4/2.
//  Copyright © 2016年 acumen. All rights reserved.
//

#import "ImageGallery.h"

#define TEXTFONTSIZE 14
#define BUTTON_CLICK_WIDTH  100
#define BUTTON_CLICK_HEIGHT 100
#define pageWidth (kScreenWidth + 20)

#define kScreenWidth    (self.view.bounds.size.width)
#define kScreenHeight   (self.view.bounds.size.height)
#define kTargetSize     CGSizeMake(kScreenWidth*[UIScreen mainScreen].scale, kScreenHeight*[UIScreen mainScreen].scale)

#define SYSTEM_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define ButtonTag 12222

@interface UIBigButton: UIButton

@end

@implementation UIBigButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds =self.bounds;
    CGFloat widthDelta = BUTTON_CLICK_WIDTH - bounds.size.width;
    CGFloat heightDelta = BUTTON_CLICK_HEIGHT - bounds.size.height;
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5* heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end

@class IGNavigationControllerDelegate;
@class IGPushAndPopAnimationController;
@class IGInteractionController;

@interface IGNavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL operateSucceed;
@property (nonatomic, assign) CGFloat leftProgress;
@property (nonatomic, strong) IGPushAndPopAnimationController *animationController;
@property (nonatomic, strong) IGInteractionController *interactionController;
@property (nonatomic, strong) NSMutableArray<IGInteractionController *> *interactionControllers;

- (IGInteractionController *)addPinchGestureOnView:(UIView *)view FromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC;

@end

@interface IGPushAndPopAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@property (nonatomic, weak) IGNavigationControllerDelegate *transitionDelegate;

- (instancetype)initWithNavigationControllerOperation:(UINavigationControllerOperation)operation;

@end

@interface IGInteractionController : UIPercentDrivenInteractiveTransition <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@property (nonatomic, assign) UINavigationControllerOperation operation;

@property (nonatomic, weak) UIViewController *toVC;
@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) IGNavigationControllerDelegate *transitionDelegate;

- (void)addPinchGestureOnView:(UIView *)view;

@end

@interface ImageGallery()
@property (nonatomic, strong) IGNavigationControllerDelegate *navigationControllerDelegate;
@property (nonatomic, strong) UILabel        *titleLabel;

@property (nonatomic, strong) UIToolbar       *toolbar;
@property (nonatomic, assign) BOOL toolbarIsHide;

@property (nonatomic, strong) NSMutableArray  *playButtonArr;

@property (nonatomic, strong) UIImage         *placeHolder;
@property (nonatomic, strong) UIImage         *barBackgroundImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, assign) id  viewControllerF;
@property (nonatomic, copy) UIColor *barTintColorF;
@property (nonatomic, copy) UIColor *tintColorF;
@property (nonatomic, assign) BOOL automaticallyAdjustsScrollViewInsetsF;
@property (nonatomic, assign) BOOL tabbarTranslucentF;
@property (nonatomic, assign) BOOL navigationTranslucentF;

@property (nonatomic, assign) BOOL hideTopBar;
@property (nonatomic, assign) BOOL hideToolBar;

- (CGRect)getImageViewFrameWithImage:(UIImage *)image;

@end

@implementation ImageGallery

- (instancetype)initWithPlaceHolder:(UIImage *)placeHolder andDelegate:(id)delegate{
    self = [super init];
    if(self){
        self.delegate       =   delegate;
        self.placeHolder    =   placeHolder;
        self.barBackgroundImage = nil;
        self.page           =   0;
        self.isPush         =   noPush;
        [self initImageScrollViewArr];
    }
    return self;
}
enum{
    leftFix,
    share,
    fix,
    play,
    fix2,
    delete,
    rightFix
};

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isPush == pushing) {
        [self getCountWithSetContentSize:YES];

        //Load OtherImage
        for (int i=0; i < self.scrollViewArr.count; i++) {
            if (i != middle) {
                [self requestImage:self.imageViewArr[i] withScrollView:self.scrollViewArr[i] atPage:_page-middle+i];
            }
        }
        [self setTitle];
        
        //Sequence ScrollViews
        [self setPositionAtPage:_page ignoreIndex:-1];
        
        [self.BgScrollView setDelegate:nil];
        [self.BgScrollView setContentOffset:CGPointMake(_page*pageWidth, 0) animated:NO];
        [self getCountWithSetContentSize:YES];
        [self.BgScrollView setDelegate:self];
    }
    [self hide:self.hideTopBar topbarWithAnimateDuration:0 backgroundChange:NO];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self setBackItem];
    [self configToolBar];
    [self.view addSubview:self.BgScrollView];
    _hideTopBar = NO;
    _hideToolBar = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self.navigationControllerDelegate;
    [self.navigationControllerDelegate addPinchGestureOnView:self.view FromVC:self toVC:_viewControllerF].operation = UINavigationControllerOperationPop;
    self.isPush = pushed;
    [self hide:!self.hideTopBar topbarWithAnimateDuration:0 backgroundChange:NO];
    [self hide:self.hideTopBar topbarWithAnimateDuration:0 backgroundChange:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isPush = noPush;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.view.frame = [UIScreen mainScreen].bounds;
    [self configToolBar];
    [self.BgScrollView setDelegate:nil];
    // Update ContentSize
    [self getCountWithSetContentSize:YES];
    [self setPositionAtPage:_page ignoreIndex:-1];
    
    // Update ImageView Size
    for (int i=0; i<self.scrollViewArr.count; i++) {
        if (self.isPush == pushing && i == middle) {
            continue;
        }
        UIImageView *imageView = self.imageViewArr[i];
        CGRect rect = [self getImageViewFrameWithImage:imageView.image];
        [imageView setFrame:rect];
        UIButton *play = [imageView viewWithTag:ButtonTag];
        play.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
    }
    [self.BgScrollView setContentOffset:CGPointMake(_page * pageWidth, 0) animated:NO];
    [self.BgScrollView setDelegate:self];
}

- (IGNavigationControllerDelegate *)navigationControllerDelegate {
    if (!_navigationControllerDelegate) {
        _navigationControllerDelegate = [[IGNavigationControllerDelegate alloc] init];
    }
    return _navigationControllerDelegate;
}

#pragma mark - UI
- (UIScrollView *)BgScrollView {
    if (!_BgScrollView) {
        _BgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, pageWidth, kScreenHeight)];
        [_BgScrollView setPagingEnabled:YES];
        [_BgScrollView setDelegate:self];
        [_BgScrollView setBackgroundColor:[UIColor clearColor]];
        [_BgScrollView setShowsHorizontalScrollIndicator:NO];
        _BgScrollView.bounces = YES;
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBar:)];
        singleTapGesture.cancelsTouchesInView = NO;
        singleTapGesture.delegate = self;
        [singleTapGesture setNumberOfTapsRequired:1];//单击
        [singleTapGesture setNumberOfTouchesRequired:1];//单点触碰
        _BgScrollView.userInteractionEnabled = YES;
        [_BgScrollView addGestureRecognizer:singleTapGesture];
    }
    return _BgScrollView;
}

- (void)setBackItem {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    if (((UIViewController*)_viewControllerF).navigationItem != nil) {
        [((UIViewController*)_viewControllerF).navigationItem setBackBarButtonItem:backItem];
    }
}

-(UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        if (_delegate && [_delegate respondsToSelector:@selector(titleColorForImageGallery:)]) {
            _titleLabel.textColor = [_delegate titleColorForImageGallery:self];
        }
        self.navigationItem.titleView = _titleLabel;
    }
    return _titleLabel;
}

- (void)initImageScrollViewArr {
    self.imageViewArr = [NSMutableArray arrayWithArray:@[[self buildImageView],[self buildImageView],[self buildImageView],[self buildImageView],[self buildImageView]]];
    
    self.scrollViewArr = [NSMutableArray arrayWithArray:@[[self buildScrollView],[self buildScrollView],[self buildScrollView],[self buildScrollView],[self buildScrollView]]];
    
    for (int i = 0; i < self.scrollViewArr.count; i++) {
        [self.scrollViewArr[i] addSubview:self.imageViewArr[i]];
        [self.BgScrollView addSubview:self.scrollViewArr[i]];
    }
}

- (UIImageView *)buildImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setClipsToBounds:YES];
    imageView.userInteractionEnabled = YES;
    imageView.backgroundColor = [UIColor clearColor];
    [imageView addSubview:[self buildPlayButton]];
    return imageView;
}

- (UIButton *)buildPlayButton {
    if (_delegate && [_delegate respondsToSelector:@selector(buttonForPlayVideo)]) {
        UIBigButton *play = [[UIBigButton alloc]init];
        UIImage *image = [_delegate buttonForPlayVideo];
        [play setImage:image forState:UIControlStateNormal];
        [play sizeToFit];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playItem)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [tapGestureRecognizer setNumberOfTouchesRequired:1];
        
        [play addGestureRecognizer:tapGestureRecognizer];
        play.tag = ButtonTag;
        play.clipsToBounds = YES;
        play.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        play.layer.cornerRadius = image.size.width/2;
        play.alpha = 0.0f;
        play.enabled = NO;
        return play;
    }
    return nil;
}

- (UIScrollView *)buildScrollView {
    UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [imageScrollView setDelegate:self];
    return imageScrollView;
}

- (void)setTitle {
    if ([self getCountWithSetContentSize:NO] > 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(titleForImageGallery:AtIndex:)]) {
            self.titleLabel.text = [_delegate titleForImageGallery:self AtIndex:_page];
            [self.titleLabel sizeToFit];
        }
    } else {
        self.navigationItem.title = @"";
    }
    [self configToolBarItem];
}

- (void)setMiddleImageViewForPushSetScale:(CGFloat)scale setCenter:(BOOL)setCenter orignalFrame:(CGRect)originalFrame centerX:(CGFloat)x cencentY:(CGFloat)y {
    
    UIImageView *imageView = self.imageViewArr[middle];
    
    if (!imageView.image) {
        [imageView setImage:[self getPushImage]];
    }
    
    originalFrame.size.height *= scale;
    originalFrame.size.width  *= scale;
    
    if (setCenter) {
        imageView.frame = originalFrame;
        imageView.center = CGPointMake(x, y);
    } else {
        CGPoint center = imageView.center;
        imageView.frame = originalFrame;
        imageView.center = center;
    }
    [self setMiddleImageViewPlayButton];
}

- (void)setMiddleImageViewForPopSetScale:(CGFloat)scale setCenter:(BOOL)setCenter centerX:(CGFloat)x cencentY:(CGFloat)y {
    
    UIImageView *imageView = self.imageViewArr[middle];
    
    if (!imageView.image) {
        [imageView setImage:[self getPushImage]];
    }
    
    CGRect originalFrame = [self getImageViewFrameWithImage:imageView.image];
    
    originalFrame.size.height *= scale;
    originalFrame.size.width  *= scale;
    
    if (setCenter) {
        imageView.frame = originalFrame;
        imageView.center = CGPointMake(x, y);
    } else {
        CGPoint center = imageView.center;
        imageView.frame = originalFrame;
        imageView.center = center;
    }
    [self setMiddleImageViewPlayButton];
}

- (void)setMiddleImageViewForPushWithScale:(BOOL)scale {
    UIImageView *imageView = self.imageViewArr[middle];
    imageView.image = [self getPushImage];
    
    imageView.frame = scale ? [self getPushViewFrameScaleFit] : [self getPushViewFrame];
    
    if (_delegate && [_delegate respondsToSelector:@selector(isVideoAtIndex:)]) {
        UIButton *play = [imageView viewWithTag:ButtonTag];
        if (_delegate && [_delegate respondsToSelector:@selector(isVideoAtIndex:)] && [_delegate isVideoAtIndex:_page]) {
            play.enabled = YES;
        } else {
            play.enabled = NO;
        }
        [self setMiddleImageViewPlayButton];
    }
}

- (void)setMiddleImageViewWhenPopFinished {
    if ([self getCountWithSetContentSize:NO] != 0) {
        UIImageView *imageView = self.imageViewArr[middle];
        CGRect pushFrame = [self getPushViewFrame];
        imageView.frame = pushFrame;
        [self setMiddleImageViewPlayButton];
        UIButton *play = [imageView viewWithTag:ButtonTag];
        if (play) {
            play.alpha = 0.0f;
        }
    }
}

- (void)setMiddleImageViewWhenPushFinished {
    if ([self getCountWithSetContentSize:NO] != 0) {
        UIImageView *imageView = self.imageViewArr[middle];
        UIButton *play = [imageView viewWithTag:ButtonTag];
        
        CGRect pushFrame = [self getImageViewFrameWithImage:imageView.image];
        imageView.frame = pushFrame;
        if (play.enabled) {
            play.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
            play.alpha = 1.0f;
        }
        play.transform = CGAffineTransformMakeScale(1, 1);
    }
}

- (void)setMiddleImageViewPlayButton {
    UIImageView *imageView = self.imageViewArr[middle];
    UIButton *play = [imageView viewWithTag:ButtonTag];
    if (play) {
        play.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
        if (play.enabled) {
            play.alpha = imageView.frame.size.width / [self getImageViewFrameWithImage:imageView.image].size.width;
        }
        CGFloat scale = [self getImageViewFrameWithImage:imageView.image].size.width;
        if (scale != 0) {
            scale = imageView.frame.size.width / scale;
        }
        if (scale > 1) {
            scale = 1;
        }
        play.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)configToolBar {
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc] init];
        _toolbar.barStyle = UIBarStyleDefault;
//        UIBarButtonItem *leftFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        UIBarButtonItem *rightFix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        UIBarButtonItem *fix2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//        UIBarButtonItem *play = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playItem)];
//        play.enabled = NO;
//        play.tintColor = [UIColor clearColor];
//
//        UIBarButtonItem *delete = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItem)];
//        UIBarButtonItem *share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItem)];
//        [_toolbar setItems:@[leftFix, share, fix, play, fix2, delete, rightFix] animated:YES];
        _toolbar.alpha = 0.0f;
    }
    if ([self isViewLoaded]) {
        if (_toolbar.superview != self.view) {
            [self.view addSubview:_toolbar];
        }
    }
    [_toolbar setFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
}

- (void)configToolBarItem {
    BOOL display = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageGallery:toolBarItemsShouldDisplayForIndex:)]) {
        
        display = [self.delegate imageGallery:self toolBarItemsShouldDisplayForIndex:_page];
        
        if (display && self.delegate && [self.delegate respondsToSelector:@selector(imageGallery:toolBarItemsForIndex:)]) {
            _toolbar.items = [self.delegate imageGallery:self toolBarItemsForIndex:_page];
        }
    }
    _toolbar.hidden = !display;
}

- (NSInteger)getCountWithSetContentSize:(BOOL)setSize {
    NSInteger count = 0;
    if (_delegate && [_delegate respondsToSelector:@selector(numOfImagesForImageGallery:)]) {
        count = [_delegate numOfImagesForImageGallery:self];
        if (setSize) {
            self.BgScrollView.contentSize = CGSizeMake(count*pageWidth, 0);
            [self.BgScrollView setFrame:CGRectMake(0, 0, pageWidth, kScreenHeight)];
        }
    }
    return count;
}

- (void)setPositionAtPage:(NSInteger)page ignoreIndex:(NSInteger)ignore {
    NSInteger sum = [self getCountWithSetContentSize:NO];
    for (int i=0; i<self.scrollViewArr.count; i++) {
        NSInteger current = page-middle+i;
        UIScrollView *view = self.scrollViewArr[i];
        if (ignore != i) {
            if (current>=0 && current<sum) {
                [view setFrame:CGRectMake(pageWidth*current, 0, kScreenWidth, self.BgScrollView.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(pageWidth*current, 0, kScreenWidth, self.BgScrollView.frame.size.height)];
            }
        }
    }
}

- (void)requestImage:(UIImageView*)imageView withScrollView:(UIScrollView*)scrollView atPage:(NSInteger)page {
    
    if (page >= [self getCountWithSetContentSize:NO] || page < 0) {
        imageView.image = nil;
        return;
    }
    UIImage *image;
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:imageAtIndex:targetSize:updateImage:)]) {
        
        imageView.tag = page;
        
        void(^updateImage)(UIImage *image) = ^(UIImage *image) {
            if (page != imageView.tag) {
                return;
            }
            if (image) {
                [imageView setImage:image];
                //set appropriate frame for imageView
                CGRect rect = [self getImageViewFrameWithImage:image];
                [imageView setFrame:rect];
                //设置最大的缩放比例为 不超过屏幕高度2倍
//                [scrollView setMaximumZoomScale:kScreenHeight/image.size.height*2];
            }
            UIButton *play = [imageView viewWithTag:ButtonTag];
            if (play) {
                play.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
                play.transform = CGAffineTransformMakeScale(1, 1);
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(isVideoAtIndex:)]) {
                    if ([self->_delegate isVideoAtIndex:page]) {
                        play.enabled = YES;
                        play.alpha = 1.0f;
                    } else {
                        play.enabled = NO;
                        play.alpha = 0.0f;
                    }
                }
            }
        };
        
        image = [_delegate imageGallery:self imageAtIndex:page targetSize:kTargetSize updateImage:^(UIImage *image) {
            updateImage(image);
        }];
        
        //if image is nil , then show placeHolder
        if (!image) {
            image = _placeHolder;
        }
        updateImage(image);
    }
}

- (CGRect)getPushViewFrame {
    CGRect rect = CGRectZero;
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:thumbViewForPushAtIndex:)]) {
        UIView *view = [_delegate imageGallery:self thumbViewForPushAtIndex:_page];
        //return view.frame;
        //getRect
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        rect = [view convertRect:view.bounds toView:window];
    }
    return rect;
}

- (CGRect)getPushViewFrameScaleFit {
    
    UIImageView *imageView = self.imageViewArr[middle];
    if (!imageView.image) {
        [imageView setImage:[self getPushImage]];
    }
    
    CGRect pushFrame = [self getPushViewFrame];
    CGRect bigFrame = [self getImageViewFrameWithImage:imageView.image];
    CGFloat width = pushFrame.size.height / bigFrame.size.height *  bigFrame.size.width;
    if (width < pushFrame.size.width) {
        CGFloat height = bigFrame.size.height * pushFrame.size.width / bigFrame.size.width;
        pushFrame.origin.y += (pushFrame.size.height - height) / 2.0f;
        pushFrame.size.height = height;
    } else {
        pushFrame.origin.x += (pushFrame.size.width - width) / 2.0f;
        pushFrame.size.width = width;
    }
    return pushFrame;
}

- (CGFloat)getMaxScaleFitWithPushView:(UIView *)pushView image:(UIImage *)image {
    CGRect pushFrame = pushView.frame;
    CGRect bigFrame = [self getImageViewFrameWithImage:image];
    
    CGFloat width = pushFrame.size.height / bigFrame.size.height *  bigFrame.size.width;
    if (width < pushFrame.size.width) {
        CGFloat height = bigFrame.size.height * pushFrame.size.width / bigFrame.size.width;
        pushFrame.size.height = height;
    } else {
        pushFrame.size.width = width;
    }
    return bigFrame.size.width / pushFrame.size.width;
}


- (UIImage *)getPushImage {
    UIImage *image = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:imageAtIndex:targetSize:updateImage:)]) {
        NSInteger page = _page;
        image = [_delegate imageGallery:self imageAtIndex:_page targetSize:kTargetSize updateImage:^(UIImage * _Nonnull image) {
            if (self->_page == page) {
                UIImageView *imageView = self.imageViewArr[middle];
                imageView.image = image;
            }
        }];
    }
    if (!image) {
        image = _placeHolder;
    }
    return image;
}

- (CGRect)getImageViewFrameWithImage:(UIImage *)image {
    if (image && image.size.height > 0 && image.size.width > 0) {
        CGFloat imageViewWidth = kScreenWidth;
        CGFloat imageViewHeight = image.size.height/image.size.width*imageViewWidth;
        if (imageViewHeight > kScreenHeight) {
            imageViewHeight = kScreenHeight;
            imageViewWidth = image.size.width/image.size.height*imageViewHeight;
        }
        return CGRectMake(kScreenWidth/2 - imageViewWidth/2, kScreenHeight/2 - imageViewHeight/2, imageViewWidth, imageViewHeight);
    }
    return CGRectZero;
}

#pragma mark - UI Event

- (void)showImageGalleryAtIndex:(NSInteger)Index fatherViewController:(UIViewController *)viewController {
    if (self.isPush == pushing) {
        return;
    }
    _page       =   Index;
    _oldPage    =   Index;
    _hideTopBar = NO;
    _hideToolBar= NO;
    self.isPush =   pushing;
    
    //Load Visiable Image
    [self setMiddleImageViewForPushWithScale:NO];
    
    //Show ImageGallery ViewController
    [self pushSelfByFatherViewController:viewController];
}

- (void)showImageGalleryWithPingInteractionController:(IGInteractionController *)interactionController {
    if (self.isPush == pushing) {
        return;
    }
    _page       =   interactionController.index;
    _oldPage    =   interactionController.index;
    _hideTopBar = NO;
    _hideToolBar = NO;
    self.isPush =   pushing;
    
    //Load Visiable Image
    [self setMiddleImageViewForPushWithScale:YES];
    
    //Show ImageGallery ViewController
    [self pushSelfByFatherViewController:interactionController.fromVC];
}

- (void)addInteractionGestureShowImageGalleryAtIndex:(NSInteger)index fatherViewController:(UIViewController *)viewController fromView:(UIView *)view imageView:(UIImageView *)imageView {
    
    IGInteractionController *interactionController = [self.navigationControllerDelegate addPinchGestureOnView:view FromVC:viewController toVC:self];
    interactionController.index = index;
    
    if (imageView.image.size.width != 0) {
        interactionController.maxScale = [self getMaxScaleFitWithPushView:view image:imageView.image];
    }
    interactionController.operation = UINavigationControllerOperationPush;
}

- (void)hide:(BOOL)hide toolbarWithAnimateDuration:(NSTimeInterval)duration {
    self.toolbarIsHide = hide;
    [self.view bringSubviewToFront:self->_toolbar];
    CGFloat alpha = hide ? 0.0f : 1.0f;
    if (duration > 0) {
        [UIView animateWithDuration:duration animations:^{
            if (self->_toolbar) {
                self->_toolbar.alpha = alpha;
            }
        }];
    } else {
        _toolbar.alpha = alpha;
    }
}

- (void)hide:(BOOL)hide topbarWithAnimateDuration:(NSTimeInterval)duration backgroundChange:(BOOL)change {
    if (self.isPush == pushed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^animate)(void) = ^{
                if (self.navigationController) {
                    [self.navigationController setNavigationBarHidden:hide animated:NO];
                    [self prefersStatusBarHidden];
                    [self setNeedsStatusBarAppearanceUpdate];
                }
            };
            if (duration > 0) {
                [UIView animateWithDuration:duration animations:^{
                    animate();
                    if (change) {
                        [self.view setBackgroundColor:hide ? [UIColor blackColor] : [UIColor whiteColor]];
                    }
                }];
            } else {
                animate();
                if (change) {
                    [self.view setBackgroundColor:hide ? [UIColor blackColor] : [UIColor whiteColor]];
                }
            }
        });
    }
}

- (void)hideBar:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer) {
        _hideTopBar = !_hideTopBar;
        _hideToolBar = !_hideToolBar;
        
        [self hide:_hideTopBar topbarWithAnimateDuration:0.4 backgroundChange:YES];
        [self hide:_hideToolBar toolbarWithAnimateDuration:0.4];
    } else {
        [self hide:NO topbarWithAnimateDuration:0 backgroundChange:NO];
    }
}

- (void)showParentViewControllerNavigationBar:(BOOL)show {
    if (((UIViewController *)_viewControllerF).navigationController.navigationBarHidden == show) {
        [((UIViewController *)_viewControllerF).navigationController setNavigationBarHidden:!show animated:NO];
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

-(void)pushSelfByFatherViewController:(UIViewController *)viewController {
    _viewControllerF = viewController;
    [_viewControllerF setHidesBottomBarWhenPushed:YES];
    
    viewController.navigationController.delegate = self.navigationControllerDelegate;
    
    //setTranslucent For origin.y at 0.0f
    [self setNavigationBarAndTabBarForImageGallery:YES];
    [self configToolBar];
    [viewController.navigationController pushViewController:self animated:YES];
}

- (void)setNavigationBarAndTabBarForImageGallery:(BOOL)set {
    UIViewController *viewControllerF = ((UIViewController*)_viewControllerF);
   if (set) {
        //record original settings
       if (viewControllerF.navigationController.navigationBar.translucent) {
           self.automaticallyAdjustsScrollViewInsetsF = viewControllerF.automaticallyAdjustsScrollViewInsets;
           self.automaticallyAdjustsScrollViewInsets = NO;
           return;
       }
       
        if (SYSTEM_LESS_THAN(@"7")) {
            self.tintColorF = viewControllerF.navigationController.navigationBar.tintColor;
        } else {
            self.barTintColorF = viewControllerF.navigationController.navigationBar.barTintColor;
        }
        self.automaticallyAdjustsScrollViewInsetsF = viewControllerF.automaticallyAdjustsScrollViewInsets;
        self.tabbarTranslucentF = viewControllerF.tabBarController.tabBar.translucent;
        self.navigationTranslucentF = viewControllerF.navigationController.navigationBar.translucent;
        //set
        self.automaticallyAdjustsScrollViewInsets = NO;
        [viewControllerF.tabBarController.tabBar setTranslucent:YES];
        self.hidesBottomBarWhenPushed = YES;
        [viewControllerF.navigationController.navigationBar setTranslucent:YES];
        if (self.barBackgroundImage == nil && _delegate && [_delegate respondsToSelector:@selector(backgroundImageForImageGalleryBar:)]) {
            self.barBackgroundImage = [ImageGallery imageForTranslucentNavigationBar:viewControllerF.navigationController.navigationBar backgroundImage:[_delegate backgroundImageForImageGalleryBar:self]];
        }
        if (self.barBackgroundImage != nil){
            [viewControllerF.navigationController.navigationBar setBackgroundImage:self.barBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    } else {
        if (viewControllerF.navigationController.navigationBar.translucent) {
            viewControllerF.automaticallyAdjustsScrollViewInsets = self.automaticallyAdjustsScrollViewInsetsF;
            return;
        }
        if (SYSTEM_LESS_THAN(@"7")) {
            viewControllerF.navigationController.navigationBar.tintColor = self.tintColorF;
        } else {
            viewControllerF.navigationController.navigationBar.barTintColor = self.barTintColorF;
        }
        viewControllerF.automaticallyAdjustsScrollViewInsets = self.automaticallyAdjustsScrollViewInsetsF;
        viewControllerF.tabBarController.tabBar.translucent = self.tabbarTranslucentF;
        viewControllerF.navigationController.navigationBar.translucent = self.navigationTranslucentF;
        if (_delegate && [_delegate respondsToSelector:@selector(backgroundImageForParentViewControllerBar)]){
            [viewControllerF.navigationController.navigationBar setBackgroundImage:[_delegate backgroundImageForParentViewControllerBar] forBarMetrics:UIBarMetricsDefault];
        }
    }
}

- (void)setLoading:(BOOL)loading {
    if (loading && !_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f);
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self.view addSubview:_activityIndicatorView];
    }
    if (loading) {
//        self.BgScrollView.scrollEnabled = NO;
        [self.view bringSubviewToFront:_activityIndicatorView];
        [_activityIndicatorView startAnimating];
    } else {
//        self.BgScrollView.scrollEnabled = YES;
        [_activityIndicatorView stopAnimating];
    }
}

#pragma mark - UIscrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.BgScrollView == scrollView) {
        CGFloat scrollviewW =  scrollView.frame.size.width;
        CGFloat x = scrollView.contentOffset.x;
        _page = (x + scrollviewW / 2) /scrollviewW;
        if (_page>=0 && _page<[self getCountWithSetContentSize:NO]) {
            
            //change Left's Left's View
            if (_page > _oldPage) {
                UIScrollView *changeScView = self.scrollViewArr[leftleft];
                UIImageView  *changeImageView = self.imageViewArr[leftleft];
                
                [self.scrollViewArr removeObject:changeScView];
                [self.scrollViewArr addObject:changeScView];
                
                [self.imageViewArr removeObject:changeImageView];
                [self.imageViewArr addObject:changeImageView];
                
                CGRect rect = changeScView.frame;
                rect.origin.x = (_page+middle)*pageWidth;
                changeScView.frame  = rect;
                
                [self requestImage:changeImageView withScrollView:changeScView atPage:_page+middle];
                [self setTitle];
                if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:middleImageHasChangeAtIndex:)]) {
                    [_delegate imageGallery:self middleImageHasChangeAtIndex:_page];
                }
                _oldPage = _page;
                
            } else if (_page < _oldPage) { //change Right's Right's View
                
                UIScrollView *changeScView = self.scrollViewArr[rightright];
                UIImageView  *changeImageView = self.imageViewArr[rightright];
                [self.scrollViewArr removeObject:changeScView];
                [self.scrollViewArr insertObject:changeScView atIndex:leftleft];
                
                [self.imageViewArr removeObject:changeImageView];
                [self.imageViewArr insertObject:changeImageView atIndex:leftleft];

                CGRect rect = changeScView.frame;
                rect.origin.x = (_page-middle)*pageWidth;
                changeScView.frame  = rect;
                [self requestImage:changeImageView withScrollView:changeScView atPage:_page-middle];
                [self setTitle];
                if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:middleImageHasChangeAtIndex:)]) {
                    [_delegate imageGallery:self middleImageHasChangeAtIndex:_page];
                }
                _oldPage = _page;
            }
        }
    }
}

#pragma mark - gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UIBigButton class]]) {
        return NO;
    }
    if (gestureRecognizer.view == _BgScrollView && [otherGestureRecognizer.view isKindOfClass:[UIBigButton class]]) {
        return NO;
    }
    if (gestureRecognizer.view == _BgScrollView && self.navigationControllerDelegate.interactive) {
        return NO;
    }
    return YES;
}

#pragma mark - tool function
-(void)deleteItem{
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:selecteDeleteImageAtIndex:)]) {
        [_delegate imageGallery:self selecteDeleteImageAtIndex:_page];
    }
}

-(void)shareItem{
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:selecteShareImageAtIndex:)]) {
        [_delegate imageGallery:self selecteShareImageAtIndex:_page];
    }
}

-(void)playItem{
    if (self.navigationControllerDelegate.interactive) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:selectePlayVideoAtIndex:)]) {
        if ([_delegate imageGallery:self selectePlayVideoAtIndex:_page]){ }
    }
}

#pragma mark - public function

- (void)deletePage:(NSInteger)page {
    if (page != _page) {
        [self updatePages];
        return;
    }
    UIImageView *deleteImageView = self.imageViewArr[middle];
    UIScrollView *deleteScrollView = self.scrollViewArr[middle];
    CGPoint point =  self.BgScrollView.contentOffset;
    NSInteger newCount = [self getCountWithSetContentSize:NO];
    if (newCount == 0) {
        UIImageView *deleteImageView = self.imageViewArr[middle];
        UIButton *deleteButton = self.playButtonArr[middle];
        [UIView animateWithDuration:0.3 animations:^{
            deleteImageView.alpha = 0.0f;
            deleteImageView.transform =  CGAffineTransformMakeScale(1.2f, 1.2f);
            deleteButton.alpha = 0.0f;
        }completion:^(BOOL finished) {
            deleteImageView.image = nil;
            deleteImageView.alpha = 1.0f;
            deleteImageView.transform =  CGAffineTransformMakeScale(1.0f, 1.0f);
            deleteButton.alpha = 1.0f;
            
            self.navigationController.delegate = nil;
            [self.navigationController popViewControllerAnimated:YES];
            [self setNavigationBarAndTabBarForImageGallery:NO];
        }];
    } else if (point.x < pageWidth*newCount) {
        [self.imageViewArr removeObject:deleteImageView];
        [self.imageViewArr addObject:deleteImageView];
        [self.scrollViewArr removeObject:deleteScrollView];
        [self.scrollViewArr addObject:deleteScrollView];
        [UIView animateWithDuration:0.3 animations:^{
            deleteScrollView.alpha = 0.0f;
            
            [self setPositionAtPage:self->_page ignoreIndex:rightright];
        }completion:^(BOOL finished) {
            deleteScrollView.frame = CGRectMake((self->_page + middle) * pageWidth, 0, kScreenWidth, kScreenHeight);
            deleteScrollView.alpha = 1.0f;
            deleteImageView.transform =  CGAffineTransformMakeScale(1.0f, 1.0f);
            [self requestImage:deleteImageView withScrollView:deleteScrollView atPage:self->_page+middle];
            [self getCountWithSetContentSize:YES];
            [self setTitle];
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(imageGallery:middleImageHasChangeAtIndex:)]) {
                [self->_delegate imageGallery:self middleImageHasChangeAtIndex:self->_page];
            }
        }];
        
    } else if (point.x == pageWidth*newCount){
        point.x -= pageWidth;
        //hide Right's View
        [UIView animateWithDuration:0.3 animations:^{
            deleteScrollView.alpha = 0.0f;
            deleteImageView.transform =  CGAffineTransformMakeScale(1.2f, 1.2f);
        }completion:^(BOOL finished) {
            deleteImageView.image = nil;
            deleteScrollView.alpha = 1.0f;
            deleteImageView.transform =  CGAffineTransformMakeScale(1.0f, 1.0f);
            [self getCountWithSetContentSize:YES];
            [self setTitle];
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(imageGallery:middleImageHasChangeAtIndex:)]) {
                [self->_delegate imageGallery:self middleImageHasChangeAtIndex:self->_page];
            }
        }];
        [self.BgScrollView setContentOffset:point animated:YES];
    }
}

- (void)updatePages {
    if (self.isPush != pushed) {
        return;
    }
    NSInteger oldCount = self.BgScrollView.contentSize.width/pageWidth;
    NSInteger newCount = [self getCountWithSetContentSize:YES];
    NSInteger addCount = newCount - oldCount;
    _page += addCount;
    [self setTitle];
    if (_delegate && [_delegate respondsToSelector:@selector(imageGallery:middleImageHasChangeAtIndex:)]) {
        [_delegate imageGallery:self middleImageHasChangeAtIndex:_page];
    }
    //Load Image
    for (int i=0; i < self.scrollViewArr.count; i++) {
        if (_oldPage == _page - middle + i) {
            //Sequence ScrollViews
            [self setPositionAtPage:_page ignoreIndex:-1];
            
            [self.BgScrollView setDelegate:nil];
            [self.BgScrollView setContentOffset:CGPointMake(_page*pageWidth, 0) animated:NO];
            [self getCountWithSetContentSize:YES];
            [self.BgScrollView setDelegate:self];
        }
        [self requestImage:self.imageViewArr[i] withScrollView:self.scrollViewArr[i] atPage:_page-middle+i];
    }
    _oldPage = _page;
}

- (void)showMessage:(NSString *)message atPercentY:(CGFloat)percentY{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 0, 0)];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:TEXTFONTSIZE];
    label.text = message;
    [label sizeToFit];
    
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    
    CGRect rect = label.frame;
    rect.size.width+=20;
    rect.size.height+=10;
    showview.frame = rect;
    showview.center = CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height * percentY);

    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    
    [self.view addSubview:showview];
    [showview addSubview:label];
    
    [UIView animateWithDuration:2.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

+ (UIImage *)imageForTranslucentNavigationBar:(UINavigationBar *)navigationBar backgroundImage:(UIImage *)image {
    if (SYSTEM_LESS_THAN(@"10")) {
        if (image!=nil) {
            CGRect rect = navigationBar.frame;
            rect.origin.y = 0;
            rect.size.height += 20;
            CGFloat scale = image.size.width/rect.size.width;
            
            rect.size.height *= scale*[[UIScreen mainScreen] scale];
            rect.size.width  *= scale*[[UIScreen mainScreen] scale];
            
            CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
            CGImageRelease(subImageRef);
            return smallImage;
        }
    }
    return image;
}

@end

#pragma mark - Push And Pop Animate

#define animateTtransitionDuration 0.5f
#define interationTtransitionDuration 0.5f

#define DampingRatio    0.7     //弹性的阻尼值
#define Velocity        0.01    //弹簧的修正速度

@implementation IGNavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    _animationController = [[IGPushAndPopAnimationController alloc] initWithNavigationControllerOperation:operation];
    _animationController.transitionDelegate = self;
    return _animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if (self.interactive) {
        self.leftProgress = 1.0f;
        return _interactionController;
    }
    self.leftProgress = 0.0f;
    self.operateSucceed = YES;
    return nil;
}

- (NSMutableArray<IGInteractionController *> *)interactionControllers {
    if (!_interactionControllers) {
        _interactionControllers = [NSMutableArray array];
    }
    return _interactionControllers;
}

- (IGInteractionController *)addPinchGestureOnView:(UIView *)view FromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC  {
    for (IGInteractionController *interactionController in self.interactionControllers) {
        if (interactionController.view == view) {
            return interactionController;
        }
    }
    IGInteractionController *interactionController = [[IGInteractionController alloc] init];
    interactionController.toVC = toVC;
    interactionController.fromVC = fromVC;
    interactionController.transitionDelegate = self;
    [interactionController addPinchGestureOnView:view];
    [self.interactionControllers addObject:interactionController];
    return interactionController;
}

@end

@implementation IGInteractionController

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
        _pinchGestureRecognizer.delegate = self;
    }
    return _pinchGestureRecognizer;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [_panGestureRecognizer setMinimumNumberOfTouches:1];
        [_panGestureRecognizer setMaximumNumberOfTouches:4];
        _panGestureRecognizer.delegate = self;
    }
    return _panGestureRecognizer;
}

- (void)setMaxScale:(CGFloat)maxScale {
    if (maxScale < 0) {
        _maxScale = -1;
    } else {
        _maxScale = maxScale;
    }
}

- (void)addPinchGestureOnView:(UIView *)view {
    self.view = view;
    self.index = -1;
    self.maxScale = -1;
    [view addGestureRecognizer:self.pinchGestureRecognizer];
    [view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    ImageGallery *imageGallery;
    if ([self.fromVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.fromVC;
    }
    
    if ([self.toVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.toVC;
    }
    
    BOOL selfGesture = gesture == self.gestureRecognizer;
    if (selfGesture) {
        self.scale = gesture.scale;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (!SYSTEM_LESS_THAN(@"8") &&
                !self.transitionDelegate.interactive &&
                gesture.scale >= 1.0f &&
                self.operation == UINavigationControllerOperationPush &&
                ![self.fromVC.navigationController.viewControllers containsObject:self.toVC]) {
                
                self.gestureRecognizer = gesture;
                self.transitionDelegate.interactionController = self;
                self.transitionDelegate.interactive = YES;
                
                [imageGallery showImageGalleryWithPingInteractionController:self];
                
                self.originalFrame = imageGallery.imageViewArr[middle].frame;
                self.originalCenter = imageGallery.imageViewArr[middle].center;

            } else if (!self.transitionDelegate.interactive &&
                       self.operation == UINavigationControllerOperationPop &&
                       [self.toVC.navigationController.viewControllers containsObject:self.fromVC]) {
                
                self.gestureRecognizer = gesture;
                self.transitionDelegate.interactionController = self;
                self.transitionDelegate.interactive = YES;
                [imageGallery hide:NO topbarWithAnimateDuration:0.3 backgroundChange:NO];
                [self.fromVC.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transitionDelegate.interactive) {
                return;
            }
            if (self.operation == UINavigationControllerOperationPush) {
                [imageGallery setMiddleImageViewForPushSetScale:self.scale setCenter:NO orignalFrame:self.originalFrame centerX:0 cencentY:0];
            }
            if (self.operation == UINavigationControllerOperationPop) {
                if (self.scale <= 3) {
                    [imageGallery setMiddleImageViewForPopSetScale:self.scale setCenter:NO centerX:0 cencentY:0];
                }
            }
            if (selfGesture) {
                [self updateInteractiveTransition:[self getProgressWithScale:self.scale limit:YES]];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled: {
            if (!self.transitionDelegate.interactive) {
                return;
            }
            if (selfGesture) {
                CGFloat progress = [self getProgressWithScale:self.scale limit:YES];
                BOOL isSucceed = NO;
                if (self.operation == UINavigationControllerOperationPush) {
                    isSucceed = (progress > 0.0f);
                }
                if (self.operation == UINavigationControllerOperationPop) {
                    isSucceed = (progress >= 0.2f);
                }
                [self finishInteractiveTransitionWithSucceed:isSucceed progress:progress];
            }
            break;
        }
        default: {
            NSLog(@"%ld", (long)gesture.state);
        }
    }
}

- (void)moveGesture:(UIPanGestureRecognizer *)gesture {
    
    CGPoint translatedPoint = [gesture translationInView:gesture.view];
    
    ImageGallery *imageGallery;
    if ([self.fromVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.fromVC;
    }
    
    if ([self.toVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.toVC;
    }
    
    BOOL selfGesture = gesture == self.gestureRecognizer;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.operation == UINavigationControllerOperationPop) {
                self.originalFrame = imageGallery.imageViewArr[middle].frame;
                self.originalCenter = imageGallery.imageViewArr[middle].center;
                if (!self.transitionDelegate.interactive) {
                    self.gestureRecognizer = gesture;
                    self.transitionDelegate.interactionController = self;
                    self.transitionDelegate.interactive = YES;
                    [imageGallery hide:NO topbarWithAnimateDuration:0.3 backgroundChange:NO];
                    [self.fromVC.navigationController popViewControllerAnimated:YES];
                }
            }
            if (self.operation == UINavigationControllerOperationPush) {
                if (!self.transitionDelegate.interactive) {
                    self.gestureRecognizer = gesture;
                    self.originalFrame = imageGallery.imageViewArr[middle].frame;
                    self.originalCenter = imageGallery.imageViewArr[middle].center;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transitionDelegate.interactive) {
                return;
            }
            if (selfGesture) {
                self.scale = (1 - translatedPoint.y / (self.fromVC.view.frame.size.height / 2.0f));
            }
            
            translatedPoint = CGPointMake(self.originalCenter.x + translatedPoint.x, self.originalCenter.y + translatedPoint.y);
            if (self.operation == UINavigationControllerOperationPop) {
                if ((selfGesture && self.scale <= 1) || (!selfGesture)) {
                    [imageGallery setMiddleImageViewForPopSetScale:self.scale setCenter:YES centerX:translatedPoint.x cencentY:translatedPoint.y];
                }
            }
            
            if (self.operation == UINavigationControllerOperationPush) {
                [imageGallery setMiddleImageViewForPushSetScale:self.scale setCenter:YES orignalFrame:self.originalFrame centerX:translatedPoint.x cencentY:translatedPoint.y];
            }
            
            if (selfGesture) {
                [self updateInteractiveTransition:[self getProgressWithScale:self.scale limit:YES]];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: case UIGestureRecognizerStateCancelled: {
            if (!self.transitionDelegate.interactive) {
                return;
            }
            if (selfGesture) {
                CGFloat progress = [self getProgressWithScale:self.scale limit:YES];
                BOOL isSucceed = NO;
                if (self.operation == UINavigationControllerOperationPush) {
                    isSucceed = (progress > 0.0f);
                }
                if (self.operation == UINavigationControllerOperationPop) {
                    isSucceed = (progress >= 0.02f);
                }
                [self finishInteractiveTransitionWithSucceed:isSucceed progress:progress];
            }
            break;
        }
        default: {
            NSLog(@"%ld", (long)gesture.state);
        }
    }
}

- (CGFloat)getProgressWithScale:(CGFloat)scale limit:(BOOL)limit{
    CGFloat progress = scale;
    if (self.operation == UINavigationControllerOperationPush) {
        progress = (progress - 1) / (self.maxScale - 1);
    } else if (self.operation == UINavigationControllerOperationPop) {
        progress = 1.0f - scale;
    } else {
        progress = 0;
    }
    if (limit) {
        if (progress < 0) {
            progress = 0;
        }
        if (progress > 1) {
            progress = 1;
        }
    }
    return progress/2;
}

- (void)finishInteractiveTransitionWithSucceed:(BOOL)succeed progress:(CGFloat)progress {
    
    if (!self.transitionDelegate.interactive) {
        return;
    }

    self.transitionDelegate.operateSucceed = succeed;
    self.transitionDelegate.interactive = NO;
    
    ImageGallery *imageGallery = nil;
    if ([self.fromVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.fromVC;
    }
    if ([self.toVC isKindOfClass:[ImageGallery class]]) {
        imageGallery = (ImageGallery *)self.toVC;
    }
    
    if (succeed) {
        [self finishInteractiveTransition];
    } else {
        [self cancelInteractiveTransition];
    }
    
    if (succeed) {
        progress = 1 - progress;
    }
    self.transitionDelegate.leftProgress = progress;
    if (self.operation == UINavigationControllerOperationPush) {
        if (!succeed && progress <= 0) {
            progress = -[self getProgressWithScale:self.scale limit:NO];
            self.transitionDelegate.leftProgress = progress;
        }
        [UIView animateKeyframesWithDuration:progress * interationTtransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionTransitionNone animations:^{
            if (succeed) {
                [imageGallery setMiddleImageViewWhenPushFinished];
            } else {
                [imageGallery setMiddleImageViewWhenPopFinished];
            }
        } completion:nil];
    }
    
    if (self.operation == UINavigationControllerOperationPop) {
        if (progress == 0) {
            progress = [self getProgressWithScale:self.scale limit:NO];
        }
        [UIView animateKeyframesWithDuration:progress * interationTtransitionDuration delay:0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionTransitionNone animations:^{
            if (succeed) {
                [imageGallery setMiddleImageViewWhenPopFinished];
            } else {
                [imageGallery setMiddleImageViewWhenPushFinished];
            }
        } completion:nil];
    }
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.pinchGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer) {
        return YES;
    }
    if (gestureRecognizer == self.panGestureRecognizer && otherGestureRecognizer == self.pinchGestureRecognizer) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer && [gestureRecognizer.view isKindOfClass:[UICollectionViewCell class]]
         && !self.transitionDelegate.interactive) {
        return NO;
    }
    return YES;
}

@end

@implementation IGPushAndPopAnimationController

- (instancetype)initWithNavigationControllerOperation:(UINavigationControllerOperation)operation {
    self = [super init];
    if (self) {
        self.operation = operation;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDelegate.interactive ? interationTtransitionDuration : animateTtransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (_operation) {
        case UINavigationControllerOperationPush:{
            UIView *containerView       = [transitionContext containerView];
            ImageGallery *toVC          = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            UIView *toView              = SYSTEM_LESS_THAN(@"8")?toVC.view:[transitionContext viewForKey:UITransitionContextToViewKey];
            UIViewController *fromVC    = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            NSTimeInterval duration     = [self transitionDuration:transitionContext];
            
            UIView *blankView = [[UIView alloc] initWithFrame:[toVC getPushViewFrame]];
            blankView.backgroundColor = fromVC.view.backgroundColor;
            [fromVC.view addSubview:blankView];
            
            [containerView addSubview:toView];
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                if (!self.transitionDelegate.interactive) {
                    [self addKeyFrameAnimationOnCellPushToVC:toVC duration:duration];
                }
                [self addkeyFrameAnimationForBarFrom:toVC isPush:YES duration:duration];
                [self addkeyFrameAnimationForBackgroundColorInPushToVC:toVC duration:duration];
            } completion:^(BOOL finished) {
                
                BOOL operateSucceed = self.transitionDelegate.operateSucceed;
                CGFloat leftTime = self.transitionDelegate.leftProgress * duration;
                
                [toVC setNavigationBarAndTabBarForImageGallery:operateSucceed];
                
                void (^operateBlock)(BOOL operateSucceed) = ^(BOOL operateSucceed) {
                    [blankView removeFromSuperview];
                    [transitionContext completeTransition:operateSucceed];
                    if (!operateSucceed) {
                        fromVC.navigationController.delegate = nil;
                    }
                };
                
                if (SYSTEM_LESS_THAN(@"8") || operateSucceed || leftTime == 0) { // iOS 7 will crash if delay completeTransition:
                    operateBlock(operateSucceed);
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(leftTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        operateBlock(operateSucceed);
                    });
                }
            }];
            break;
        }
        case UINavigationControllerOperationPop:{
            UIView *containerView       = [transitionContext containerView];
            ImageGallery *fromVC        = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toVC      = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
            toVC.view.frame = [UIScreen mainScreen].bounds;
            
            UIView *fromView            = SYSTEM_LESS_THAN(@"8")?fromVC.view:[transitionContext viewForKey:UITransitionContextFromViewKey];
            UIView *toView              = SYSTEM_LESS_THAN(@"8")?toVC.view:[transitionContext viewForKey:UITransitionContextToViewKey];
            NSTimeInterval duration     = [self transitionDuration:transitionContext];
            
            [containerView insertSubview:toView belowSubview:fromView];
            [fromView bringSubviewToFront:toView];
            
            UIView *blankView = [[UIView alloc] initWithFrame:[fromVC getPushViewFrame]];
            blankView.backgroundColor = toVC.view.backgroundColor;
            [toView addSubview:blankView];
            
            RGBackCompletion com = nil;
            if ([fromVC.delegate respondsToSelector:@selector(imageGallery:willBackToParentViewController:)]) {
                com = [fromVC.delegate imageGallery:fromVC willBackToParentViewController:toVC];
            }
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView animateKeyframesWithDuration:duration delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                
                if (toVC.navigationController.navigationBarHidden) {
                    [fromVC hide:NO topbarWithAnimateDuration:0 backgroundChange:NO];
                }
                
                if (!self.transitionDelegate.interactive) {
                    [self addKeyFrameAnimationOnCellPopFromVC:fromVC duration:duration];
                }
                [self addkeyFrameAnimationForBarFrom:fromVC isPush:NO duration:duration];
                [self addkeyFrameAnimationForBackgroundColorInPopWithFakeBackground:fromView duration:duration];
            } completion:^(BOOL finished) {
                [fromVC setNavigationBarAndTabBarForImageGallery:!self.transitionDelegate.operateSucceed];
                if (self.transitionDelegate.operateSucceed) {
                    [blankView removeFromSuperview];
                    toVC.navigationController.delegate = nil;
                    fromVC.navigationController.delegate = nil;
                    [transitionContext completeTransition:YES];
                    [fromVC showParentViewControllerNavigationBar:YES];
                    if (com) {
                        com(YES);
                    }
                } else {
                    [blankView removeFromSuperview];
                    [transitionContext completeTransition:NO];
                    if (com) {
                        com(NO);
                    }
                }
            }];
            break;
        }
        default:{}
        break;
    }
}

- (void)addKeyFrameAnimationOnCellPushToVC:(ImageGallery *)toVC duration:(NSTimeInterval)duration {
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration animations:^{
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:DampingRatio initialSpringVelocity:Velocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [toVC setMiddleImageViewWhenPushFinished];
        } completion:nil];
    }];
}

- (void)addKeyFrameAnimationOnCellPopFromVC:(ImageGallery *)fromVC duration:(NSTimeInterval)duration {
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration animations:^{
        [fromVC setMiddleImageViewWhenPopFinished];
    }];
}

- (void)addkeyFrameAnimationForBackgroundColorInPushToVC:(ImageGallery *)toVC duration:(NSTimeInterval)duration {
    [toVC.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration animations:^{
        [toVC.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    }];
}

- (void)addkeyFrameAnimationForBackgroundColorInPopWithFakeBackground:(UIView *)toView duration:(NSTimeInterval)duration {
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration animations:^{
        [toView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
    }];
}

- (void)addkeyFrameAnimationForBarFrom:(ImageGallery *)imageGallery isPush:(BOOL)isPush duration:(NSTimeInterval)duration {
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:duration animations:^{
        if (isPush) {
            [imageGallery hide:NO toolbarWithAnimateDuration:0];
        } else {
            [imageGallery hide:YES toolbarWithAnimateDuration:0];
        }
    }];
}
@end

