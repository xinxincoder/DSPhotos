//
//  DSClipImageAdjustImageView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSClipImageAdjustImageView.h"
#import "DSClipFrameView.h"
#import "DSTouchMaskView.h"

@interface DSClipImageAdjustImageView ()<UIScrollViewDelegate> {
    
    CGFloat _scaleWidth;     //self与图片宽度的比
    CGFloat _scaleHeight;    //self与图片高度的比
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView* imageDSView;

@property (nonatomic, strong) DSClipFrameView *clipFrameView;
/** 遮罩视图，主要为了响应UISCrollView的滑动事件 */
@property (nonatomic, strong) DSTouchMaskView *maskView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation DSClipImageAdjustImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubviews];
        [self initXIBData];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self createSubviews];
    [self initXIBData];
}

- (void)initXIBData {
    
#if !TARGET_INTERFACE_BUILDER
    
    self.image = _image;
    self.frameLineWidth = _frameLineWidth;
    self.frameColor = _frameColor;
    self.maskColor = _maskColor;
#endif
    
}

- (void)createSubviews {
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.clipsToBounds = NO;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 3;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView* imageDSView = [[UIImageView alloc] init];
    imageDSView.userInteractionEnabled = YES;
    imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [scrollView addSubview:imageDSView];
    self.imageDSView = imageDSView;
    
    DSTouchMaskView *maskView = [[DSTouchMaskView alloc] initWithFrame:self.bounds];
    UIColor *maskColor = [UIColor colorWithWhite:0 alpha:0.6];
    if (self.maskColor) maskColor = self.maskColor;
    maskView.backgroundColor = maskColor;
    maskView.userInteractionEnabled = NO;
    maskView.receiver = scrollView;
    [self addSubview:maskView];
    self.maskView = maskView;
    
    DSClipFrameView *clipFrameView = [[DSClipFrameView alloc] init];
    clipFrameView.userInteractionEnabled = NO;
    [self addSubview:clipFrameView];
    self.clipFrameView = clipFrameView;
    
    self.type = _type;
}

#pragma mark - 设置透明区域
- (void)resetClipTransparentArea {
    
    if (self.maskLayer && self.maskLayer.superlayer) {
        
        [self.maskLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    
    UIBezierPath *clearPath = nil;
    
    switch (_type) {
        case DSClipImageAdjustImageViewTypeRound:
            clearPath = [[UIBezierPath bezierPathWithOvalInRect:self.clipFrameView.frame] bezierPathByReversingPath];
            break;
            
        case DSClipImageAdjustImageViewTypeRectangle:
            clearPath = [[UIBezierPath bezierPathWithRect:self.clipFrameView.frame] bezierPathByReversingPath];
            break;
    }
    
    [path appendPath:clearPath];
    maskLayer.path = path.CGPath;
    self.maskLayer = maskLayer;
    self.maskView.layer.mask = maskLayer;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageDSView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.imageDSView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    self.clipFrameView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    [self resetClipTransparentArea];
    
    self.scrollView.frame = self.clipFrameView.frame;
    self.scrollView.center = self.maskView.center;
}

#pragma mark - SetMethod
- (void)setImage:(UIImage *)image {
    
    if (!image) return;
    _image = image;
    
    self.imageDSView.image = _image;
    
    CGFloat clipFrameViewWidth;
    CGFloat clipFrameViewHeight;
    
    CGFloat imageWidth = _image.size.width;
    CGFloat imageHeight = _image.size.height;
    
    _scaleWidth = CGRectGetWidth(self.frame) / imageWidth;
    _scaleHeight = CGRectGetHeight(self.frame) / imageHeight;
    
    if (CGRectGetHeight(self.bounds) >= CGRectGetWidth(self.bounds)) {
        
        switch (self.contentType) {
            case DSClipImageAdjustImageViewContentTypeScaleAspectFill: {
                
                clipFrameViewWidth = CGRectGetWidth(self.bounds);
                
                break;
                
            }
            case DSClipImageAdjustImageViewContentTypeScaleAspectFit: {
                
                clipFrameViewWidth = CGRectGetWidth(self.bounds) * 3/4;
                
                break;
            }
        }
        
        clipFrameViewHeight = clipFrameViewWidth;
        
        if (_scaleWidth > _scaleHeight) {
            
            if (imageWidth * _scaleHeight <= clipFrameViewWidth){
                
                self.imageDSView.frame = CGRectMake(0, 0, clipFrameViewWidth, imageHeight*clipFrameViewWidth/imageWidth);
                
            }else {
                
                self.imageDSView.frame = CGRectMake(0, 0, imageWidth * _scaleHeight, CGRectGetHeight(self.frame));
            }
            
        }else {
            
            if (imageHeight * _scaleWidth <= clipFrameViewWidth){
                
                self.imageDSView.frame = CGRectMake(0, 0, imageWidth*clipFrameViewWidth/imageHeight, clipFrameViewWidth);
                
            }else {
                
                self.imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), imageHeight * _scaleWidth);
            }
        }
        
    }else {
        
        switch (self.contentType) {
                
            case DSClipImageAdjustImageViewContentTypeScaleAspectFill: {
                
                clipFrameViewHeight = CGRectGetHeight(self.bounds);
                
                break;
                
            }
            case DSClipImageAdjustImageViewContentTypeScaleAspectFit: {
                
                clipFrameViewHeight = CGRectGetHeight(self.bounds) * 3/4;
                
                break;
            }
        }
        
        clipFrameViewWidth = clipFrameViewHeight;
        
        if (_scaleWidth > _scaleHeight) {
            
            if (imageWidth * _scaleHeight <= clipFrameViewHeight){
                
                self.imageDSView.frame = CGRectMake(0, 0, clipFrameViewHeight, imageHeight*clipFrameViewHeight/imageWidth);
                
            }else {
                
                self.imageDSView.frame = CGRectMake(0, 0, imageWidth * _scaleHeight, CGRectGetHeight(self.frame));
            }
            
        }else {
            
            if (imageHeight * _scaleWidth <= clipFrameViewHeight){
                
                self.imageDSView.frame = CGRectMake(0, 0, imageWidth *clipFrameViewHeight/imageHeight, clipFrameViewHeight);
                
            }else {
                
                self.imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), imageHeight * _scaleWidth);
            }
        }
    }
    
    self.clipFrameView.frame = CGRectMake(0, 0, clipFrameViewWidth, clipFrameViewHeight);
    
    self.imageDSView.center = CGPointMake(self.clipFrameView.frame.size.width*0.5, self.clipFrameView.frame.size.height*0.5);
    
    self.scrollView.contentSize = self.imageDSView.frame.size;
    [self scrollViewDidZoom:self.scrollView];
    [self.scrollView setContentOffset:CGPointMake((CGRectGetWidth(self.imageDSView.frame) - CGRectGetWidth(self.clipFrameView.frame))*0.5, (CGRectGetHeight(self.imageDSView.frame) - CGRectGetHeight(self.clipFrameView.frame))*0.5) animated:NO];
    
    [self resetClipTransparentArea];
    
}

- (void)setFrameColor:(UIColor *)frameColor {
    _frameColor = frameColor;
    
    self.clipFrameView.frameColor = _frameColor;
}

- (void)setFrameLineWidth:(CGFloat)frameLineWidth {
    _frameLineWidth = frameLineWidth;
    
    self.clipFrameView.frameLineWidth = _frameLineWidth;
}

- (void)setType:(DSClipImageAdjustImageViewType)type {
    _type = type;
    
    switch (_type) {
        case DSClipImageAdjustImageViewTypeRound:
            self.clipFrameView.type = DSClipFrameViewTypeRound;
            break;
            
        case DSClipImageAdjustImageViewTypeRectangle:
            self.clipFrameView.type = DSClipFrameViewTypeRectangle;
            break;
    }
    
    [self resetClipTransparentArea];
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    
    self.maskView.backgroundColor = _maskColor;
}

- (void)setContentType:(DSClipImageAdjustImageViewContentType)contentType {
    _contentType = contentType;
    
    self.image = _image;
}

#pragma mark - 完成裁剪方法
- (UIImage *)completeClipImage {
    
    CGFloat scaleFactorX = self.image.size.width*self.image.scale/(self.imageDSView.frame.size.width/self.scrollView.zoomScale);
    CGFloat scaleFactorY = self.image.size.height*self.image.scale/(self.imageDSView.frame.size.height/self.scrollView.zoomScale);
    
    CGRect rect = [self.clipFrameView convertRect:self.clipFrameView.bounds toView:self.imageDSView];
    
    rect = CGRectMake(CGRectGetMinX(rect)*scaleFactorX, CGRectGetMinY(rect)*scaleFactorY, CGRectGetWidth(rect)*scaleFactorX, CGRectGetHeight(rect)*scaleFactorY);
    
    UIImage *fixedImage = self.image;
    CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], rect);
    UIImage* newImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    if (_type == DSClipImageAdjustImageViewTypeRound) {
        
        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, 0);
        
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        [roundPath addClip];
        [newImage drawAtPoint:CGPointZero];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return newImage;
}

@end
