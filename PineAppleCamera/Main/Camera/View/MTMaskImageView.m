//
//  MTMaskImageView.m
//  helloMeitu
//
//  Created by shaqima on 16/8/10.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "MTMaskImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTMaskImageView
@synthesize thumImageView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)showEnlargeViewWithPoint:(CGPoint)point{
    thumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,100,100)];
    thumImageView.center = point;
    [self addSubview:thumImageView];
    UIImage *image = [self getImageInPoint:point];
    thumImageView.image = image;
    
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"4.png"] CGImage];
    mask.frame = CGRectMake(0, 0, 100, 100);
    thumImageView.layer.mask = mask;
    thumImageView.layer.masksToBounds = YES;
}


-(UIImage *)getImageInPoint:(CGPoint)point{
    CGFloat x = point.x - 50;
    CGFloat y = point.y - 50;
    CGRect rect = CGRectMake(x, y, 100, 100);
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef =viewImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    CGSize size;
    size.width = 100;
    size.height = 100;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}
@end
