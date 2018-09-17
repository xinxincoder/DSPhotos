//
//  UIImage+FixOrientation.h
//  PhotosManager
//
//  Created by  ZhuHong on 2017/6/8.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FixOrientation)

/** 解决旋转90度问题 */
+ (UIImage *)fixOrientation_DSPhoto:(UIImage *)aImage;

@end
