//
//  UIImageView+RGGif.m
//  CampTalk
//
//  Created by renge on 2019/8/3.
//  Copyright © 2019 yuru. All rights reserved.
//

#import "UIImageView+RGGif.h"
#import "FLAnimatedImage.h"
#import <RGUIKit/RGUIKit.h>

@implementation UIImageView(RGGif)

+ (void)load {
    [self rg_swizzleOriginalSel:@selector(setContentMode:) swizzledSel:@selector(rg_setContentMode:)];
    [self rg_swizzleOriginalSel:@selector(image) swizzledSel:@selector(rg_image)];
    [self rg_swizzleOriginalSel:@selector(setImage:) swizzledSel:@selector(rg_setImage:)];
}

- (UIImage *)rg_image {
    if (self.rg_image) {
        return self.rg_image;
    }
    FLAnimatedImageView *gifView = [self rg_valueForKey:@"gifView"];
    if (gifView.animatedImage) {
        return [gifView.animatedImage imageLazilyCachedAtIndex:0];
    }
    return nil;
}

- (void)rg_setImage:(UIImage *)image {
    FLAnimatedImageView *gifView = [self rg_valueForKey:@"gifView"];
    if ([image isKindOfClass:UIImage.class]) {
        [self rg_setImage:image];
        gifView.animatedImage = nil;
    } else if ([image isKindOfClass:FLAnimatedImage.class]) {
        [self rg_setImage:nil];
        self.gifView.animatedImage = (FLAnimatedImage *)image;
    } else if ([image isKindOfClass:NSData.class]) {
        [self rg_setImageData:(NSData *)image];
    } else {
        if (self.image) {
            [self rg_setImage:nil];
        }
        if (gifView.animatedImage) {
            gifView.animatedImage = nil;
        }
    }
}

- (void)rg_setContentMode:(UIViewContentMode)mode {
    [self rg_setContentMode:mode];
    FLAnimatedImageView *gifView = [self rg_valueForKey:@"gifView"];
    if (gifView.contentMode != mode) {
        gifView.contentMode = mode;
    }
}

- (FLAnimatedImageView *)gifView {
    FLAnimatedImageView *gifView = [self rg_valueForKey:@"gifView"];
    if (!gifView) {
        gifView = [[FLAnimatedImageView alloc] initWithFrame:self.bounds];
        [self rg_setValue:gifView forKey:@"gifView" retain:YES];
        gifView.contentMode = self.contentMode;
        gifView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:gifView atIndex:0];
    }
    return gifView;
}

- (void)rg_setImagePath:(NSString *)path async:(BOOL)async completion:(void (^ _Nullable)(void))completion {
    if (async) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self rg_setImageData:data];
                if (completion) {
                    completion();
                }
            });
        });
    } else {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        [self rg_setImageData:data];
        if (completion) {
            completion();
        }
    }
}

- (void)rg_setImagePath:(NSString *)path {
    [self rg_setImagePath:path async:NO completion:nil];
}

- (void)rg_setImageData:(NSData *)data {
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    if (image) {
        self.image = (UIImage *)image;
    } else {
        self.image = [UIImage imageWithData:data];
    }
}

- (BOOL)rg_isAnimating {
    return self.gifView.isAnimating;
}

- (void)rg_stop {
    [self.gifView stopAnimating];
}

- (void)rg_start {
    [self.gifView startAnimating];
}

@end


@implementation UIImage (RGGif)

+ (UIImage *)rg_imageOrGifWithData:(NSData *)data {
    FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
    if (image) {
        return (UIImage *)image;
    }
    return [UIImage imageWithData:data];
}

@end


