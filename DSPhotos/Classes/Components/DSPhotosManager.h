//
//  DSPhotosManager.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, DSPhotosAuthorizationStatus) {
    DSPhotosAuthorizationStatusNotDetermined = 0,
    DSPhotosAuthorizationStatusNotAuthorized,
    DSPhotosAuthorizationStatusAuthorized,
};

@interface DSPhotosManager : NSObject

/* 获取相册的权限 */
+ (DSPhotosAuthorizationStatus)authorizationStatus;

/* 请求相册权限 */
+ (void)requestAuthorizationWithCompletionHandler:(void(^)(BOOL granted))handler;

/**
 根据权限做处理,如果第一次会有系统的授权弹窗
 
 @param handler 是否授权的block
 */
+ (void)accordingToAuthorityWithHandler:(void(^)(BOOL authorized))handler;

@end
