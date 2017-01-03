//
//  PACollectionViewLineLayout.m
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/27.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#import "PACollectionViewLineLayout.h"

@implementation PACollectionViewLineLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    NSArray *attsArray = [[NSArray alloc] initWithArray:original copyItems:YES];
    
    CGFloat centerX = self.collectionView.frame.size.width / 2 + self.collectionView.contentOffset.x;
    
    for (UICollectionViewLayoutAttributes *atts in attsArray) {
        CGFloat space = ABS(atts.center.x - centerX);
        CGFloat scale = 1 - space/self.collectionView.frame.size.width;
        atts.transform = CGAffineTransformMakeScale(scale, scale);
        
    }
    return attsArray;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    NSArray *attsArray = [super layoutAttributesForElementsInRect:rect];
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width / 2;
    CGFloat minSpace = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in attsArray) {
        
        if (ABS(minSpace) > ABS(attrs.center.x - centerX)) {
            minSpace = attrs.center.x - centerX;
        }
    }
    proposedContentOffset.x += minSpace;
    return proposedContentOffset;
    
}

@end
