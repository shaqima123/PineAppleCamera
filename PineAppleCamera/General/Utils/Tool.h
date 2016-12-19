//
//  Tool.h
//  helloMeitu
//
//  Created by meitu on 16/7/13.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface Tool : NSObject
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
+ (UIImage *)pa_cmSampleBufferRefToUIImage:(CMSampleBufferRef)sampleBuffer;
@end
