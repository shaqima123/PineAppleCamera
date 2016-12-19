//
//  MTMaskImageView.h
//  helloMeitu
//
//  Created by shaqima on 16/8/10.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTMaskImageView : UIImageView
@property (nonatomic,strong) UIImageView *thumImageView;

- (void)showEnlargeViewWithPoint:(CGPoint)point;
@end
