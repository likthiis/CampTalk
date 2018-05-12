//
//  ViewController.m
//  CampTalk
//
//  Created by LD on 2018/4/17.
//  Copyright © 2018年 yuru. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CTChatTableViewController.h"
#import "CTLoginViewController.h"
#import "CTNavigationController.h"

@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"linJiang" withExtension:@"m4a"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
    
    if (self.player) {
        [self.player prepareToPlay];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linJiang:)];
    [self.view addGestureRecognizer:tap];
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:nil];
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(login:)];
}

- (void)linJiang:(id)sender {
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chat:(id)sender {
    CTChatTableViewController *vc = [CTChatTableViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)login:(id)sender {
    CTNavigationController *ngv = [CTNavigationController navigationWithRoot:[[CTLoginViewController alloc] initWithStyle:UITableViewStylePlain]];
    ngv.type = CTNavigationBackgroundTypeAllTranslucent;
    [self presentViewController:ngv animated:YES completion:nil];
}

@end
