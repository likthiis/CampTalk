//
//  CTImagePickerViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTImagePickerViewController.h"
#import "CTImageAlbumListViewController.h"
#import <Photos/Photos.h>

#import "CTUserConfig.h"

#import "Bluuur.h"

static PHImageRequestOptions *__ctImagePickerOptions;


@interface CTImagePickerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) CAShapeLayer *checkMarkLayer;
@property (nonatomic, strong) CAShapeLayer *selectedLayer;

@end

@implementation CTImagePickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2.f;
        self.clipsToBounds = YES;
        [self.contentView.layer addSublayer:self.selectedLayer];
    }
    return self;
}

- (CAShapeLayer *)checkMarkLayer {
    if (!_checkMarkLayer) {
        _checkMarkLayer = [CAShapeLayer layer];
        _checkMarkLayer.frame = CGRectMake(0, 0, 30, 30);
        
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        
        [bezier2Path moveToPoint: CGPointMake(6.f, 17.95)];
        [bezier2Path addLineToPoint: CGPointMake(12.3f, 24.02)];
        [bezier2Path addLineToPoint: CGPointMake(25.77, 9.4)];

        _checkMarkLayer.path = bezier2Path.CGPath;
        _checkMarkLayer.fillColor = [UIColor clearColor].CGColor;
        _checkMarkLayer.strokeColor = [UIColor blackColor].CGColor;
        _checkMarkLayer.lineWidth = 2.f;
        _checkMarkLayer.lineCap = kCALineCapRound;
        _checkMarkLayer.lineJoin = kCALineJoinRound;
        _checkMarkLayer.strokeEnd = 0.f;
        _checkMarkLayer.strokeStart = 0.f;
    }
    return _checkMarkLayer;
}

- (CAShapeLayer *)selectedLayer {
    if (!_selectedLayer) {
        _selectedLayer = [CAShapeLayer layer];
        _selectedLayer.frame = CGRectMake(0, 0, 30, 30);
        _selectedLayer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 30, 30) cornerRadius:15.f].CGPath;
        _selectedLayer.strokeColor = [UIColor whiteColor].CGColor;
        _selectedLayer.fillColor = [UIColor clearColor].CGColor;
        _selectedLayer.lineWidth = 2.f;
        
        [_selectedLayer addSublayer:self.checkMarkLayer];
    }
    return _selectedLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    [self.contentView sendSubviewToBack:_imageView];
    
    CGRect frame = _selectedLayer.frame;
    frame.origin.x = self.contentView.bounds.size.width - frame.size.width - 5.f;
    frame.origin.y = 5.f;
    _selectedLayer.frame = frame;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _selectedLayer.fillColor = [UIColor whiteColor].CGColor;
        _checkMarkLayer.strokeEnd = 1.f;
    } else {
        _selectedLayer.fillColor = [UIColor clearColor].CGColor;
        _checkMarkLayer.strokeEnd = 0.f;
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (void)setAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (_asset == asset || [_asset.localIdentifier isEqualToString:asset.localIdentifier]) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __ctImagePickerOptions = [[PHImageRequestOptions alloc] init];
        __ctImagePickerOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    });
    
    _asset = asset;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:__ctImagePickerOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (self.asset == asset) {
            self.imageView.image = result;
        }
    }];
}

@end

@interface CTImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL needScrollToBottom;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize thumbSize;

@property (nonatomic, strong) NSIndexPath *recordMaxIndexPath;

@end

@implementation CTImagePickerViewController

+ (CTImagePickerViewController *)presentByViewController:(UIViewController *)presentingViewController pickResult:(ImagePickResult)pickResult {
    
    CTImagePickerViewController *vc = [[CTImagePickerViewController alloc] init];
    
    void(^loadData)(void) = ^{
        vc.collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    };
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    loadData();
                });
            }
        }];
    } else {
        loadData();
    }

    CTImageAlbumListViewController *list = [[CTImageAlbumListViewController alloc] initWithStyle:UITableViewStylePlain];
    list.pickResult = pickResult;
    list.title = @"相册";
    
    UINavigationController *nvg = [[UINavigationController alloc] initWithRootViewController:list];
    [nvg setViewControllers:@[list, vc] animated:NO];
    
    [presentingViewController presentViewController:nvg animated:YES completion:nil];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[CTUserConfig chatBackgroundImagePath]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    MLWBluuurView *backgroundView = [[MLWBluuurView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    backgroundView.blurRadius = 3.5;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.frame = imageView.bounds;
    [imageView addSubview:backgroundView];
    self.collectionView.backgroundView = imageView;
    
    [self.collectionView registerClass:[CTImagePickerCell class] forCellWithReuseIdentifier:@"CTImagePickerCell"];
    
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(down)];
    self.navigationItem.rightBarButtonItem = down;
    [self configViewWithCollection:_collection];
}

- (void)setCollection:(PHAssetCollection *)collection {
    _collection = collection;
    _assets = [PHAsset fetchAssetsInAssetCollection:_collection options:nil];
    if (self.isViewLoaded) {
        [self configViewWithCollection:_collection];
    }
}

- (void)configViewWithCollection:(PHAssetCollection *)collection {
    _needScrollToBottom = YES;
    self.navigationItem.title = _collection.localizedTitle;
    [self.collectionView reloadData];
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat recordHeight = self.collectionView.frame.size.height;
    _collectionView.frame = self.view.bounds;
    
    [self configItemSize];
    [_collectionView reloadData];
    
    if (!_needScrollToBottom) {
        
        if (recordHeight != self.collectionView.frame.size.height) {
            
            if (!_recordMaxIndexPath) {
                return;
            
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordMaxIndexPathIfNeed) object:nil];
            
            [self.collectionView scrollToItemAtIndexPath:self.recordMaxIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordMaxIndexPathIfNeed) object:nil];
                
                [UIView performWithoutAnimation:^{
                    [self.collectionView scrollToItemAtIndexPath:self.recordMaxIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }];
            });
        }
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 2.f;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [self configItemSize];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (void)configItemSize {
    CGFloat space = 2.f;
    NSInteger count = _collectionView.bounds.size.width / (80 + space);
    CGFloat width = _collectionView.bounds.size.width - (count > 0 ? (count - 1) * space : 0);
    width = 1.f * width / count ;
    _itemSize = CGSizeMake(width, width);
    _thumbSize = CGSizeMake(width * [UIScreen mainScreen].scale, width * [UIScreen mainScreen].scale);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_needScrollToBottom && _assets) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
        _needScrollToBottom = NO;
    }
}

- (CTImageAlbumListViewController *)rootAlbumViewController {
    UIViewController *root = self.navigationController.viewControllers.firstObject;
    if ([root isKindOfClass:CTImageAlbumListViewController.class]) {
        return (CTImageAlbumListViewController *)root;
    }
    return nil;
}

- (void)down {
    [self.rootAlbumViewController callBack];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CTImagePickerCell" forIndexPath:indexPath];
    PHAsset *photo = _assets[indexPath.row];
    [cell setAsset:photo targetSize:_thumbSize];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_recordMaxIndexPath) {
        [self recordMaxIndexPathIfNeed];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordMaxIndexPathIfNeed) object:nil];
        [self performSelector:@selector(recordMaxIndexPathIfNeed) withObject:nil afterDelay:0.3f inModes:@[NSRunLoopCommonModes]];
    }
    PHAsset *photo = _assets[indexPath.row];
    if ([self.rootAlbumViewController contain:photo]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:YES];
    }
}

- (void)recordMaxIndexPathIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recordMaxIndexPathIfNeed) object:nil];
    
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            self.recordMaxIndexPath = obj;
        } else {
            if (self.recordMaxIndexPath.row < obj.row) {
                self.recordMaxIndexPath = obj;
            }
        }
    }];
    _recordMaxIndexPath = _recordMaxIndexPath.copy;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rootAlbumViewController contain:_assets[indexPath.row]]) {
        [self.rootAlbumViewController removePhotos:@[_assets[indexPath.row]]];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    } else {
        [self.rootAlbumViewController addPhotos:@[_assets[indexPath.row]]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rootAlbumViewController contain:_assets[indexPath.row]]) {
        [self.rootAlbumViewController removePhotos:@[_assets[indexPath.row]]];
    }
}

@end
