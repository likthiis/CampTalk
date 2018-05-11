//
//  CTImageAlbumListViewController.h
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTImagePickerViewController.h"

@interface CTImageAlbumListViewController : UITableViewController

@property (nonatomic, copy) ImagePickResult pickResult;

@property (nonatomic, strong) NSMutableArray <PHAsset *> *pickPhotos;

- (void)setPhotos:(NSArray <PHAsset *> *)phassets;
- (void)addPhotos:(NSArray <PHAsset *> *)phassets;
- (void)removePhotos:(NSArray <PHAsset *> *)phassets;
- (BOOL)contain:(PHAsset *)phassets;

- (void)callBack;

@end
