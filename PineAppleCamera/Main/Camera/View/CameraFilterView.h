//
//  CameraFilterView.h
//  helloMeitu
//
//  Created by meitu on 16/7/15.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraFilterViewDelegate;

@interface CameraFilterView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *picArray;//图片数组
@property (strong, nonatomic) NSMutableArray *nameArray;
@property (strong, nonatomic) id <CameraFilterViewDelegate> cameraFilterDelegate;
@end

@protocol CameraFilterViewDelegate <NSObject>

- (void)switchCameraFilter:(NSInteger)index;//滤镜选择方法

@end
