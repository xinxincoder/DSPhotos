//
//  PhotoItemCell.h
//  PhotosManager
//
//  Created by  liuxx on 2017/4/13.
//  Copyright © 2017年 CustomUI. All rights reserved.
//



#import <UIKit/UIKit.h>
@class DSPhotoModel;
@class PhotoItemCell;

@protocol PhotoItemCellDelegate <NSObject>

// 删除当前图片
- (void)deletePhotoItemCell:(PhotoItemCell*)cell;

@end

@interface PhotoItemCell : UICollectionViewCell

// 为了获取放大之前的位置
@property (nonatomic, weak, readonly) UIImageView* imageDSView;

// 在编辑状态, 是否自带删除按钮 默认: 不带
@property (nonatomic, assign) BOOL ownDeleteFunction;

// 代理
@property (nonatomic, weak) id<PhotoItemCellDelegate> delegate;

// 数据
@property (nonatomic, strong) DSPhotoModel* photoModel;

@end
