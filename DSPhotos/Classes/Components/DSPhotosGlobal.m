//
//  DSPhotosGlobal.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotosGlobal.h"

@implementation DSPhotosGlobal

+ (instancetype)global {
    
    static DSPhotosGlobal *_global;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _global = [[DSPhotosGlobal alloc] init];
    });
    
    return _global;
}

+ (UIImage *)configureImage:(UIImage *)image tintColor:(UIColor *)tintColor {
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    //设置绘制图片上下文
    UIGraphicsBeginImageContextWithOptions(imageRect.size, false, image.scale);
    //得到上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //绘制图片
    [image drawInRect:imageRect];
    //设置渲染颜色
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    
    //设置透明度(值可根据需求更改)
    //    CGContextSetAlpha(context, 0.5);
    //设置混合模式
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    //设置位置大小
    CGContextFillRect(context, imageRect);
    //绘制图片
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    
    //完成绘制
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end

