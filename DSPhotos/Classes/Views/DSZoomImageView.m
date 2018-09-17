//
//  DSZoomImageView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSZoomImageView.h"
#import "DSPhotosCommon.h"

@interface DSZoomImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DSZoomImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 3;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView* imageDSView = [[UIImageView alloc] init];
    imageDSView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [scrollView addSubview:imageDSView];
    self.imageDSView = imageDSView;
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)doubleTap{
    
    if (_scrollView.zoomScale > 1) {
        
        [_scrollView setZoomScale:1 animated:YES];
        
    } else {
        
        CGPoint touchPoint = [doubleTap locationInView:_imageDSView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat zoomWidth = UI_SCREEN_WIDTH_PC / newZoomScale;
        CGFloat zoomHeight = UI_SCREEN_HEIGHT_PC / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - zoomWidth/2, touchPoint.y - zoomHeight/2, zoomWidth, zoomHeight) animated:YES];
        
    }
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
    
    NSLog(@"%f",offsetX);
    
    scrollView.subviews[0].center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

- (void)setFrame:(CGRect)frame {
    
    if (self.scrollView.zoomScale == 1) {
        [super setFrame:frame];
        self.imageDSView.center = self.center;
    }
    
}

- (void)setImage:(UIImage *)image {
    if (!image) return;
    _image = image;
    
    self.imageDSView.image = _image;
    
    CGFloat imageWidth = _image.size.width;
    CGFloat imageHeight = _image.size.height;
    
    CGFloat scaleWidth = UI_SCREEN_WIDTH_PC / imageWidth;
    CGFloat scaleHeight = UI_SCREEN_HEIGHT_PC / imageHeight;
    
    CGRect cFrame = self.imageDSView.frame;
    if (scaleWidth > scaleHeight) {
        cFrame.size = CGSizeMake(imageWidth * scaleHeight, UI_SCREEN_HEIGHT_PC);
    } else {
        cFrame.size = CGSizeMake(UI_SCREEN_WIDTH_PC, imageHeight * scaleWidth);
    }
    self.imageDSView.frame = cFrame;
    
    if (self.scrollView.zoomScale == 1) {
        
        self.imageDSView.center = self.center;
    }
    
}

- (CGFloat)zoomScale {
    
    return self.scrollView.zoomScale;
}

- (void)setZoomScale:(CGFloat)zoomScale {
    
    [self.scrollView setZoomScale:zoomScale];
}

@end
