//
//  DSClipFrameView.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

// 剪切类型
typedef NS_ENUM(NSUInteger, DSClipFrameViewType) {
    // 矩形框，四个拐角和边有突起的线
    DSClipFrameViewTypeFreedomRectangle,
    // 矩形框，四个拐角有突起的线
    DSClipFrameViewTypeRatioRectangle,
    // 圆形框
    DSClipFrameViewTypeRound,
    // 矩形框
    DSClipFrameViewTypeRectangle,
};

// 一张图片的区域
typedef NS_OPTIONS(NSUInteger, DSClipFrameViewTouchSpotLayerOptions) {
    // 未知
    DSClipFrameViewTouchSpotLayerOptionsNone        = 0,
    // 顶部
    DSClipFrameViewTouchSpotLayerOptionsTop         = 1 << 0,
    // 左边
    DSClipFrameViewTouchSpotLayerOptionsLeft        = 1 << 1,
    // 底部
    DSClipFrameViewTouchSpotLayerOptionsBottom      = 1 << 2,
    // 右边
    DSClipFrameViewTouchSpotLayerOptionsRight       = 1 << 3,
    
};

@interface DSClipFrameView : UIView
/** 选框的类型 */
@property (nonatomic, assign) DSClipFrameViewType type;

/** 触摸点的线宽（即手动控制的视图的线），默认2 */
@property (nonatomic, assign) CGFloat touchSpotLineWidth;
/** 触摸点的线长（即手动控制的视图的线），默认20 */
@property (nonatomic, assign) CGFloat touchSpotLineLength;
/** 触摸点的线颜色（即手动控制的视图的线），默认白色 */
@property (nonatomic, strong) UIColor *touchSpotColor;
/** 选框的颜色，默认白色 */
@property (nonatomic, strong) UIColor *frameColor;
/** 选框的线宽，默认1 */
@property (nonatomic, assign) CGFloat frameLineWidth;

/**
 根据触摸的区域得出区域的枚举
 
 @param location 触摸的区域
 @return 区域的枚举
 */
- (DSClipFrameViewTouchSpotLayerOptions)touchSpotLayerOptionsWithLocation:(CGPoint)location;

@end

