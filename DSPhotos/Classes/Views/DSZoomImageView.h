//
//  DSZoomImageView.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSZoomImageView : UIView

@property (nonatomic, strong) UIImageView* imageDSView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGFloat zoomScale;

- (void)setZoomScale:(CGFloat)zoomScale;

@end
