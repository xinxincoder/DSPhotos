//
//  DSAlbumsModel.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHFetchResult;

@interface DSAlbumsModel : NSObject

@property (nonatomic, copy) NSString* albumCategoryNmae;
@property (nonatomic, strong) NSMutableArray* albums;

@end

@interface DSAlbumModel : NSObject

// 相册名称
@property (nonatomic, copy) NSString* albumName;

// 相册图片集
@property (nonatomic, strong) PHFetchResult* fetchResult;

@end
