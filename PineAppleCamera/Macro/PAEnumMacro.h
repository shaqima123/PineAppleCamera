//
//  PAEnumMacro.h
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#ifndef PAEnumMacro_h
#define PAEnumMacro_h


#endif /* PAEnumMacro_h */

/**
 * 相机闪光灯模式
 */
typedef NS_ENUM(NSInteger, CameraManagerFlashMode) {
    
    CameraManagerFlashModeAuto,  /**< 自动模式 */
    
    CameraManagerFlashModeOff,  /**< 闪光灯关闭模式 */
    
    CameraManagerFlashModeOn,  /**< 闪光灯打开模式 */
    
    CameraManagerFlashModeOpen  /**< 闪光灯常亮模式 */
};


/**
 * 聚焦状态
 */
typedef NS_ENUM(NSInteger,TouchState){
    
    AutoFocusAndExpose,/**< 自动聚焦曝光状态 */
    
    ManualFocusAndExpose,/**< 手动聚焦曝光状态 */
    
    PartFocusAndExpose/**< 聚焦曝光分离状态 */
};

//Sliderbar Mode
typedef NS_ENUM(NSInteger,SliderBarKind) {
    
    isExposeMode,
    
    isSecMode,
    
    isISOMode,
    
    isFocusMode,
    
    isWhiteBalanceMode,
    
};
