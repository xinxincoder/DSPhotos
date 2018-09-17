//
//  DSPhotosGlobal.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DSGLOBAL [DSPhotosGlobal global]

@interface DSPhotosGlobal : NSObject

@property (nonatomic, strong) UIColor *globalTextColor;

@property (nonatomic, strong) UIColor *globalBackArrowColor;

@property (nonatomic, strong) UIImage *globalBackArrowImage;

+ (instancetype)global;

+ (UIImage *)configureImage:(UIImage *)image tintColor:(UIColor *)tintColor;

@end
