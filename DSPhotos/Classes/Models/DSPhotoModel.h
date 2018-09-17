//
//  DSPhotoModel.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class PHAsset;


typedef NS_ENUM(NSUInteger, DSPhotoModelType) {
    DSPhotoModelTypeImage,
    DSPhotoModelTypeVideo,
};

@interface DSPhotoModel : NSObject

/** 快速通过 mAsset 创建对象 */
+ (instancetype)photoWithAsset:(PHAsset*)mAsset;

/** 原始的资源对象 */
@property (nonatomic, copy, readonly) PHAsset *mAsset;

@property (nonatomic, assign) DSPhotoModelType type;

#pragma mark - Image

//图片在屏幕的尺寸
@property (nonatomic, assign, readonly) CGRect imgFrame;

/** 图片数据 */
@property (nonatomic, strong) NSData* imageData;
/** 缩略图: 本地展示，或视频缩略图 */
@property (nonatomic, strong) UIImage* thumbnailImage;

@property (nonatomic, copy) NSString* thumbnailImageURLString;
/** 使用图: 浏览/提交 */
@property (nonatomic, strong) UIImage* image;

@property (nonatomic, copy) NSString *imageURLString;

#pragma mark - Video

@property (nonatomic, strong) AVAsset *videoAsset;

@property (nonatomic, strong) AVAudioMix *audioMix;

@property (nonatomic, strong) NSData *videoData;

@property (nonatomic, assign) NSTimeInterval videoTime;

#pragma mark - 其余属性
/** 是否选中当前照片 (这个字段貌似没没有作用了) */
@property (nonatomic, assign) BOOL DSSelected;

/** 当前选中的第几张 */
@property (nonatomic, assign) NSInteger curSelectedIndex;

@property (nonatomic, assign) BOOL selectedIndexAnimatable;

@property (nonatomic, assign) BOOL shadeAnimatable;

/** 相当于MINE */
@property (nonatomic, copy) NSString* dataUTI;
@property (nonatomic, strong) NSDictionary * info;
@property (nonatomic, copy) NSString* fileName;

@property (nonatomic, strong) id extra;


/**
 如果传入这个值的话，返回uiview的代理可直接return photoModel.photoView
 没有传的话，要自己在代理方法返回相应的view
 */
@property (nonatomic, strong) UIView *photoView;

#pragma mark - 动画

@property (nonatomic, assign) CGPoint touchPoint;

@end

