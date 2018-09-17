//
//  DSVideoController.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSVideoController.h"
#import "DSPhotosCommon.h"
#import <AVFoundation/AVFoundation.h>
#import "DSPhotoModel.h"

@interface DSVideoController ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation DSVideoController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.model.videoAsset];
    playerItem.audioMix = self.model.audioMix;
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playerLayer.frame = self.view.bounds;
    self.player = player;
    [self.view.layer addSublayer:playerLayer];
    
    [self createBottomView];
}

- (void)createBottomView {
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 60, CGRectGetWidth(self.view.bounds), 60)];
    
    bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bottomView];
    
    CGFloat y = CGRectGetHeight(bottomView.bounds)*0.5 - 20;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(20, y, 40, 40);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:cancelButton];
    
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)*0.5-20, y, 40, 40);
    [playButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_PLAYVIDEO] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_PAUSEVIDEO] forState:UIControlStateSelected];
    [playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:playButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 40 - 20, y, 40, 40);
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    
    [bottomView addSubview:doneButton];
    
}

- (void)cancelAction:(UIButton *)btn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        
        [self.player play];
        
    }else {
        
        [self.player pause];
    }
    
}

@end
