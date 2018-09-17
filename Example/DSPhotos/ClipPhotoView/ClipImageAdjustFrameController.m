//
//  ClipImageAdjustFrameController.m
//  ClipImageViewManager
//
//  Created by XXL on 2017/5/16.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "ClipImageAdjustFrameController.h"
#import "ClipImageResultController.h"
#import <DSPhotos/DSPhotos-umbrella.h>

@interface ClipImageAdjustFrameController ()

@property (strong, nonatomic) IBOutlet DSClipImageAdjustFrameView *clipImageView;

@property (strong, nonatomic) IBOutlet UITextField *ratioTextField;

@end

@implementation ClipImageAdjustFrameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ClipImageAdjustFrameController";
//    DSClipImageAdjustFrameView *clipImageView = [[DSClipImageAdjustFrameView alloc] initWithFrame:self.view.bounds];
//    clipImageView.aspectRatio = @"4:3";
}

- (IBAction)sureClip:(id)sender {
    
    UIImage *image = [self.clipImageView completeClipImage];
    ClipImageResultController *controller = [[ClipImageResultController alloc] init];
    controller.image = image;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)freedomAction:(id)sender {
    self.ratioTextField.text = nil;
    self.clipImageView.type = DSClipImageAdjustFrameViewTypeFreedomRectangle;
}
- (IBAction)oneToOneRationAction:(id)sender {
    self.ratioTextField.text = nil;
    self.clipImageView.type = DSClipImageAdjustFrameViewTypeOneToOneRatioRectangle;
}

- (IBAction)customRationAction:(id)sender {
    
    if (![self.ratioTextField.text containsString:@":"]) return;
    self.clipImageView.aspectRatio = self.ratioTextField.text;
}

@end
