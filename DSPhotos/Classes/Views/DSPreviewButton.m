//
//  DSPreviewButton.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPreviewButton.h"
#import "DSPhotosCommon.h"

@implementation DSPreviewButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.layer.borderWidth = 1.0;
    self.titleLabel.layer.cornerRadius = 5.0;
    
    
    return self;
}

- (void)setSelecteColor:(UIColor *)selecteColor {
    _selecteColor = selecteColor;
    
    self.epcUserInteractionEnabled = self.epcUserInteractionEnabled;
}

- (void)setTitleBackgroundColor:(UIColor *)titleBackgroundColor {
    _titleBackgroundColor = titleBackgroundColor;
    
    self.epcUserInteractionEnabled = self.epcUserInteractionEnabled;
}

- (void)setEpcUserInteractionEnabled:(BOOL)epcUserInteractionEnabled {
    _epcUserInteractionEnabled = epcUserInteractionEnabled;
    
    if (epcUserInteractionEnabled) {
        
        if (!self.titleBackgroundColor) {
            
            self.titleBackgroundColor = [UIColor whiteColor];
        }
        
        self.titleLabel.layer.backgroundColor = self.titleBackgroundColor.CGColor;
        self.titleLabel.layer.borderColor = self.selecteColor.CGColor;
        [self setTitleColor:self.selecteColor forState:UIControlStateNormal];
        
    } else {
        
        self.titleLabel.layer.backgroundColor = RGBA_PC(222, 222, 222, 0.7).CGColor;
        self.titleLabel.layer.borderColor = self.titleLabel.layer.backgroundColor;
        
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = self.bounds;
}

@end
