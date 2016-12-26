//
//  PAMenuCollectionViewCell.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/24.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PAMenuCollectionViewCell.h"

@interface PAMenuCollectionViewCell()

@property (nonatomic ,weak) IBOutlet UIButton * button;

@end
@implementation PAMenuCollectionViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button.titleLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
}

- (void)setContentString:(NSString *)contentString
{
    _contentString = contentString;
    [_button setTitle:_contentString forState:UIControlStateNormal];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (_isSelected) {
        [_button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];;
}

@end
