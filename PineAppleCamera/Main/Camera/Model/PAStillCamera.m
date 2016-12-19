//
//  PAStillCamera.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PAStillCamera.h"

//自定义头文件

#import "PAUtilsMacro.h"

typedef void (^CompleteHandleBlock)(double intervalTime);

@interface PAStillCamera()
{
    CALayer *_focusLayer; //聚焦层
}

@property (nonatomic , assign) CGFloat beginGestureScale;//开始的缩放比例
@property (nonatomic , assign) CGFloat effectiveScale;//最后的缩放比例
@property (nonatomic , assign) CGFloat minExposureRate;//最小曝光率
@property (nonatomic , assign) CGFloat maxExposureRate;//最高曝光率

@property double startTime;
@property double endTime;
@property double intervalTime;

@property (nonatomic, copy) void(^timeBlock)(double intervalTime);

@end


@implementation PAStillCamera
#pragma mark init方法
/** 初始化相机方法，参数为cameraPosition，默认预置为原图 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self = [super initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
    }
    self.beginGestureScale = 1.0f;
    self.effectiveScale = 1.0f;
    self.minExposureRate = 1.0f;
    self.maxExposureRate = 1.0f;
    
    self.outputImageOrientation = UIInterfaceOrientationPortrait;//设置照片的方向为设备的定向
    self.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    self.horizontallyMirrorRearFacingCamera = NO;
    [self setFlashMode:CameraManagerFlashModeAuto];
    [self setTouchState:AutoFocusAndExpose];
    [self startCameraCapture];
    
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    
    
    return self;
}

/** 全能相机初始化方法 */
- (id)initWithCameraPosition:(AVCaptureDevicePosition) cameraPosition{
    return [self initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:cameraPosition];
}


#pragma mark 聚焦曝光

/** 设置聚焦曝光图片 */
- (void)setAutoFocusImage:(UIImage *)image{
    if (!image) return;
    if (!_focusLayer) {
        _autoFocusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _autoFocusImageView.image = image;
        CALayer *layer = _autoFocusImageView.layer;
        layer.hidden = YES;
        [self.preview.layer addSublayer:layer];
        _focusLayer = layer;
    }
}

/** 分别设置聚焦图片和曝光图片 */
- (void)setFocusAndExposeImage:(UIImage *)focusImage and:(UIImage *)exposeImage {
    _focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,70.0f,70.0f)];
    _exposeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,80.0f,80.0f)];
    _focusImageView.image = focusImage;
    _exposeImageView.image = exposeImage;
    [self.preview addSubview:_exposeImageView];
    [self.preview addSubview:_focusImageView];
    [_exposeImageView setHidden:YES];
    [_focusImageView setHidden:YES];
}


/** 给preview增加pinch手势 */
- (void)addPinchGestureToPreview{
    if (_preview) {
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExpose:)];
        [self.preview addGestureRecognizer:_pinch];
        //pinch.delegate = self;
    }
    else{
        NSLog(@"Please init the preview first.");
    }
}

/** 给preview增加tap手势（单击）*/
- (void)addSingleTapToPreview{
    if (_preview) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusFunction:)];
        [_singleTap setNumberOfTapsRequired:1];
        [self.preview addGestureRecognizer:_singleTap];
        //        if (_doubleTap) {
        //            [_singleTap requireGestureRecognizerToFail:_doubleTap];
        //        }
    }
    else{
        NSLog(@"Please init the preview first.");
    }
}

/** 给preview增加tap手势（双击）*/
- (void)addDoubleTapToPreview{
    if (_preview) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toFocus:)];
        [_doubleTap setNumberOfTapsRequired:2];
        [self.preview addGestureRecognizer:_doubleTap];
    }
    else{
        NSLog(@"Please init the preview first.");
    }
}

/** 给聚焦曝光图片设置pan手势 */
- (void)addPanGestureToAutoImageView{
    if (_autoFocusImageView) {
        _panOfAutoImageView = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAutoFocus:)];
        [_autoFocusImageView setUserInteractionEnabled:YES];
        [_autoFocusImageView addGestureRecognizer:_panOfAutoImageView];
        //pan.delegate = self;
    }
    else{
        NSLog(@"Please init the autoFocusImageView first.");
    }
}

/** 给聚焦图片增加pan手势 */
- (void)addPanGestureToFocusImageView{
    if (_focusImageView) {
        _panOfPartFocusView = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPartFocus:)];
        [_focusImageView addGestureRecognizer:_panOfPartFocusView];
        [_focusImageView setUserInteractionEnabled:YES];
        // pan1.delegate = self;
    }
    else{
        NSLog(@"Please init the focusImageView first.");
    }
}

/** 给曝光图片增加pan手势 */
- (void)addPanGestureToExposeImageView{
    if (_exposeImageView) {
        _panOfPartExposeView = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPartExpose:)];
        [_exposeImageView addGestureRecognizer:_panOfPartExposeView];
        [_exposeImageView setUserInteractionEnabled:YES];
        //pan2.delegate = self;
    }
    else{
        NSLog(@"Please init the exposeImageView first.");
    }
}

/** 一次给相机添加所有手势 */
- (void)addGesturesToCamera{
    if (_preview) {
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(focusAndExpose:)];
        [self.preview addGestureRecognizer:_pinch];
        //pinch.delegate = self;
        
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusFunction:)];
        [_singleTap setNumberOfTapsRequired:1];
        [self.preview addGestureRecognizer:_singleTap];
        
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toFocus:)];
        [_doubleTap setNumberOfTapsRequired:2];
        [self.preview addGestureRecognizer:_doubleTap];
        
        //        if (_doubleTap) {
        //            [_singleTap requireGestureRecognizerToFail:_doubleTap];
        //        }
        //
        //        if (_pinch) {
        //            [_singleTap requireGestureRecognizerToFail:_pinch];
        //        }
        
    }
    else{
        NSLog(@"Please init the preview first.");
    }
    
    if (_focusImageView) {
        _panOfPartFocusView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPartFocus:)];
        [_focusImageView addGestureRecognizer:_panOfPartFocusView];
        [_focusImageView setUserInteractionEnabled:YES];
        // pan1.delegate = self;
    }
    else{
        NSLog(@"Please init the focusImageView first.");
    }
    if (_exposeImageView) {
        _panOfPartExposeView = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPartExpose:)];
        [_exposeImageView addGestureRecognizer:_panOfPartExposeView];
        [_exposeImageView setUserInteractionEnabled:YES];
        //pan2.delegate = self;
    }
    else{
        NSLog(@"Please init the exposeImageView first.");
    }
    
    if (_autoFocusImageView) {
        _panOfAutoImageView = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAutoFocus:)];
        [_autoFocusImageView setUserInteractionEnabled:YES];
        [_autoFocusImageView addGestureRecognizer:_panOfAutoImageView];
        //pan.delegate = self;
    }
    else{
        NSLog(@"Please init the autoFocusImageView first.");
    }
}


/** 对焦 */

- (void)focusFunction:(UITapGestureRecognizer *)tap{
    [self focus:tap complete:^(double intervalTime) {
        //NSLog(@"聚焦时间:%f",intervalTime);
    }];
}
- (void)focus:(UITapGestureRecognizer *)tap complete:(CompleteHandleBlock)completeHandlBlock {
    self.preview.userInteractionEnabled = NO;
    CGPoint touchPoint = [tap locationInView:tap.view];
    
    switch (self.touchState) {
        case AutoFocusAndExpose:
        case ManualFocusAndExpose:
            self.touchState = ManualFocusAndExpose;
            [self layerAnimationWithPoint:touchPoint];
            
            if(self.cameraPosition == AVCaptureDevicePositionBack){
                touchPoint = CGPointMake( touchPoint.y /tap.view.bounds.size.height ,1-touchPoint.x/tap.view.bounds.size.width);
            }
            else
                touchPoint = CGPointMake(touchPoint.y /tap.view.bounds.size.height ,touchPoint.x/tap.view.bounds.size.width);
            
            //将x、y坐标交换是为了解决照相机焦点坐标轴和屏幕坐标轴的映射问题
            if([self.inputCamera isExposurePointOfInterestSupported] && [self.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                NSError *error;
                if ([self.inputCamera lockForConfiguration:&error]) {
                    
                    [self.inputCamera setExposurePointOfInterest:touchPoint];
                    [self.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    if ([self.inputCamera isFocusPointOfInterestSupported] && [self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                        [self.inputCamera setFocusPointOfInterest:touchPoint];
                        [self.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
                    }
                    [self.inputCamera unlockForConfiguration];
                    
                    completeHandlBlock(_intervalTime);
                } else {
                    NSLog(@"ERROR = %@", error);
                }
            }
            break;
        case PartFocusAndExpose:
            self.touchState = PartFocusAndExpose;
            [_focusImageView setCenter:touchPoint];
            
            if(self.cameraPosition == AVCaptureDevicePositionBack){
                touchPoint = CGPointMake( touchPoint.y /tap.view.bounds.size.height ,1-touchPoint.x/tap.view.bounds.size.width);
            }
            else
                touchPoint = CGPointMake(touchPoint.y /tap.view.bounds.size.height ,touchPoint.x/tap.view.bounds.size.width);
            NSError *error;
            if ([self.inputCamera lockForConfiguration:&error]) {
                if ([self.inputCamera isFocusPointOfInterestSupported] && [self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    [self.inputCamera setFocusPointOfInterest:touchPoint];
                    [self.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
                }
                [self.inputCamera unlockForConfiguration];
            }else{
                NSLog(@"ERROR = %@",error);
            }
            self.preview.userInteractionEnabled = YES;
            break;
    }
    
}
/** 自动对焦 */
- (void)toFocus:(UITapGestureRecognizer *)tap{
    self.preview.userInteractionEnabled = NO;
    CGPoint touchPoint = CGPointMake(_preview.bounds.size.width/2, _preview.bounds.size.height/2);
    
    switch (self.touchState) {
        case AutoFocusAndExpose:
        case ManualFocusAndExpose:
        case PartFocusAndExpose:
            self.touchState = AutoFocusAndExpose;
            [_autoFocusImageView setHidden:NO];
            [_focusImageView setHidden:YES];
            [_exposeImageView setHidden:YES];
            [_autoFocusImageView setCenter:touchPoint];
            
            if(self.cameraPosition == AVCaptureDevicePositionBack){
                touchPoint = CGPointMake( touchPoint.y /tap.view.bounds.size.height ,1-touchPoint.x/tap.view.bounds.size.width);
            }
            else
                touchPoint = CGPointMake(touchPoint.y /tap.view.bounds.size.height ,touchPoint.x/tap.view.bounds.size.width);
            
            NSError *error;
            if ([self.inputCamera lockForConfiguration:&error]) {
                if ([self.inputCamera isFocusPointOfInterestSupported] && [self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    [self.inputCamera setFocusPointOfInterest:touchPoint];
                    [self.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
                }
                [self.inputCamera unlockForConfiguration];
            }else{
                NSLog(@"ERROR = %@",error);
            }
            break;
    }
    NSNotification * notice = [NSNotification notificationWithName:@"123" object:nil userInfo:@{@"post":@YES}];
    //发送消息
    [[NSNotificationCenter defaultCenter] postNotification:notice];
    self.preview.userInteractionEnabled = YES;
}

/** 对焦与曝光分离 */
- (void)focusAndExpose:(UIPinchGestureRecognizer *)pinch {
    switch (self.touchState) {
        case AutoFocusAndExpose:
        case ManualFocusAndExpose:
        case PartFocusAndExpose:
            [self setTouchState:PartFocusAndExpose];
            self.preview.userInteractionEnabled = NO;
            _focusLayer.hidden = YES;
            int touchCount = pinch.numberOfTouches;
            if (touchCount == 2) {
                CGPoint point1 = [pinch locationOfTouch:0 inView:pinch.view];
                CGPoint point2 = [pinch locationOfTouch:1 inView:pinch.view];
                [_exposeImageView setHidden:NO];
                [_focusImageView setHidden:NO];
                [_exposeImageView setCenter:point2];
                [_focusImageView setCenter:point1];
            }
            self.preview.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
}

/** 拖动自动对焦框 */
- (void)panAutoFocus:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint;
    self.autoFocusImageView.userInteractionEnabled = NO;
    if (pan.state != UIGestureRecognizerStateFailed) {
        CGPoint translation=[pan translationInView:self.cameraView];
        float x = _autoFocusImageView.center.x + translation.x;
        float y = _autoFocusImageView.center.y + translation.y;
        if (x < 0) {
            x = 0;
        }
        if (x > self.preview.frame.size.width) {
            x = self.preview.frame.size.width;
        }
        if (y < 0) {
            y = 0;
        }
        if (y > self.preview.frame.size.height) {
            y = self.preview.frame.size.height;
        }
        touchPoint = CGPointMake(x,y);
        _autoFocusImageView.center = touchPoint;
        [pan setTranslation:CGPointZero inView:self.cameraView];
    }
    if(pan.state == UIGestureRecognizerStateEnded)
    {
        if(self.cameraPosition == AVCaptureDevicePositionBack){
            touchPoint = CGPointMake( touchPoint.y /_preview.bounds.size.height ,1-touchPoint.x/_preview.bounds.size.width);
        }
        else
            touchPoint = CGPointMake(touchPoint.y /_preview.bounds.size.height ,touchPoint.x/_preview.bounds.size.width);
        
        //将x、y坐标交换是为了解决照相机焦点坐标轴和屏幕坐标轴的映射问题
        if([self.inputCamera isExposurePointOfInterestSupported] && [self.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            NSError *error;
            if ([self.inputCamera lockForConfiguration:&error]) {
                [self.inputCamera setExposurePointOfInterest:touchPoint];
                [self.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                if ([self.inputCamera isFocusPointOfInterestSupported] && [self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    [self.inputCamera setFocusPointOfInterest:touchPoint];
                    [self.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
                }
                [self.inputCamera unlockForConfiguration];
            } else {
                NSLog(@"ERROR = %@", error);
            }
        }
    }
    self.autoFocusImageView.userInteractionEnabled = YES;
}

/** 拖动分离对焦框 */
- (void)panPartFocus:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint;
    self.focusImageView.userInteractionEnabled = NO;
    if (pan.state != UIGestureRecognizerStateFailed) {
        CGPoint translation=[pan translationInView:self.cameraView];
        float x = _focusImageView.center.x + translation.x;
        float y = _focusImageView.center.y + translation.y;
        if (x < 0) {
            x = 0;
        }
        if (x > self.preview.frame.size.width) {
            x = self.preview.frame.size.width;
        }
        if (y < 0) {
            y = 0;
        }
        if (y > self.preview.frame.size.height) {
            y = self.preview.frame.size.height;
        }
        touchPoint = CGPointMake(x,y);
        _focusImageView.center = touchPoint;
        [pan setTranslation:CGPointZero inView:self.cameraView];
    }
    
    if(pan.state == UIGestureRecognizerStateEnded)
    {
        if(self.cameraPosition == AVCaptureDevicePositionBack){
            touchPoint = CGPointMake( touchPoint.y /_preview.bounds.size.height ,1-touchPoint.x/_preview.bounds.size.width);
        }
        else
            touchPoint = CGPointMake(touchPoint.y /_preview.bounds.size.height ,touchPoint.x/_preview.bounds.size.width);
        //将x、y坐标交换是为了解决照相机焦点坐标轴和屏幕坐标轴的映射问题
        
        NSError *error;
        if ([self.inputCamera lockForConfiguration:&error]) {
            if ([self.inputCamera isFocusPointOfInterestSupported] && [self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                [self.inputCamera setFocusPointOfInterest:touchPoint];
                [self.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            }
            [self.inputCamera unlockForConfiguration];
        }else{
            NSLog(@"ERROR = %@",error);
        }
        
    }
    self.focusImageView.userInteractionEnabled = YES;
}

/** 拖动分离曝光框 */
- (void)panPartExpose:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint;
    self.exposeImageView.userInteractionEnabled = NO;
    if (pan.state != UIGestureRecognizerStateFailed) {
        CGPoint translation=[pan translationInView:self.cameraView];
        NSLog(@"x = %f,y = %f",translation.x,translation.y);
        float x = _exposeImageView.center.x + translation.x;
        float y = _exposeImageView.center.y + translation.y;
        if (x < 0) {
            x = 0;
        }
        if (x > self.preview.frame.size.width) {
            x = self.preview.frame.size.width;
        }
        if (y < 0) {
            y = 0;
        }
        if (y > self.preview.frame.size.height) {
            y = self.preview.frame.size.height;
        }
        touchPoint = CGPointMake(x,y);
        _exposeImageView.center = touchPoint;
        [pan setTranslation:CGPointZero inView:self.cameraView];
    }
    
    if(pan.state == UIGestureRecognizerStateEnded)
    {
        if(self.cameraPosition == AVCaptureDevicePositionBack){
            touchPoint = CGPointMake( touchPoint.y /_preview.bounds.size.height ,1-touchPoint.x/_preview.bounds.size.width);
        }
        else
            touchPoint = CGPointMake(touchPoint.y /_preview.bounds.size.height ,touchPoint.x/_preview.bounds.size.width);
        
        //将x、y坐标交换是为了解决照相机焦点坐标轴和屏幕坐标轴的映射问题
        
        if([self.inputCamera isExposurePointOfInterestSupported] && [self.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
        {
            NSError *error;
            if ([self.inputCamera lockForConfiguration:&error]) {
                [self.inputCamera setExposurePointOfInterest:touchPoint];
                [self.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                [self.inputCamera unlockForConfiguration];
            } else {
                NSLog(@"ERROR = %@", error);
            }
        }
        
    }
    self.exposeImageView.userInteractionEnabled = YES;
}

/** layer层聚焦动画实现 */
- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

/** 动画的delegate方法 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:0.5f];
}

/** focusLayer回到初始化状态 */
- (void)focusLayerNormal {
    self.preview.userInteractionEnabled = YES;
    // _focusLayer.hidden = YES;
}

#pragma mark 闪光灯设置

/** 设置闪光灯模式 */
- (void)setFlashMode:(CameraManagerFlashMode)flashMode {
    _flashMode = flashMode;
    
    switch (flashMode) {
        case CameraManagerFlashModeAuto: {
            [self.inputCamera lockForConfiguration:nil];
            if ([self.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.inputCamera setFlashMode:AVCaptureFlashModeAuto];
                if (self.inputCamera.torchMode == AVCaptureTorchModeOn) {
                    [self.inputCamera setTorchMode:AVCaptureTorchModeOff];
                }
            }
            [self.inputCamera unlockForConfiguration];
        }
            break;
        case CameraManagerFlashModeOff: {
            [self.inputCamera lockForConfiguration:nil];
            if ([self.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.inputCamera setFlashMode:AVCaptureFlashModeOff];
                if (self.inputCamera.torchMode == AVCaptureTorchModeOn) {
                    [self.inputCamera setTorchMode:AVCaptureTorchModeOff];
                }
            }
            [self.inputCamera unlockForConfiguration];
        }
            
            break;
        case CameraManagerFlashModeOn: {
            [self.inputCamera lockForConfiguration:nil];
            if ([self.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.inputCamera setFlashMode:AVCaptureFlashModeOn];
                if (self.inputCamera.torchMode == AVCaptureTorchModeOn) {
                    [self.inputCamera setTorchMode:AVCaptureTorchModeOff];
                }
                
            }
            [self.inputCamera unlockForConfiguration];
        }
            break;
        case CameraManagerFlashModeOpen:{
            [self.inputCamera lockForConfiguration:nil];
            if ([self.inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
                [self.inputCamera setTorchMode:AVCaptureTorchModeOn];
            }
            if ([self.inputCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.inputCamera setFlashMode:AVCaptureFlashModeOff];
            }
            [self.inputCamera unlockForConfiguration];
        }
        default:
            break;
    }
}

#pragma mark 转置相机
/** 转置相机 */
- (void) rotateCamera{
    [self stopCameraCapture];
    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        [self initWithCameraPosition:AVCaptureDevicePositionBack];
    }
    else if(self.cameraPosition == AVCaptureDevicePositionBack)
    {
        [self initWithCameraPosition:AVCaptureDevicePositionFront];
    }
    self.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.horizontallyMirrorFrontFacingCamera = YES;
    self.horizontallyMirrorRearFacingCamera = NO;
    [self startCameraCapture];
}


#pragma mark 调整焦距
/** 调整焦距 */
- (void)focusDisdanceWithSliderValue:(float)sliderValue{
    self.effectiveScale = self.beginGestureScale * sliderValue;
    if (self.effectiveScale < 1.0f) {
        self.effectiveScale = 1.0f;
    }
    CGFloat maxScaleAndCropFactor = 6.0f;
    if (self.effectiveScale > maxScaleAndCropFactor)
        self.effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    NSError *error;
    if([self.inputCamera lockForConfiguration:&error]){
        [self.inputCamera setVideoZoomFactor:self.effectiveScale];
        [self.inputCamera unlockForConfiguration];
    }
    else {
        NSLog(@"ERROR = %@", error);
    }
    [CATransaction commit];
}

#pragma mark 调整曝光值
/** 调整曝光补偿 */
- (void)exposeRateWithSliderValue:(float)sliderValue{
    NSError *error;
    if ([self.inputCamera lockForConfiguration:&error]) {
        [self.inputCamera setExposureTargetBias:self.minExposureRate * sliderValue completionHandler:^(CMTime syncTime) {
            NSLog(@"手动曝光补偿时间戳:");
            CMTimeShow(syncTime);
        }];
        
        //        [self.inputCamera setFocusModeLockedWithLensPosition:sliderValue completionHandler:^(CMTime syncTime) {
        //            CMTimeShow(syncTime);
        //        }];
        [self.inputCamera unlockForConfiguration];
    } else {
        NSLog(@"ERROR = %@", error);
    }
    
}

#pragma mark 调整聚焦值
/** 调整聚焦值 */
- (void)focusRateWithSliderValue:(float)sliderValue{
    NSError *error;
    if ([self.inputCamera lockForConfiguration:&error]) {
        if([self.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
            [self.inputCamera setFocusModeLockedWithLensPosition:sliderValue completionHandler:^(CMTime syncTime) {
                NSLog(@"手动聚焦时间戳:");
                CMTimeShow(syncTime);//所施加的透镜位置获取第一个图像缓存的时间戳
            }];
        }
        [self.inputCamera unlockForConfiguration];
    } else {
        NSLog(@"ERROR = %@", error);
    }
    
}

#pragma mark 调整白平衡
/** 调整白平衡 */

- (float)getCurrentTemperature{
    AVCaptureWhiteBalanceGains x = self.inputCamera.deviceWhiteBalanceGains;
    AVCaptureWhiteBalanceTemperatureAndTintValues para = [self.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:x];
    return para.temperature;
}
- (void)whiteBalanceWithSliderValue:(float)sliderValue{
    NSError *error;
    if (sliderValue) {
        if ([self.inputCamera lockForConfiguration:&error]){
            int incandescentLightCompensation = sliderValue;
            int tint = 1;
            AVCaptureWhiteBalanceTemperatureAndTintValues para = {incandescentLightCompensation,tint};
            AVCaptureWhiteBalanceGains whiteBalanceGains = [self.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:para];
            [self.inputCamera setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:whiteBalanceGains completionHandler:^(CMTime syncTime) {
                NSLog(@"白平衡时间戳:");
                CMTimeShow(syncTime);
            }];
            
            [self.inputCamera unlockForConfiguration];
        }
        else{
            NSLog(@"ERROR = %@",error);
        }
    }
}


#pragma mark 调整ISO
/** 调整ISO */
- (void)ISORateWithSliderValue:(float)sliderValue{
    NSError *error;
    if (sliderValue) {
        if ([self.inputCamera lockForConfiguration:&error]) {
            [self.inputCamera setExposureModeCustomWithDuration:self.inputCamera.exposureDuration ISO:sliderValue completionHandler:^(CMTime syncTime) {
                NSLog(@"ISO调整时间戳:");
                CMTimeShow(syncTime);
            }];
            [self.inputCamera unlockForConfiguration];
        }
        else{
            NSLog(@"ERROR = %@",error);
        }
    }
}

#pragma mark 调整曝光时间
/** 调整曝光时间 */
- (void)secRateWithSliderValue:(float)sliderValue{
    NSError *error;
    if (sliderValue) {
        CMTime sec = CMTimeMake(sliderValue * 10000,10000);
        if ([self.inputCamera lockForConfiguration:&error]) {
            [self.inputCamera setExposureModeCustomWithDuration:sec ISO:self.inputCamera.ISO completionHandler:^(CMTime syncTime) {
                NSLog(@"sec调整时间戳:");
                CMTimeShow(syncTime);
            }];
            [self.inputCamera unlockForConfiguration];
        }
        else{
            NSLog(@"ERROR = %@",error);
        }
    }
}

- (AVCaptureDeviceFormat *)getActiveFormat{
    return self.inputCamera.activeFormat;
}

- (void)refresh{
    
}
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        BOOL adjustingFocus =[[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ?@"YES":@"NO");
        NSLog(@"Change dictionary: %@", change);
        if (adjustingFocus) {
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%f", a];
            _startTime = [timeString doubleValue];
        }
        else{
            NSDate* dat1 = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval b=[dat1 timeIntervalSince1970];
            NSString *timeString2 = [NSString stringWithFormat:@"%f", b];
            _endTime = [timeString2 doubleValue];
            _intervalTime = _endTime - _startTime;
            
            NSLog(@"聚焦时间为%f",_intervalTime);
            
        }
    }
}

@end
