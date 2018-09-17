//
//  DSSelectedButton.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSSelectedButton.h"
#import "DSPhotosCommon.h"

@implementation DSSelectedButton

// 构造
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.layer.cornerRadius = 8.0;
    self.titleLabel.font = [UIFont systemFontOfSize:11];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.titleLabel.layer.borderWidth = 1.0;
    self.titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.selecteColor = [UIColor redColor];
    
    //    self.userInteractionEnabled = NO;
    
    return self;
}


- (void)transferBiggerThanBigger {
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    
    [self.layer addAnimation:animation forKey:nil];
}

- (void)setCurSelectedIndex:(NSInteger)curSelectedIndex {
    
    [self setCurSelectedIndex:curSelectedIndex animated:NO];
}

- (void)setCurSelectedIndex:(NSInteger)curSelectedIndex animated:(BOOL)animated {
    
    _curSelectedIndex = curSelectedIndex;
    
    if (curSelectedIndex == 0) {
        
        [self setTitle:@" " forState:UIControlStateNormal];
        self.titleLabel.layer.backgroundColor = RGBA_PC(222, 222, 222, 0.7).CGColor;
        
    } else {
        
        NSString *title;
        //这里不需要显示数字，只需要填充就可以
        if (_curSelectedIndex == -1) {
            
            title = @" ";
            
        }else {
            
            title = @(curSelectedIndex).stringValue;
        }
        
        self.titleLabel.layer.backgroundColor = self.selecteColor.CGColor;
        [self setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
        
        if (animated) [self transferBiggerThanBigger];
        
    }
}

- (void)setSelecteColor:(UIColor *)selecteColor {
    _selecteColor = selecteColor;
    
    self.curSelectedIndex = self.curSelectedIndex;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect cFrame = self.titleLabel.frame;
    cFrame.size = CGSizeMake(16, 16);
    cFrame.origin.x = (CGRectGetWidth(self.bounds) - 16)*0.5;
    cFrame.origin.y = (CGRectGetHeight(self.bounds) - 16)*0.5;
    
    self.titleLabel.frame = cFrame;
}

@end
