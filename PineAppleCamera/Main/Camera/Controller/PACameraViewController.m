//
//  PACameraViewController.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PACameraViewController.h"

//第三方头文件
#import <GPUImage.h>
#import <GPUImageView.h>

//自定义头文件
#import "PAStaticMacro.h"
#import "PAUtilsMacro.h"
#import "PAEnumMacro.h"
#import "Tool.h"

//Model
#import "PAStillCamera.h"

//Controller
#import "PACheckPhotoViewController.h"

//View
#import "MTBubbleButton.h"
#import "CameraFilterView.h"
#import "MTMaskImageView.h"
#import "GPUImageBeautifyFilter.h"

typedef NS_ENUM(NSInteger, FilterViewState) {
    
    FilterViewHidden,//隐藏
    
    FilterViewUsing //显示
};


@interface PACameraViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) PAStillCamera *cameraManager;

//根据storyboard上将界面分为三个View，预览View，底部View以及整体的cameraView
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet GPUImageView *preview;

@property (nonatomic , assign) FilterViewState filterViewState;
@property (nonatomic , assign) SliderBarKind sliderBarKind;

@property (weak ,nonatomic) MTBubbleButton *flashMenu;
@property (strong, nonatomic) UIButton *homeBtn;
@property (strong, nonatomic) UIButton *turnButton;
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UIButton *exposeButton;
@property (weak, nonatomic) IBOutlet UIButton *secButton;
@property (weak, nonatomic) IBOutlet UIButton *ISOButton;
@property (weak, nonatomic) IBOutlet UIButton *whiteBalanceButton;

@property (weak, nonatomic) UIButton *preSelectedButton;
@property (strong ,nonatomic) UILabel *enlargeLabel;//放大倍数
@property (strong ,nonatomic) UISlider *slider;//焦距调整条
@property (strong ,nonatomic) UISlider *expose_slider;
@property (strong ,nonatomic) UISlider *focus_slider;
@property (strong ,nonatomic) UISlider *whiteBalance_slider;
@property (strong ,nonatomic) UISlider *ISO_slider;
@property (strong ,nonatomic) UISlider *sec_slider;

@property (nonatomic,copy) NSString *lastFlashMode;

@property CameraFilterView *cameraFilterView;

@property (strong, nonatomic) GPUImageGammaFilter *filter;
@property (strong,nonatomic ) GPUImageView *filterView;
//@property (strong ,nonatomic) MTMaskImageView * maskView;放大视图

//@property (strong, nonatomic) GPUImageGammaFilter *maskFilter;
//@property (strong, nonatomic) GPUImageView *maskFilterView;

@property (strong, nonatomic) AVCaptureStillImageOutput *photoOutput;
@property (assign, nonatomic) CMSampleBufferRef photoOutputBuffer;

@property (strong, nonatomic) PACheckPhotoViewController *checkVC;

@end

@implementation PACameraViewController

- (void)viewDidLoad{
    [self initView];
    [self setUpData];
    
}

- (void)initView
{
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES];
    //初始化CheckController
    _checkVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"kPACheckPhotoViewController"];
    //初始化相机，默认为前置相机
    _cameraManager = [[PAStillCamera alloc] init];
    _cameraManager.preview = _preview;
    _cameraManager.cameraView = _cameraView;
    
    [_cameraManager setAutoFocusImage:[UIImage imageNamed:@"touch_focus_x"]];//初始化聚焦图片
    [_cameraManager setFocusAndExposeImage:[UIImage imageNamed:@"touch_focus_y"] and:[UIImage imageNamed:@"touch_expose_x"]];
    [_cameraManager addGesturesToCamera];
    [_bottomView setBackgroundColor:[UIColor blackColor]];
    _filter = [[GPUImageGammaFilter alloc] init];//初始化滤镜 默认初始化为原图
    [self addSliderBar];
    [self addTurnButton];
    [self flashAnimation];
    
   
    [_exposeButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
    [self addExposeSliderBar];
    [_cameraView bringSubviewToFront:_bottomView];


}

- (void)setUpData
{
    [_checkVC setFilterCode:0];
    [self.cameraManager addTarget:_filter];
    
    _filterView = self.preview;
    // _maskView = [[MTMaskImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    //[_maskView showEnlargeViewWithPoint:CGPointMake(100, 100)];
    
    // [_preview addSubview:_maskView];
    
    //    _maskFilterView = (GPUImageView *)_maskView;
    //
    //    [_maskView setBackgroundColor:[UIColor whiteColor]];
    [_filter addTarget:_filterView];
    
    [self setFilterViewState:FilterViewHidden];
    [self setSliderBarKind:isExposeMode];
    _lastFlashMode = @"Camera-FlashAuto";
    _preSelectedButton = _exposeButton;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshUI) name:@"123" object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[_cameraManager startCameraCapture];
}

#pragma mark UI方法
//添加sliderbar到主视图上
- (void)addSliderBar{
    _enlargeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, self.preview.bounds.size.height/2 - 105, 40, 20)];
    [_enlargeLabel setFont:[UIFont systemFontOfSize:9]];
    [self.preview addSubview:_enlargeLabel];
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120,self.preview.bounds.size.height/2, 200, 20)];
    //UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(100, 450, 200, 20)];
    _slider.minimumValue = 1.0;
    _slider.maximumValue = 6.0;
    _slider.value = 1.0;
    _slider.transform =CGAffineTransformMakeRotation(3*M_PI/2);
    
    [_enlargeLabel setText:[NSString stringWithFormat:@"%.1fX",_slider.value]];
    [_slider addTarget:self action:@selector(focusDisdance) forControlEvents:UIControlEventValueChanged];
    
    [self.preview addSubview:_slider];
    
}
//添加曝光sliderbar到主视图上
- (void)addExposeSliderBar{
    _expose_slider =  [[UISlider alloc] initWithFrame:CGRectMake(35,4 * self.bottomView.bounds.size.height/9,300, 20)];
    _expose_slider.minimumValue = -5.0;
    _expose_slider.maximumValue = 5.0;
    
    //    _expose_slider.minimumValue = 0.0;
    //    _expose_slider.maximumValue = 1.0;
    _expose_slider.value = (_expose_slider.maximumValue + _expose_slider.minimumValue) / 2;
    
    //_expose_slider.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    [_expose_slider addTarget:self action:@selector(exposeRate) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:_expose_slider];
}

//添加聚焦sliderbar到主视图上
- (void)addFocusSliderBar{
    _focus_slider = [[UISlider alloc] initWithFrame:CGRectMake(35,4 * self.bottomView.bounds.size.height/9, 300, 20)];
    _focus_slider.minimumValue = 0.0f;
    _focus_slider.maximumValue = 1.0f;
    _focus_slider.value = (_focus_slider.maximumValue + _focus_slider.minimumValue) /2;
    
    [_focus_slider addTarget:self action:@selector(focusRate) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:_focus_slider];
}


- (void)addWhiteBalanceSliderBar{
    _whiteBalance_slider = [[UISlider alloc] initWithFrame:CGRectMake(35,4 * self.bottomView.bounds.size.height/9,300, 20)];
    _whiteBalance_slider.minimumValue = 3000.f;
    _whiteBalance_slider.maximumValue = 9000.f;
    
    _whiteBalance_slider.value = [_cameraManager getCurrentTemperature];
    [_whiteBalance_slider addTarget:self action:@selector(whiteBalanceRate) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:_whiteBalance_slider];
}

- (void)addISOSliderBar{
    _ISO_slider = [[UISlider alloc] initWithFrame:CGRectMake(35, 4 * self.bottomView.bounds.size.height/9, 300, 20)];
    _ISO_slider.minimumValue = [[_cameraManager getActiveFormat] minISO];
    _ISO_slider.maximumValue = [[_cameraManager getActiveFormat] maxISO];
    
    _ISO_slider.value = [_cameraManager.inputCamera ISO];
    NSLog(@"min:%f,max:%f,current:%f",_ISO_slider.minimumValue,_ISO_slider.maximumValue,_ISO_slider.value);
    [_ISO_slider addTarget:self action:@selector(ISORate) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:_ISO_slider];
}

- (void)addSecSliderBar{
    _sec_slider = [[UISlider alloc] initWithFrame:CGRectMake(35, 4 * self.bottomView.bounds.size.height/9, 300, 20)];
    CMTime minValue = _cameraManager.inputCamera.activeFormat.minExposureDuration;
    CMTime maxValue = _cameraManager.inputCamera.activeFormat.maxExposureDuration;
    _sec_slider.minimumValue = (float)minValue.value / minValue.timescale;
    _sec_slider.maximumValue = (float)maxValue.value / maxValue.timescale / 2.f;
    
    _sec_slider.value = 1.f/33.f;
    NSLog(@"min:%f,max:%f,current:%f",_sec_slider.minimumValue,_sec_slider.maximumValue,_sec_slider.value);
    [_sec_slider addTarget:self action:@selector(secRate) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:_sec_slider];
}
- (void)addTurnButton{
    _turnButton = [[UIButton alloc] initWithFrame:CGRectMake(self.preview.frame.size.width - 60.0f,20.0f, 40.0f, 40.0f)];
    [_turnButton setImage:[UIImage imageNamed:@"Camera-Change"] forState:UIControlStateNormal];
    [_turnButton addTarget:self action:@selector(turn) forControlEvents:UIControlEventTouchUpInside];
    _turnButton.layer.cornerRadius = _turnButton.frame.size.height / 2.f;
    _turnButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    
    _turnButton.clipsToBounds = YES;
    [self.preview addSubview:_turnButton];
}
//添加滤镜视图到主视图上
- (void)addCameraFilterView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _cameraFilterView = [[CameraFilterView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - _bottomView.frame.size.height - (SCREEN_WIDTH - 4)/5, SCREEN_WIDTH, (SCREEN_WIDTH - 4)/5) collectionViewLayout:layout];
    NSMutableArray *filterNameArray = [[NSMutableArray alloc] initWithCapacity:kPACameraFilterCount];
    for (NSInteger index = 0; index < kPACameraFilterCount; index++) {
        UIImage *image = [UIImage imageNamed:@"girl"];
        [filterNameArray addObject:image];
    }
    _cameraFilterView.cameraFilterDelegate = self;
    _cameraFilterView.picArray = filterNameArray;
    [self.view addSubview:_cameraFilterView];
}

//使用滤镜
- (IBAction)useFilter:(id)sender {
    if (self.filterViewState == FilterViewHidden) {
        [self addCameraFilterView];
        [self setFilterViewState:FilterViewUsing];
    }
    else {
        [_cameraFilterView removeFromSuperview];
        [self setFilterViewState:FilterViewHidden];
    }
}

//手动聚焦
- (IBAction)chooseFocus:(id)sender {
    if (self.sliderBarKind != isFocusMode) {
        [self addFocusSliderBar];
        [self setSliderBarKind:isFocusMode];
        [_focusButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
        
        [_preSelectedButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        if (_preSelectedButton == _exposeButton) {
            [_expose_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _focusButton)
        {
            [_focus_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _secButton)
        {
            [_sec_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _ISOButton)
        {
            [_ISO_slider removeFromSuperview];
            
        }
        else if(_preSelectedButton == _whiteBalanceButton)
        {
            [_whiteBalance_slider removeFromSuperview];
        }
        _preSelectedButton = _focusButton;
    }
}

//手动曝光
- (IBAction)chooseExpose:(id)sender {
    if (self.sliderBarKind != isExposeMode) {
        [self addExposeSliderBar];
        [self setSliderBarKind:isExposeMode];
        [_exposeButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
        [_preSelectedButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        if (_preSelectedButton == _exposeButton) {
            [_expose_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _focusButton)
        {
            [_focus_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _secButton)
        {
            [_sec_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _ISOButton)
        {
            [_ISO_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _whiteBalanceButton)
        {
            [_whiteBalance_slider removeFromSuperview];
        }
        _preSelectedButton = _exposeButton;
    }
}

- (IBAction)chooseSec:(id)sender {
    if (self.sliderBarKind != isSecMode) {
        [self addSecSliderBar];
        [self setSliderBarKind:isSecMode];
        [_secButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
        [_preSelectedButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        if (_preSelectedButton == _exposeButton) {
            [_expose_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _focusButton)
        {
            [_focus_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _secButton)
        {
            [_sec_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _ISOButton)
        {
            [_ISO_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _whiteBalanceButton)
        {
            [_whiteBalance_slider removeFromSuperview];
        }
        _preSelectedButton = _secButton;
    }
}


- (IBAction)chooseISO:(id)sender {
    if (self.sliderBarKind != isISOMode) {
        [self addISOSliderBar];
        [self setSliderBarKind:isISOMode];
        [_ISOButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
        [_preSelectedButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        if (_preSelectedButton == _exposeButton) {
            [_expose_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _focusButton)
        {
            [_focus_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _secButton)
        {
            [_sec_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _ISOButton)
        {
            [_ISO_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _whiteBalanceButton)
        {
            [_whiteBalance_slider removeFromSuperview];
        }
        _preSelectedButton = _ISOButton;
    }
    
}

- (IBAction)chooseWhiteBalance:(id)sender {
    if (self.sliderBarKind != isWhiteBalanceMode) {
        [self addWhiteBalanceSliderBar];
        [self setSliderBarKind:isWhiteBalanceMode];
        [_whiteBalanceButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:0.f alpha:1.f] forState:UIControlStateNormal];
        [_preSelectedButton setTitleColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f] forState:UIControlStateNormal];
        if (_preSelectedButton == _exposeButton) {
            [_expose_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _focusButton)
        {
            [_focus_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _secButton)
        {
            [_sec_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _ISOButton)
        {
            [_ISO_slider removeFromSuperview];
        }
        else if(_preSelectedButton == _whiteBalanceButton)
        {
            [_whiteBalance_slider removeFromSuperview];
        }
        _preSelectedButton = _whiteBalanceButton;
    }
}

//闪光灯设置

-(void)flashAnimation{
    //UILabel *homeLabel = [self createHomeButtonView];
    _homeBtn  = [self createHomeButtonView];
    [_homeBtn addTarget:self action:@selector(homeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    MTBubbleButton *menuView = [[MTBubbleButton alloc] initWithFrame:CGRectMake(20, 20, _homeBtn.frame.size.width, _homeBtn.frame.size.height) expansionDirection:DirectionRight];
    menuView.homeButtonView = _homeBtn;
    [menuView addButtons:[self createDemoButtonArray]];
    _flashMenu = menuView;
    [self.preview addSubview:_flashMenu];
}

- (void)homeButtonClick{
    if (!_flashMenu.isCollapsed) {
        [_homeBtn setImage:[UIImage imageNamed:_lastFlashMode] forState:UIControlStateNormal];
        [_homeBtn setTitle:@"" forState:UIControlStateNormal];
        [_flashMenu dismissButtons];
    }
    else{
        [_homeBtn setImage:nil forState:UIControlStateNormal];
        [_homeBtn setTitle:@"收回" forState:UIControlStateNormal];
        [_flashMenu showButtons];
    }
}

- (UIButton *)createHomeButtonView {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 40.f, 40.f)];
    [button setImage:[UIImage imageNamed:@"Camera-FlashAuto"] forState:UIControlStateNormal];
    button.layer.cornerRadius = button.frame.size.height / 2.f;
    button.backgroundColor =[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    button.clipsToBounds = YES;
    return button;
}

- (NSArray *)createDemoButtonArray {
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (NSString *imageName in @[@"Camera-FlashAuto", @"Camera-Flash", @"Camera-FlashNone", @"Camera-FlashAlways"]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
        
        button.clipsToBounds = YES;
        button.tag = i++;
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonsMutable addObject:button];
    }
    return [buttonsMutable copy];
}
- (void)buttonClick:(UIButton *)sender {
    NSLog(@"DWButton tapped, tag: %ld", (long)sender.tag);
    switch ((int)sender.tag) {
        case 0:
            [_homeBtn setImage:[UIImage imageNamed:@"Camera-FlashAuto"] forState:UIControlStateNormal];
            [_cameraManager setFlashMode:CameraManagerFlashModeAuto];
            _lastFlashMode = @"Camera-FlashAuto";
            [_homeBtn setTitle:@"" forState:UIControlStateNormal];
            break;
        case 1:
            [_homeBtn setImage:[UIImage imageNamed:@"Camera-Flash"] forState:UIControlStateNormal];
            [_cameraManager setFlashMode:CameraManagerFlashModeOn];
            _lastFlashMode = @"Camera-Flash";
            [_homeBtn setTitle:@"" forState:UIControlStateNormal];
            break;
        case 2:
            [_homeBtn setImage:[UIImage imageNamed:@"Camera-FlashNone"] forState:UIControlStateNormal];
            [_cameraManager setFlashMode:CameraManagerFlashModeOff];
            _lastFlashMode = @"Camera-FlashNone";
            [_homeBtn setTitle:@"" forState:UIControlStateNormal];
            break;
        case 3:
            [_homeBtn setImage:[UIImage imageNamed:@"Camera-FlashAlways"] forState:UIControlStateNormal];
            [_cameraManager setFlashMode:CameraManagerFlashModeOpen];
            _lastFlashMode = @"Camera-FlashAlways";
            [_homeBtn setTitle:@"" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark 滤镜

//选择滤镜
- (void)switchCameraFilter:(NSInteger)index {
    [self.cameraManager removeAllTargets];
    switch (index) {
        case 0:
            _filter = [[GPUImageFilter alloc] init];//原图
            [_checkVC setFilterCode:0];
            break;
        case 1:
            _filter = [[GPUImageBeautifyFilter alloc] init];//绿巨人
            [_checkVC setFilterCode:1];
            break;
        case 2:
            _filter = [[GPUImageColorInvertFilter alloc] init];//负片
            [_checkVC setFilterCode:2];
            break;
        case 3:
            _filter = [[GPUImageSepiaFilter alloc] init];//老照片
            [_checkVC setFilterCode:3];
            break;
        case 4: {
            _filter = [[GPUImageGaussianBlurPositionFilter alloc] init];
            [(GPUImageGaussianBlurPositionFilter*)_filter setBlurRadius:40.0/320.0];
            [_checkVC setFilterCode:4];
        }
            break;
        case 5:
            _filter = [[GPUImageMedianFilter alloc] init];
            [_checkVC setFilterCode:5];
            break;
        case 6:
            _filter = [[GPUImageVignetteFilter alloc] init];//黑晕
            [_checkVC setFilterCode:6];
            break;
        case 7:
            _filter = [[GPUImageKuwaharaRadius3Filter alloc] init];
            [_checkVC setFilterCode:7];
            break;
        case 8:
            _filter = [[GPUImageBilateralFilter alloc] init];
            [_checkVC setFilterCode:8];
        default:
            _filter = [[GPUImageFilter alloc] init];
            [_checkVC setFilterCode:0];
            break;
    }
    
    [self.cameraManager addTarget:_filter];
    [_filter addTarget:_filterView];
}

#pragma mark 拍照

- (IBAction)takePhoto:(id)sender {
    _photoOutput = [_cameraManager getPhotoOutput];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [_photoOutput setOutputSettings:outputSettings];
    AVCaptureConnection *captureConnection=[_photoOutput connectionWithMediaType:AVMediaTypeVideo];
    //根据连接取得设备输出的数据
    [_photoOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image =[UIImage imageWithData:imageData];
            _checkVC.image = image;
            [self.navigationController pushViewController:_checkVC animated:YES];
        }
    }];
}

#pragma mark 转置摄像头

- (void)turn{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_cameraManager rotateCamera];
        [self.cameraManager addTarget:_filter];
        _filterView = (GPUImageView *)self.preview;
        [_filter addTarget:_filterView];
        [self focusDisdance];
        [self exposeRate];
        [self whiteBalanceRate];
        [self ISORate];
        [self secRate];
    });
    [self performSelector:@selector(animationCamera) withObject:self afterDelay:0.2f];
}

- (void) animationCamera {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    if (self.cameraManager.cameraPosition == AVCaptureDevicePositionFront) {
        animation.subtype = kCATransitionFromRight;
    }
    else if(self.cameraManager.cameraPosition == AVCaptureDevicePositionBack)
        animation.subtype = kCATransitionFromLeft;
    [self.cameraView.layer addAnimation:animation forKey:nil];
}
#pragma mark 调整焦距

- (void)focusDisdance{
    [_enlargeLabel setText:[NSString stringWithFormat:@"%.1fX",_slider.value]];
    [_cameraManager focusDisdanceWithSliderValue:_slider.value];
}

#pragma mark 调整曝光
//设置曝光
- (void)exposeRate{
    [_cameraManager exposeRateWithSliderValue:_expose_slider.value];
}

- (void)focusRate{
    [_cameraManager focusRateWithSliderValue:_focus_slider.value];
    
}

- (void)whiteBalanceRate{
    [_cameraManager whiteBalanceWithSliderValue:_whiteBalance_slider.value];
}

- (void)ISORate{
    [_cameraManager ISORateWithSliderValue:_ISO_slider.value];
}

- (void)secRate{
    [_cameraManager secRateWithSliderValue:_sec_slider.value];
}


- (void)refreshUI{
    NSLog(@"refresh");
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
