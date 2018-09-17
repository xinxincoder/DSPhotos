//
//  PhotosCellCell.h
//  PhotosManager
//
//  Created by  liuxx on 2017/4/11.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotosCell;
@class DSPhotoModel;

@protocol PhotosCellDelegate <NSObject>

- (void)photosCell:(PhotosCell*)cell didSelecteWithMode:(DSPhotoModel*)mode;

@optional
- (void)photosCell:(PhotosCell*)cell deleteWithPhotoMode:(DSPhotoModel*)photoMode;

@end

@interface PhotosCell : UITableViewCell

/** 快速获取cell */
+ (instancetype)cell:(UITableView*)tableView;

// 数据
@property (nonatomic, strong) NSMutableArray* photos;
// 最大限制
@property (nonatomic, assign) NSInteger maxCount;

// 是否处于编辑状态 默认: 不编辑
@property (nonatomic, assign) BOOL DSEdit;

// 在编辑状态, 是否自带删除按钮 默认: 不带
@property (nonatomic, assign) BOOL ownDeleteFunction;

// 代理
@property (nonatomic, weak) id<PhotosCellDelegate> delegate;



/**
 是否要长安拖动效果 默认: 没有
 */
@property (nonatomic, assign, getter=isDrag) BOOL drag;

@end
