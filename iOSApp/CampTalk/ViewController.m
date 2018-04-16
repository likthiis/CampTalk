//
//  ViewController.m
//  CampTalk
//
//  Created by LD on 2018/4/17.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"linJiang" withExtension:@"m4a"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    
    if (self.player) {
        [self.player prepareToPlay];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linJiang:)];
    [self.view addGestureRecognizer:tap];
}

- (void)linJiang:(id)sender {
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
