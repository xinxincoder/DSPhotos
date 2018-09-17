//
//  DSPhotoController.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSPhotoController.h"
#import <Photos/Photos.h>
#import "DSPhotoModel.h"
#import "DSPhotoCell.h"
#import "DSBrowserController.h"
#import "DSVideoController.h"
#import "DSPhotosGlobal.h"
#import "DSAlbumController.h"
#import "DSAlbumsModel.h"
#import "DSPhotosCommon.h"
#import "DSPreviewButton.h"

#import "DSTakePhotoManager.h"
#import "UIImage+FixOrientation.h"

static NSString* const ID = @"DSPhotosCell";

@interface DSPhotoController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DSAlbumControllerDelegate, DSPhotosCellDelegate, DSBrowserControllerDelegate>

#pragma mark - 数据
@property (nonatomic, strong) NSMutableArray* fetchPhotoResult;

/** 记录是否第一次 */
@property (nonatomic, assign) BOOL recordFirst;

#pragma mark - 展示
@property (nonatomic, weak) UICollectionView* collectionView;

/** 查看相册 */
@property (weak, nonatomic) UIButton *pAlbumButton;

// 预览
@property (nonatomic, weak) UIButton* previewButton;

@property (nonatomic, weak) UIButton *originalPhotoButton;

// 为了防止快速点击 "完成" 按钮.
@property (nonatomic, assign) BOOL refuseRepeatOK;

@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation DSPhotoController

// 构造方法
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.recordFirst = YES;
    
    self.canTakePicture = NO;
    
    self.minimumLimit = 1;
    
    self.maximumLimit = 250.0;
    
    self.selecteColor = [UIColor redColor];
    
    return self;
}

#pragma mark -
#pragma mark - 懒加载
- (NSMutableArray*)fetchPhotoResult {
    if (!_fetchPhotoResult) {
        _fetchPhotoResult = [NSMutableArray array];
    }
    return _fetchPhotoResult;
}

- (void)setSelecteColor:(UIColor *)selecteColor {
    _selecteColor = selecteColor;
    
    // TODO: Done
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSInteger lastIndex = self.pPhotoFetchResult.count - 1;
    
    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height) animated:NO];
    
    if (lastIndex >= 0) {
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 安装子控件
    [self setupViews];
    
    // 背景 白色
    self.view.backgroundColor = [UIColor colorWithRed:(236.0/255) green:(236.0/255) blue:(244.0/255) alpha:1];
}

// 安装子控件
- (void)setupViews {
    
    UIColor *globalTextColor = DSGLOBAL.globalTextColor;
    UIImage *backArrowImage = DSGLOBAL.globalBackArrowImage;
    UIColor *backArrowColor = DSGLOBAL.globalBackArrowColor;
    
    
    UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItemButton.adjustsImageWhenDisabled = NO;
    leftItemButton.adjustsImageWhenHighlighted = NO;
    
    [leftItemButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_BACKINDICATOR] forState:UIControlStateNormal];
    if (backArrowImage) {
        
        [leftItemButton setImage:backArrowImage forState:UIControlStateNormal];
    }
    
    if (backArrowColor) {
        UIImage *image = leftItemButton.imageView.image;
        image =  [DSPhotosGlobal configureImage:image tintColor:backArrowColor];
        [leftItemButton setImage:image forState:UIControlStateNormal];
    }
    
    [leftItemButton setTitle:@"相册" forState:UIControlStateNormal];
    [leftItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (globalTextColor) {
        
        [leftItemButton setTitleColor:globalTextColor forState:UIControlStateNormal];
    }
    
    leftItemButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [leftItemButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [leftItemButton sizeToFit];
    [leftItemButton addTarget:self action:@selector(leftItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightItemButton setTitle:@"取消" forState:UIControlStateNormal];
    [rightItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (globalTextColor) {
        
        [rightItemButton setTitleColor:globalTextColor forState:UIControlStateNormal];
    }
    
    rightItemButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [rightItemButton sizeToFit];
    [rightItemButton addTarget:self action:@selector(rightItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = DSMinimumLineSpacing;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.alwaysBounceVertical = YES;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.contentInset = UIEdgeInsetsMake(DSPhotoCellMargin, DSPhotoCellMargin, 45.0+DSPhotoCellMargin, DSPhotoCellMargin);
    collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(DSPhotoCellMargin, 0, 45.0+DSPhotoCellMargin, 0);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:DSPhotosCell.class forCellWithReuseIdentifier:ID];
    
    collectionView.frame = self.view.bounds;
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    UIToolbar *bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-45.0, self.view.bounds.size.width, 45.0)];
    bottomToolbar.translucent = NO;
    bottomToolbar.layer.shadowOpacity = YES;
    bottomToolbar.layer.shadowOffset = CGSizeMake(0, -1);
    bottomToolbar.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:bottomToolbar];
    
    // 预览
    UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:ThemeColor_PC forState:UIControlStateNormal];
    [previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previewButton addTarget:self action:@selector(goPreviewClick:) forControlEvents:UIControlEventTouchUpInside];
    [previewButton sizeToFit];
    previewButton.enabled = NO;
    self.previewButton = previewButton;
    UIBarButtonItem *previewItem = [[UIBarButtonItem alloc] initWithCustomView:previewButton];
    
    UIButton *originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    originalPhotoButton.adjustsImageWhenDisabled = NO;
    originalPhotoButton.adjustsImageWhenHighlighted = NO;
    [originalPhotoButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_ORIGINALPHOTOUNSELECTED] forState:UIControlStateNormal];
    [originalPhotoButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_ORIGINALPHOTOSELECTED] forState:UIControlStateSelected];
    [originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
    [originalPhotoButton setTitleColor:self.selecteColor forState:UIControlStateNormal];
    originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:15];
    originalPhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [originalPhotoButton sizeToFit];
    CGRect frame = originalPhotoButton.frame;
    frame.size.width += 10;
    originalPhotoButton.frame = frame;
    [originalPhotoButton addTarget:self action:@selector(originalPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.originalPhotoButton = originalPhotoButton;
    
    UIBarButtonItem *originalPhotoItem = [[UIBarButtonItem alloc] initWithCustomView:originalPhotoButton];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *title = @"确定";
    if (self.doneTitle) title = self.doneTitle;
    [doneButton setTitle:title forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.backgroundColor = ThemeColor_PC;
    doneButton.frame = CGRectMake(0, 0, 90, 35.0);
    doneButton.layer.cornerRadius = 4;
    doneButton.layer.masksToBounds = YES;
    [doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton = doneButton;
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    NSMutableArray *items = @[previewItem,flexibleItem,doneItem].mutableCopy;
    
    if (self.showOriginalPhotoButton) [items insertObject:originalPhotoItem atIndex:1];
    
    [bottomToolbar setItems:items];
    
    [self updateTitlte];
    
}

- (void)leftItemAction:(UIButton *)btn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemAction:(UIButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// 完成
- (void)doneClick {
    
    if (self.selectedAssets.count < self.minimumLimit) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
            
            [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeLessThanMinimumLimit];
        }
        
        return;
    }
    
    // 统一返回
    [self selectDonePhotoWithPhotoModels];
    
}

- (void)goPreviewClick:(DSPreviewButton*)previewButton {
    
    if (!previewButton.enabled) return;
    
    DSPhotoModel *photoModel = self.selectedAssets.firstObject;
    
    if (photoModel.type == DSPhotoModelTypeVideo) {
        
        DSVideoController *videoController = [[DSVideoController alloc] init];
        videoController.model = photoModel;
        [self.navigationController pushViewController:videoController animated:YES];
        return;
    }
    
    // 浏览图片
    [self browerWithPhots:self.selectedAssets index:0];
}

- (void)originalPhotoAction:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    [self updateOriginalPhotoStatus];
}

- (void)updateOriginalPhotoStatus {
    
    if (self.originalPhotoButton.selected && self.selectedAssets.count > 0) {
        
        __block NSUInteger dataLength = 0;
        
        void(^imageDataBlock)() = ^{
            
            for (DSPhotoModel *photoModel in self.selectedAssets) {
                
                dataLength += photoModel.imageData.length;
            }
            
            NSString *bytes = [self getBytesFromDataLength:dataLength];
            
            bytes = [NSString stringWithFormat:@"原图(%@)",bytes];
            [self.originalPhotoButton setTitle:bytes forState:UIControlStateNormal];
            [self.originalPhotoButton sizeToFit];
            CGRect frame = self.originalPhotoButton.frame;
            frame.size.width += 10;
            self.originalPhotoButton.frame = frame;
            
        };
        
        NSMutableArray *noImageDatas = [NSMutableArray array];
        
        [self.selectedAssets enumerateObjectsUsingBlock:^(DSPhotoModel *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (!photoModel.imageData) [noImageDatas addObject:photoModel];
            
        }];
        
        if (noImageDatas.count == 0) imageDataBlock();
        
        __block NSUInteger noImageDatasCount = noImageDatas.count;
        
        [noImageDatas enumerateObjectsUsingBlock:^(DSPhotoModel *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [[PHImageManager defaultManager] requestImageDataForAsset:photoModel.mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                noImageDatasCount--;
                
                photoModel.imageData = imageData;
                photoModel.dataUTI = dataUTI;
                photoModel.info = info;
                
                if (noImageDatasCount == 0) imageDataBlock();
                
            }];
        }];
        
    }else {
        
        [self.originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
        
        [self.originalPhotoButton sizeToFit];
        CGRect frame = self.originalPhotoButton.frame;
        frame.size.width += 10;
        self.originalPhotoButton.frame = frame;
        
    }
}

/** 更新标题 */
- (void)updateTitlte {
    
    if (self.maximumLimit != 1) {
        
        NSString *count = self.selectedAssets.count > 0 ? [NSString stringWithFormat:@"(%zd)",self.selectedAssets.count]: @"";
        
        if (!_doneTitle) _doneTitle = @"确定";
        NSString *title = [NSString stringWithFormat:@"%@%@", _doneTitle,count];
        [self.doneButton setTitle:title forState:UIControlStateNormal];
        
    }
    
    self.previewButton.enabled = (self.selectedAssets.count > 0);
    
    [self updateOriginalPhotoStatus];
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}




- (void)setPPhotoFetchResult:(PHFetchResult *)pPhotoFetchResult {
    _pPhotoFetchResult = pPhotoFetchResult;
    
    // 移除当前所有的资源
    [self.fetchPhotoResult removeAllObjects];
    
    // 将资源 PHAsset 转成 DSPhotoMode 对象
    for (NSInteger i=0; i<pPhotoFetchResult.count; i++) {
        PHAsset *mAsset = pPhotoFetchResult[i];
        
        DSPhotoModel* photoMode = [DSPhotoModel photoWithAsset:mAsset];
        // 添加到哦数组
        
        for (DSPhotoModel *photoModel in self.selectedAssets) {
            
            if ([photoMode isEqual:photoModel]) {
                
                photoMode = photoModel;
                break;
            }
        }
        
        [self.fetchPhotoResult addObject:photoMode];
    }
    
    // 到这里 self.fetchPhotoResult 是当前相册中的图片数据 (DSPhotoMode)
    
    
    // 接下来处理选中效果: 第一次进来的时候可能会带有已选择的图片进入,要标明为已经选中的状态,防止重复选择.
    if (self.recordFirst) {
        self.recordFirst = NO;
        
        for (DSPhotoModel* seletedMode in self.photos) {
            if ([seletedMode isKindOfClass:[DSPhotoModel class]] && ![self.selectedAssets containsObject:seletedMode]) {
                
                if (seletedMode.curSelectedIndex != -1) {
                    
                    seletedMode.curSelectedIndex = self.selectedAssets.count+1;
                }
                
                [self.selectedAssets addObject:seletedMode];
            }
        }
    }
    
    // 让 self.selectedAssets 中的数据与 self.fetchPhotoResult 中的数据 对应
    for (NSInteger i=0; i<self.selectedAssets.count; i++) {
        DSPhotoModel* selectedMode = self.selectedAssets[i];
        
        for (NSInteger j=0; j<self.fetchPhotoResult.count; j++) {
            DSPhotoModel* photoMode = self.fetchPhotoResult[j];
            if ([selectedMode isEqual:photoMode]) {
                // 直接替换成选中的那个对象
                [self.fetchPhotoResult replaceObjectAtIndex:j withObject:selectedMode];
            }
        }
    }
    //    }
    
    [self.collectionView reloadData];
    
}


#pragma mark -
#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = self.canTakePicture?1:0;
    count += self.fetchPhotoResult.count;
    return count;
}

// 定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [DSPhotosCommon epcAssetGridCellSize];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger item = indexPath.item;
    
    DSPhotosCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if (self.canTakePicture) {
        if (item == 0) {
            
            // 有拍照功能, 则第一个cell显示拍照
            cell.photoModel = nil;
            cell.delegate = nil;
            return cell;
        }
        
        cell.photoModel = self.fetchPhotoResult[item-1];
        
    } else {
        cell.photoModel = self.fetchPhotoResult[item];
    }
    
    cell.delegate = self;
    
    cell.selecteColor = self.selecteColor;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    DSPhotosCell* cell = (DSPhotosCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    if (!cell.photoModel) {
//        // 拍照
//        [self p_takePhoto];
//        return;
//    }
//    
//    // 查看图片
//    NSUInteger item = indexPath.item;
//    if (self.canTakePicture) {
//        item -= 1;
//    }
//    
//    [self browerWithPhots:self.fetchPhotoResult index:item];
}

#pragma mark - DSBrowserControllerDelegate
- (void)browserController:(DSBrowserController *)browserController checkOriginalPhotoButtonStatus:(BOOL)status {
    
    self.originalPhotoButton.selected = status;
    
    [self updateOriginalPhotoStatus];
}

- (void)photosProtocol:(DSBrowserController *)photosProtocol didSelectPhotoAtIndex:(NSInteger)index_ photoModel:(DSPhotoModel *)photoModel {
    
    NSInteger indexx = [self.fetchPhotoResult indexOfObject:photoModel];
    
    [self.selectedAssets addObject:photoModel];
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:(indexx + (self.canTakePicture?1:0)) inSection:0]]];
    [self updateOriginalPhotoStatus];
}

- (void)photosProtocol:(DSBrowserController *)photosProtocol didDeselectPhotoAtIndex:(NSInteger)index photoModel:(DSPhotoModel *)photoModel {
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSInteger newIndex = [self.fetchPhotoResult indexOfObject:photoModel];
    
    if (self.canTakePicture) newIndex = newIndex + 1;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:newIndex inSection:0];
    
    [indexPaths addObject:indexPath];
    
    for (NSInteger i = photoModel.curSelectedIndex; i < self.selectedAssets.count; i ++) {
        
        DSPhotoModel *model = self.selectedAssets[i];
        model.curSelectedIndex = i;
        NSUInteger item = [self.fetchPhotoResult indexOfObject:model];
        indexPath = [NSIndexPath indexPathForItem:(item + (self.canTakePicture?1:0)) inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.selectedAssets enumerateObjectsUsingBlock:^(DSPhotoModel * _Nonnull model, NSUInteger index, BOOL * _Nonnull stop) {
        
        if ([photoModel.mAsset.localIdentifier isEqualToString:model.mAsset.localIdentifier]) {
            
            [self.selectedAssets removeObject:photoModel];
            *stop = YES;
        }
        
    }];
    
    photoModel.curSelectedIndex = 0;
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    [self updateOriginalPhotoStatus];
    [self updateTitlte];
}

- (void)photosProtocol:(DSBrowserController *)photosProtocol selectDonePhotoWithPhotoModels:(NSArray<DSPhotoModel *> *)photoModels {
    
    if (!photosProtocol.canSelectCurrentWhenNoSelect) {
        
        if (self.selectedAssets.count < self.minimumLimit) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeLessThanMinimumLimit];
            }
            
            
            return;
        }
    }
    
    // 统一返回
    [self selectDonePhotoWithPhotoModels];
}

// 打开相机的完整流程
- (void)p_takePhoto {
    [[DSTakePhotoManager sharedInstance] takePhotoWithSourceVC:self backAssetBlock:^(DSPhotoModel *photoModel) {
        if (!photoModel) {
            return ;
        }
        if (self.maximumLimit == 1) {
            // 这种情况,就把已经选中的从selectedAssets中都移除
            // 遍历，改变状态
            for (DSPhotoModel* photoMode in self.selectedAssets) {
                photoMode.DSSelected = NO;
                photoMode.curSelectedIndex = 0;
            }
            // 移除
            [self.selectedAssets removeAllObjects];
        }
        
        photoModel.DSSelected = YES;
        photoModel.curSelectedIndex = self.selectedAssets.count+1;
        [self.selectedAssets addObject:photoModel];
        
        [self.fetchPhotoResult insertObject:photoModel atIndex:0];
        
        // 更新 title
        [self updateTitlte];
        // 刷新
        [self.collectionView reloadData];
    }];
}

#pragma mark -
#pragma mark - DSPhotosCellDelegate
- (BOOL)photosProtocol:(DSPhotosCell *)photosProtocol willSelectPhotoModel:(DSPhotoModel *)photoModel {
    
    if (photoModel.curSelectedIndex != 0 || self.selectedAssets.count == 0) return YES;
    //如果选了图片或者视频就不能再选视频了
    if (photoModel.type == DSPhotoModelTypeVideo) {
        
        DSPhotoModel *firstModel = self.selectedAssets.firstObject;
        
        if (firstModel.type == DSPhotoModelTypeImage) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeImageAndVideoSimultaneously];
            }
            
            return NO;
        }
        
        if (firstModel.type == DSPhotoModelTypeVideo) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeMoreThanOneVideo];
            }
            
            return NO;
        }
        
        return YES;
    }
    
    if (photoModel.type == DSPhotoModelTypeImage) {
        
        DSPhotoModel *lastModel = self.selectedAssets.lastObject;
        if (lastModel.type == DSPhotoModelTypeVideo) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeImageAndVideoSimultaneously];
            }
            return NO;
        }
        
        if (self.selectedAssets.count >= self.maximumLimit && _maximumLimit != 1) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeMoreThanMaximumLimit];
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)photosProtocol:(DSPhotosCell *)photosProtocol didSelectPhotoModel:(DSPhotoModel *)photoModel {
    
    if (!photoModel) return;
    // 说明 cell 被允许选中
    //    cell.photoMode.DSSelected = !cell.photoMode.DSSelected;
    
    //对于_maximumLimit = 1的单独处理，不需要显示数字
    if (_maximumLimit == 1) {
        
        DSPhotoModel *oldModel;
        
        if (self.selectedAssets.count > 0 ) {
            
            oldModel = self.selectedAssets.firstObject;
            
            NSInteger oldIndex = [self.fetchPhotoResult indexOfObject:oldModel];
            NSIndexPath* oldIndexPath = [NSIndexPath indexPathForItem:oldIndex inSection:0];
            
            if ([oldModel isEqual:photoModel]) {
                
                if (oldModel.curSelectedIndex == -1) {
                    
                    photoModel.curSelectedIndex = 0;
                    
                    [self.selectedAssets removeObject:oldModel];
                    
                }
                
                
            }else {
                
                oldModel.curSelectedIndex = 0;
                
                [self.selectedAssets removeObject:oldModel];
                
            }
            
            if (oldIndexPath) {
                
                [self.collectionView reloadItemsAtIndexPaths:@[oldIndexPath]];
            }
            
        }
        
        // 刷新这个cell
        NSInteger index_ = [self.fetchPhotoResult indexOfObject:photoModel];
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index_ inSection:0];
        
        if (![oldModel isEqual:photoModel]) {
            
            photoModel.curSelectedIndex = -1;
            // 添加到
            [self.selectedAssets addObject:photoModel];
            
            if (indexPath) {
                
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
            
        }
        
        
    }else {
        
        if (photoModel.curSelectedIndex == 0) {
            
            // 刷新这个cell
            NSInteger index_ = [self.fetchPhotoResult indexOfObject:photoModel];
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index_ inSection:0];
            
            // 添加到
            [self.selectedAssets addObject:photoModel];
            
            photoModel.curSelectedIndex = self.selectedAssets.count;
            
            
            if (indexPath) {
                
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
            
        }else {
            
            if ([self.selectedAssets containsObject:photoModel]) {
                
                
                NSInteger index_ = [self.fetchPhotoResult indexOfObject:photoModel];
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index_ inSection:0];
                
                // 清空
                photoModel.curSelectedIndex = 0;
                // 刷新这个cell
                NSMutableArray* indexPaths = [NSMutableArray array];
                
                if (indexPath) {
                    
                    [indexPaths addObject:indexPath];
                }
                
                // 先记录当前图片是选中的第几张
                NSUInteger currentSelectedIndex = [self.selectedAssets indexOfObject:photoModel];
                
                [self.selectedAssets removeObject:photoModel];
                
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(currentSelectedIndex, self.selectedAssets.count - currentSelectedIndex)];
                
                [self.selectedAssets enumerateObjectsAtIndexes:indexSet options:NSEnumerationConcurrent usingBlock:^(DSPhotoModel* photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    photoModel.curSelectedIndex = idx+1;
                    
                    NSUInteger item = [self.fetchPhotoResult indexOfObject:photoModel];
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item + (self.canTakePicture?1:0) inSection:0];
                    
                    // 判断是否在可视范围
                    if ([self.collectionView cellForItemAtIndexPath:indexPath]) {
                        
                        [indexPaths addObject:indexPath];
                    }
                    
                }];
                
                if (indexPaths.count > 0) {
                    
                    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
                }
            }
        }
        
    }
    
    // 更新标题
    [self updateTitlte];
}

#pragma mark -
#pragma mark - 查看图片
- (void)browerWithPhots:(NSMutableArray*)photos index:(NSUInteger)currentIndex {
    
    DSBrowserController* browserVC = [[DSBrowserController alloc] init];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerAppearanceForPhotoController:)]) {
        
        browserVC = [self.delegate browserControllerAppearanceForPhotoController:self];
    }
    browserVC.maximumLimit = self.maximumLimit;
    browserVC.minimumLimit = self.minimumLimit;
    browserVC.selectOriginalPhoto = self.originalPhotoButton.selected;
    browserVC.selecteColor = self.selecteColor;
    browserVC.showOriginalPhotoButton = self.showOriginalPhotoButton;
    browserVC.delegate =  self;
    browserVC.selectedAssets = self.selectedAssets;
    browserVC.currentIndex = currentIndex;
    browserVC.fetchPhotoResult = photos.copy;
    [self.navigationController pushViewController:browserVC animated:YES];
}

- (void)photosProtocol:(id)photosProtocol selectPhotosTipWithTipType:(DSPhotosProtocolTipType)tipType {
    
    switch (tipType) {
        case DSPhotosProtocolTipTypeMoreThanMaximumLimit: {
            
            BOOL can = self.selectedAssets.count < self.maximumLimit;
            if (can) {
                
                return;
            }
            
            // 提示操作
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeMoreThanMaximumLimit];
            }
            
            break;
        }
        default:
            break;
    }
}


- (BOOL)photosProtocol:(DSBrowserController*)photosProtocol willSelectPhotoAtIndex:(NSInteger)index photoModel:(DSPhotoModel *)photoModel {
    
    return (self.selectedAssets.count < self.maximumLimit);
}

/**
 统一处理返回
 */
- (void)selectDonePhotoWithPhotoModels {
    
    if (self.refuseRepeatOK) {
        return;
    }
    
    self.refuseRepeatOK = YES;
    
    [self didSelctedPhotosLoadingStatus:YES];
    
    // 使用 static 才能在 block 中修改值
    static NSInteger imageCount = 0;
    
    // 很有意义的设置
    imageCount = self.selectedAssets.count;
    
    if (self.selectedAssets.count == 1) {
        
        DSPhotoModel *photoModel = self.selectedAssets.firstObject;
        
        if (photoModel.type == DSPhotoModelTypeVideo) {

            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestExportSessionForVideo:photoModel.mAsset options:options exportPreset:AVAssetExportPresetMediumQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                
                AVURLAsset *asset = (AVURLAsset *)exportSession.asset;
                NSURL *assetURL = asset.URL;
                
                photoModel.fileName = assetURL.lastPathComponent;
                
                NSDateFormatter *formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                //读取到沙盒中
                NSString *videoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/output-%@.%@", [formater stringFromDate:[NSDate date]],[assetURL lastPathComponent]];
                
                //设置导出地址
                exportSession.outputURL = [NSURL fileURLWithPath: videoPath];
                //设置导出文件类型
                exportSession.outputFileType = [self chooseVideoType:[assetURL pathExtension]];
                //导出
                [exportSession exportAsynchronouslyWithCompletionHandler:^{
                    
                    if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                        //转成NSData用来上传，使用dataWithContentsOfFile：options：error方法并不会把数据全部加载进内存里面,而是使用内存映射的方式获取NSData。不会导致内存暴增而导致崩溃。
                        NSData *videoData = [NSData dataWithContentsOfFile : videoPath options : NSDataReadingMappedIfSafe error : nil];
                        
                        photoModel.videoData = videoData;
//                        photoModel.dataUTI = exportSession.outputFileType;
                        photoModel.info = info;
                        
                        // 说明获取原始图片结束了
                        [self didSelctedPhotosLoadingStatus:NO];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectDonePhotoWithPhotoModels:)]) {
                            
                            [self.delegate photosProtocol:self selectDonePhotoWithPhotoModels:self.selectedAssets];
                        }
                    }
                }];
            }];
        
            return;
        }
    }
    
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    for (DSPhotoModel* photoModel in self.selectedAssets) {
        
        void (^exceptionBlock)() = ^() {
            
            [[PHImageManager defaultManager] requestImageForAsset:photoModel.mAsset targetSize:CGSizeMake(photoModel.mAsset.pixelWidth, photoModel.mAsset.pixelHeight) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                photoModel.image = result;
                
                NSData *imageData;
                //压缩图片
                if ((self.originalPhotoButton && !self.originalPhotoButton.selected) || self.targetCompression != 0) {
                    
                    imageData = [DSPhotosCommon imageCompressForSize:result targetPx:self.targetCompression];
                }
                
                photoModel.imageData = imageData;
                //                photoModel.dataUTI = dataUTI;
                photoModel.info = info;
                
                imageCount--;
                if (imageCount == 0) {
                    // 说明获取原始图片结束了
                    [self didSelctedPhotosLoadingStatus:NO];
                    
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectDonePhotoWithPhotoModels:)]) {
                        
                        [self.delegate photosProtocol:self selectDonePhotoWithPhotoModels:self.selectedAssets];
                    }
                    self.refuseRepeatOK = NO;
                }
            }];
        };
        [[PHImageManager defaultManager] requestImageDataForAsset:photoModel.mAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            if (imageData)
            {
                if (self.selectedAssets.count == 1) {
                    
                    if (orientation != UIImageOrientationUp) {
                        UIImage* image = [UIImage imageWithData:imageData];
                        image = [UIImage fixOrientation_DSPhoto:image];
                        imageData = UIImageJPEGRepresentation(image, DSCompressionQuality);
                        
                        photoModel.image = image;
                        
                    } else {
                        
                        photoModel.image = [UIImage imageWithData:imageData];
                        
                    }
                    
                }else {
                    
                    
                    photoModel.image = [UIImage imageWithData:imageData];
                }
                
                //图片稍微大点就传不过去，只要先压缩了
                
                
                //            if (self.targetCompression == 0) {
                //
                //                self.targetCompression = 1024;
                //            }
                
                //            imageData = [DSPhotosConst imageCompressForSize:compressImage targetPx:self.targetCompression];
                
                //压缩图片
                if ((self.originalPhotoButton && !self.originalPhotoButton.selected) || self.targetCompression != 0) {
                    
                    UIImage *compressImage = [UIImage imageWithData:imageData];
                    imageData = [DSPhotosCommon imageCompressForSize:compressImage targetPx:self.targetCompression];
                }
                
                photoModel.imageData = imageData;
                photoModel.dataUTI = dataUTI;
                photoModel.info = info;
                
                imageCount--;
                if (imageCount == 0) {
                    // 说明获取原始图片结束了
                    [self didSelctedPhotosLoadingStatus:NO];
                    
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectDonePhotoWithPhotoModels:)]) {
                        
                        [self.delegate photosProtocol:self selectDonePhotoWithPhotoModels:self.selectedAssets];
                    }
                    
                    
                    self.refuseRepeatOK = NO;
                }
                
            } else {
                exceptionBlock();
            }
            
        }];
        //        NSUInteger pixelWidth =  photoModel.mAsset.pixelWidth;
        //        NSUInteger pixelHeight =  photoModel.mAsset.pixelHeight;
        
        //        [[PHImageManager defaultManager] requestImageForAsset:photoModel.mAsset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        //
        //            if ([[info valueForKey:@"PHImageResultIsDegradedKey"]integerValue]==0){
        //                // Do something with the FULL SIZED image
        //                photoModel.image = result;
        //                imageCount--;
        //
        //
        //            }
        //            
        //        }];
    }
}

/**
 选择图片加载大图的过程中,要做的操作.一般是用于调用加载框
 
 @param start YES 开始   NO 结束
 */
- (void)didSelctedPhotosLoadingStatus:(BOOL)start {
    if (start) {
        // 开始
    } else {
        // 结束
    }
}

- (NSString *)chooseVideoType:(NSString *)videoType {
    
    videoType = videoType.uppercaseString;
    
    if ([videoType isEqualToString:@"MOV"]) {
        return AVFileTypeQuickTimeMovie;
    }else if ([videoType isEqualToString:@"MP4"]) {
        return AVFileTypeMPEG4;

    }
    return AVFileTypeMPEG4;
}

@end
