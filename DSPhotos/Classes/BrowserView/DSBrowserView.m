//
//  DSBrowserView.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSBrowserView.h"
#import "DSBrowserCell.h"
#import "DSPhotoModel.h"
#import "DSPhotosCommon.h"
#import "UIImageView+WebCache.h"

static NSString *const ReuseIdentifier = @"DSBrowserCell";

@interface DSBrowserView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

//当前索引
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) DSPhotoModel *currentModel;

//所有图片模型
@property (nonatomic, strong) NSMutableArray <DSPhotoModel *> *photoModels;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UICollectionView *collectionView;

/** 一开始触摸的点 */
@property (nonatomic, assign) CGPoint beginPoint;

/** 删除按钮 */
@property (nonatomic, strong) UIButton *deleteButton;

/** 假的imageview */
@property (nonatomic, strong) UIImageView *fakeImageView;
/** 帷幕视图，就是后面的黑色背景 */
@property (nonatomic, strong) UIView *backdropView;
/** 窗口 */
@property (nonatomic, strong) UIWindow *window;
/** 加载框 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/** 外部自定义的个辅助视图 */
@property (nonatomic, weak) UIView* accessoryView;

/** 是否显示了 */
@property (nonatomic, assign) BOOL isShow;

/** 图片的缩放数 */
@property (nonatomic, assign) CGFloat scale;

/** 是否可以平移 */
@property (nonatomic, assign) BOOL isCanPan;

@end



@implementation DSBrowserView

- (void)setUpSubviews {
    
    self.positon = BrowserTtilePositionTop;
    
    [self createSubviews];
    
    UITapGestureRecognizer *sigleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    sigleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:sigleTapGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    sigleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:longPressGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
}

#pragma mark - Lazy loading
- (UIWindow *)window {
    
    if (!_window) {
        
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (UIImageView *)fakeImageView {
    
    if (!_fakeImageView ) {
        
        _fakeImageView = [[UIImageView alloc] init];
        _fakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _fakeImageView.layer.masksToBounds = YES;
        _fakeImageView.backgroundColor = [UIColor blackColor];
    }
    
    return _fakeImageView;
}

- (UIView *)backdropView {
    
    if (!_backdropView) {
        
        _backdropView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backdropView.backgroundColor = [UIColor blackColor];
    }
    return _backdropView;
}

- (UIButton *)deleteButton {
    
    if (!_deleteButton) {
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 44, 20, 44, 44);
        
        NSString *imageName = (_deleteImageName) ? _deleteImageName:EPC_IMG_PHOTO_DELETE;
        [_deleteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        CGFloat y = 20;
        if (self.positon == BrowserTtilePositionBottom) {
            y = CGRectGetHeight(self.frame) - 44;
        }
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.frame), 44)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.center = CGPointMake(self.fakeImageView.bounds.size.width*0.5, self.fakeImageView.bounds.size.height*0.5);
        [self.fakeImageView addSubview:_indicatorView];
    }
    return _indicatorView;
    
}

#pragma mark - 初始化
+ (nonnull instancetype)browserViewWithPhotoModels:(nonnull NSArray <DSPhotoModel *>*)photoModels currentIndex:(NSInteger)currentIndex {
    
    DSBrowserView *instance = [[self alloc] init];
    [instance setUpSubviews];
    instance.photoModels = photoModels.mutableCopy;
    instance.currentIndex = currentIndex;
    instance.currentModel = photoModels[currentIndex];
    [instance.collectionView reloadData];
    return instance;
    
    
}

+ (nonnull instancetype)browserViewWithPhotoModel:(nonnull DSPhotoModel *)photoModel {
    
    return [self browserViewWithPhotoModels:@[photoModel] currentIndex:0];
}


+ (nonnull instancetype)browserViewWithImage:(nonnull UIImage *)image {
    
    DSPhotoModel *model = [[DSPhotoModel alloc] init];
    model.image = image;
    
    return [self browserViewWithPhotoModels:@[model] currentIndex:0];
    
}

+ (nonnull instancetype)browserViewWithImageUrlString:(nonnull NSString *)urlString {
    
    DSPhotoModel *model = [[DSPhotoModel alloc] init];
    model.imageURLString = urlString;
    return [self browserViewWithPhotoModels:@[model] currentIndex:0];
}

- (void)createSubviews {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = DSBroswerMargin;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, DSBroswerHalfMargin, 0, DSBroswerHalfMargin);
    
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    flowLayout.itemSize = mainScreenBounds.size;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-DSBroswerHalfMargin, 0, UI_SCREEN_WIDTH_PC + DSBroswerMargin, UI_SCREEN_HEIGHT_PC)collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.alwaysBounceHorizontal = YES;
    collectionView.backgroundColor = [UIColor blackColor];
    collectionView.contentSize = CGSizeMake(self.photoModels.count * (UI_SCREEN_WIDTH_PC + DSBroswerMargin), 0);
    [collectionView registerClass:[DSBrowserCell class] forCellWithReuseIdentifier:ReuseIdentifier];
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView setContentOffset:CGPointMake(self.currentIndex * (UI_SCREEN_WIDTH_PC + DSBroswerMargin), 0) animated:NO];
}

#pragma mark - TargetAction
- (void)singleTapAction:(UITapGestureRecognizer *)singleTap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserViewDidSingleTap:)]) {
        
        [self.delegate browserViewDidSingleTap:self];
    }
    
    if (self.deleteButton.superview) [self.deleteButton removeFromSuperview];
    if (self.titleLabel.superview) [self.titleLabel removeFromSuperview];
    
    DSPhotoModel *photoModel = _photoModels[_currentIndex];
    
    UIView *fromView;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:updatePhotoPositionWhenDeletePhotoModel:atIndex:)]) {
        
        fromView = [self.delegate browserView:self updatePhotoPositionWhenDeletePhotoModel:photoModel atIndex:_currentIndex];
    }
    
    if (!fromView) {
        
        fromView = photoModel.photoView;
    }
    
    CGRect originalFrame = CGRectZero;
    
    if (CGRectEqualToRect(fromView.superview.frame, self.window.frame)) {
        
        originalFrame = fromView.frame;
        
    } else {
        
        originalFrame = [fromView convertRect:fromView.bounds toView:self.window];
        
        CGRect intersectionRect = CGRectIntersection(self.window.bounds, originalFrame);
        
        if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
            //有点放大的效果
            originalFrame = CGRectInset(self.window.bounds, -50, -50);
        }
    }
    
    [self hideWithPhotoModel:photoModel originalFrame:originalFrame];
    
    _isShow = NO;
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:longPressActionWithPhotoModel:atIndex:)]) {
            
            DSPhotoModel *photoModel = _photoModels[_currentIndex];
            
            [self.delegate browserView:self longPressActionWithPhotoModel:photoModel atIndex:_currentIndex];
        }
 
    }
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan {
    
    CGPoint velocity = [pan velocityInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        if (velocity.y < 0) {
            
            _isCanPan = NO;
            return;
        }
        
        _isCanPan = YES;
        
        self.beginPoint = [pan locationInView:self];
        
        self.collectionView.hidden = YES;
        if (self.accessoryView) {
            self.accessoryView.hidden = YES;
        }
        if (self.deleteButton) {
            self.deleteButton.hidden = YES;
        }
        self.currentModel = _photoModels[_currentIndex];
        
        if (self.currentModel.image) {
            
            self.fakeImageView.image = self.currentModel.image;
            
        }else {
            
            UIImage *image;
            //就是一开始就加在出来图片了
            if (self.currentModel.thumbnailImage) {
                
                image = self.currentModel.thumbnailImage;
                
            }else {
                //没在去主动去获取加载的图片，要自己本地看一下有没有
                image = [SDImageCache.sharedImageCache imageFromCacheForKey:self.currentModel.thumbnailImageURLString];
                self.currentModel.thumbnailImage = image;
            }
            
            self.fakeImageView.image = image;
        }
        
        self.fakeImageView.frame = self.currentModel.imgFrame;
        
        self.backdropView.alpha = 1;
        [self.window addSubview:self.backdropView];
        [self.window addSubview:self.fakeImageView];
        
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint location = [pan locationInView:self];
        
        CGFloat distance = location.y - _beginPoint.y;
        
        NSLog(@"distance = %f",distance);
        
        CGPoint translation = [pan translationInView:self];
        [pan setTranslation:CGPointZero inView:self];
        
        
        self.fakeImageView.center = CGPointMake(self.fakeImageView.center.x + translation.x, self.fakeImageView.center.y + translation.y);
        
        self.scale = MIN(1, 1 - (distance)/1000);
        
        self.fakeImageView.frame = CGRectMake(self.fakeImageView.frame.origin.x, self.fakeImageView.frame.origin.y, self.currentModel.imgFrame.size.width * self.scale, self.currentModel.imgFrame.size.height * self.scale);
        
        self.backdropView.alpha = 1 - distance/200;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        
        if (!_isCanPan) return;
        
        if (self.scale < 1) {
            
            DSPhotoModel *photoModel = _photoModels[_currentIndex];
        
            UIView *fromView;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:updatePhotoPositionWhenDeletePhotoModel:atIndex:)]) {
                
                fromView = [self.delegate browserView:self updatePhotoPositionWhenDeletePhotoModel:photoModel atIndex:_currentIndex];
            }
            
            if (!fromView) {
                
                fromView = photoModel.photoView;
            }

            
            CGRect originalFrame = CGRectZero;
            
            if (CGRectEqualToRect(fromView.superview.frame, self.window.frame)) {
                
                originalFrame = fromView.frame;
                
            } else {
                
                originalFrame = [fromView convertRect:fromView.bounds toView:self.window];
                
                CGRect intersectionRect = CGRectIntersection(self.window.bounds, originalFrame);
                
                if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
                    //有点放大的效果
                    originalFrame = CGRectInset(self.window.bounds, -50, -50);
                }
            }
            
            
            [self.accessoryView removeFromSuperview];
            
            [UIView animateWithDuration:0.35 animations:^{
                
                self.backdropView.alpha = 0;
                
                self.fakeImageView.frame = originalFrame;
                
                if (CGRectEqualToRect(originalFrame, CGRectInset(self.window.bounds, -50, -50))) {
                    
                    self.fakeImageView.alpha = 0;
                }
                
            } completion:^(BOOL finished) {
                
                [self.backdropView removeFromSuperview];
                [self.fakeImageView removeFromSuperview];
                [self removeFromSuperview];
                self.fakeImageView = nil;
                self.backdropView = nil;
                self.indicatorView = nil;
                
                if (self.accessoryView) [self.accessoryView removeFromSuperview];
                
                self.isShow = NO;
                
            }];
            
            
        }else {
            
            [UIView animateWithDuration:0.35 animations:^{
                
                self.fakeImageView.frame = self.currentModel.imgFrame;
                
            } completion:^(BOOL finished) {
                
                self.collectionView.hidden = NO;
                if (self.accessoryView) {
                    self.accessoryView.hidden = NO;
                }
                if (self.deleteButton) {
                    self.deleteButton.hidden = NO;
                }
                
                [self.fakeImageView removeFromSuperview];
                [self.backdropView removeFromSuperview];
                
            }];
        }
    }
}

- (void)deleteButtonAction:(UIButton *)btn {
    
    DSPhotoModel *deleteModel = _photoModels[_currentIndex];
    
    if (![_photoModels containsObject:deleteModel]) return;
    
    [_photoModels removeObject:deleteModel];
    
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_currentIndex inSection:0]]];
    
    if (_photoModels.count == 0)  {
        
        [self removeFromSuperview];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:deletePhotoModel:index:)]) {
        
        [self.delegate browserView:self deletePhotoModel:deleteModel index:_currentIndex];
    }
    
    [self scrollViewDidScroll:self.collectionView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger index = (scrollView.contentOffset.x + (UI_SCREEN_WIDTH_PC + DSBroswerMargin) * 0.5) / (UI_SCREEN_WIDTH_PC + DSBroswerMargin);
    
    if (_photoModels.count <= 1) {
        self.titleLabel.text = @"";
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd",index+1,_photoModels.count];
    }
    
    _currentIndex = index;
    
    if (_currentIndex >= _photoModels.count) {
        
        _currentIndex = _photoModels.count - 1;
    }
    
    if (_currentIndex >= 0) {
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:configureAccessoryView:photoModel:atIndex:)]) {
            
            [self.delegate browserView:self configureAccessoryView:self.accessoryView photoModel:_photoModels[_currentIndex] atIndex:index];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _photoModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DSBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DSBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.model = _photoModels[indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(DSBrowserCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.zoomScale = 1;
}

#pragma mark - CustomMethod
/** 显示 */
- (void)show {
    
    if (_isShow) return;
    
    DSPhotoModel *photoModel = _photoModels[_currentIndex];
    _currentModel = photoModel;
    if (!photoModel.photoView) {
        
        NSAssert(photoModel.photoView, @"当前的图片必须要传photoView属性，以确保起始位置");
    }
    
    if (!photoModel.thumbnailImage && !photoModel.thumbnailImageURLString) {
        
        NSAssert(photoModel.thumbnailImage || photoModel.thumbnailImageURLString, @"至少有一个缩略图资源，placeHolderImage,placeholderImageUrlString");
    }
    
    self.window.windowLevel = UIWindowLevelAlert;
    
    UIView *fromView = photoModel.photoView;
    CGRect originalFrame;
    
    if (CGRectEqualToRect(fromView.superview.frame, self.window.frame)) {
        
        originalFrame = fromView.frame;
        
    }else {
        
        originalFrame = [fromView convertRect:fromView.bounds toView:self.window];
    }
    
    self.fakeImageView.frame = originalFrame;
    
    [self.window addSubview:self.fakeImageView];
    
    //如果有大图就显示大图
    if (photoModel.image) {
        
        self.fakeImageView.image = photoModel.image;
        
    }else {
        //没有就先显示缩略图
        //如果有缩略图就显示缩略图
        if (photoModel.thumbnailImage) {
            
            self.fakeImageView.image = photoModel.thumbnailImage;
            
        }else {
            
            UIImage *image = [SDImageCache.sharedImageCache imageFromCacheForKey:photoModel.thumbnailImageURLString];
            
            if (image) {
                
                photoModel.thumbnailImage = image;
                self.fakeImageView.image = image;
                
            }else {
                
                //没有加载网络缩略图
                NSURL *url = [NSURL URLWithString:photoModel.thumbnailImageURLString];
                
                
                [self.indicatorView startAnimating];
                
                [SDWebImageManager.sharedManager loadImageWithURL:url options:0 progress:NULL completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    
                    photoModel.thumbnailImage = image;
                    [self.indicatorView stopAnimating];
                    self.fakeImageView.image = image;
                    
                }];
                
            }
            
        }
    }
    
    [self displayWithPhotoModel:photoModel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setupAccessoryViewInBrowserView:)]) {
        UIView* otherView = [self.delegate setupAccessoryViewInBrowserView:self];
        
        if (otherView) {
            
            [self addSubview:otherView];
            
            self.accessoryView = otherView;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserView:configureAccessoryView:photoModel:atIndex:)]) {
                
                [self.delegate browserView:self configureAccessoryView:otherView photoModel:photoModel atIndex:_currentIndex];
            }
        }
    }
    
    _isShow = YES;
}

- (void)displayWithPhotoModel:(DSPhotoModel *)photoModel {
    
    self.backdropView.alpha = 0;
    
    if (photoModel.type == DSPhotoModelTypeImage) {
        
        [self.window insertSubview:self.backdropView belowSubview:self.fakeImageView];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            self.backdropView.alpha = 1;
            self.fakeImageView.frame = photoModel.imgFrame;
            self.indicatorView.center = self.fakeImageView.center;
            
        } completion:^(BOOL finished) {
            
            self.frame = self.window.bounds;
            [self.window addSubview:self];
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            
            if (_isCanDelete) [self addSubview:self.deleteButton];
            if (self.showTitle) [self addSubview:self.titleLabel];
            self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd",_currentIndex+1,_photoModels.count];
            
            [self.backdropView removeFromSuperview];
            [self.fakeImageView removeFromSuperview];
            [self.indicatorView removeFromSuperview];
            
        }];
    }
    
    if (photoModel.type == DSPhotoModelTypeVideo) {
        
        //视频播放
    }
}

- (void)hideWithPhotoModel:(DSPhotoModel *)photoModel originalFrame:(CGRect)originalFrame {
    
    if (photoModel.image) {
        
        self.fakeImageView.image = photoModel.image;
        
    }else {
        
        UIImage *image;
        //就是一开始就加在出来图片了
        if (photoModel.thumbnailImage) {
            
            image = photoModel.thumbnailImage;
            
        }else {
            //没在去主动去获取加载的图片，要自己本地看一下有没有
            image = [SDImageCache.sharedImageCache imageFromCacheForKey:photoModel.thumbnailImageURLString];
            photoModel.thumbnailImage = image;
        }
        
        self.fakeImageView.image = image;
    }
    
    self.fakeImageView.frame = photoModel.imgFrame;
    
    self.backdropView.alpha = 1;
    [self.window addSubview:self.backdropView];
    [self.window addSubview:self.fakeImageView];
    
    [self removeFromSuperview];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        self.backdropView.alpha = 0;
        
        self.fakeImageView.frame = originalFrame;
        
        if (CGRectEqualToRect(originalFrame, CGRectInset(self.window.bounds, -50, -50))) {
            
            self.fakeImageView.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        
        [self.backdropView removeFromSuperview];
        [self.fakeImageView removeFromSuperview];
        self.fakeImageView = nil;
        self.backdropView = nil;
        self.indicatorView = nil;
        
        if (self.accessoryView) [self.accessoryView removeFromSuperview];
        
        
    }];
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0) {
    
    return YES;
}


/**
 重写,只要是移除当前视图就是设置 windowLevel 的值.
 */
- (void)removeFromSuperview {
    
    self.window.windowLevel = UIWindowLevelNormal;
    
    [super removeFromSuperview];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"dealloc ===== DSBrowserView");
#endif
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    self.accessoryView.frame = CGRectMake(0, self.frame.size.height - 80, self.frame.size.width, 80.);
//}

@end
