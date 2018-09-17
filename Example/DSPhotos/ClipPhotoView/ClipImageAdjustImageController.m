//
//  ClipImageAdjustImageController.m
//  ClipImageViewManager
//
//  Created by XXL on 2017/5/16.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "ClipImageAdjustImageController.h"
#import "ClipImageResultController.h"
#import "DSClipImageAdjustImageView.h"

@interface ClipImageAdjustImageController ()

@property (strong, nonatomic) IBOutlet DSClipImageAdjustImageView *clipImageView;

@end

@implementation ClipImageAdjustImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"ClipImageAdjustImageController";
        
}
- (IBAction)roundAction:(id)sender {
    
    self.clipImageView.type = DSClipImageAdjustImageViewTypeRound;
}
- (IBAction)rectangleAction:(id)sender {
    
    self.clipImageView.type = DSClipImageAdjustImageViewTypeRectangle;
}
- (IBAction)sureClipAction:(id)sender {
    
    UIImage *image = [self.clipImageView completeClipImage];
    ClipImageResultController *controller = [[ClipImageResultController alloc] init];
    controller.image = image;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
