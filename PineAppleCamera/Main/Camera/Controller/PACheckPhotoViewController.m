//
//  PACheckPhotoViewController.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PACheckPhotoViewController.h"

#import <GPUImage.h>
#import "UIImage+fixOrientation.h"
#import "Tool.h"
#import "CameraFilterView.h"
#import "PAStaticMacro.h"
#import "PAUtilsMacro.h"
#import "GPUImageBeautifyFilter.h"

static int count = 0;
static int CameraFilterCount = 9;

@interface PACheckPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *increaseHeightButton;
@property (weak,nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) UIImage *currentImage;
@property CameraFilterView *cameraFilterView;
@property GPUImageFilter *filter;

@end

@implementation PACheckPhotoViewController

#pragma mark 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [_bottomView setBackgroundColor:[UIColor blackColor]];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.image = [self.image fixOrientation];
    [self switchCameraFilter:_FilterCode];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 保存照片
//
- (IBAction)saveImage:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_currentImage, nil, nil, nil);
    NSLog(@"保存照片成功...");
}


#pragma mark 应用滤镜方法
//使用滤镜

- (IBAction)useFilter:(id)sender {
    if (count%2==0) {
        [self addCameraFilterView];
        count++;
    }
    else
    {
        [_cameraFilterView removeFromSuperview];
        count++;
    }
    
}

- (IBAction)useIncreaseHeight:(id)sender {
    //    IncreaseHeightViewController * increaseHeightVC = [[IncreaseHeightViewController alloc] init];
    //    increaseHeightVC.originImage = _currentImage;
    //    [self.navigationController pushViewController:increaseHeightVC animated:YES];
}

- (void)addCameraFilterView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cameraFilterView = [[CameraFilterView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT - _bottomView.frame.size.height - (SCREEN_WIDTH - 4 )/5, SCREEN_WIDTH, (SCREEN_WIDTH - 4 ) / 5) collectionViewLayout:layout];
    NSMutableArray *filterNameArray = [[NSMutableArray alloc] initWithCapacity:CameraFilterCount];
    for (NSInteger index = 0; index < CameraFilterCount; index++) {
        UIImage *image = [UIImage imageNamed:@"girl"];
        [filterNameArray addObject:image];
    }
    _cameraFilterView.cameraFilterDelegate = self;
    _cameraFilterView.picArray = filterNameArray;
    [self.view addSubview:_cameraFilterView];
}


- (void)switchCameraFilter:(NSInteger)index {
    UIImage *inputImage = self.image;
    
    switch (index) {
        case 0:
            _filter = [[GPUImageFilter alloc] init];//原图
            break;
        case 1:
            _filter = [[GPUImageBeautifyFilter alloc] init];//绿巨人
            break;
        case 2:
            _filter = [[GPUImageColorInvertFilter alloc] init];//负片
            break;
        case 3:
            _filter = [[GPUImageSepiaFilter alloc] init];//老照片
            break;
        case 4: {
            _filter = [[GPUImageGaussianBlurPositionFilter alloc] init];
            [(GPUImageGaussianBlurPositionFilter*)_filter setBlurRadius:40.0/320.0];
        }
            break;
        case 5:
            _filter = [[GPUImageMedianFilter alloc] init];
            break;
        case 6:
            _filter = [[GPUImageVignetteFilter alloc] init];//黑晕
            break;
        case 7:
            _filter = [[GPUImageKuwaharaRadius3Filter alloc] init];
            break;
        case 8:
            _filter = [[GPUImageBilateralFilter alloc] init];
        default:
            _filter = [[GPUImageFilter alloc] init];
            break;
    }
    
    
    [_filter forceProcessingAtSize:inputImage.size];
    [_filter useNextFrameForImageCapture];
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    [stillImageSource addTarget:_filter];
    
    [stillImageSource processImage];
    
    _currentImage = [_filter imageFromCurrentFramebuffer];
    [self.imageView setImage:_currentImage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
