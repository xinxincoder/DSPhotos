//
//  PhotoItemCell.m
//  PhotosManager
//
//  Created by  liuxx on 2017/4/13.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "PhotoItemCell.h"
#import <DSPhotos/DSPhotos-umbrella.h>
#import "DSPhotosCommon.h"

@interface PhotoItemCell ()

// 为了获取放大之前的位置
@property (nonatomic, weak) UIImageView* imageDSView;
// 删除按钮
@property (nonatomic, weak) UIButton* deleteBtn;

@end

@implementation PhotoItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // 图片
    UIImageView* imageDSView = [[UIImageView alloc] init];
    imageDSView.clipsToBounds = YES;
    // 使图片不拉伸 填充
    imageDSView.contentMode = UIViewContentModeScaleAspectFill;
    imageDSView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:imageDSView];
    self.imageDSView = imageDSView;
        
    // 选中效果
    UIButton* deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.imageView.contentMode = UIViewContentModeCenter;
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [deleteBtn setImage:[UIImage imageNamed:EPC_IMG_PHOTO_DELETE] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:EPC_IMG_PHOTO_DELETE] forState:UIControlStateSelected];
    [deleteBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.hidden = YES;
    [self.contentView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    
    return self;
}

// 删除事件
- (void)btnClick {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deletePhotoItemCell:)]) {
        
        [self.delegate deletePhotoItemCell:self];
    }
}

- (void)setDelegate:(id<PhotoItemCellDelegate>)delegate {
    _delegate = delegate;
    
    // 没有值,就隐藏删除按钮
    self.deleteBtn.hidden = self.ownDeleteFunction?(delegate == nil):YES;
    
    [self setNeedsLayout];
}

- (void)setPhotoModel:(DSPhotoModel *)photoModel {
    _photoModel = photoModel;
    
    if (photoModel) {
        
        UIImage *image = photoModel.thumbnailImage;
        
        if (!image) {
            
            image = photoModel.image;
        }
        
        self.imageDSView.image = image;
    } else {
        self.imageDSView.image = [UIImage imageNamed:@"BBS_addPhotos"];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGFloat margin = (!self.deleteBtn.hidden)?0.5:0.25;
//    margin *= EPCDeleteSizeLength;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = CGRectGetWidth(self.contentView.frame) - 0;
    CGFloat height = CGRectGetHeight(self.contentView.frame) - y;
    self.imageDSView.frame = CGRectMake(x, y, width, height);
    
    self.deleteBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - EPCDeleteSizeLength, 0, EPCDeleteSizeLength, EPCDeleteSizeLength);
}

@end
