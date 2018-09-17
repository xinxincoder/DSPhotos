//
//  DSTouchMaskView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSTouchMaskView.h"

@implementation DSTouchMaskView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self pointInside:point withEvent:event]) {
        
        return self.receiver;
    }
    
    return nil;
}

@end

