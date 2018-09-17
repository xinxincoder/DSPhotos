//
//  DSPhotoCell.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPhotosProtocol.h"

@protocol DSPhotosCellDelegate <DSPhotosProtocol>

@end

@interface DSPhotosCell : UICollectionViewCell

@property (nonatomic, strong) DSPhotoModel* photoModel;

@property (nonatomic, weak) id<DSPhotosCellDelegate> delegate;

/**
 选中图标的颜色
 */
@property (nonatomic, strong) UIColor* selecteColor;

@end

