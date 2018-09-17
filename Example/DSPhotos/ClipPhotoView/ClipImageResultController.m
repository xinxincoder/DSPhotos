//
//  ClipImageResultController.m
//  ClipImageViewManager
//
//  Created by XXL on 2017/5/16.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "ClipImageResultController.h"

@interface ClipImageResultController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ClipImageResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"完成裁剪";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    imageView.image = self.image;
}

@end
