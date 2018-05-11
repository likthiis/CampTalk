//
//  CTImageAlbumListViewController.m
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "CTImageAlbumListViewController.h"

@interface CTImageAlbumListViewController ()

@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *assetCollections;

@property (nonatomic, strong) PHAssetCollection *cameraRoll;
@property (nonatomic, strong) PHFetchResult<PHAsset *> *cameraRollAssets;

@end

@implementation CTImageAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
    _assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    _cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    _cameraRollAssets = [PHAsset fetchAssetsInAssetCollection:_cameraRoll options:nil];
    
    UIBarButtonItem *down = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(callBack)];
    self.navigationItem.rightBarButtonItem = down;
}

- (NSMutableArray<PHAsset *> *)pickPhotos {
    if (!_pickPhotos) {
        _pickPhotos = [NSMutableArray array];
    }
    return _pickPhotos;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + _assetCollections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _cameraRollAssets.count > 0 ? 1 : 0;
    }
    return [PHAsset fetchAssetsInAssetCollection:_assetCollections[section - 1] options:nil].count > 0 ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PHAsset *asset;
    if (indexPath.section == 0) {
        asset = _cameraRollAssets.lastObject;
        cell.textLabel.text = _cameraRoll.localizedTitle;
    } else {
        asset = [PHAsset fetchAssetsInAssetCollection:_assetCollections[indexPath.section - 1] options:nil].lastObject;
        cell.textLabel.text = _assetCollections[indexPath.section - 1].localizedTitle;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(40, 40) contentMode:PHImageContentModeAspectFill options:0 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
        [cell setNeedsLayout];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *collection = nil;
    if (indexPath.section == 0) {
        collection = _cameraRoll;
    } else {
        collection = _assetCollections[indexPath.section - 1];
    }
    CTImagePickerViewController *albumDetails = [[CTImagePickerViewController alloc] init];
    albumDetails.collection = collection;
    [self.navigationController pushViewController:albumDetails animated:YES];
}

- (void)setPhotos:(NSArray<PHAsset *> *)phassets {
    [self.pickPhotos replaceObjectsInRange:NSMakeRange(0, self.pickPhotos.count) withObjectsFromArray:phassets];
}

- (void)addPhotos:(NSArray<PHAsset *> *)phassets {
    [phassets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull addPhoto, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = [self.pickPhotos indexOfObjectPassingTest:^BOOL(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([addPhoto.localIdentifier isEqualToString:obj.localIdentifier]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index == NSNotFound) {
            [self.pickPhotos addObject:addPhoto];
        }
    }];
}

- (void)removePhotos:(NSArray<PHAsset *> *)phassets {
    [phassets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull removedPhoto, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = [self.pickPhotos indexOfObjectPassingTest:^BOOL(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([removedPhoto.localIdentifier isEqualToString:obj.localIdentifier]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound) {
            [self.pickPhotos removeObjectAtIndex:index];
        }
    }];
}

- (BOOL)contain:(PHAsset *)phassets {
    return [self.pickPhotos containsObject:phassets];
}

- (void)callBack {
    if (_pickResult) {
        _pickResult(_pickPhotos, self);
    }
}

@end
