//
//  CameraFilterView.m
//  helloMeitu
//
//  Created by meitu on 16/7/15.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "CameraFilterView.h"
#import "PACameraFilterCollectionViewCell.h"

static const float CELL_HEIGHT = 84.0f;
static const float CELL_WIDTH = 56.0f;
@implementation CameraFilterView

#pragma mark 初始化方法

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.nameArray = [NSMutableArray arrayWithObjects:@"原图",@"美颜",@"经典",@"碧波",@"记忆",@"哥特风",@"LOMO",@"水墨",@"云端",@"彩虹瀑", nil];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

#pragma mark collection 方法
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_picArray count];
}

- (PACameraFilterCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PACameraFilterCollectionViewCell";
    
    [collectionView registerNib:[UINib nibWithNibName:@"PACameraFilterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:identifier];
    
//    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    PACameraFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.filterName = [_nameArray objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_cameraFilterDelegate switchCameraFilter:indexPath.row];
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



@end
