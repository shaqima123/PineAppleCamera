//
//  PAStillCamera.h
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import <GPUImage.h>

//自定义头文件
#import "PAEnumMacro.h"

/**
 *  自定义相机类
 */

@interface PAStillCamera : GPUImageStillCamera

@property (strong ,nonatomic) UIView *preview;//预览视图
@property (strong ,nonatomic) UIView *cameraView;
@property (strong ,nonatomic) UIImageView *focusImageView;//聚焦ImageView
@property (strong ,nonatomic) UIImageView *exposeImageView;//曝光ImageView
@property (strong ,nonatomic) UIImageView *autoFocusImageView;//自动聚焦曝光ImageView

@property (nonatomic , copy)  UITapGestureRecognizer *singleTap;
@property (nonatomic , copy)  UITapGestureRecognizer *doubleTap;
@property (nonatomic , copy)  UIPanGestureRecognizer *panOfAutoImageView;
@property (nonatomic , copy)  UIPinchGestureRecognizer *pinch;
@property (nonatomic , copy)  UIPanGestureRecognizer *panOfPartFocusView;
@property (nonatomic , copy)  UIPanGestureRecognizer *panOfPartExposeView;

@property AVCaptureStillImageOutput *photoOutput;

@property (nonatomic , assign) TouchState touchState;
@property (nonatomic , assign) CameraManagerFlashMode flashMode;

/**
 *   初始化相机
 *   默认初始化相机为前置相机，前置摄像为镜像，后置非镜像
 *   默认闪光灯为自动闪光模式
 *   默认聚焦状态为自动聚焦
 *   @param     cameraPosition  相机位置
 *
 *   @return  id 相机实例
 */
- (id)initWithCameraPosition:(AVCaptureDevicePosition) cameraPosition;

/**
 *   设置闪光灯模式功能
 *
 *   @param     flashMode  闪光灯模式
 *
 *   @return  无
 */
- (void)setFlashMode:(CameraManagerFlashMode)flashMode;


/**
 *   转置相机
 *
 *   @param   无
 *
 *   @return  无
 */
- (void) rotateCamera;

/**
 *   设置聚焦图片
 *
 *   @param    image  自动聚焦图片（包括曝光）
 *
 *   @return  无
 */
- (void)setAutoFocusImage:(UIImage *)image;

/**
 *   设置聚焦图片
 *
 *   @param    focusImage 聚焦图片  exposeImage 曝光图片
 *
 *   @return  无
 */
- (void)setFocusAndExposeImage:(UIImage *)focusImage and:(UIImage *)exposeImage;

/**
 *   调整焦距功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)focusDisdanceWithSliderValue:(float)sliderValue;


/**
 *   调整曝光值功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)exposeRateWithSliderValue:(float)sliderValue;

/**
 *   调整聚焦值功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)focusRateWithSliderValue:(float)sliderValue;

/**
 *   调整曝光时间功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)secRateWithSliderValue:(float)sliderValue;


/**
 *   调整ISO功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)ISORateWithSliderValue:(float)sliderValue;


/**
 *   调整白平衡功能
 *
 *   @param    sliderValue  浮点值，通常为slider控件的value值
 *
 *   @return  无
 */
- (void)whiteBalanceWithSliderValue:(float)sliderValue;
- (float)getCurrentTemperature;

/**
 *   添加所有默认手势（包括以下六种）
 *
 *   @param   无
 *
 *   @return  无
 */
- (void)addGesturesToCamera;

/**
 *   手势添加功能
 *
 *   @param   无
 *
 *   @return  无
 */
- (void)addSingleTapToPreview;//在preview上添加tap手势
- (void)addDoubleTapToPreview;//在preview上添加双击手势
- (void)addPinchGestureToPreview;//在preview上添加pinch手势

- (void)addPanGestureToAutoImageView;//在autoImageView上添加拖动手势
- (void)addPanGestureToFocusImageView;//在focusImageView上添加拖动手势
- (void)addPanGestureToExposeImageView;//在exposeImageView上添加拖动手势

- (AVCaptureDeviceFormat *)getActiveFormat;

@end
