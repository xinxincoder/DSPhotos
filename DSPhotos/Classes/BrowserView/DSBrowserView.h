//
//  DSBrowserView.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BrowserTtilePosition) {
    /** 顶部 */
    BrowserTtilePositionTop,
    /** 底部 */
    BrowserTtilePositionBottom
};

@class DSPhotoModel;
@class DSBrowserView;

@protocol DSBrowserViewDelegate <NSObject>

@optional

#pragma mark - 添加自定义视图
/** 你可能会再增加其它视图 */
- (nonnull UIView *)setupAccessoryViewInBrowserView:(nonnull DSBrowserView *)browserView;

/**
 对于自己添加的视图进行配置
 
 @param browserView browserView
 @param accessoryView accessoryView
 @param index 当前视图的索引
 */
- (void)browserView:(nonnull DSBrowserView *)browserView configureAccessoryView:(nonnull UIView *)accessoryView photoModel:(nonnull DSPhotoModel *)photoModel atIndex:(NSInteger)index;



/**
 长按大图的事件

 @param browserView browserView
 @param photoModel photoModel
 @param index 当前视图的索引
 */
- (void)browserView:(nonnull DSBrowserView *)browserView longPressActionWithPhotoModel:(nonnull DSPhotoModel *)photoModel atIndex:(NSInteger)index;

/**
 单击取消时的事件
 
 @param browserView browserView
 */
- (void)browserViewDidSingleTap:(nonnull DSBrowserView *)browserView;

/**
 删除一个视图
 
 @param browserView browserView
 @param photoModel 视图的模型
 @param index 当前视图的索引
 */
- (void)browserView:(nonnull DSBrowserView *)browserView deletePhotoModel:(DSPhotoModel *_Nullable)photoModel index:(NSInteger)index;


/**
 当你删除某个视图的时候图片的原始位置改变你需要传最新的位置

 @param browserView browserView
 @param photoModel photoModel
 @param index index
 */
- (nonnull UIView *)browserView:(nonnull DSBrowserView *)browserView updatePhotoPositionWhenDeletePhotoModel:(DSPhotoModel *_Nullable)photoModel atIndex:(NSInteger)index;

@end

@interface DSBrowserView : UIView

// 在编辑状态, 是否可以删除 默认: 不带
@property (nonatomic, assign) BOOL isCanDelete;

@property (nonatomic, copy) NSString * _Nullable deleteImageName;

/** 默认不显示 */
@property (nonatomic, assign) BOOL showTitle;

@property (nonatomic, weak) id<DSBrowserViewDelegate> _Nullable delegate;


/**
 初始化类方法（多张图片）
 
 @param photoModels 所有图片的模型
 @param currentIndex 显示的图片的索引
 @return instancetype
 */
+ (nonnull instancetype)browserViewWithPhotoModels:(nonnull NSArray <DSPhotoModel *>*)photoModels currentIndex:(NSInteger)currentIndex;


/**
 初始化类方法（一个模型）
 
 @param photoModel photoModel
 @return instancetype
 */
+ (nonnull instancetype)browserViewWithPhotoModel:(nonnull DSPhotoModel *)photoModel;
/**
 初始化类方法（一张图片）
 
 @param image 图片
 @return instancetype
 */
+ (nonnull instancetype)browserViewWithImage:(nonnull UIImage *)image;


/**
 初始化类方法（一张图片）
 
 @param urlString 图片的url
 @return instancetype
 */
+ (nonnull instancetype)browserViewWithImageUrlString:(nonnull NSString *)urlString;

/** 默认顶部 */
@property (nonatomic, assign) BrowserTtilePosition positon;


- (void)show;

@end
