//
//  DSBrowserController.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSBrowserController.h"
#import "DSBrowserCell.h"
#import "DSPhotosCommon.h"
#import "DSPhotoModel.h"
#import "DSSelectedButton.h"
#import <Photos/Photos.h>
#import "DSPreviewButton.h"
#import "DSPhotosGlobal.h"

static NSString *const ReuseIdentifier = @"DSBrowserCell";

#define kBarAlpha (0.7)

@interface DSBrowserController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate> {
    
    BOOL _isBarHidden;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) DSSelectedButton *selectedButton;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UIToolbar *bottomToolbar;

@property (nonatomic, strong) NSMutableArray <DSPhotoModel *>* seletedPhotoModels;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *>* indexPaths;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UINavigationBar *navigationBar;

@property (nonatomic, weak) UIButton *originalPhotoButton;

@property (nonatomic, weak) UINavigationItem *naviItem;

/**
 为了解决 进入控制空 就会调用 scrollViewDidScroll:的尴尬
 */
@property (nonatomic, assign) BOOL draged;

@end

@implementation DSBrowserController

#pragma mark - LazyLoad
- (NSMutableArray<DSPhotoModel *> *)seletedPhotoModels {
    
    if (!_seletedPhotoModels) {
        
        _seletedPhotoModels = [NSMutableArray array];
        [_seletedPhotoModels addObjectsFromArray:self.selectedAssets];
    }
    return _seletedPhotoModels;
}

- (NSMutableArray<NSIndexPath *> *)indexPaths {
    
    if (!_indexPaths) {
        
        _indexPaths = [NSMutableArray array];
    }
    return _indexPaths;
}

#pragma mark - CycleLife
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (UIColor *)selecteColor {
    
    if (!_selecteColor) {
        
        _selecteColor = [UIColor redColor];
    }
    return _selecteColor;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * (UI_SCREEN_WIDTH_PC + DSBroswerMargin), 0) animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11, *)) {
        
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        
    }else {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.minimumLimit = 1;
    
    [self createSubviews];
    [self createNavigationBar];
    [self createBottomToolbar];
    [self updateOriginalPhotoStatus];
    
    DSPhotoModel *model = _fetchPhotoResult[_currentIndex];
    _selectedButton.curSelectedIndex = model.curSelectedIndex;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTapGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:singleTapGestureRecognizer];
}

- (void)createNavigationBar {
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    navigationBar.barStyle = UIBarStyleBlack;
    navigationBar.subviews.firstObject.alpha = kBarAlpha;
    navigationBar.tintColor = [UIColor whiteColor];
    navigationBar.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH_PC, 64);
    [self.view addSubview:self.navigationBar = navigationBar];
    
    UINavigationItem *navigatonItem = [[UINavigationItem alloc] init];
    self.naviItem = navigatonItem;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.adjustsImageWhenDisabled = NO;
    backButton.adjustsImageWhenHighlighted = NO;
    
    UIImage *backArrowImage = DSGLOBAL.globalBackArrowImage;
    UIColor *backArrowColor = DSGLOBAL.globalBackArrowColor;
    
    UIImage *backIndicatorImage = [UIImage imageNamed:EPC_IMG_PHOTO_BACKINDICATOR];
    if (backIndicatorImage) {
        
        [backButton setImage:backIndicatorImage forState:UIControlStateNormal];
    }
    
    if (backArrowImage) {
        
        [backButton setImage:backArrowImage forState:UIControlStateNormal];
    }
    
    if (backArrowColor) {
        
        UIImage *image = backButton.imageView.image;
        
        image = [DSPhotosGlobal configureImage:image tintColor:backArrowColor];
        [backButton setImage:image forState:UIControlStateNormal];
    }
    
    if (self.backTitleArrtibuteText) {
        
        [backButton setAttributedTitle:self.backTitleArrtibuteText forState:UIControlStateNormal];
        
    }
    
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    DSSelectedButton *selectedButton = [DSSelectedButton buttonWithType:UIButtonTypeCustom];
    selectedButton.frame = CGRectMake(0, 0, 30, 30);
    selectedButton.backgroundColor = [UIColor clearColor];
    [selectedButton addTarget:self action:@selector(selectedBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    selectedButton.selecteColor = ThemeColor_PC;
    self.selectedButton = selectedButton;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:selectedButton];
    
    [navigatonItem setLeftBarButtonItem:leftItem];
    [navigatonItem setRightBarButtonItem:rightItem];
    
    [navigationBar setItems:@[navigatonItem]];
}

- (void)backAction:(UIButton*)btn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBottomToolbar {
    
    UIToolbar *bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49)];
    bottomToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    bottomToolbar.barStyle = UIBarStyleBlack;
    bottomToolbar.subviews.firstObject.alpha = kBarAlpha;
    
    //    [self.view addSubview:self.bottomToolbar = bottomToolbar];
    
    UIButton *originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    originalPhotoButton.adjustsImageWhenDisabled = NO;
    originalPhotoButton.adjustsImageWhenHighlighted = NO;
    [originalPhotoButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_ORIGINALPHOTOUNSELECTED] forState:UIControlStateNormal];
    [originalPhotoButton setImage:[UIImage imageNamed:EPC_IMG_PHOTO_ORIGINALPHOTOSELECTED] forState:UIControlStateSelected];
    [originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
    [originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:15];
    originalPhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    originalPhotoButton.selected = self.selectOriginalPhoto;
    [originalPhotoButton sizeToFit];
    CGRect frame = originalPhotoButton.frame;
    frame.size.width += 10;
    originalPhotoButton.frame = frame;
    [originalPhotoButton addTarget:self action:@selector(originalPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    self.originalPhotoButton = originalPhotoButton;
    
    UIBarButtonItem *originalPhotoItem = [[UIBarButtonItem alloc] initWithCustomView:originalPhotoButton];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *bottomTitle = @"确定";
    if (self.doneTitle) bottomTitle = self.doneTitle;
    [doneButton setTitle:bottomTitle forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
    doneButton.backgroundColor = ThemeColor_PC;
    doneButton.frame = CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49);
    doneButton.layer.shadowOpacity = YES;
    doneButton.layer.shadowOffset = CGSizeMake(0, -1);
    doneButton.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //    doneButton.layer.sh
    //    doneButton.selecteColor = [UIColor whiteColor];
    //    doneButton.titleBackgroundColor = self.selecteColor;
    [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneButton = doneButton];
    
    //    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    //
    //    NSMutableArray *items = @[doneItem].mutableCopy;
    //
    //    if (self.showOriginalPhotoButton) [items insertObject:originalPhotoItem atIndex:0];
    //
    //    [bottomToolbar setItems:items];
    
    [self updateDoneButtonStatus];
    
}

- (void)createSubviews {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = DSBroswerMargin;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, DSBroswerHalfMargin, 0, DSBroswerHalfMargin);
    
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    flowLayout.itemSize = mainScreenBounds.size;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-DSBroswerHalfMargin, 0, UI_SCREEN_WIDTH_PC + DSBroswerMargin, UI_SCREEN_HEIGHT_PC) collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerClass:[DSBrowserCell class] forCellWithReuseIdentifier:ReuseIdentifier];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.backgroundColor = RGB_PC(240, 240, 246);
    collectionView.contentSize = CGSizeMake(self.fetchPhotoResult.count * (UI_SCREEN_WIDTH_PC + DSBroswerMargin), 0);
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    self.flowLayout = flowLayout;
}

#pragma mark - UpdateData
- (void)updateOriginalPhotoStatus {
    
    if (self.originalPhotoButton.selected && self.seletedPhotoModels.count > 0) {
        
        __block NSUInteger dataLength = 0;
        
        void(^imageDataBlock)() = ^{
            
            for (DSPhotoModel *photoModel in self.seletedPhotoModels) {
                
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
        
        [self.seletedPhotoModels enumerateObjectsUsingBlock:^(DSPhotoModel *photoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
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

#pragma mark - Target Action
- (void)originalPhotoAction:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    
    [self updateOriginalPhotoStatus];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserController:checkOriginalPhotoButtonStatus:)]) {
        
        [self.delegate browserController:self checkOriginalPhotoButtonStatus:btn.isSelected];
    }
}

- (void)selectedBtnAction:(DSSelectedButton *)btn {
    
    DSPhotoModel *model = _fetchPhotoResult[_currentIndex];
    NSInteger index_ = _currentIndex;
    
    [self.indexPaths removeAllObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index_ inSection:0];
    [self.indexPaths addObject:indexPath];
    
    if (self.maximumLimit == 1) {
        
        if (self.seletedPhotoModels.count > 0 ) {
            
            model.curSelectedIndex = 0;
            btn.curSelectedIndex = 0;
            [self.seletedPhotoModels removeObject:model];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didDeselectPhotoAtIndex:photoModel:)]) {
                
                [self.delegate photosProtocol:self didDeselectPhotoAtIndex:index_ photoModel:model];
            }
            
        }else {
            
            model.curSelectedIndex = -1;
            [btn setCurSelectedIndex:-1 animated:YES];
            [self.seletedPhotoModels addObject:model];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didSelectPhotoAtIndex:photoModel:)]) {
                
                [self.delegate photosProtocol:self didSelectPhotoAtIndex:index_ photoModel:model];
            }
            
            
        }
        
        
    }else {
        
        if (model.curSelectedIndex == 0) {
            
            BOOL isCanNextStep = YES;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
                
                [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeMoreThanMaximumLimit];
                
                isCanNextStep = NO;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:willSelectPhotoAtIndex:photoModel:)]) {
                
                isCanNextStep = [self.delegate photosProtocol:self willSelectPhotoAtIndex:index_ photoModel:model];
            }
            
            if (isCanNextStep) {
                
                if (![self.seletedPhotoModels containsObject:model]) {
                    
                    [self.seletedPhotoModels addObject:model];
                }
                
                model.curSelectedIndex = self.seletedPhotoModels.count;
                
                [btn setCurSelectedIndex:self.seletedPhotoModels.count animated:YES];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didSelectPhotoAtIndex:photoModel:)]) {
                    
                    [self.delegate photosProtocol:self didSelectPhotoAtIndex:index_ photoModel:model];
                }
            }
            
        }else {
            
            
            for (NSInteger i = model.curSelectedIndex; i < self.seletedPhotoModels.count; i ++) {
                
                DSPhotoModel *photoModel = self.seletedPhotoModels[i];
                photoModel.curSelectedIndex -= 1;
                indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self.indexPaths addObject:indexPath];
            }
            
            [self.seletedPhotoModels enumerateObjectsUsingBlock:^(DSPhotoModel * _Nonnull photoModel, NSUInteger index, BOOL * _Nonnull stop) {
                
                if ([photoModel.mAsset.localIdentifier isEqualToString:model.mAsset.localIdentifier]) {
                    
                    [self.seletedPhotoModels removeObject:model];
                    *stop = YES;
                }
                
            }];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didDeselectPhotoAtIndex:photoModel:)]) {
                
                [self.delegate photosProtocol:self didDeselectPhotoAtIndex:index_ photoModel:model];
            }
            
            model.curSelectedIndex = 0;
            btn.curSelectedIndex = 0;
        }
        
        
    }
    
    [UIView performWithoutAnimation:^{
        
        [self.collectionView reloadItemsAtIndexPaths:self.indexPaths];
    }];
    
    [self updateOriginalPhotoStatus];
    
    [self updateDoneButtonStatus];
}

- (void)updateDoneButtonStatus {
    
    NSString *title = (self.seletedPhotoModels.count > 0)?[NSString stringWithFormat:@"(%zd)",self.seletedPhotoModels.count]:@"";
    
    if (!_doneTitle) _doneTitle = @"确定";
    
    [self.doneButton setTitle:[NSString stringWithFormat:@"%@%@",_doneTitle,title] forState:UIControlStateNormal];
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

- (void)doneAction:(UIButton *)btn {
    
    if (self.selectedAssets.count < self.minimumLimit) return;
    
    if (_canSelectCurrentWhenNoSelect && self.seletedPhotoModels.count == 0) {
        
        DSPhotoModel *model = self.fetchPhotoResult[_currentIndex];
        [self.seletedPhotoModels addObject:model];
        model.curSelectedIndex = self.seletedPhotoModels.count;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:didSelectPhotoAtIndex:photoModel:)]) {
            
            [self.delegate photosProtocol:self didSelectPhotoAtIndex:_currentIndex photoModel:model];
        }
        
    }else if (self.seletedPhotoModels.count < self.minimumLimit) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectPhotosTipWithTipType:)]) {
            
            [self.delegate photosProtocol:self selectPhotosTipWithTipType:DSPhotosProtocolTipTypeLessThanMinimumLimit];
            return;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photosProtocol:selectDonePhotoWithPhotoModels:)]) {
        
        [self.delegate photosProtocol:self selectDonePhotoWithPhotoModels:self.seletedPhotoModels];
    }
}

- (void)singleTapAction:(UITapGestureRecognizer *)singleTap {
    
    _isBarHidden = !_isBarHidden;
    self.navigationBar.hidden = _isBarHidden;
    self.bottomToolbar.hidden = _isBarHidden;
    self.doneButton.hidden = _isBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
    
}

#pragma mark - 状态栏设置
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationNone;
}

- (BOOL)prefersStatusBarHidden {
    
    return _isBarHidden;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.draged) {
        // 说明没有手动的滑动过scrollView
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        return;
    }
    NSInteger index_ = (scrollView.contentOffset.x + (UI_SCREEN_WIDTH_PC + DSBroswerMargin)*0.5)/(UI_SCREEN_WIDTH_PC + DSBroswerMargin);
    
    //    self.naviItem.title = [NSString stringWithFormat:@"%zd/%zd",index_ + 1,_fetchPhotoResult.count];
    DSPhotoModel *model = _fetchPhotoResult[index_];
    _selectedButton.curSelectedIndex = model.curSelectedIndex;
    _currentIndex = index_;
}

// 开始手动的滑动 scrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.draged = YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _fetchPhotoResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DSBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DSBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.model = self.fetchPhotoResult[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(DSBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.zoomScale = 1;
}

#pragma mark - UIGestureRecognizerDelegate
//解决单击手势和双击手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//
//    self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//}

@end
