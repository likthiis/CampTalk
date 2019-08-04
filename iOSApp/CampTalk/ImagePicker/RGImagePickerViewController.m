//
//  CTImagePickerViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "RGImagePickerViewController.h"
#import "RGImageAlbumListViewController.h"

#import <RGUIKit/RGUIKit.h>

#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>

#import "ImageGallery.h"

#import "RGImagePickerConst.h"
#import "RGImagePickerCache.h"
#import "RGImagePicker.h"
#import "UIImageView+RGGif.h"

#import "RGImagePickerCell.h"

#import "CTUserConfig.h"

#import "Bluuur.h"

@interface RGImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, RGImagePickerCellDelegate, ImageGalleryDelegate>

@property (nonatomic, assign) BOOL needScrollToBottom;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize thumbSize;

@property (nonatomic, strong) NSIndexPath *recordMaxIndexPath;

@property (nonatomic, strong) ImageGallery *imageGallery;

@property (nonatomic, strong) UIToolbar *toolBar;

@property (nonatomic, strong) UIButton *toolBarLabel;
@property (nonatomic, strong) UIButton *toolBarLabelGallery;

@end

@implementation RGImagePickerViewController

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
    
    [self.collectionView registerClass:[RGImagePickerCell class] forCellWithReuseIdentifier:@"RGImagePickerCell"];
    self.collectionView.allowsMultipleSelection = self.cache.maxCount > 1;
    
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rg_dismiss)];
    self.navigationItem.rightBarButtonItem = down;
    [self __configViewWithCollection:_collection];
    
    _imageGallery = [[ImageGallery alloc] initWithPlaceHolder:[UIImage rg_imageWithName:@"sad"] andDelegate:self];
    
    [self.view addSubview:self.toolBar];
    self.toolBar.items = [self __toolBarItemForGallery:NO];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 2.f;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        [self __configItemSize];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
    }
    return _toolBar;
}

- (void)setCollection:(PHAssetCollection *)collection {
    _collection = collection;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = predicate;
    
    _assets = [PHAsset fetchAssetsInAssetCollection:_collection options:option];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if (self.isViewLoaded) {
        [self __configViewWithCollection:_collection];
    }
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat recordHeight = self.collectionView.frame.size.height;
    _collectionView.frame = self.view.bounds;
    
    [self __configItemSize];
    [_collectionView reloadData];
    
    if (!_needScrollToBottom) {
        
        if (recordHeight != self.collectionView.frame.size.height) {
            
            if (!_recordMaxIndexPath) {
                return;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__recordMaxIndexPathIfNeed) object:nil];
            
            [self.collectionView scrollToItemAtIndexPath:self.recordMaxIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__recordMaxIndexPathIfNeed) object:nil];
                
                [UIView performWithoutAnimation:^{
                    [self.collectionView scrollToItemAtIndexPath:self.recordMaxIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }];
            });
        }
    }
    self.toolBar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44, self.view.bounds.size.width, 44);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self __scrollToBottomIfNeed];
}

- (void)__configViewWithCollection:(PHAssetCollection *)collection {
    [self.collectionView reloadData];
    [self __configTitle];
    [self setNeedScrollToBottom:YES];
    [self __scrollToBottomIfNeed];
    [self.view setNeedsLayout];
}

- (void)__configTitle {
    NSString *title = [NSString stringWithFormat:@"%@ (%lu/%lu)", _collection.localizedTitle, (unsigned long)self.cache.pickPhotos.count, (unsigned long)self.cache.maxCount];
    self.navigationItem.title = title;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_collection.localizedTitle style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)__scrollToBottomIfNeed {
    if (_needScrollToBottom && _assets) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
        _needScrollToBottom = NO;
    }
}

- (void)__configItemSize {
    CGFloat space = 2.f;
    NSInteger count = _collectionView.bounds.size.width / (80 + space);
    CGFloat width = _collectionView.bounds.size.width - (count > 0 ? (count - 1) * space : 0);
    width = 1.f * width / count ;
    _itemSize = CGSizeMake(width, width);
    _thumbSize = CGSizeMake(width * [UIScreen mainScreen].scale, width * [UIScreen mainScreen].scale);
}

- (void)__down {
    [self.cache callBack:self];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RGImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RGImagePickerCell" forIndexPath:indexPath];
    PHAsset *photo = _assets[indexPath.row];
    cell.cache = self.cache;
    [cell setAsset:photo targetSize:_thumbSize];
    cell.delegate = self;
    
    if (_imageGallery.page == indexPath.row) {
        if (_imageGallery.isPush > noPush) {
            cell.contentView.alpha = 0;
        } else {
            cell.contentView.alpha = 1;
        }
    } else {
        cell.contentView.alpha = 1;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_recordMaxIndexPath) {
        [self __recordMaxIndexPathIfNeed];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__recordMaxIndexPathIfNeed) object:nil];
        [self performSelector:@selector(__recordMaxIndexPathIfNeed) withObject:nil afterDelay:0.3f inModes:@[NSRunLoopCommonModes]];
    }
    PHAsset *photo = _assets[indexPath.row];
    if ([self.cache contain:photo]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [cell setSelected:YES];
    }
}

- (void)__recordMaxIndexPathIfNeed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(__recordMaxIndexPathIfNeed) object:nil];
    
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RGImagePickerCell *cell = (RGImagePickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.lastTouchForce == 0) {
        PHAsset *photo = _assets[indexPath.row];
        BOOL needLoad = !photo.rgIsLoaded;
        if (needLoad) {
            [RGImagePickerCell loadOriginalWithAsset:photo updateCell:cell];
            return NO;
        }
        [_imageGallery showImageGalleryAtIndex:indexPath.row fatherViewController:self];
        return NO;
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.cache contain:_assets[indexPath.row]]) {
//        [self.cache removePhotos:@[_assets[indexPath.row]]];
//    }
//}

- (void)__selectItemWithCurrentGalleryPage {
    [self __selectItemAtIndex:_imageGallery.page orCell:nil];
    [_imageGallery configToolBarItem];
}

- (void)__selectItemAtIndex:(NSInteger)index orCell:(RGImagePickerCell *_Nullable)cell {
    PHAsset *asset = self->_assets[index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    if (!cell) {
        cell = (RGImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    }
    
    BOOL isFull = self.cache.isFull;
    
    if (indexPath) {
        if ([self.cache contain:asset]) {
            [self.cache removePhotos:@[asset]];
            [cell setSelected:NO animated:YES];
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        } else {
            [RGImagePickerCell needLoadWithAsset:asset result:^(BOOL needLoad) {
                if (needLoad) {
                    [RGImagePickerCell loadOriginalWithAsset:asset updateCell:cell];
                } else {
                    if (self.cache.maxCount <= 1) {
                        [self.cache setPhotos:@[asset]];
                        [cell setSelected:YES animated:YES];
                        [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    } else {
                        if (self.cache.pickPhotos.count < self.cache.maxCount) {
                            [self.cache addPhotos:@[asset]];
                            [cell setSelected:YES animated:YES];
                            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    }
                }
            }];
        }
    }
    if (self.cache.isFull != isFull) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        NSMutableArray *visiable = [NSMutableArray arrayWithArray:self.collectionView.indexPathsForVisibleItems];
        [visiable removeObject:indexPath];
        [self.collectionView reloadItemsAtIndexPaths:visiable];
        [CATransaction commit];
    }
    [self __configViewWhenCacheChanged];
}

- (void)__configViewWhenCacheChanged {
    self.toolBar.items = [self __toolBarItemForGallery:NO];
    [self __configTitle];
}

- (NSArray <UIBarButtonItem *> *)__toolBarItemForGallery:(BOOL)forGallery {
    NSMutableArray *array = [NSMutableArray array];
    
    PHAsset *asset = forGallery ? _assets[_imageGallery.page] : nil;
    
    UIBarButtonItem *countItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (!_toolBarLabelGallery) {
        _toolBarLabelGallery = [[UIButton alloc] init];
        [_toolBarLabelGallery setBackgroundImage:[UIImage rg_templateImageWithSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        _toolBarLabelGallery.layer.cornerRadius = 12;
        _toolBarLabelGallery.clipsToBounds = YES;
    }
    
    if (!_toolBarLabel) {
        _toolBarLabel = [[UIButton alloc] init];
        [_toolBarLabel setBackgroundImage:[UIImage rg_templateImageWithSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        _toolBarLabel.layer.cornerRadius = 12;
        _toolBarLabel.clipsToBounds = YES;
    }
    
    UIButton *label = forGallery ? _toolBarLabelGallery : _toolBarLabel;
    NSString *text = @(self.cache.pickPhotos.count).stringValue;
    
    if (![text isEqualToString:[label titleForState:UIControlStateNormal]]) {
        [label setTitle:text forState:UIControlStateNormal];
        [label sizeToFit];
        CGFloat width = MAX(label.frame.size.width + 2, 28);
        label.frame = CGRectMake(0, 0, width, 28);
    }
    
    countItem.customView = label;
    [array addObject:countItem];
    
    [array addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    if (asset) {
        if ([self.cache contain:asset]) {
            [array addObject:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(__selectItemWithCurrentGalleryPage)]];
        } else {
            if (asset.rgIsLoaded) {
                UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(__selectItemWithCurrentGalleryPage)];
                addItem.enabled = !self.cache.isFull;
                [array addObject:addItem];
            } else {
                UIActivityIndicatorView *loading = [UIActivityIndicatorView new];
                loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
                [loading sizeToFit];
                [loading startAnimating];
                UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:loading];
                [array addObject:loadingItem];
            }
        }
    }
    
    [array addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(__down)];
    down.enabled = self.cache.pickPhotos.count;
    [array addObject:down];
    
    return array;
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // https://developer.apple.com/documentation/photokit/phphotolibrarychangeobserver?language=objc
    // Photos may call this method on a background queue;
    // switch to the main queue to update the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check for changes to the displayed album itself
        // (its existence and metadata, not its member assets).
        
        //        PHObjectChangeDetails *albumChanges = [changeInstance changeDetailsForObject:self.assets];
        //        if (albumChanges) {
        //            // Fetch the new album and update the UI accordingly.
        //            self.displayedAlbum = [albumChanges objectAfterChanges];
        //            self.navigationController.navigationItem.title = self.assets.localizedTitle;
        //        }
        
        // Check for changes to the list of assets (insertions, deletions, moves, or updates).
        
        BOOL isFull = self.cache.isFull;
        
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assets];
        if (collectionChanges) {
            // Get the new fetch result for future change tracking.
            PHFetchResult <PHAsset *> *oldAssets = self.assets;
            self.assets = collectionChanges.fetchResultAfterChanges;
            
            if (collectionChanges.hasIncrementalChanges)  {
                // Tell the collection view to animate insertions/deletions/moves
                // and to refresh any cells that have changed content.
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removed = collectionChanges.removedIndexes;
                    if (removed.count) {
                        [self.collectionView deleteItemsAtIndexPaths:[self __indexPathsFromIndexSet:removed]];
                        
                        NSArray *removePhotos = [oldAssets objectsAtIndexes:removed];
                        [self.cache removePhotos:removePhotos];
                        
                        [removed enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                            [self->_imageGallery deletePage:idx];
                        }];
                        [self __configViewWhenCacheChanged];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (self.cache.isFull != isFull) {
                                [self.collectionView reloadData];
                            }
                        });
                    }
                    NSIndexSet *inserted = collectionChanges.insertedIndexes;
                    if (inserted.count) {
                        [self.collectionView insertItemsAtIndexPaths:[self __indexPathsFromIndexSet:inserted]];
                    }
                    NSIndexSet *changed = collectionChanges.changedIndexes;
                    if (changed.count) {
                        [self.cache removeCachePhotoForAsset:[self.assets objectsAtIndexes:changed]];
                        [self.collectionView reloadItemsAtIndexPaths:[self __indexPathsFromIndexSet:changed]];
                        [self->_imageGallery updatePages];
                    }
                    if (collectionChanges.hasMoves) {
                        [collectionChanges enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:fromIndex inSection:0];
                            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
                            [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                        }];
                    }
                } completion:nil];
            } else {
                // Detailed change information is not available;
                // repopulate the UI from the current fetch result.
                [self.collectionView reloadData];
            }
        }
    });
}

- (NSArray<NSIndexPath *> *)__indexPathsFromIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:indexSet.count];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    return array;
}

#pragma mark - RGImagePickerCellDelegate

- (void)imagePickerCell:(RGImagePickerCell *)cell touchForce:(CGFloat)force maximumPossibleForce:(CGFloat)maximumPossibleForce {
    if (maximumPossibleForce) {
        maximumPossibleForce /= 2.5f;
        self.view.alpha = MAX(0, (maximumPossibleForce - force) / maximumPossibleForce);
    }
}

- (void)didCheckForImagePickerCell:(RGImagePickerCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self __selectItemAtIndex:indexPath.row orCell:cell];
}

#pragma mark - ImageGalleryDelegate

- (NSInteger)numOfImagesForImageGallery:(ImageGallery *)imageGallery {
    return _assets.count;
}

- (UIColor *)titleColorForImageGallery:(ImageGallery *)imageGallery {
    return self.navigationController.navigationBar.tintColor;
}

- (UIImage *)backgroundImageForImageGalleryBar:(ImageGallery *)imageGallery {
    return self.navigationController.navigationBar.backIndicatorImage;
}

- (UIImage *)backgroundImageForParentViewControllerBar {
    return nil;
}

- (NSString *)titleForImageGallery:(ImageGallery *)imageGallery AtIndex:(NSInteger)index {
    if (index >= 0) {
        PHAsset *assert = _assets[index];
        NSString *title = [[assert creationDate] rg_stringWithDateFormat:@"yyyy-MM-dd\nHH:mm"];
        
//        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//        [geocoder reverseGeocodeLocation:_assets[index].location
//                       completionHandler:^(NSArray *placemarks, NSError *error){
//                           if(!error){
//                               for (CLPlacemark *place in placemarks) {
//                                   NSString *city = place.locality;
//                                   NSString *administrativeArea = place.administrativeArea;
//                                   NSString *addressString = nil;
//                                   if ([city isEqualToString:administrativeArea]) {
//                                       //四大直辖市
//                                       addressString = [NSString stringWithFormat:@"%@%@",city,place.subLocality];
//                                   } else{
//                                       addressString = [NSString stringWithFormat:@"%@%@",administrativeArea,city];
//                                   }
//                                   break;
//                               }
//                           }
//                       }];
        return title;
    } else {
        return @"";
    }
}

- (UIImage *)imageGallery:(ImageGallery *)imageGallery imageAtIndex:(NSInteger)index targetSize:(CGSize)targetSize updateImage:(void (^ _Nullable)(UIImage * _Nonnull))updateImage {
    if (index>=0) {
        PHAsset *asset = _assets[index];
        if (updateImage) {
            [RGImagePicker loadResourceFromAsset:asset progressHandler:nil completion:^(NSData * _Nullable imageData, NSError * _Nullable error) {
                UIImage *image = [UIImage rg_imageOrGifWithData:imageData];
                if (image) {
                    updateImage(image);
                }
                if ([self->_assets[imageGallery.page].localIdentifier isEqualToString:asset.localIdentifier]) {
                    [imageGallery configToolBarItem];
                }
            }];
        }
        return [self.cache imageForAsset:asset];
    } else {
        return nil;
    }
}

- (BOOL)isVideoAtIndex:(NSInteger)index {
    return NO;
}

- (UIImage *)buttonForPlayVideo {
    return [UIImage imageNamed:@"jus_video_play"];
}

- (BOOL)imageGallery:(ImageGallery *)imageGallery selectePlayVideoAtIndex:(NSInteger)index {
//    if (index >= 0) {
//        MediaDetailsModel *model = _dataList[index];
//        MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:model.fileUrl];
//        [imageGallery presentMoviePlayerViewControllerAnimated:movie];
//    }
    return YES;
}

- (void)imageGallery:(ImageGallery *)imageGallery selecteDeleteImageAtIndex:(NSInteger)index {
//    [self showAlertDeleteInView:imageGallery.view];
}

- (void)imageGallery:(ImageGallery *)imageGallery selecteShareImageAtIndex:(NSInteger)index {
//    [self showAlertSaveInView:imageGallery.view];
}

- (UIView *)imageGallery:(ImageGallery *)imageGallery thumbViewForPushAtIndex:(NSInteger)index {
    if (index >= 0) {
        if (imageGallery.isPush == pushed) {
            if (imageGallery.isPush == pushed && index>=0) {
                NSIndexPath *needShowIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                if (![self.collectionView.indexPathsForVisibleItems containsObject:needShowIndexPath]) {
                    [self.collectionView scrollToItemAtIndexPath:needShowIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                }
            }
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            [CATransaction commit];
        }
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        return cell;
    } else  {
        return nil;
    }
}

- (BOOL)imageGallery:(ImageGallery *)imageGallery toolBarItemsShouldDisplayForIndex:(NSInteger)index {
    return YES;
}

- (NSArray<UIBarButtonItem *> *)imageGallery:(ImageGallery *)imageGallery toolBarItemsForIndex:(NSInteger)index {
    return [self __toolBarItemForGallery:YES];
}

- (RGBackCompletion)imageGallery:(ImageGallery *)imageGallery willBackToParentViewController:(UIViewController *)viewController {
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:imageGallery.page inSection:0]];
    cell.contentView.alpha = 0;
    
    RGBackCompletion com = ^(BOOL flag) {
        cell.contentView.alpha = 1;
    };
    
    return com;
}

@end
