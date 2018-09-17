//
//  DSAlbumsModel.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSAlbumsModel.h"

@implementation DSAlbumsModel

#pragma mark -
#pragma mark - 懒加载
- (NSMutableArray *)albums {
    if (!_albums) {
        _albums = [NSMutableArray array];
    }
    return _albums;
}

@end

@implementation DSAlbumModel

@end
