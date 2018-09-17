//
//  DSPhotosManager.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotosManager.h"

@implementation DSPhotosManager

/* 获取相册的权限 */
+ (DSPhotosAuthorizationStatus)authorizationStatus {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
            return DSPhotosAuthorizationStatusNotDetermined;
            break;
        case PHAuthorizationStatusRestricted:
            return DSPhotosAuthorizationStatusNotAuthorized;
            break;
        case PHAuthorizationStatusDenied:
            return DSPhotosAuthorizationStatusNotAuthorized;
            break;
        case PHAuthorizationStatusAuthorized:
            return DSPhotosAuthorizationStatusAuthorized;
            break;
    }
}

/* 请求相册权限 */
+ (void)requestAuthorizationWithCompletionHandler:(void(^)(BOOL granted))handler {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    handler(YES);
                    break;
                    
                default:
                    handler(NO);
                    break;
            }
            
        });
    }];
}

/**
 根据权限做处理,如果第一次会有系统的授权弹窗
 
 @param handler 是否授权的block
 */
+ (void)accordingToAuthorityWithHandler:(void(^)(BOOL authorized))handler {
    
    DSPhotosAuthorizationStatus status = [DSPhotosManager authorizationStatus];
    switch (status) {
        case DSPhotosAuthorizationStatusNotDetermined: {
            
            [DSPhotosManager requestAuthorizationWithCompletionHandler:^(BOOL granted) {
                
                if (granted) {
                    
                    handler(YES);
                    
                }else {
                    
                    return;
                }
                
            }];
            
            break;
        }
            
        case DSPhotosAuthorizationStatusNotAuthorized:
            
            handler(NO);
            break;
            
        case DSPhotosAuthorizationStatusAuthorized:
            
            handler(YES);
            break;
    }
}


@end
