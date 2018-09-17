//
//  DSAlbumController.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSFetchMediaType) {
    DSFetchMediaTypeAll = 0,
    DSFetchMediaTypeImage   = 1,
    DSFetchMediaTypeVideo   = 2,
    DSFetchMediaTypeAudio   = 3,
};

@class DSAlbumController;
@class DSAlbumModel;
@class DSPhotoController;

// 相册代理
@protocol DSAlbumControllerDelegate <NSObject>

// 提供这个代理的目的在于可能 DSPhotoController 可能需要创建子类
@required
- (DSPhotoController *)photoControllerForAlbumController;

@end

@interface DSAlbumController : UIViewController

@property (nonatomic, weak) id<DSAlbumControllerDelegate> delegate;

@property (nonatomic, assign) DSFetchMediaType fetchMediaType;

@end
