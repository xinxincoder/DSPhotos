//
//  DSTakePhotoManager.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DSPhotoModel.h"
#import <AVFoundation/AVFoundation.h>

// 相机权限类型
typedef NS_ENUM(NSUInteger, DSTakePhotoAuthorizationStatus) {
    // 还未设置权限
    DSTakePhotoAuthorizationStatusNotDetermined = 0,
    // 未授权
    DSTakePhotoAuthorizationStatusNotAuthorized,
    // 已授权
    DSTakePhotoAuthorizationStatusAuthorized,
};

typedef void (^TakePhotoAssetBlock)(DSPhotoModel* photoModel);

@interface DSTakePhotoManager : NSObject

/* 获取照相机的权限 */
+ (DSTakePhotoAuthorizationStatus)authorizationStatus;
/* 请求相机权限 */
+ (void)requestAuthorizationWithCompletionHandler:(void(^)(BOOL granted))handler;

/**
 单例
 */
+ (instancetype)sharedInstance;

/**
 开始拍照 （tagetCompression 压缩系数
 设置为1024大概为压缩为1M左右）
 
 @param sourceVC 拍照当前的控制权
 @param backAssetBlock 拍照数据回传
 */
- (void)takePhotoWithSourceVC:(UIViewController*)sourceVC backAssetBlock:(TakePhotoAssetBlock)backAssetBlock;


/**
 开始拍照
 
 @param sourceVC 拍照当前的控制权
 @param tagetCompression 压缩系数
 @param backAssetBlock 拍照数据回传
 */
- (void)takePhotoWithSourceVC:(UIViewController*)sourceVC tagetCompression:(CGFloat)tagetCompression backAssetBlock:(TakePhotoAssetBlock)backAssetBlock;

@end
