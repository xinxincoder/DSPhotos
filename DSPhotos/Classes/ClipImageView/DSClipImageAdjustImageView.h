//
//  DSClipImageAdjustImageView.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, DSClipImageAdjustImageViewType) {
    
    DSClipImageAdjustImageViewTypeRound,       //圆形框
    DSClipImageAdjustImageViewTypeRectangle,   //矩形框
};

typedef NS_ENUM(NSUInteger, DSClipImageAdjustImageViewContentType) {
    
    DSClipImageAdjustImageViewContentTypeScaleAspectFill,
    DSClipImageAdjustImageViewContentTypeScaleAspectFit,
    
};

IB_DESIGNABLE

@interface DSClipImageAdjustImageView : UIView

@property (nonatomic, strong) IBInspectable UIImage *image;

#if TARGET_INTERFACE_BUILDER

@property (nonatomic, assign) IBInspectable NSInteger type;
@property (nonatomic, assign) IBInspectable NSInteger contentType;

#else

@property (nonatomic, assign) DSClipImageAdjustImageViewType type;
@property (nonatomic, assign) DSClipImageAdjustImageViewContentType contentType;

#endif


/** 选框的颜色，默认白色 */
@property (nonatomic, strong) IBInspectable UIColor *frameColor;
/** 选框的线宽，默认1 */
@property (nonatomic, assign) IBInspectable CGFloat frameLineWidth;

/** 遮罩颜色，默认[UIColor colorWithWhite:0 alpha:0.6] */
@property (nonatomic, strong) IBInspectable UIColor *maskColor;

/**
 完成裁剪
 
 @return 返回裁剪后的图片
 */
- (UIImage *)completeClipImage;

@end
