//
//  DSPhotosConfiguration.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DSPhotosConfiguration : NSObject

/**
 配置主题文字颜色
 
 @param themeColor 颜色
 */
+ (void)configureThemeTextColor:(UIColor *)themeColor;

/**
 配置主题返回按钮图片
 
 @param backArrowImage 图片
 */
+ (void)configureThemeBackArrowImage:(UIImage *)backArrowImage;

/**
 配置主题返回按钮颜色
 
 @param themeColor 颜色
 */
+ (void)configureThemeTextAndBackArrowColor:(UIColor *)themeColor;

//+ (void)configureThemeSelectColor:(UIColor *)selectColor;

@end
