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

#import "RGImagePickerCache.h"
#import "RGImagePickerCell.h"

#import "CTUserConfig.h"

#import "Bluuur.h"

@interface RGImagePickerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, RGImagePickerCellDelegate>

@property (nonatomic, assign) BOOL needScrollToBottom;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize thumbSize;

@property (nonatomic, strong) NSIndexPath *recordMaxIndexPath;

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
    
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(down)];
    self.navigationItem.rightBarButtonItem = down;
    [self configViewWithCollection:_collection];
}

- (void)setCollection:(PHAssetCollection *)collection {
    _collection = collection;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = predicate;
    
    _assets = [PHAsset fetchAssetsInAssetCollection:_collection options:option];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if (self.isViewLoaded) {
        [self configViewWithCollection:_collection];
    }
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)configViewWithCollection:(PHAssetCollection *)collection {
    self.navigationItem.title = _collection.localizedTitle;
    [self.collectionView reloadData];
    
    [self setNeedScrollToBottom:YES];
    [self scrollToBottomIfNeed];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomIfNeed];
}

- (void)scrollToBottomIfNeed {
    if (_needScrollToBottom && _assets) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.assets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        });
        _needScrollToBottom = NO;
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

- (RGImagePickerCache *)cache {
    return _cache;
//    UIViewController *root = self.navigationController.viewControllers.firstObject;
//    if ([root isKindOfClass:RGImageAlbumListViewController.class]) {
//        return (RGImageAlbumListViewController *)root;
//    }
//    return nil;
}

- (void)down {
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
    [cell setAsset:photo targetSize:_thumbSize];
    cell.delegate = self;
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
    if ([self.cache contain:photo]) {
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RGImagePickerCell *cell = (RGImagePickerCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.lastTouchForce == 0) {
        PHAsset *photo = _assets[indexPath.row];
        BOOL needLoad = [cell needLoadWithAsset:photo];
        if (needLoad) {
            [cell loadOriginalWithAsset:photo];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cache contain:_assets[indexPath.row]]) {
        [self.cache removePhotos:@[_assets[indexPath.row]]];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    } else {
        [self.cache setPhotos:@[_assets[indexPath.row]]];
//        [self.cache addPhotos:@[_assets[indexPath.row]]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cache contain:_assets[indexPath.row]]) {
        [self.cache removePhotos:@[_assets[indexPath.row]]];
    }
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
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assets];
        if (collectionChanges) {
            // Get the new fetch result for future change tracking.
            self.assets = collectionChanges.fetchResultAfterChanges;
            
            if (collectionChanges.hasIncrementalChanges)  {
                // Tell the collection view to animate insertions/deletions/moves
                // and to refresh any cells that have changed content.
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removed = collectionChanges.removedIndexes;
                    if (removed.count) {
                        [self.collectionView deleteItemsAtIndexPaths:[self indexPathsFromIndexSet:removed]];
                    }
                    NSIndexSet *inserted = collectionChanges.insertedIndexes;
                    if (inserted.count) {
                        [self.collectionView insertItemsAtIndexPaths:[self indexPathsFromIndexSet:inserted]];
                    }
                    NSIndexSet *changed = collectionChanges.changedIndexes;
                    if (changed.count) {
                        [self.collectionView reloadItemsAtIndexPaths:[self indexPathsFromIndexSet:changed]];
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

- (NSArray<NSIndexPath *> *)indexPathsFromIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:indexSet.count];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    return array;
}

#pragma mark - RGImagePickerCellDelegate

- (void)RGImagePickerCell:(RGImagePickerCell *)cell touchForce:(CGFloat)force maximumPossibleForce:(CGFloat)maximumPossibleForce {
    if (maximumPossibleForce) {
        self.view.alpha = (maximumPossibleForce - force) / maximumPossibleForce;
    }
}

@end
