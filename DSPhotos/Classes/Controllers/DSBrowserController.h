//
//  DSBrowserController.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPhotosProtocol.h"

@class DSBrowserController;

@protocol DSBrowserControllerDelegate <DSPhotosProtocol>

- (void)browserController:(DSBrowserController *)browserController checkOriginalPhotoButtonStatus:(BOOL)status;

@end

@interface DSBrowserController : UIViewController

@property (nonatomic, weak) id<DSBrowserControllerDelegate> delegate;
// 当前图片的位置
@property (nonatomic, assign) NSUInteger currentIndex;
/** 最大限制 */
@property (nonatomic, assign) NSUInteger maximumLimit;
/** 最小限制，默认是1 */
@property (nonatomic, assign) NSUInteger minimumLimit;

// 所有图片集合 (DSPhotoModel)
@property (nonatomic, strong) NSMutableArray <DSPhotoModel *>* fetchPhotoResult;

@property (nonatomic, strong) NSMutableArray <DSPhotoModel *>* selectedAssets;

#pragma mark - Appearance
/** 当没有选中图片时，点击底部按钮默认选择当前这一张(如果设置了这个属性，photosManagerWillSelectDonePhotosLessThanMinimumLimit就不会执行) */
@property (nonatomic, assign) BOOL canSelectCurrentWhenNoSelect;
/** 选中图标的颜色 默认红色 */
@property (nonatomic, strong) UIColor* selecteColor;
/** 返回按键的图片 */
@property (nonatomic, strong) UIImage *backIndicatorImage;
/** 返回按键的文字 */
@property (nonatomic, strong) NSAttributedString *backTitleArrtibuteText;
/** 确定标题标题 */
@property (nonatomic, copy) NSString *doneTitle;
/** 是否展示原图的按钮 */
@property (nonatomic, assign) BOOL showOriginalPhotoButton;
/** 是否选中原图的按钮 */
@property (nonatomic, assign) BOOL selectOriginalPhoto;

@end
