//
//  RGImagePickerCache.m
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "RGImagePickerCache.h"
#import <RGUIKit/RGUIKit.h>

@implementation PHAsset (RGLoaded)

- (void)setRgIsLoaded:(BOOL)rgIsLoaded {
    [self rg_setValue:@(rgIsLoaded) forKey:@"RGLoaded" retain:YES];
}

- (BOOL)rgIsLoaded {
    return [[self rg_valueForKey:@"RGLoaded"] boolValue];
}

@end

@implementation RGImagePickerCache

- (NSMutableArray<PHAsset *> *)pickPhotos {
    if (!_pickPhotos) {
        _pickPhotos = [NSMutableArray array];
    }
    return _pickPhotos;
}

- (NSMutableArray<NSDictionary<NSString *,UIImage *> *> *)cachePhotos {
    if (!_cachePhotos) {
        _cachePhotos = [NSMutableArray array];
    }
    return _cachePhotos;
}

- (void)addCachePhoto:(UIImage *)photo forAsset:(PHAsset *)asset {
    NSUInteger index = [self indexForCacheAsset:asset];
    if (index != NSNotFound) {
        UIImage *image = self.cachePhotos[index].allValues.firstObject;
        if (photo.size.width > image.size.width || photo.size.height > image.size.height) {
            self.cachePhotos[index] = @{asset.localIdentifier: photo};
        }
        return;
    }
    if (self.cachePhotos.count > 100) {
        [self.cachePhotos removeObjectAtIndex:0];
    }
    [self.cachePhotos addObject:@{asset.localIdentifier: photo}];
}

- (void)removeCachePhotoForAsset:(NSArray <PHAsset *> *)assets {
    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = [self indexForCacheAsset:obj];
        if (index == NSNotFound) {
            return;
        }
        [self.cachePhotos removeObjectAtIndex:index];
    }];
}

- (NSUInteger)indexForCacheAsset:(PHAsset *)asset {
    for (NSInteger i = 0; i < self.cachePhotos.count; i++) {
        NSDictionary<NSString *,UIImage *> *obj = self.cachePhotos[i];
        if ([obj.allKeys.firstObject isEqualToString:asset.localIdentifier]) {
            return i;
        }
    }
    return NSNotFound;
}

- (UIImage *)imageForAsset:(PHAsset *)asset {
    NSUInteger index = [self indexForCacheAsset:asset];
    if (index != NSNotFound) {
        return self.cachePhotos[index].allValues.firstObject;
    }
    return nil;
}

- (void)setPhotos:(NSArray<PHAsset *> *)phassets {
    [self.pickPhotos removeAllObjects];
    [self.pickPhotos addObjectsFromArray:phassets];
//    [self.pickPhotos replaceObjectsInRange:NSMakeRange(0, self.pickPhotos.count) withObjectsFromArray:phassets];
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

- (BOOL)isFull {
    return self.pickPhotos.count >= self.maxCount;
}

- (void)callBack:(UIViewController *)viewController {
    if (_pickResult) {
        _pickResult(_pickPhotos, viewController);
    }
}

@end
