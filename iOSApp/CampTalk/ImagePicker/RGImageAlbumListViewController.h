//
//  CTImageAlbumListViewController.h
//  CampTalk
//
//  Created by renge on 2018/5/7.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGImagePickerConst.h"
#import "RGImagePickerCache.h"

@class RGImagePickerCache;

@interface RGImageAlbumListViewController : UITableViewController

@property (nonatomic, copy) RGImagePickResult pickResult;
@property (nonatomic, strong) RGImagePickerCache *cache;

@end
