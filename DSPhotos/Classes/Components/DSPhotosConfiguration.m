//
//  DSPhotosConfiguration.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotosConfiguration.h"
#import "DSPhotosGlobal.h"

@implementation DSPhotosConfiguration

+ (void)configureThemeTextColor:(UIColor *)themeColor {
    
    [[DSPhotosGlobal global] setGlobalTextColor:themeColor];
}


+ (void)configureThemeBackArrowImage:(UIImage *)backArrowImage {
    
    [[DSPhotosGlobal global] setGlobalBackArrowImage:backArrowImage];
}

+ (void)configureThemeTextAndBackArrowColor:(UIColor *)themeColor {
    
    [[DSPhotosGlobal global] setGlobalTextColor:themeColor];
    [[DSPhotosGlobal global] setGlobalBackArrowColor:themeColor];
    
}


@end
