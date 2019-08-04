//
//  ImageGallery.h
//  yb
//
//  Created by LD on 16/4/2.
//  Copyright © 2016年 acumen. All rights reserved.
//
 /**********************
      ImageGallery
 ***********************
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^RGBackCompletion)(BOOL flag);
@protocol ImageGalleryDelegate;

@interface ImageGallery : UIViewController<UIScrollViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
enum{
    noPush,
    pushing,
    pushed,
};
@property (strong,nonatomic) NSMutableArray<UIScrollView *>  *scrollViewArr;
@property (strong,nonatomic) NSMutableArray<UIImageView *>  *imageViewArr;
@property (strong,nonatomic) UIScrollView    *BgScrollView;

@property (assign,nonatomic) NSInteger      isPush; //0 noPush 1 pushing 2 pushed
@property (assign,nonatomic) NSInteger      oldPage;
@property (assign,nonatomic) NSInteger      page;
@property (weak,nonatomic) id<ImageGalleryDelegate> delegate;

enum {
    leftleft,
    left,
    middle,
    right,
    rightright
};

+ (UIImage *)imageForTranslucentNavigationBar:(UINavigationBar *)navigationBar backgroundImage:(UIImage *)image;

- (instancetype)initWithPlaceHolder:(UIImage *)placeHolder andDelegate:(id)delegate;

- (void)showImageGalleryAtIndex:(NSInteger)Index fatherViewController:(UIViewController *)viewController;

- (void)addInteractionGestureShowImageGalleryAtIndex:(NSInteger)index fatherViewController:(UIViewController *)viewController fromView:(UIView *)view imageView:(UIImageView *)imageView;

- (void)showMessage:(NSString *)message atPercentY:(CGFloat)percentY;

- (void)updatePages;
- (void)deletePage:(NSInteger)page;

- (void)configToolBarItem;

- (void)setLoading:(BOOL)loading;

@end

@protocol ImageGalleryDelegate <NSObject>

- (UIImage *)backgroundImageForImageGalleryBar:(ImageGallery *)imageGallery;
- (UIImage *)backgroundImageForParentViewControllerBar;

- (NSInteger)numOfImagesForImageGallery:(ImageGallery *)imageGallery;
- (UIView *)imageGallery:(ImageGallery *)imageGallery thumbViewForPushAtIndex:(NSInteger)index;

- (UIImage *)imageGallery:(ImageGallery *)imageGallery imageAtIndex:(NSInteger)index targetSize:(CGSize)targetSize updateImage:(void(^_Nullable)(UIImage *image))updateImage;

- (UIColor *_Nullable)titleColorForImageGallery:(ImageGallery *)imageGallery;
- (NSString *_Nullable)titleForImageGallery:(ImageGallery *)imageGallery AtIndex:(NSInteger)index;

- (UIImage *_Nullable)buttonForPlayVideo;
- (BOOL)isVideoAtIndex:(NSInteger)index;

@optional

- (void)imageGallery:(ImageGallery *)imageGallery middleImageHasChangeAtIndex:(NSInteger)index;

- (BOOL)imageGallery:(ImageGallery *)imageGallery selectePlayVideoAtIndex:(NSInteger)index;

- (BOOL)imageGallery:(ImageGallery *)imageGallery toolBarItemsShouldDisplayForIndex:(NSInteger)index;
- (NSArray <UIBarButtonItem *> *)imageGallery:(ImageGallery *)imageGallery toolBarItemsForIndex:(NSInteger)index;

- (void)imageGallery:(ImageGallery *)imageGallery selecteDeleteImageAtIndex:(NSInteger)index;
- (void)imageGallery:(ImageGallery *)imageGallery selecteShareImageAtIndex:(NSInteger)index;

- (RGBackCompletion)imageGallery:(ImageGallery *)imageGallery willBackToParentViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
