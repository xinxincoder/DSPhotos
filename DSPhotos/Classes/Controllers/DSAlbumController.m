//
//  DSAlbumController.m
//  DSPhotosDemo
//
//  Created by XXL on 2017/9/5.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSAlbumController.h"
#import <Photos/Photos.h>
#import "DSAlbumsModel.h"
#import "DSAlbumCell.h"
#import "DSPhotosCommon.h"
#import "DSPhotoController.h"
#import "DSPhotosGlobal.h"

static NSString *const AlbumCellIdentifier = @"AlbumCellIdentifier";

@interface DSAlbumController () <UITableViewDataSource, UITableViewDelegate>

// 所有相册
@property (nonatomic, strong) NSMutableArray* allAlbums;

@property (nonatomic, strong) NSMutableArray* selectedPhotoModels;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL firstLoad;

@property (nonatomic, strong) DSPhotoController *phototsController;

@end

@implementation DSAlbumController

#pragma mark - 懒加载
- (NSMutableArray *)allAlbums {
    if (!_allAlbums) {
        _allAlbums = [NSMutableArray array];
    }
    return _allAlbums;
}

- (NSMutableArray *)selectedPhotoModels {
    
    if (!_selectedPhotoModels) {
        _selectedPhotoModels = [NSMutableArray array];
    }
    return _selectedPhotoModels;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_firstLoad) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoControllerForAlbumController)]) {
            
            DSPhotoController *photoController = [self.delegate photoControllerForAlbumController];
            photoController.selectedAssets = self.selectedPhotoModels;
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            
            if (self.fetchMediaType != DSFetchMediaTypeAll) {
                
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",self.fetchMediaType];
            }
            
            for (PHAssetCollection *assetCollection in self.allAlbums) {
                
                if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    
                    photoController.title = assetCollection.localizedTitle;
                    photoController.pPhotoFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                    break;
                }
            }
            
            [self.navigationController pushViewController:photoController animated:NO];
            
            _firstLoad = NO;
            
        }
        
        NSAssert(self.delegate && [self.delegate respondsToSelector:@selector(photoControllerForAlbumController)], @"请实现photoControllerForAlbumController代理");
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    _firstLoad = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:(236.0/255) green:(236.0/255) blue:(244.0/255) alpha:1];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.frame = self.view.bounds;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [tableView registerClass:[DSAlbumCell class] forCellReuseIdentifier:AlbumCellIdentifier];
    [self.view addSubview:self.tableView = tableView];
    
    // 给 tableView 加一个footerView
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.view.frame), 20.0)];
    tableView.tableFooterView = footerView;
    
    // 获取所有的相册
    [self fetchAllAlbums];
    
    UIButton *rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightItemButton setTitle:@"取消" forState:UIControlStateNormal];
    [rightItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIColor *globalTextColor = DSGLOBAL.globalTextColor;
    if (globalTextColor) {
        
        [rightItemButton setTitleColor:globalTextColor forState:UIControlStateNormal];
    }
    rightItemButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightItemButton sizeToFit];
    [rightItemButton addTarget:self action:@selector(rightItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)rightItemAction:(UIButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/** 获取所有的相册 */
- (void)fetchAllAlbums {
    
    PHFetchOptions *mOptions = [[PHFetchOptions alloc] init];
    mOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    // 智能相册
    mOptions                 = [mOptions copy];
    mOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle"ascending:YES]];
    PHFetchResult *smartAlbums = [PHAssetCollection
                                  fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                  subtype:PHAssetCollectionSubtypeAny
                                  options:mOptions];
    
    if (smartAlbums.count > 0) {
        
        PHFetchOptions *mOptions = [[PHFetchOptions alloc] init];
        mOptions                 = [mOptions copy];
        mOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        if (self.fetchMediaType != DSFetchMediaTypeAll) {
            
            mOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",self.fetchMediaType];
        }
        NSMutableArray *mSmartAlbumArray = [NSMutableArray arrayWithCapacity:smartAlbums.count];
        
        for (PHAssetCollection *mCollection in smartAlbums) {
            
            PHFetchResult *mFResult = [PHAsset fetchAssetsInAssetCollection:mCollection options:mOptions];
            
            if (mFResult.count) [mSmartAlbumArray addObject:mCollection];
        }
        
        [self.allAlbums addObjectsFromArray:mSmartAlbumArray];
        
    }
    
    // 个人相册
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:mOptions];
    
    if (topLevelUserCollections.count > 0) {
        
        PHFetchOptions *mOptions = [[PHFetchOptions alloc] init];
        mOptions                 = [mOptions copy];
        mOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        if (self.fetchMediaType != DSFetchMediaTypeAll) {
            
            mOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",self.fetchMediaType];
        }
        NSMutableArray *userAlbum = [NSMutableArray array];
        
        for (NSInteger i=0; i<topLevelUserCollections.count; i++) {
            PHAssetCollection *collection = topLevelUserCollections[i];
            PHFetchResult* mFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            
            if (mFetchResult.count > 0)   [userAlbum addObject:collection];
        }
        
        [self.allAlbums addObjectsFromArray:userAlbum];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.allAlbums.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAssetCollection *assetCollection = self.allAlbums[indexPath.section];
    
    DSAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:AlbumCellIdentifier forIndexPath:indexPath];
    
    cell.assetCollection = assetCollection;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.00001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PHAssetCollection *assetCollection = self.allAlbums[indexPath.section];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoControllerForAlbumController)]) {
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        
        if (self.fetchMediaType != DSFetchMediaTypeAll) {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",self.fetchMediaType];
        }
        
        DSPhotoController *photoController = [self.delegate photoControllerForAlbumController];
        photoController.selectedAssets = self.selectedPhotoModels;
        photoController.title = assetCollection.localizedTitle;
        photoController.pPhotoFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        [self.navigationController pushViewController:photoController animated:YES];
        self.phototsController = photoController;
    }
    
    NSAssert(self.delegate && [self.delegate respondsToSelector:@selector(photoControllerForAlbumController)], @"请实现photoControllerForAlbumController代理");
}

@end
