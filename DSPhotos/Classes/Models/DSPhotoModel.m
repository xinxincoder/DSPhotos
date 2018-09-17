//
//  DSPhotoModel.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotoModel.h"
#import <Photos/Photos.h>
#import "DSPhotosCommon.h"

@interface DSPhotoModel ()

/** 原始的资源对象 */
@property (nonatomic, copy) PHAsset *mAsset;

@end

@implementation DSPhotoModel

/** 快速通过 mAsset 创建对象 */
+ (instancetype)photoWithAsset:(PHAsset*)mAsset {
    DSPhotoModel* photoModel = [[self alloc] init];
    
    // 赋值
    photoModel.mAsset = mAsset;
    
    return photoModel;
}

// 设置资源对象
- (void)setMAsset:(PHAsset *)mAsset {
    _mAsset = mAsset;
    
    if (_mAsset.mediaType == PHAssetMediaTypeImage) {
        
        _type = DSPhotoModelTypeImage;
    }
    
    if (_mAsset.mediaType == PHAssetMediaTypeVideo) {
        
        _type = DSPhotoModelTypeVideo;
    }
    
    // TODO:暂无其它处理
}

- (BOOL)isEqual:(DSPhotoModel*)object {
    
    return [object.mAsset.localIdentifier isEqual:self.mAsset.localIdentifier];
}

- (void)setCurSelectedIndex:(NSInteger)curSelectedIndex {
    
    if (_curSelectedIndex == 0 && curSelectedIndex != 0) {
        
        _selectedIndexAnimatable = YES;
        
    }else {
        
        _selectedIndexAnimatable = NO;
    }
    
    _curSelectedIndex = curSelectedIndex;
}

- (CGRect)imgFrame {
    
    UIImage *image = nil;
    if (_thumbnailImage) image = _thumbnailImage;
    if (_image) image = _image;
    
    if (!image) {
        return CGRectMake(0, 0, UI_SCREEN_WIDTH_PC, UI_SCREEN_HEIGHT_PC);
    }
    
    //判断首先缩放的值
    float scaleX = UI_SCREEN_WIDTH_PC/image.size.width;
    float scaleY = UI_SCREEN_HEIGHT_PC/image.size.height;
    
    //倍数小的，先到边缘
    CGRect frame;
    if (scaleX > scaleY) {
        
        //Y方向先到边缘
        float imgViewWidth = image.size.width*scaleY;
        
        frame =  CGRectMake((UI_SCREEN_WIDTH_PC - imgViewWidth)/2, 0, imgViewWidth, UI_SCREEN_HEIGHT_PC);
        
    } else {
        
        //X先到边缘
        float imgViewHeight = image.size.height*scaleX;
        
        frame = CGRectMake(0, (UI_SCREEN_HEIGHT_PC - imgViewHeight)/2, UI_SCREEN_WIDTH_PC, imgViewHeight);
    }
    
    return frame;
}

- (NSString *)fileName {
    
    if (self.type == DSPhotoModelTypeImage) {
        
        NSString* fileURLKey = [self.info objectForKey:@"PHImageFileURLKey"];
        if (!fileURLKey) {
            return nil;
        }
        
        return  [fileURLKey lastPathComponent];
    }
    
    return _fileName;
}

@end
