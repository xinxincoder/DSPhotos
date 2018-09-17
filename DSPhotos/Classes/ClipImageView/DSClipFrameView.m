//
//  DSClipFrameView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSClipFrameView.h"

typedef NS_ENUM(NSUInteger, DSClipFrameViewTouchSpotLayerType) {
    
    DSClipFrameViewTouchSpotLayerTypeCorner,   //拐角
    DSClipFrameViewTouchSpotLayerTypeLine,     //边上中间的线
    
};

//触摸的区域
static const CGFloat TouchSpotArea = 30.0;

static const CGFloat TouchSpotLineLength = 20.0;
static const CGFloat TouchSpotLineWidth = 2.0;
static const CGFloat FrameLineWidth = 1.0;

@interface DSClipFrameView ()

@property (nonatomic, strong) CAShapeLayer *touchSpotCornerLayer;

@property (nonatomic, strong) CAShapeLayer *touchSpotLineLayer;

@property (nonatomic, strong) CAShapeLayer *mainRectLayer;

@property (nonatomic, strong) CAShapeLayer *roundLayer;
@property (nonatomic, strong) CAShapeLayer *rectangleLayer;

@end

@implementation DSClipFrameView

- (CGFloat)touchSpotLineWidth {
    
    if (_touchSpotLineWidth == 0) {
        
        _touchSpotLineWidth = TouchSpotLineWidth;
    }
    return _touchSpotLineWidth;
}

- (CGFloat)touchSpotLineLength {
    
    if (_touchSpotLineLength == 0) {
        
        _touchSpotLineLength = TouchSpotLineLength;
    }
    return _touchSpotLineLength;
}

- (UIColor *)touchSpotColor {
    
    if (!_touchSpotColor) {
        
        _touchSpotColor = [UIColor whiteColor];
    }
    return _touchSpotColor;
}

- (UIColor *)frameColor {
    
    if (!_frameColor) {
        
        _frameColor = [UIColor whiteColor];
    }
    return _frameColor;
}

- (CGFloat)frameLineWidth {
    
    if (_frameLineWidth == 0) {
        
        _frameLineWidth = FrameLineWidth;
    }
    return _frameLineWidth;
}

- (void)setType:(DSClipFrameViewType)type {
    _type = type;
    
    if (self.roundLayer && self.roundLayer.superlayer) {
        
        [self.roundLayer removeFromSuperlayer];
    }
    
    if (self.rectangleLayer && self.rectangleLayer.superlayer) {
        
        [self.rectangleLayer removeFromSuperlayer];
    }
    
    
    switch (_type) {
            
        case DSClipFrameViewTypeFreedomRectangle:
        case DSClipFrameViewTypeRatioRectangle:
            [self createTouchSpotRectangleLayer];
            break;
            
        case DSClipFrameViewTypeRound:
            [self createRoundLayer];
            break;
        case DSClipFrameViewTypeRectangle:
            [self createRectangleLayer];
            break;
    }
}

#pragma mark - 绘制大小不会改变的选框
- (void)createRoundLayer {
    
    if (self.roundLayer && self.roundLayer.superlayer) {
        
        [self.roundLayer removeFromSuperlayer];
    }
    
    if (self.rectangleLayer && self.rectangleLayer.superlayer) {
        
        [self.rectangleLayer removeFromSuperlayer];
    }
    
    
    CAShapeLayer *roundLayer = [CAShapeLayer layer];
    roundLayer.strokeColor = self.frameColor.CGColor;
    roundLayer.fillColor = [UIColor clearColor].CGColor;
    roundLayer.lineWidth = self.frameLineWidth;
    
    CGFloat minLength = MIN(self.bounds.size.width, self.bounds.size.height);
    
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, minLength, minLength)];
    roundLayer.path = roundPath.CGPath;
    
    [self.layer addSublayer:roundLayer];
    self.roundLayer = roundLayer;
}

- (void)createRectangleLayer {
    if (self.rectangleLayer && self.rectangleLayer.superlayer) {
        
        [self.rectangleLayer removeFromSuperlayer];
    }
    
    if (self.roundLayer && self.roundLayer.superlayer) {
        
        [self.roundLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *rectangleLayer = [CAShapeLayer layer];
    rectangleLayer.strokeColor = self.frameColor.CGColor;
    rectangleLayer.fillColor = [UIColor clearColor].CGColor;
    rectangleLayer.lineWidth = self.frameLineWidth;
    
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:self.bounds];
    rectangleLayer.path = rectanglePath.CGPath;
    
    [self.layer addSublayer:rectangleLayer];
    self.rectangleLayer = rectangleLayer;
}

#pragma mark - 绘制会变的选框
- (void)createTouchSpotRectangleLayer {
    
    if (self.mainRectLayer && self.mainRectLayer.superlayer) {
        
        [self.mainRectLayer removeFromSuperlayer];
    }
    
    if (self.touchSpotCornerLayer && self.touchSpotCornerLayer.superlayer) {
        
        [self.touchSpotCornerLayer removeFromSuperlayer];
    }
    
    if (self.touchSpotLineLayer && self.touchSpotLineLayer.superlayer) {
        
        [self.touchSpotLineLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *mainRectLayer = [CAShapeLayer layer];
    mainRectLayer.strokeColor = self.frameColor.CGColor;
    mainRectLayer.fillColor = [UIColor clearColor].CGColor;
    mainRectLayer.lineWidth = self.frameLineWidth;
    
    UIBezierPath *mainRectPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [mainRectPath moveToPoint:CGPointMake(self.bounds.size.width/3, 0)];
    [mainRectPath addLineToPoint:CGPointMake(self.bounds.size.width/3, self.bounds.size.height)];
    
    [mainRectPath moveToPoint:CGPointMake(self.bounds.size.width*2/3, 0)];
    [mainRectPath addLineToPoint:CGPointMake(self.bounds.size.width*2/3, self.bounds.size.height)];
    
    [mainRectPath moveToPoint:CGPointMake(0, self.bounds.size.height/3)];
    [mainRectPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height/3)];
    
    [mainRectPath moveToPoint:CGPointMake(0, self.bounds.size.height*2/3)];
    [mainRectPath addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height*2/3)];
    
    mainRectLayer.path = mainRectPath.CGPath;
    [self.layer addSublayer:mainRectLayer];
    self.mainRectLayer = mainRectLayer;
    
    CAShapeLayer *touchSpotCornerLayer = [self touchSpotLayerWithTouchSpotLayerType:DSClipFrameViewTouchSpotLayerTypeCorner];
    [self.layer addSublayer:touchSpotCornerLayer];
    self.touchSpotCornerLayer = touchSpotCornerLayer;
    
    if (self.type == DSClipFrameViewTypeFreedomRectangle) {
        
        CAShapeLayer *touchSpotLineLayer = [self touchSpotLayerWithTouchSpotLayerType:DSClipFrameViewTouchSpotLayerTypeLine];
        [self.layer addSublayer:touchSpotLineLayer];
        self.touchSpotLineLayer = touchSpotLineLayer;
    }
}

- (CAShapeLayer *)touchSpotLayerWithTouchSpotLayerType:(DSClipFrameViewTouchSpotLayerType)touchSpotLayerType {
    
    CAShapeLayer *touchSpotLayer = [CAShapeLayer layer];
    touchSpotLayer.strokeColor = self.touchSpotColor.CGColor;
    touchSpotLayer.fillColor = [UIColor clearColor].CGColor;
    touchSpotLayer.lineWidth = self.touchSpotLineWidth;
    
    UIBezierPath *touchSpotPath = [UIBezierPath bezierPath];
    
    switch (touchSpotLayerType) {
        case DSClipFrameViewTouchSpotLayerTypeCorner: {
            
            [touchSpotPath moveToPoint:CGPointMake(self.touchSpotLineLength, -self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, -self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, self.touchSpotLineLength)];
            
            [touchSpotPath moveToPoint:CGPointMake(self.bounds.size.width - self.touchSpotLineLength, -self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth*0.5, -self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth*0.5, self.touchSpotLineLength)];
            
            [touchSpotPath moveToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, self.bounds.size.height - self.touchSpotLineLength)];
            [touchSpotPath addLineToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(self.touchSpotLineLength, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            
            [touchSpotPath moveToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth*0.5, self.bounds.size.height - self.touchSpotLineLength)];
            [touchSpotPath addLineToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth*0.5, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(self.bounds.size.width-self.touchSpotLineLength, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            
            
            break;
        }
        case DSClipFrameViewTouchSpotLayerTypeLine: {
            
            [touchSpotPath moveToPoint:CGPointMake((self.bounds.size.width - self.touchSpotLineLength)*0.5 , -self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake((self.bounds.size.width - self.touchSpotLineLength)*0.5 + self.touchSpotLineLength, -self.touchSpotLineWidth*0.5)];
            
            [touchSpotPath moveToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, (self.bounds.size.height - self.touchSpotLineLength)*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(-self.touchSpotLineWidth*0.5, (self.bounds.size.height - self.touchSpotLineLength)*0.5 + self.touchSpotLineLength)];
            
            [touchSpotPath moveToPoint:CGPointMake((self.bounds.size.width - self.touchSpotLineLength)*0.5, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake((self.bounds.size.width - self.touchSpotLineLength)*0.5 + self.touchSpotLineLength, self.bounds.size.height + self.touchSpotLineWidth*0.5)];
            
            [touchSpotPath moveToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth*0.5, (self.bounds.size.height - self.touchSpotLineLength)*0.5)];
            [touchSpotPath addLineToPoint:CGPointMake(self.bounds.size.width + self.touchSpotLineWidth *0.5, (self.bounds.size.height - self.touchSpotLineLength)*0.5 + self.touchSpotLineLength)];
            
            break;
        }
    }
    touchSpotLayer.path = touchSpotPath.CGPath;
    return touchSpotLayer;
}

/**
 根据触摸的区域得出区域的枚举
 
 @param location 触摸的区域
 @return 区域的枚举
 */
- (DSClipFrameViewTouchSpotLayerOptions)touchSpotLayerOptionsWithLocation:(CGPoint)location {
    
    CGFloat minLocationWidth = (CGRectGetWidth(self.bounds) - TouchSpotArea)*0.5;
    CGFloat minLocationHeight = (CGRectGetHeight(self.bounds) - TouchSpotArea)*0.5;
    
    if (self.type == DSClipFrameViewTypeFreedomRectangle) {
        
        if (location.x >= minLocationWidth &&
            location.x <= minLocationWidth + TouchSpotArea &&
            location.y >= -TouchSpotArea &&
            location.y <= TouchSpotArea) {
            
            return DSClipFrameViewTouchSpotLayerOptionsTop;
        }
        
        if (location.x >= -TouchSpotArea &&
            location.x <= TouchSpotArea &&
            location.y >= minLocationHeight &&
            location.y <= minLocationHeight + TouchSpotArea) {
            
            return DSClipFrameViewTouchSpotLayerOptionsLeft;
        }
        
        if (location.x >= minLocationWidth &&
            location.x <= minLocationWidth + TouchSpotArea &&
            location.y >= CGRectGetHeight(self.bounds) - TouchSpotArea &&
            location.y <= CGRectGetHeight(self.bounds) + TouchSpotArea) {
            
            return DSClipFrameViewTouchSpotLayerOptionsBottom;
        }
        
        if (location.x >= CGRectGetWidth(self.bounds) - TouchSpotArea &&
            location.x <= CGRectGetWidth(self.bounds) + TouchSpotArea &&
            location.y >= minLocationHeight &&
            location.y <= minLocationHeight + TouchSpotArea) {
            
            return DSClipFrameViewTouchSpotLayerOptionsRight;
        }
    }
    
    if (location.x >= -TouchSpotArea &&
        location.x <= TouchSpotArea &&
        location.y >= -TouchSpotArea &&
        location.y <= TouchSpotArea) {
        
        return DSClipFrameViewTouchSpotLayerOptionsTop |
        DSClipFrameViewTouchSpotLayerOptionsLeft;
    }
    
    if (location.x >= CGRectGetWidth(self.bounds) - TouchSpotArea &&
        location.x <= CGRectGetWidth(self.bounds) + TouchSpotArea &&
        location.y >= -TouchSpotArea &&
        location.y <= TouchSpotArea) {
        
        return DSClipFrameViewTouchSpotLayerOptionsTop |
        DSClipFrameViewTouchSpotLayerOptionsRight;
    }
    
    if (location.x >= - TouchSpotArea &&
        location.x <= TouchSpotArea &&
        location.y >= CGRectGetHeight(self.bounds) - TouchSpotArea &&
        location.y <= CGRectGetHeight(self.bounds) + TouchSpotArea) {
        
        return DSClipFrameViewTouchSpotLayerOptionsBottom |
        DSClipFrameViewTouchSpotLayerOptionsLeft;
    }
    
    if (location.x >= CGRectGetWidth(self.bounds) - TouchSpotArea &&
        location.x <= CGRectGetWidth(self.bounds) + TouchSpotArea &&
        location.y >= CGRectGetHeight(self.bounds) - TouchSpotArea &&
        location.y <= CGRectGetHeight(self.bounds) + TouchSpotArea) {
        
        return DSClipFrameViewTouchSpotLayerOptionsBottom |
        DSClipFrameViewTouchSpotLayerOptionsRight;
        
    }else {
        
        return DSClipFrameViewTouchSpotLayerOptionsNone;
    }
}

//如果是可拖拽变形的矩形框要一直绘制
- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
    self.type = _type;
}

@end
