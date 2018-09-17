//
//  DSPhotosCommon.h
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//


#define EPC_IMG_PHOTO_DESELECTED     @"UCPhotoIconDeselected"
#define EPC_IMG_PHOTO_SELECTED       @"UCPhotoIconSelected"
#define EPC_IMG_PHOTO_CAMERA         @"UCPhotoIconCamera"
#define EPC_IMG_PHOTO_ADDPHOTO       @"BBS_addPhotos"
#define EPC_IMG_PHOTO_DELETE         @"doc_ disagree"
#define EPC_IMG_PHOTO_BACKINDICATOR  @"EC_Back"

#define EPC_IMG_PHOTO_ALBUMINDICATOR  @"PHOTO_ALBUMINDICATOR"

#define EPC_IMG_PHOTO_ORIGINALPHOTOUNSELECTED @"OriginalUnselect"
#define EPC_IMG_PHOTO_ORIGINALPHOTOSELECTED  @"OriginalSelect"

#define EPC_IMG_PHOTO_PAUSEVIDEO  @"PHOTO_PAUSEVIDEO"
#define EPC_IMG_PHOTO_PLAYVIDEO  @"PHOTO_PLAYVIDEO"

// 颜色
#define RGBA_PC(R, G, B, A) [UIColor colorWithRed:(R)/255.0f green:(G)/255.0f blue:(B)/255.0f alpha:(A)]
#define RGB_PC(R, G, B) RGBA_PC(R, G, B, 1.0)

#define ThemeColor_PC RGB_PC(18, 183, 245)

// 屏幕尺寸
#define UI_SCREEN_WIDTH_PC      ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT_PC     ([[UIScreen mainScreen] bounds].size.height)

// 回归主线程
#define DS_dispatch_main_async_safe_PC(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 浏览大图相册之间测间距 */
UIKIT_EXTERN CGFloat const DSBroswerMargin;

/** 相册之间测间距的一半 */
UIKIT_EXTERN CGFloat const DSBroswerHalfMargin;

/** 左右间距 */
UIKIT_EXTERN CGFloat const DSPhotoCellMargin;

/** 图片间距 */
UIKIT_EXTERN CGFloat const DSMinimumLineSpacing;

/** 删除按钮的大小 */
UIKIT_EXTERN CGFloat const EPCDeleteSizeLength;

/** 图片压缩系数 */
UIKIT_EXTERN CGFloat const DSCompressionQuality;

@interface DSPhotosCommon : NSObject

/** 相册中,图片的宽高 */
+ (CGSize)epcAssetGridCellSize;

/** 制作成缩略图  一般targetPx传1024*/
+ (NSData *)imageCompressForSize:(UIImage *)sourceImage targetPx:(NSInteger)targetPx;



@end
