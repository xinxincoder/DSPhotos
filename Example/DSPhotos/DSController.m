//
//  DSController.m
//  PhotosManager
//
//  Created by  liuxx on 2017/4/11.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSController.h"
#import "PhotosCell.h"
#import <DSPhotos/DSPhotos-umbrella.h>
#import "DSBrowserTestController.h"

@interface DSController () <DSAlbumControllerDelegate, DSPhotoControllerDelegate, PhotosCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray* photos;

@property (nonatomic, assign) NSUInteger maxLimit;

@property (nonatomic, assign) BOOL DSEdit;

@end

@implementation DSController

- (NSMutableArray *)photos {
    
    if (!_photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maxLimit = 50;
    
    // 完成按钮
    UIButton* doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 0, 60, 30);
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTitle:@"编辑" forState:UIControlStateSelected];
    [doneBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    doneBtn.selected = YES;
    [doneBtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    
    self.DSEdit = doneBtn.selected;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图片编辑" style:UIBarButtonItemStylePlain target:self action:@selector(goClipPhoto)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
// 图片编辑
- (void)goClipPhoto {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ClipPhotoView" bundle:nil];
    UIViewController* vc = [sb instantiateInitialViewController];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doneClick:(UIButton*)btn {
    btn.selected = !btn.selected;
    
    self.DSEdit = btn.selected;
}

- (void)setDSEdit:(BOOL)DSEdit {
    _DSEdit = DSEdit;
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - DSPhotoControllerDelegate
- (void)photosProtocol:(DSPhotoController *)photosProtocol selectDonePhotoWithPhotoModels:(NSArray<DSPhotoModel *> *)photoModels {
    
    [self.photos removeAllObjects];
    [self.photos addObjectsFromArray:photoModels];
    
    
    [self.tableView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:NULL];

}

- (void)photosProtocol:(id)photosProtocol selectPhotosTipWithTipType:(DSPhotosProtocolTipType)tipType {
    
    switch (tipType) {
        case DSPhotosProtocolTipTypeMoreThanMaximumLimit:
            NSLog(@"选多了,亲");
            break;
            
        case DSPhotosProtocolTipTypeLessThanMinimumLimit:
            NSLog(@"给点面子,至少选一张吧");
        break;
        case DSPhotosProtocolTipTypeImageAndVideoSimultaneously:
            NSLog(@"相片和视频不能同时选");
        break;
        case DSPhotosProtocolTipTypeMoreThanOneVideo:
            NSLog(@"只能选择一个视频");
        break;}
}

#pragma mark -
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (DSBrowserController *)browserControllerAppearanceForPhotoController:(DSPhotoController *)photoController {
    
    DSBrowserController *browserVC = [[DSBrowserController alloc] init];
//    browserVC.selecteColor = self.selecteColor;
    browserVC.backIndicatorImage = [UIImage imageNamed:EPC_IMG_PHOTO_BACKINDICATOR];
//    browserVC.doneTitle = @"发送";
    browserVC.canSelectCurrentWhenNoSelect = YES;
    return browserVC;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ((self.DSEdit == NO) && (self.photos.count == 0)) {
        return 0;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat margin = 0.5 * EPCDeleteSizeLength;
    NSUInteger line = 4;
    
    if (UI_SCREEN_WIDTH_PC >= 1023) {
        line = 8;
    } else if (UI_SCREEN_WIDTH_PC >= 767) {
        line = 6;
    }
    
    CGFloat mScreenWidth = UI_SCREEN_WIDTH_PC;
    CGFloat mCellWidth   = floor((mScreenWidth - margin - margin*0.5 - margin*0.5*(line-1))/line);
    
    NSUInteger count = (self.photos.count >= self.maxLimit)?self.maxLimit:(self.DSEdit?(self.photos.count+1):self.photos.count);
    
    count = (count/line)+(((count%line) == 0)?0:1);
    
    CGFloat heihgt = 0.75*EPCDeleteSizeLength;
    heihgt += count*mCellWidth + (count-1)*EPCDeleteSizeLength*0.25;
    
    
    return heihgt;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        PhotosCell* cell = [PhotosCell cell:tableView];
        
        cell.maxCount = self.maxLimit;
        // 自带删除功能
        cell.ownDeleteFunction = YES;
        cell.DSEdit = self.DSEdit;
        cell.delegate = self;
        cell.photos = self.photos;
        // 有拖拽效果
        cell.drag = YES;
        
        return cell;

    }else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"加载网络图片";
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
       DSBrowserTestController *controller = [st instantiateViewControllerWithIdentifier:@"DSBrowserTestController"];
        
        [self.navigationController pushViewController:controller animated:YES];
    }

}

#pragma mark -
#pragma mark - PhotosCellDelegate
- (void)photosCell:(PhotosCell *)cell didSelecteWithMode:(DSPhotoModel *)model {
    if (!model) {
        // 添加图片
        [self goPhotos];
        return;
    }
   
    // 浏览图片
    DSBrowserController* browerVC = [[DSBrowserController alloc] init];
    browerVC.showOriginalPhotoButton = YES;
    browerVC.fetchPhotoResult = self.photos;
    browerVC.currentIndex = [self.photos indexOfObject:model];
    
    [self.navigationController pushViewController:browerVC animated:YES];
}

// 删除某一张图片
- (void)photosCell:(PhotosCell *)cell deleteWithPhotoMode:(DSPhotoModel *)photoMode {
    // 删除数据
    [self.photos removeObject:photoMode];
    // 刷新 tableView
    [self.tableView reloadData];
}

// 添加图片
- (void)goPhotos {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"请选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        if ([DSTakePhotoManager authorizationStatus] == DSTakePhotoAuthorizationStatusNotAuthorized) {
            return;
        }
        
        
        DSTakePhotoManager *manager = [DSTakePhotoManager sharedInstance];
        [manager takePhotoWithSourceVC:self backAssetBlock:^(DSPhotoModel *photoModel) {
           
            [self.photos addObject:photoModel];
            [self.tableView reloadData];
        }];
        
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DSPhotosManager accordingToAuthorityWithHandler:^(BOOL authorized) {
            
            if (authorized) {
                
                [DSPhotosConfiguration configureThemeTextAndBackArrowColor:[UIColor darkGrayColor]];
                
                DSAlbumController *albumController = [[DSAlbumController alloc] init];
                
                albumController.delegate = self;
                albumController.fetchMediaType = DSFetchMediaTypeAll;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
                
                [self presentViewController:navigationController animated:YES completion:NULL];
                
            }else {
                
//                NSLog(@"没有权限");
            }
            
        }];

    }];
    
    [controller addAction:cameraAction];
    [controller addAction:photoAction];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark- DSAlbumControllerDelegate
- (DSPhotoController *)photoControllerForAlbumController {

    DSPhotoController* photosVC = [[DSPhotoController alloc] init];
    photosVC.photos = self.photos;
    photosVC.delegate = self;
    photosVC.maximumLimit = 15;
    photosVC.targetCompression = 1054;
//    photosVC.canTakePicture = NO; 弃用
//    photosVC.doneTitle = @"发送";
//    photosVC.showOriginalPhotoButton = YES;
    photosVC.selecteColor = [UIColor purpleColor];
//    [self.navigationController pushViewController:photosVC animated:YES];
    return photosVC;
}

@end
