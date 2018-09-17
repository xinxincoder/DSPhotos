//
//  DSAlbumCell.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSAlbumCell.h"
#import "DSAlbumsModel.h"
#import <Photos/Photos.h>
#import "DSPhotosCommon.h"

static CGSize kAssetRowThumbnailSize;

@interface DSAlbumCell ()

@property (nonatomic, strong) UIImageView *photoImageView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) UIImageView *indicatorImageView;

// 缓存图片
@property (nonatomic, strong) PHCachingImageManager *pImageManager;

@end

@implementation DSAlbumCell

#pragma mark - 懒加载
- (PHCachingImageManager *)pImageManager {
    if (!_pImageManager) {
        _pImageManager = [[PHCachingImageManager alloc] init];
    }
    return _pImageManager;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ;
    
    CGFloat mScale = [UIScreen mainScreen].scale;
    kAssetRowThumbnailSize = CGSizeMake(108*mScale, 108*mScale);
    
    UIImageView *photoImageView = [[UIImageView alloc] init];
    photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    photoImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.photoImageView = photoImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = [UIColor darkTextColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel = nameLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.textColor = [UIColor darkGrayColor];
    countLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.countLabel = countLabel];
    
    UIImageView *indicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:EPC_IMG_PHOTO_ALBUMINDICATOR]];
    
    [self.contentView addSubview:self.indicatorImageView = indicatorImageView];
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    self.nameLabel.text = _assetCollection.localizedTitle;
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:nil];
    PHAsset *asset = fetchResult.firstObject;
    
    self.countLabel.text = [NSString stringWithFormat:@" (%zd)",fetchResult.count];
    
    [self.pImageManager requestImageForAsset:asset targetSize:kAssetRowThumbnailSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (!result) return;
        self.photoImageView.image = result;
    }];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.photoImageView.frame = CGRectMake(12, 3, 68, 65);
    
    CGFloat nameLabelX = CGRectGetMaxX(self.photoImageView.frame) + 10;
    self.nameLabel.frame = CGRectMake(nameLabelX, 24, 0, 23);
    [self.nameLabel sizeToFit];
    
    CGFloat countLabelX = CGRectGetMaxX(self.nameLabel.frame) + 3;
    self.countLabel.frame = CGRectMake(countLabelX, CGRectGetMinY(self.nameLabel.frame), 0, CGRectGetHeight(self.nameLabel.frame));
    [self.countLabel sizeToFit];
    
    CGFloat indicatorImageViewWidth = 10;
    CGFloat indicatorImageViewHeight = 16;
    
    self.indicatorImageView.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - indicatorImageViewHeight - indicatorImageViewWidth, 27, indicatorImageViewWidth, indicatorImageViewHeight);
}

@end
