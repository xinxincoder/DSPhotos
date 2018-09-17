//
//  DSBrowserCell.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSPhotoModel;

typedef NS_ENUM(NSUInteger, DSBrowserCellType) {
    
    DSBrowserCellTypeDisplay,
    DSBrowserCellTypeSelectable,
};

@interface DSBrowserCell : UICollectionViewCell

@property (nonatomic, assign) DSBrowserCellType type;

@property (nonatomic, strong) DSPhotoModel *model;

@property (nonatomic, assign) CGFloat zoomScale;

@end
