//
//  DSClipImageAdjustFrameView.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSClipImageAdjustFrameViewType) {
    
    DSClipImageAdjustFrameViewTypeFreedomRectangle,       //自动调节选框
    DSClipImageAdjustFrameViewTypeOneToOneRatioRectangle, //1:1比例的选框
    DSClipImageAdjustFrameViewTypeCustomRatioRectangle,   //自定义比例选框，直接设置aspectRatio即可
};

IB_DESIGNABLE
@interface DSClipImageAdjustFrameView : UIView

#if TARGET_INTERFACE_BUILDER

@property (nonatomic, assign) IBInspectable NSInteger type;

#else

/** 裁剪框类型 */
@property (nonatomic, assign) DSClipImageAdjustFrameViewType type;

#endif

/** 裁剪前的图片 */
@property (nonatomic, strong) IBInspectable UIImage *image;
/** 触摸点的线宽（即手动控制的视图的线），默认2 */
@property (nonatomic, assign) IBInspectable CGFloat touchSpotLineWidth;
/** 触摸点的线长（即手动控制的视图的线），默认20 */
@property (nonatomic, assign) IBInspectable CGFloat touchSpotLineLength;
/** 触摸点的线颜色（即手动控制的视图的线），默认白色 */
@property (nonatomic, strong) IBInspectable UIColor *touchSpotColor;
/** 选框的颜色，默认白色 */
@property (nonatomic, strong) IBInspectable UIColor *frameColor;
/** 选框的线宽，默认1 */
@property (nonatomic, assign) IBInspectable CGFloat frameLineWidth;
/** 输入宽高比的格式为（width:height) */
@property (nonatomic, copy) IBInspectable NSString *aspectRatio;
/** 遮罩颜色，默认[UIColor colorWithWhite:0 alpha:0.6] */
@property (nonatomic, strong) IBInspectable UIColor *maskColor;

/**
 完成裁剪
 
 @return 返回裁剪后的图片
 */
- (UIImage *)completeClipImage;

@end
