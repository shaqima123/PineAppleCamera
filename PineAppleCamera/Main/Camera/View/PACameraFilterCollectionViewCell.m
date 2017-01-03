//
//  PACameraFilterCollectionViewCell.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/27.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PACameraFilterCollectionViewCell.h"

@interface PACameraFilterCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UILabel *filterNameLabel;

@end
@implementation PACameraFilterCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _filterImageView.layer.cornerRadius = 3.f;
    _filterImageView.clipsToBounds = YES;
    [_filterImageView setFrame:CGRectMake(3, 6, 50, 50)];
    [_filterImageView setImage:[UIImage imageNamed:@"girl"]];

    
    [_filterNameLabel setFont:[UIFont systemFontOfSize:16.f]];
    [_filterNameLabel setTextColor:[UIColor whiteColor]];
    
}

- (void)setFilterName:(NSString *)filterName
{
    [self.filterNameLabel setText:filterName];
}

@end
