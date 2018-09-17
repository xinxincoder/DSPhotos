//
//  DSPhotoCell.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotoCell.h"
#import "DSPhotoModel.h"
#import <Photos/Photos.h>
#import "DSPhotosCommon.h"
#import "DSSelectedButton.h"
#import <AVFoundation/AVFoundation.h>

@interface DSPhotosCell ()<CAAnimationDelegate>

@property (nonatomic, strong) UIControl *shadeControl;

@property (nonatomic, strong) UILabel *timeLabel;

// 控件
@property (nonatomic, weak) UIImageView* imageDSView;

@property (nonatomic, strong) UIView *snapshotView;


@property (nonatomic, weak) DSSelectedButton* selectedBtn;
// 缓存图片
@property (strong, nonatomic) PHCachingImageManager *pImageManager;

@end

@implementation DSPhotosCell

#pragma mark - 懒加载
- (PHCachingImageManager *)pImageManager {
    if (!_pImageManager) {
        _pImageManager = [[PHCachingImageManager alloc] init];
    }
    return _pImageManager;
}

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
    
    UIControl *shadeControl = [[UIControl alloc] init];
    shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    shadeControl.clipsToBounds = NO;
    [shadeControl addTarget:self action:@selector(shadeControlAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.shadeControl = shadeControl];
    
    // 选中效果
    DSSelectedButton* selectedBtn = [DSSelectedButton buttonWithType:UIButtonTypeCustom];
    selectedBtn.userInteractionEnabled = NO;
    selectedBtn.selecteColor = ThemeColor_PC;
    selectedBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    selectedBtn.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:selectedBtn];
    self.selectedBtn = selectedBtn;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.text = @"00:00";
    [self.contentView addSubview:self.timeLabel = timeLabel];
    
    return self;
}

- (void)setDelegate:(id<DSPhotosCellDelegate>)delegate {
    _delegate = delegate;
    
    self.selectedBtn.hidden = (delegate == nil);
}

- (void)setSelecteColor:(UIColor *)selecteColor {
    _selecteColor = selecteColor;
    
    self.selectedBtn.selecteColor = ThemeColor_PC;
}

// 设置图片
- (void)setPhotoModel:(DSPhotoModel *)photoModel {
    _photoModel = photoModel;
    
    if (!_photoModel) {
        // 拍照
        self.imageDSView.image = [UIImage imageNamed:EPC_IMG_PHOTO_CAMERA];
        [self.shadeControl removeFromSuperview];
        return;
    }
    // 设置选中时的效果
    [self.selectedBtn setCurSelectedIndex:_photoModel.curSelectedIndex animated:_photoModel.selectedIndexAnimatable];
    

    self.timeLabel.hidden = !(_photoModel.type == DSPhotoModelTypeVideo);
    
    if (_photoModel.type == DSPhotoModelTypeVideo) {
        
        AVAsset *asset = photoModel.videoAsset;
        
        if (asset) {
            
            CMTime time = asset.duration;
            
            NSTimeInterval timeInterval = (NSTimeInterval)time.value/time.timescale;
            
            NSInteger minute = timeInterval/60;
            NSInteger second = (NSInteger)(timeInterval)%60;
            NSString *timeText = [NSString stringWithFormat:@"%02zd:%02zd",minute,second];
            self.timeLabel.text = timeText;
            
            _photoModel.videoTime = timeInterval;
            
        }else {
            
            [self.pImageManager requestAVAssetForVideo:photoModel.mAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    photoModel.videoAsset = asset;
                    photoModel.audioMix = audioMix;
                    
                    CMTime time = asset.duration;
                    
                    NSTimeInterval timeInterval = (NSTimeInterval)time.value/time.timescale;
                    
                    NSInteger minute = timeInterval/60;
                    NSInteger second = (NSInteger)(timeInterval)%60;
                    NSString *timeText = [NSString stringWithFormat:@"%02zd:%02zd",minute,second];
                    self.timeLabel.text = timeText;
                    
                    _photoModel.videoTime = timeInterval;
                });
            }];
        }
    }
    
    if (photoModel.thumbnailImage) {
        // 有图,就不用重新从 mAsset 中获取
        self.imageDSView.image = photoModel.thumbnailImage;
        
        if (_photoModel.curSelectedIndex != 0) {
        
            if (_photoModel.selectedIndexAnimatable) {
        
                if (_photoModel.shadeAnimatable) {
                    
                     self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
                    [self selectWithAnimationShadeControl];
                    
                }else {
                    
                    self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                    
                }
                
            }else {
                
                self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }
    
        }else {

            if (_photoModel.shadeAnimatable) {

                self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
                [self selectWithAnimationShadeControl];

            }else {

                self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            }


        }

        
        return;
    }
    
    // 这里应该弄一种占位图的.因为从 mAsset 中获取图片需要时间
    [self setMAsset:photoModel.mAsset];
}

- (void)setMAsset:(PHAsset *)mAsset {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    CGSize kAssetGridThumbnailSize = [DSPhotosCommon epcAssetGridCellSize];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    kAssetGridThumbnailSize = CGSizeMake(kAssetGridThumbnailSize.width * scale, kAssetGridThumbnailSize.height * scale);
    
    __weak typeof(self) weakSelf = self;
    [self.pImageManager requestImageForAsset:mAsset targetSize:kAssetGridThumbnailSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        // 这里判断,感觉木有意义
        if ([weakSelf.photoModel.mAsset.localIdentifier isEqualToString:mAsset.localIdentifier]) {
            // 顺便也把这个值也弄上了.
            weakSelf.photoModel.thumbnailImage = result;
        }
        weakSelf.imageDSView.image = result;
    }];
    
}

- (void)shadeControlAction:(UIControl *)ctrl event:(UIEvent *)event {
    
    BOOL isCanNextStep = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:willSelectPhotoModel:)]) {
        
        isCanNextStep =  [self.delegate photosProtocol:self willSelectPhotoModel:_photoModel];
    }
    
    if (isCanNextStep && self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didSelectPhotoModel:)]) {
        
        UITouch *touch = event.allTouches.anyObject;
        
        CGPoint point = [touch locationInView:self];
        
        _photoModel.touchPoint = point;
        _photoModel.shadeAnimatable = YES;
        [self.delegate photosProtocol:self didSelectPhotoModel:_photoModel];
    }
}

// 布局视图
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageDSView.frame = self.contentView.bounds;
    self.shadeControl.frame = self.contentView.bounds;
    self.selectedBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 8, -8, 16, 16);
    
    self.timeLabel.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - 20, CGRectGetWidth(self.contentView.bounds) - 4, 20);
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (CGRectContainsPoint(self.selectedBtn.frame, point)) {
        
        return self.shadeControl;
    }
    
    return [super hitTest:point withEvent:event];
}

- (void)selectWithAnimationShadeControl {
    
    CGPoint point = _photoModel.touchPoint;
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    CGRect startRect = CGRectMake(point.x, point.y, 1, 1);

    CGFloat radius = CGRectGetWidth(self.frame)*sqrtf(2.0);
    
    CGRect endRect = CGRectInset(startRect, -radius, -radius);
    
    if (_photoModel.curSelectedIndex == 0) {
        
        CGRect temp = startRect;
    
        startRect = endRect;
        
        endRect = temp;
    }
    
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    UIBezierPath *startClearPath = [[UIBezierPath bezierPathWithOvalInRect:startRect] bezierPathByReversingPath];

    [startPath appendPath:startClearPath];

    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    UIBezierPath *endClearPath = [[UIBezierPath bezierPathWithOvalInRect:endRect] bezierPathByReversingPath];
    
    [endPath appendPath:endClearPath];
    
    layer.path = endPath.CGPath;
    
    self.shadeControl.layer.mask = layer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.45;
    animation.fromValue = (__bridge id _Nullable)(startPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    animation.delegate = self;
    animation.fillMode = kCAFillModeBackwards;
    animation.removedOnCompletion = NO;
    [self.shadeControl.layer.mask addAnimation:animation forKey:nil];
    
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    self.shadeControl.layer.mask = nil;
    
    if (_photoModel.curSelectedIndex != 0) {
        
        self.shadeControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    _photoModel.shadeAnimatable = NO;
}

@end
