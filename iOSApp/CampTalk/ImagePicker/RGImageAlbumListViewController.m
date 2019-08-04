//
//  CTImageAlbumListViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "RGImageAlbumListViewController.h"
#import "RGImagePickerViewController.h"
#import <RGUIKit/RGUIKit.h>

@interface RGImageAlbumListViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHAssetCollection *cameraCollections;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *cameraAssets;

@property (nonatomic, strong) PHAssetCollection *favAssetCollections;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *favAssets;

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *assetCollections;

@end

@implementation RGImageAlbumListViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        [self loadData];
    }
    return self;
}

- (void)loadData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = predicate;
    
    // 所有照片
    _cameraCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    _cameraAssets = [PHAsset fetchAssetsInAssetCollection:_cameraCollections options:option];
    
    // 收藏
    _favAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil].lastObject;
    _favAssets = [PHAsset fetchAssetsInAssetCollection:_favAssetCollections options:option];
    
    // 其他相册
    _assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:RGTableViewCell.class forCellReuseIdentifier:RGCellIDValue1];
    
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rg_dismiss)];
    self.navigationItem.rightBarButtonItem = down;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + _assetCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _cameraAssets.count > 0 ? 1 : 0;
    }
    if (section == 1) {
        return _favAssets.count > 0 ? 1 : 0;
    }
    return [PHAsset fetchAssetsInAssetCollection:_assetCollections[section - 2] options:nil].count > 0 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RGCellIDValue1 forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PHAsset *asset;
    if (indexPath.section == 0) {
        asset = _cameraAssets.lastObject;
        cell.textLabel.text = _cameraCollections.localizedTitle;
        cell.detailTextLabel.text = @(_cameraAssets.count).stringValue;
    } else if (indexPath.section == 1) {
        asset = _favAssets.lastObject;
        cell.textLabel.text = _favAssetCollections.localizedTitle;
        cell.detailTextLabel.text = @(_favAssets.count).stringValue;
    } else {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.predicate = predicate;
        
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:_assetCollections[indexPath.section - 2] options:option];
        asset = result.lastObject;
        
        cell.textLabel.text = _assetCollections[indexPath.section - 2].localizedTitle;
        cell.detailTextLabel.text = @(result.count).stringValue;
    }
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(40, 40) contentMode:PHImageContentModeAspectFill options:0 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
        [cell setNeedsLayout];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *collection = nil;
    if (indexPath.section == 0) {
        collection = _cameraCollections;
    } else if (indexPath.section == 1) {
        collection = _favAssetCollections;
    } else {
        collection = _assetCollections[indexPath.section - 2];
    }
    RGImagePickerViewController *albumDetails = [[RGImagePickerViewController alloc] init];
    albumDetails.collection = collection;
    albumDetails.cache = self.cache;
    [self.navigationController pushViewController:albumDetails animated:YES];
}

- (void)callBack {
    [self.cache callBack:self];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
    });
}

@end
