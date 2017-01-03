//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import <GPUImage.h>

@class GPUImageCombinationFilter;

@interface GPUImageBeautifyFilter : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;//双边模糊
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;//边缘检测算法（黑白对比度较强）
    GPUImageCombinationFilter *combinationFilter;//自定义的三输入滤波器
    GPUImageHSBFilter *hsbFilter;
}

@end
