//
//  DSPhotoController.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "DSPhotosProtocol.h"
@class DSBrowserController;
@class DSPhotoController;

@protocol DSPhotoControllerDelegate <DSPhotosProtocol>

// 查看图片时返回一个 DSBrowserController 控制器, 或者其子类的对象
- (DSBrowserController *)browserControllerAppearanceForPhotoController:(DSPhotoController *)photoController;

@end

@interface DSPhotoController : UIViewController

// 图片集
@property (nonatomic, strong) PHFetchResult *pPhotoFetchResult;

/** 已经选中的图片(DSPhotoMode) */
@property (nonatomic, strong) NSMutableArray* selectedAssets;

/** 被选中的图片 */
@property (nonatomic, strong) NSMutableArray* photos;

/** 代理 */
@property (nonatomic, weak) id<DSPhotoControllerDelegate> delegate;

/** 最大限制 */
@property (nonatomic, assign) NSUInteger maximumLimit;

/** 最小限制，默认是1 */
@property (nonatomic, assign) NSUInteger minimumLimit;

/** 是否带拍照功能, 默认: 不能 */
@property (nonatomic, assign) BOOL canTakePicture NS_DEPRECATED_IOS(2_0, 8_0);
/** 是否展示原图的按钮 */
@property (nonatomic, assign) BOOL showOriginalPhotoButton;

/** 图片的压缩系数，设置为1024大概为压缩为1M左右 */
@property (nonatomic, assign) CGFloat targetCompression;

/** 选中图标的颜色 默认红色 */
@property (nonatomic, strong) UIColor* selecteColor;

/** 确定标题 */
@property (nonatomic, copy) NSString *doneTitle;

/**
 选择图片加载大图的过程中,要做的操作.一般是用于调用加载框
 
 @param start YES 开始   NO 结束
 */
- (void)didSelctedPhotosLoadingStatus:(BOOL)start;

@end
