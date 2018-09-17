//
//  DSBrowserTestCell.m
//  PhotosManager
//
//  Created by XXL on 2017/7/26.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSBrowserTestCell.h"
#import <DSPhotos/DSPhotos-umbrella.h>
#import "DSPhotoModel.h"
#import "UIImageView+WebCache.h"

@interface DSBrowserTestCell ()<DSBrowserViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageee;

@end

@implementation DSBrowserTestCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    self.imageee.userInteractionEnabled = YES;
    [self.imageee addGestureRecognizer:tap];
    
//    NSURL *ul = [NSURL URLWithString:@"http://img2.imgtn.bdimg.com/it/u=635311535,1396226307&fm=26&gp=0.jpg"];
//    [self.imageView sd_setImageWithURL:ul completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//       
//        NSLog(@"%@",image);
//        
//    }];
    
}

- (void)setModel:(DSPhotoModel *)model {
    _model = model;
    
    [self.imageee sd_setImageWithURL:_model.thumbnailImageURLString];
}
- (void)tapAction:(UITapGestureRecognizer *)tap {
    
//    DSPhotoModel *model1 = [[DSPhotoModel alloc] init];
////    model1.image = [UIImage imageNamed:@"1"];
//    model1.imageURLString = @"https://image1.drugs360.cn/euc/09jEC66MLPUuRn4mmwMMeUrO/image.jpg";
//    
//    DSPhotoModel *model2 = [[DSPhotoModel alloc] init];
//    model2.imageURLString = @"https://image1.drugs360.cn/euc/09lD9pZlHQPKFmCwyJAvRs3N/image.jpg";
    
    self.model.photoView = self.imageee;
    
    NSArray *array = @[self.model];
    
    DSBrowserView *bb = [DSBrowserView browserViewWithPhotoModels:array currentIndex:0];
    bb.delegate = self;
    [bb show];
}

- (UIView *)browserView:(DSBrowserView *)browserView viewForPhotoModel:(DSPhotoModel *)photoModel atIndex:(NSInteger)index {
    
    return self.imageee;
}

@end
