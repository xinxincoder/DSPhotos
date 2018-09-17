//
//  DSBrowserCell.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSBrowserCell.h"
#import "DSPhotoModel.h"
#import "DSPhotosCommon.h"
#import <Photos/Photos.h>
#import "DSZoomImageView.h"

#import "UIImageView+WebCache.h"


@interface DSBrowserCell ()

@property (nonatomic, strong) DSZoomImageView* zoomImageDSView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation DSBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    
    DSZoomImageView *imageDSView = [[DSZoomImageView alloc] init];
    imageDSView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView addSubview:imageDSView];
    self.zoomImageDSView = imageDSView;
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    indicatorView.hidesWhenStopped = YES;
    [self.contentView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    
}


- (void)setModel:(DSPhotoModel *)model {
    _model = model;
    
    if (_model.mAsset) {
        
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:_model.mAsset targetSize:[UIScreen mainScreen].bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            
            if ([info[PHImageResultIsDegradedKey] boolValue]) {
                
                if (_model.thumbnailImage) {
                    
                    weakSelf.zoomImageDSView.image = _model.thumbnailImage;
                    
                }else {
                    
                    weakSelf.zoomImageDSView.image = result;
                }
                
            } else {
                
                _model.thumbnailImage = result;
                _model.image = result;
                weakSelf.zoomImageDSView.image = result;
            }
        }];
        
    }else {
    
        if (_model.image) {
            
            self.zoomImageDSView.image = _model.image;
            return;
            
        }else if (_model.imageURLString) {
            
            
            [self.indicatorView startAnimating];
            
            UIImage *placeholderImage;
            
            if (_model.thumbnailImage) {
                
                placeholderImage = _model.thumbnailImage;
                
            }else {
                
                UIImage *image = [SDImageCache.sharedImageCache imageFromCacheForKey:_model.thumbnailImageURLString];
                
                placeholderImage = image;
                
            }
            
            //以后可以添加进度条的图标
            self.zoomImageDSView.image = placeholderImage;
            [self.zoomImageDSView.imageDSView sd_setImageWithURL:[NSURL URLWithString:_model.imageURLString] placeholderImage:placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
                
            } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
                _model.image = image;
                self.zoomImageDSView.image = image;
                
                [self.indicatorView stopAnimating];
                
            }];
            
            return;
            
        }else if (_model.thumbnailImage){
            
            self.zoomImageDSView.image = _model.thumbnailImage;
            return;
        }
    
    }
    
}

- (void)setZoomScale:(CGFloat)zoomScale {
    _zoomScale = zoomScale;
    
    self.zoomImageDSView.zoomScale = _zoomScale;
    
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.zoomImageDSView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.indicatorView.center = self.contentView.center;
}

@end
