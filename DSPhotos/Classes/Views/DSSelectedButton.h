//
//  DSSelectedButton.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSSelectedButton : UIButton

/** 当前选中的标号 */
@property (nonatomic, assign) NSInteger curSelectedIndex;

/**
 选中图标的颜色
 */
@property (nonatomic, strong) UIColor* selecteColor;

- (void)setCurSelectedIndex:(NSInteger)curSelectedIndex animated:(BOOL)animated;

@end
