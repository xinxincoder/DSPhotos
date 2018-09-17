//
//  DSClipImageAdjustFrameView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSClipImageAdjustFrameView.h"
#import "DSClipFrameView.h"

@interface DSClipImageAdjustFrameView () {
    
    CGFloat _minSize;        //缩小时的最小尺寸
    CGFloat _widthRatio;     //宽度的比例
    CGFloat _heightRatio;    //长度的比例
    BOOL _isFreedomAdjust;   //是否自动调节(即不是按比例调节)
    CGFloat _scaleWidth;     //self与图片宽度的比
    CGFloat _scaleHeight;    //self与图片高度的比
}

/** imageDSView */
@property (nonatomic, strong) UIImageView* imageDSView;
/** 选框 */
@property (nonatomic, strong) DSClipFrameView *clipFrameView;
/** 遮罩视图 */
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
/** 触摸点 */
@property (nonatomic, assign) DSClipFrameViewTouchSpotLayerOptions touchSpotLayerOptions;

@end

@implementation DSClipImageAdjustFrameView
#pragma mark - 初始化
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
    self.touchSpotLineLength = _touchSpotLineLength;
    self.touchSpotLineWidth = _touchSpotLineWidth;
    self.touchSpotColor = _touchSpotColor;
    self.frameLineWidth = _frameLineWidth;
    self.frameColor = _frameColor;
    
#endif
    
}

- (void)createSubviews {
    
    self.backgroundColor = [UIColor blackColor];
    
    _minSize = 3*self.touchSpotLineLength + 2;
    
    UIImageView* imageDSView = [[UIImageView alloc] init];
    imageDSView.userInteractionEnabled = YES;
    imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self addSubview:imageDSView];
    self.imageDSView = imageDSView;
    
    UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
    UIColor *maskColor = [UIColor colorWithWhite:0 alpha:0.6];
    if (self.maskColor) maskColor = self.maskColor;
    maskView.backgroundColor = maskColor;
    [self.imageDSView addSubview:maskView];
    self.maskView = maskView;
    
    DSClipFrameView *clipFrameView = [[DSClipFrameView alloc] init];
    [self.imageDSView addSubview:clipFrameView];
    self.clipFrameView = clipFrameView;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAcion:)];
    [clipFrameView addGestureRecognizer:panGestureRecognizer];
    
    _isFreedomAdjust = YES;
}

#pragma mark - 选择框内透明
- (void)resetClipTransparentArea {
    
    if (self.maskLayer && self.maskLayer.superlayer) {
        
        [self.maskLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect:self.clipFrameView.frame] bezierPathByReversingPath];
    [path appendPath:clearPath];
    maskLayer.path = path.CGPath;
    self.maskLayer = maskLayer;
    self.maskView.layer.mask = maskLayer;
}

#pragma mark - 重新设置裁剪框和遮罩框
- (void)resetClipFrameAndMaskViewFrame {
    
    CGFloat clipFrameViewWidth = 0.0;
    CGFloat clipFrameViewHeight = 0.0;
    //设置比例
    if (_aspectRatio && ![_aspectRatio isEqualToString:@""]) {
        
        //图片的长比宽大
        if (_scaleWidth >= _scaleHeight) {
            
            clipFrameViewWidth = CGRectGetWidth(self.imageDSView.frame)*3/4;
            clipFrameViewHeight = clipFrameViewWidth * _heightRatio / _widthRatio;
            
        }else {
            
            clipFrameViewHeight = CGRectGetHeight(self.imageDSView.frame)*3/4;
            clipFrameViewWidth = clipFrameViewHeight * _widthRatio / _heightRatio;
        }
        
    }else {
        
        switch (self.type) {
                
            case DSClipImageAdjustFrameViewTypeFreedomRectangle: {
                
                self.clipFrameView.type = DSClipFrameViewTypeFreedomRectangle;
                
                _aspectRatio = nil;
                
                clipFrameViewWidth = CGRectGetWidth(self.imageDSView.frame)*3/4;
                clipFrameViewHeight = CGRectGetHeight(self.imageDSView.frame)*3/4;
                break;
            }
                
            case DSClipImageAdjustFrameViewTypeOneToOneRatioRectangle: {
                
                _aspectRatio = @"1:1";
                self.clipFrameView.type = DSClipFrameViewTypeRatioRectangle;
                
                //图片的长比宽大
                if (_scaleWidth >= _scaleHeight) {
                    
                    clipFrameViewWidth = CGRectGetWidth(self.imageDSView.frame)*3/4;
                    clipFrameViewHeight = clipFrameViewWidth;
                    
                }else {
                    
                    clipFrameViewHeight = CGRectGetHeight(self.imageDSView.frame)*3/4;
                    clipFrameViewWidth = clipFrameViewHeight;
                    
                }
                
                break;
            }
                
            case DSClipImageAdjustFrameViewTypeCustomRatioRectangle: {
                
                NSAssert(!_aspectRatio || [_aspectRatio isEqualToString:@""], @"如果选择DSClipImageAdjustFrameViewTypeCustomRatioRectangle，请设置aspectRatio");
                
                break;
            }
        }
    }
    
    self.clipFrameView.frame = CGRectMake(0, 0, clipFrameViewWidth, clipFrameViewHeight);
    
    self.maskView.frame = self.imageDSView.bounds;
    
    self.clipFrameView.center = CGPointMake(CGRectGetWidth(self.imageDSView.bounds)*0.5, CGRectGetHeight(self.imageDSView.bounds)*0.5);
    
    [self resetClipTransparentArea];
}

#pragma mark - GestureRecognizerAcion
- (void)panGestureRecognizerAcion:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
    
    CGPoint location = [panGestureRecognizer locationInView:panGestureRecognizer.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        self.touchSpotLayerOptions = [self.clipFrameView touchSpotLayerOptionsWithLocation:location];
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        CGRect originalFrame = panGestureRecognizer.view.frame;
        
        if (self.touchSpotLayerOptions & DSClipFrameViewTouchSpotLayerOptionsTop) {
            
            CGFloat willHeight = CGRectGetHeight(originalFrame) - translation.y;
            CGFloat minHeight = _minSize;
            CGFloat maxHeight = CGRectGetMaxY(originalFrame);
            CGFloat expectHeight = MIN(MAX(minHeight, willHeight), maxHeight);
            
            
            if (_isFreedomAdjust || (self.imageDSView.bounds.size.width >= self.imageDSView.bounds.size.height)) {
                
                originalFrame.origin.y = maxHeight - expectHeight;
                originalFrame.size.height = expectHeight;
                
            }else {
                
                originalFrame.origin.y = maxHeight - originalFrame.size.width * _heightRatio / _widthRatio;
                originalFrame.size.height = originalFrame.size.width * _heightRatio / _widthRatio;
            }
        }
        
        if (self.touchSpotLayerOptions & DSClipFrameViewTouchSpotLayerOptionsLeft) {
            
            CGFloat willWidth = CGRectGetWidth(originalFrame) - translation.x;
            CGFloat minWidth = _minSize;
            CGFloat maxWidth = CGRectGetMaxX(originalFrame);
            CGFloat expectWidth = MIN(MAX(minWidth, willWidth), maxWidth);
            
            if (_isFreedomAdjust || (self.imageDSView.bounds.size.width <= self.imageDSView.bounds.size.height)) {
                
                originalFrame.origin.x = maxWidth - expectWidth;
                originalFrame.size.width = expectWidth;
                
            }else {
                
                originalFrame.origin.x = maxWidth - originalFrame.size.height * _widthRatio / _heightRatio;
                originalFrame.size.width = originalFrame.size.height * _widthRatio / _heightRatio;
            }
        }
        
        if (self.touchSpotLayerOptions & DSClipFrameViewTouchSpotLayerOptionsBottom) {
            
            CGFloat willHeight = CGRectGetHeight(originalFrame) + translation.y;
            CGFloat minHeight = _minSize;
            CGFloat maxHeight = CGRectGetHeight(self.imageDSView.bounds) - CGRectGetMinY(originalFrame);
            CGFloat expectHeight = MIN(MAX(minHeight, willHeight), maxHeight);
            
            if (_isFreedomAdjust || (self.imageDSView.bounds.size.width >= self.imageDSView.bounds.size.height)) {
                
                originalFrame.size.height = expectHeight;
                
            }else {
                
                originalFrame.size.height = originalFrame.size.width * _heightRatio / _widthRatio;
            }
        }
        
        if (self.touchSpotLayerOptions & DSClipFrameViewTouchSpotLayerOptionsRight) {
            
            CGFloat willWidth = CGRectGetWidth(originalFrame) + translation.x;
            CGFloat minWidth = _minSize;
            CGFloat maxWidth = CGRectGetWidth(self.imageDSView.bounds) -  CGRectGetMinX(originalFrame);
            CGFloat expectWidth = MIN(MAX(minWidth, willWidth), maxWidth);
            
            if (_isFreedomAdjust || self.imageDSView.bounds.size.width <= self.imageDSView.bounds.size.height) {
                
                originalFrame.size.width = expectWidth;
                
            }else {
                
                originalFrame.size.width = originalFrame.size.height * _widthRatio / _heightRatio;
                
            }
        }
        
        panGestureRecognizer.view.frame = originalFrame;
        
        if (self.touchSpotLayerOptions == DSClipFrameViewTouchSpotLayerOptionsNone) {
            
            CGPoint willCenter = CGPointMake(panGestureRecognizer.view.center.x + translation.x, panGestureRecognizer.view.center.y + translation.y);
            CGFloat centerMinX = panGestureRecognizer.view.frame.size.width / 2.0f;
            CGFloat centerMaxX = self.imageDSView.frame.size.width - panGestureRecognizer.view.frame.size.width / 2.0f;
            
            CGFloat centerMinY = panGestureRecognizer.view.frame.size.height / 2.0f ;
            CGFloat centerMaxY = self.imageDSView.frame.size.height - panGestureRecognizer.view.frame.size.height / 2.0f;
            
            panGestureRecognizer.view.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
        }
    }
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
        panGestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        
        self.touchSpotLayerOptions = DSClipFrameViewTouchSpotLayerOptionsNone;
    }
    
    [self resetClipTransparentArea];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageWidth = _image.size.width;
    CGFloat imageHeight = _image.size.height;
    
    _scaleWidth = CGRectGetWidth(self.frame) / imageWidth;
    _scaleHeight = CGRectGetHeight(self.frame) / imageHeight;
    //图片的长比宽大
    if (_scaleWidth > _scaleHeight) {
        
        self.imageDSView.frame = CGRectMake(0, 0, imageWidth * _scaleHeight, CGRectGetHeight(self.bounds));
        
    }else {
        
        self.imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), imageHeight * _scaleWidth);
    }
    
    self.imageDSView.center = CGPointMake(CGRectGetWidth(self.bounds)*0.5, CGRectGetHeight(self.bounds)*0.5);
    [self resetClipFrameAndMaskViewFrame];
    self.imageDSView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
}

#pragma mark - SetMethod
- (void)setImage:(UIImage *)image {
    
    if (!image) return;
    
    _image = image;
    
    self.imageDSView.image = _image;
    
}

- (void)setAspectRatio:(NSString *)aspectRatio {
    _aspectRatio = aspectRatio;
    
    if (self.type == DSClipImageAdjustFrameViewTypeFreedomRectangle && !_aspectRatio) {
        
        self.clipFrameView.type = DSClipFrameViewTypeFreedomRectangle;
        _isFreedomAdjust = YES;
        
    }else {
        
        self.clipFrameView.type = DSClipFrameViewTypeRatioRectangle;
        _isFreedomAdjust = NO;
        
        _widthRatio = [self.aspectRatio componentsSeparatedByString:@":"].firstObject.floatValue;
        _heightRatio = [self.aspectRatio componentsSeparatedByString:@":"].lastObject.floatValue;
        
    }
    [self resetClipFrameAndMaskViewFrame];
}

- (void)setFrameColor:(UIColor *)frameColor {
    _frameColor = frameColor;
    
    self.clipFrameView.frameColor = _frameColor;
}

- (void)setFrameLineWidth:(CGFloat)frameLineWidth {
    _frameLineWidth = frameLineWidth;
    
    self.clipFrameView.frameLineWidth = _frameLineWidth;
}

- (void)setTouchSpotColor:(UIColor *)touchSpotColor {
    _touchSpotColor = touchSpotColor;
    
    self.clipFrameView.touchSpotColor = _touchSpotColor;;
}

- (void)setTouchSpotLineWidth:(CGFloat)touchSpotLineWidth {
    _touchSpotLineWidth = touchSpotLineWidth;
    
    self.clipFrameView.touchSpotLineWidth = _touchSpotLineWidth;
}

- (void)setTouchSpotLineLength:(CGFloat)touchSpotLineLength {
    _touchSpotLineLength = touchSpotLineLength;
    
    self.clipFrameView.touchSpotLineLength = _touchSpotLineLength;
}

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    
    self.maskView.backgroundColor = _maskColor;
}

- (void)setType:(DSClipImageAdjustFrameViewType)type {
    _type = type;
    
    
    if (_type == DSClipImageAdjustFrameViewTypeFreedomRectangle) {
        
        self.aspectRatio = nil;
    }
    
    if (_type == DSClipImageAdjustFrameViewTypeOneToOneRatioRectangle) {
        
        self.aspectRatio = @"1:1";
    }
}

#pragma mark - 完成裁剪方法
- (UIImage *)completeClipImage {
    
    CGFloat scaleFactorX = self.image.size.width*self.image.scale/self.imageDSView.frame.size.width;
    CGFloat scaleFactorY = self.image.size.height*self.image.scale/self.imageDSView.frame.size.height;
    
    CGRect rect = CGRectMake(CGRectGetMinX(self.clipFrameView.frame)*scaleFactorX, CGRectGetMinY(self.clipFrameView.frame)*scaleFactorY, CGRectGetWidth(self.clipFrameView.frame)*scaleFactorX, CGRectGetHeight(self.clipFrameView.frame)*scaleFactorY);
    
    UIImage *fixedImage = self.image;
    CGImageRef imageRef = CGImageCreateWithImageInRect([fixedImage CGImage], rect);
    UIImage* newImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return newImage;
}

@end
