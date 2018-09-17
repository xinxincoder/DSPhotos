//
//  DSTakePhotoManager.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSTakePhotoManager.h"
#import "DSPhotoModel.h"
#import <Photos/Photos.h>
#import "UIImage+FixOrientation.h"
#import "DSPhotosManager.h"
#import "DSPhotosCommon.h"

@interface DSTakePhotoManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController* sourceVC;

@property (nonatomic, copy) TakePhotoAssetBlock backAssetBlock;

@property (nonatomic, assign) CGFloat targetCompression;

@end

@implementation DSTakePhotoManager

static DSTakePhotoManager *SINGLETON    = nil;
static bool        isFirstAccess = YES;

#pragma mark - Life Cycle
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return [[[self class] alloc] init];
}

- (id)mutableCopy {
    return [[[self class] alloc] init];
}

- (id)init {
    if (SINGLETON) return SINGLETON;
    if (isFirstAccess) [self doesNotRecognizeSelector:_cmd];
    self = [super init];
    return self;
}

/**
 单例
 */
+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // init
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

/**
 开始拍照
 */
- (void)takePhotoWithSourceVC:(UIViewController*)sourceVC tagetCompression:(CGFloat)tagetCompression backAssetBlock:(TakePhotoAssetBlock)backAssetBlock {
    
    // 断言
    NSAssert([sourceVC isKindOfClass:[UIViewController class]], @"请设置 'self.sourceVC' 的值");
    
    self.targetCompression = tagetCompression;
    
    self.sourceVC = sourceVC;
    self.backAssetBlock = backAssetBlock;
    
    [self takePhoto];
}

- (void)takePhotoWithSourceVC:(UIViewController *)sourceVC backAssetBlock:(TakePhotoAssetBlock)backAssetBlock {
    
    [self takePhotoWithSourceVC:sourceVC tagetCompression:1024 backAssetBlock:backAssetBlock];
}

- (void)takePhoto {
    // 进入相机
    void (^openBlock) () = ^{
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType    = sourceType;
            [self.sourceVC presentViewController:picker animated:YES completion:nil];
        } else {
            // 不能打开了
        }
    };
    
    // 权限判断
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            // 第一次访问
            // 没有确认过
            
            // 需要问一下,弹出是否同意提示框
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                
                void (^completionBlock)(void) = ^{
                    if(granted){
                        // 同意
                        // 进入相机
                        openBlock();
                    } else {
                        // 不同意
                        //                        [self.sourceVC dismissViewControllerAnimated:YES completion:NULL];
                    }
                };
                
                DS_dispatch_main_async_safe_PC(completionBlock);
                
                
            }];
        }
            break;
        case AVAuthorizationStatusRestricted: {
            // (此状态,暂未使用)
            // 被拒绝
        }
            break;
        case AVAuthorizationStatusDenied: {
            // 被否认过
        }
            break;
        case AVAuthorizationStatusAuthorized: {
            // 进入相机
            openBlock();
        }
            break;
            
        default: {
            // 未知状态
        }
            break;
    }
}

#pragma MARK -
#pragma MARK - UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        DSPhotosAuthorizationStatus status = [DSPhotosManager authorizationStatus];
        
        switch (status) {
            case DSPhotosAuthorizationStatusNotDetermined:
            case DSPhotosAuthorizationStatusNotAuthorized: {
                
                DSPhotoModel* photoModel = [[DSPhotoModel alloc] init];
                
                //0.8这个值返回的data最近接存入相册中的data
                NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
                if (image.imageOrientation != UIImageOrientationUp) {
                    UIImage* image = [UIImage imageWithData:imageData];
                    image = [UIImage fixOrientation_DSPhoto:image];
                    imageData = UIImageJPEGRepresentation(image, DSCompressionQuality);
                    
                    photoModel.image = image;
                    
                } else {
                    
                    photoModel.image = image;
                }
                
                if (self.targetCompression != 0) {
                    
                    UIImage *compressImage = [UIImage imageWithData:imageData];
                    
                    imageData = [DSPhotosCommon imageCompressForSize:compressImage targetPx:self.targetCompression];
                }
                
                
                photoModel.imageData = imageData;
                photoModel.dataUTI = type;
                photoModel.info = info;
                
                self.backAssetBlock(photoModel);
                
                
                
                [self imagePickerControllerDidCancel:picker];
                
                break;
            }
            case DSPhotosAuthorizationStatusAuthorized: {
                
                [self loadImageFinished:image imagePickerController:picker];
                break;
                
            }
        }
        
    } else {
        // 取消
        [self imagePickerControllerDidCancel:picker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.sourceVC dismissViewControllerAnimated:YES completion:NULL];
}



// 保存到相册
- (void)loadImageFinished:(UIImage *)image imagePickerController:(UIImagePickerController *)picker
{
    NSMutableArray *imageIds = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        void (^completionBlock)() = ^{
            
            if (success) {
                // 获取 imageIds(唯一标识) 中的资源
                PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull mAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                    *stop = YES;
                    
                    [[PHImageManager defaultManager] requestImageDataForAsset:mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                        
                        DSPhotoModel* photoModel = [DSPhotoModel photoWithAsset:mAsset];
                        
                        if (orientation != UIImageOrientationUp) {
                            UIImage* image = [UIImage imageWithData:imageData];
                            image = [UIImage fixOrientation_DSPhoto:image];
                            imageData = UIImageJPEGRepresentation(image, DSCompressionQuality);
                            
                            photoModel.image = image;
                        } else {
                            photoModel.image = [UIImage imageWithData:imageData];
                        }
                        
                        if (self.targetCompression != 0) {
                            
                            UIImage *compressImage = [UIImage imageWithData:imageData];
                            
                            imageData = [DSPhotosCommon imageCompressForSize:compressImage targetPx:self.targetCompression];
                        }
                        
                        photoModel.imageData = imageData;
                        photoModel.dataUTI = dataUTI;
                        photoModel.info = info;
                        
                        NSLog(@"%@", photoModel.fileName);
                        
                        if (weakSelf.backAssetBlock) {
                            weakSelf.backAssetBlock(photoModel);
                        }
                        
                        // 取消
                        [weakSelf imagePickerControllerDidCancel:picker];
                        
                    }];
                    
                }];
            } else {
                if (weakSelf.backAssetBlock) {
                    weakSelf.backAssetBlock(nil);
                }
                // 取消
                [weakSelf imagePickerControllerDidCancel:picker];
            }
        };
        
        DS_dispatch_main_async_safe_PC(completionBlock);
        
    }];
}

/* 获取照相机的权限 */
+ (DSTakePhotoAuthorizationStatus)authorizationStatus {
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            return DSTakePhotoAuthorizationStatusNotDetermined;
            break;
        case AVAuthorizationStatusRestricted:
            return DSTakePhotoAuthorizationStatusNotAuthorized;
            break;
        case AVAuthorizationStatusDenied:
            return DSTakePhotoAuthorizationStatusNotAuthorized;
            break;
        case AVAuthorizationStatusAuthorized:
            return DSTakePhotoAuthorizationStatusAuthorized;
            break;
    }
    
}
/* 请求相机权限 */
+ (void)requestAuthorizationWithCompletionHandler:(void(^)(BOOL granted))handler {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        handler(granted);
        
    }];
}

@end
