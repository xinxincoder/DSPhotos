//
//  PhotosCellCell.m
//  PhotosManager
//
//  Created by  liuxx on 2017/4/11.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "PhotosCell.h"
#import "PhotoItemCell.h"


#import <DSPhotos/DSPhotos-umbrella.h>


static NSString* const BlanckID = @"BlanckID";
static NSString* const ID = @"PhotoItemCell";


@interface PhotosCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoItemCellDelegate, DSBrowserViewDelegate>

@property (nonatomic, weak) UICollectionView* collectionView;

@property (nonatomic, strong) UILabel *label;

@end

@implementation PhotosCell

/** 快速获取cell */
+ (instancetype)cell:(UITableView*)tableView {
    static NSString* const ID = @"PhotosCell";
    PhotosCell* cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        [tableView registerClass:self forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    cell.backgroundColor = [UIColor redColor];
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0.0, 0, 0.0);
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    
    [collectionView registerClass:[PhotoItemCell class] forCellWithReuseIdentifier:ID];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:BlanckID];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    // 添加长按手势 (http://blog.csdn.net/wgl_happy/article/details/52179608)
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    [collectionView addGestureRecognizer:longPress];
    
    
    // 默认是挺大的
    self.maxCount = 250;
    
    return self;
}



/**
 长按手势 事件
 */
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longPress {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        [self action:longPress];
    } else {
        [self iOS9_Action:longPress];
    }
}


/**
 9 系统之前的移动方式
 */
- (void)action:(UILongPressGestureRecognizer *)longPress {

}

/**
 9 系统以及之后的移动方式
 */
- (void)iOS9_Action:(UILongPressGestureRecognizer *)longPress {
    
    if (!self.isDrag || (self.photos.count <= 1)) {
        return;
    }
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 手势开始, 判断手势落点位置是否在row上
            
            if (!indexPath) {
                break;
            }
            
            
            // 放到顶层
            [self.collectionView bringSubviewToFront:cell];
            
            // 移动 cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            
            [self scaleViewWithView:cell scale:1.05f];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            // 手势状态持续改变中, 移动过程中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView]];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            // 手势结束,关闭移动移动
            [self.collectionView endInteractiveMovement];
            [self scaleViewWithView:cell scale:1.0f];
        }
            break;
        default:
        { // 其它(未知,取消...)
            // 取消移动
            [self.collectionView cancelInteractiveMovement];
            [self scaleViewWithView:cell scale:1.0f];
            
        }
            break;
    }
}

// 视图的缩放
- (void)scaleViewWithView:(UIView* )view scale:(CGFloat)scale {
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    // InOut 表示进入和出去时都启动动画
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    // 动画时间
    [UIView setAnimationDuration:0.5f];
    // 先让要显示的view最小直至消失
    view.transform=CGAffineTransformMakeScale(scale, scale);
    // 启动动画
    [UIView commitAnimations];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isDrag) {
        return NO;
    }
    
    if ((self.photos.count == indexPath.row) || (self.photos.count <= 1)) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 从某个地方移动到另外一个地方
    // 实现了cell之间的交互,还要对数据进行调整
    
    if (destinationIndexPath.row >= self.photos.count) {
        
        [collectionView reloadData];
        return;
    }
    
    // 取出起始数据
    DSPhotoModel* phoneMode = self.photos[sourceIndexPath.row];
    
    // 删除
    [self.photos removeObject:phoneMode];
    
    // 插入新位置
    [self.photos insertObject:phoneMode atIndex:destinationIndexPath.row];
    
}


- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    
    [self.collectionView reloadData];
}

#pragma MARK -
#pragma MARK - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.photos.count >= self.maxCount) {
        return self.maxCount;
    }
    
    
    return self.DSEdit?(self.photos.count + 1):self.photos.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获取: 先注册,避免闪退
    PhotoItemCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    // 是否自带删除功能
    cell.ownDeleteFunction = self.ownDeleteFunction;
    
    // 赋值
    if (indexPath.item == self.photos.count) {
        // 上传图片
        cell.photoModel = nil;
        cell.delegate = nil;
        
    } else {
        id unknowClass = self.photos[indexPath.item];
        cell.photoModel = unknowClass;
        
        cell.delegate = self.DSEdit?self:nil;
    }
    
    // 返回
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoItemCell* cell = (PhotoItemCell* )[collectionView cellForItemAtIndexPath:indexPath];
    
    id unknowClass = nil;
    if ([cell isKindOfClass:[PhotoItemCell class]]) {
        unknowClass = cell.photoModel;
    }
    
    if (cell.photoModel) {
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.photos.count == 1) {
            
            DSPhotoModel *model = self.photos.firstObject;
            
            if (model.type == DSPhotoModelTypeVideo) {
                
                return;
            }
            
        }
        
        
        [self.photos enumerateObjectsUsingBlock:^(DSPhotoModel *  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
           
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
            model.photoView = cell;
            
        }];
        
        DSBrowserView *browserView = [DSBrowserView browserViewWithPhotoModels:self.photos currentIndex:indexPath.row];
        browserView.isCanDelete = _DSEdit;
        browserView.delegate = self;
        [browserView show];

    
    }else {
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(photosCell:didSelecteWithMode:)]) {
            [self.delegate photosCell:self didSelecteWithMode:unknowClass];
        }
    }
}


#pragma mark -
#pragma mark - PhotoItemCellDelegate
- (void)deletePhotoItemCell:(PhotoItemCell *)cell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photosCell:deleteWithPhotoMode:)]) {
        [self.delegate photosCell:self deleteWithPhotoMode:cell.photoModel];
    }
}

#pragma mark -
#pragma mark - UICollectionViewDelegateFlowLayout
// 设置单元格大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CGFloat margin = 0.5 * EPCDeleteSizeLength;
    NSUInteger line = 4;
    
    if (UI_SCREEN_WIDTH_PC >= 1023) {
        line = 8;
    } else if (UI_SCREEN_WIDTH_PC >= 767) {
        line = 6;
    }
    
    CGFloat mScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat mCellWidth   = floor((mScreenWidth - margin - margin*0.5 - margin*0.5*(line-1))/line);
    
    
    return CGSizeMake(mCellWidth, mCellWidth);
    
}

// 设置单元格之间的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat leftBottomMargin = EPCDeleteSizeLength*0.5;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(leftBottomMargin*0.5, leftBottomMargin, leftBottomMargin, leftBottomMargin*0.5);
    
    return edgeInsets;
    
}

// 设置行列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    CGFloat leftBottomMargin = EPCDeleteSizeLength*0.5;
    
    return leftBottomMargin*0.5;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    // 同上
    return [self collectionView:collectionView layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.contentView.bounds;
    
}

#pragma mark - DSBrowserViewDelegate
//- (UIView *)browserView:(DSBrowserView *)browserView viewForPhotoModel:(DSPhotoModel *)photoModel atIndex:(NSInteger)index {
//    
//    PhotoItemCell *cell = (PhotoItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//    return cell.imageDSView;
//}

- (void)browserView:(DSBrowserView *)browserView deletePhotoModel:(DSPhotoModel *)photoModel index:(NSInteger)index {
    
//    [self.photos removeObject:photoModel];
//    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photosCell:deleteWithPhotoMode:)]) {
        [self.delegate photosCell:self deleteWithPhotoMode:photoModel];
    }
    
}

- (UIView *)browserView:(DSBrowserView *)browserView updatePhotoPositionWhenDeletePhotoModel:(DSPhotoModel *)photoModel atIndex:(NSInteger)index {
    
    PhotoItemCell *cell = (PhotoItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imageDSView;

}

- (UIView *)setupAccessoryViewInBrowserView:(DSBrowserView *)browserView {
    
    UIView *accessoryView = [[UIView alloc] init];
    accessoryView.frame = CGRectMake(0, UI_SCREEN_HEIGHT_PC - 200, UI_SCREEN_WIDTH_PC, 200);
    accessoryView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = accessoryView.bounds;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [accessoryView addSubview:self.label = label];
    return accessoryView;
}

- (void)browserView:(DSBrowserView *)browserView configureAccessoryView:(UIView *)accessoryView photoModel:(nonnull DSPhotoModel *)photoModel atIndex:(NSInteger)index {
    
    self.label.text = [NSString stringWithFormat:@"这是第%zd张图",index+1];
}

- (void)browserView:(DSBrowserView *)browserView longPressActionWithPhotoModel:(DSPhotoModel *)photoModel atIndex:(NSInteger)index {
    
    NSLog(@"长按了大图");
}

@end
