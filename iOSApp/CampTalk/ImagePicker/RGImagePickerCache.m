//
//  RGImagePickerCache.m
//  CampTalk
//
//  Created by renge on 2019/8/1.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "RGImagePickerCache.h"

@implementation RGImagePickerCache

- (NSMutableArray<PHAsset *> *)pickPhotos {
    if (!_pickPhotos) {
        _pickPhotos = [NSMutableArray array];
    }
    return _pickPhotos;
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

- (void)callBack:(UIViewController *)viewController {
    if (_pickResult) {
        _pickResult(_pickPhotos, viewController);
    }
}

@end
