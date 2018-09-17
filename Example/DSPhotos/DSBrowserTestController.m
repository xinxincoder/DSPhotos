//
//  DSBrowserTestController.m
//  PhotosManager
//
//  Created by XXL on 2017/7/26.
//  Copyright © 2017年 CustomUI. All rights reserved.
//

#import "DSBrowserTestController.h"
#import "DSBrowserTestCell.h"
#import <DSPhotos/DSPhotos-umbrella.h>

@interface DSBrowserTestController ()

@property (nonatomic, strong) NSArray *array;

@end

@implementation DSBrowserTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DSPhotoModel *model1 = [[DSPhotoModel alloc] init];
    //    model1.image = [UIImage imageNamed:@"1"];
    model1.thumbnailImageURLString = @"https://image1.drugs360.cn/euc/66493A39BE05B57E/image.jpg?imageView2/2/w/183/h/156";
    
    model1.imageURLString = @"https://image1.drugs360.cn/euc/66493A39BE05B57E/image.jpg";
    
    DSPhotoModel *model2 = [[DSPhotoModel alloc] init];
    model2.imageURLString = @"https://image1.drugs360.cn/euc/E0F46F850C1EEC8C/image.jpg";
    model2.thumbnailImageURLString = @"https://image1.drugs360.cn/euc/E0F46F850C1EEC8C/image.jpg?imageView2/2/w/183/h/156";
    
    DSPhotoModel *model3 = [[DSPhotoModel alloc] init];
    model3.thumbnailImageURLString = @"https://image1.drugs360.cn/euc/547926FD9D054EF4/image.jpg?imageView2/2/w/183/h/232";
    model3.imageURLString = @"https://image1.drugs360.cn/euc/547926FD9D054EF4/image.jpg";
    
//    DSPhotoModel *model4 = [[DSPhotoModel alloc] init];
//    model4.imageURLString = @"https://image1.drugs360.cn/euc/09la4cotxpVC05N81TDTWvhF/image.jpg";
//
//    
//    DSPhotoModel *model5 = [[DSPhotoModel alloc] init];
//    model5.imageURLString = @"https://image1.drugs360.cn/euc/09la4clWejGFavUOBmjq1iNb/image.jpg";
//    
//    DSPhotoModel *model6 = [[DSPhotoModel alloc] init];
//    model6.imageURLString = @"https://image1.drugs360.cn/euc/09lfIZLsTRKxWR7fF2TO3lG2/image.jpg";
//    
//    DSPhotoModel *model7 = [[DSPhotoModel alloc] init];
//    model7.imageURLString = @"https://image1.drugs360.cn/euc/09lf5jFpTAb1Qs9s1TvDnIt8/image.jpg";

    
    self.array = @[model1,model2,model3,model1,model2,model3,model1,model2,model3,model1,model2,model3,model1,model2,model3,model1,model2,model3,model1,model2,model3];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSBrowserTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DSBrowserTestCell" forIndexPath:indexPath];
    cell.model = self.array[indexPath.section];
    return cell;
}


@end
