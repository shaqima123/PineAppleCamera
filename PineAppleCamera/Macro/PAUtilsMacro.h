//
//  PAUtilsMacro.h
//  PineAppleCamera
//
//  Created by zj－db0737 on 16/12/17.
//  Copyright © 2016年 zj－db0737. All rights reserved.
//

#ifndef PAUtilsMacro_h
#define PAUtilsMacro_h


#endif /* PAUtilsMacro_h */

// 屏幕大小
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//TabBar以及ToolBar高度
#define PADiaryTabBarHeight 49.f
#define PAToolBarHeight 51.f

// 浮点值比较
#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)
#define flessthan(a,b) (fabs(a) < fabs(b)+FLT_EPSILON)

// 角度转弧度
#define MT_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180

// 弧度转角度
#define MT_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

// 版本判断
#define SYSTEM_VERSION_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/**
 *  是否是X.X寸屏幕
 */
#define IS_3_5_INCH                 (CGRectGetHeight([UIScreen mainScreen].bounds) == 480)
#define IS_4_INCH                   (CGRectGetHeight([UIScreen mainScreen].bounds) == 568)
#define IS_4_7_INCH                 (CGRectGetHeight([UIScreen mainScreen].bounds) == 667)
#define IS_5_5_INCH                 (CGRectGetHeight([UIScreen mainScreen].bounds) == 736)

/*** Definitions of inline functions. ***/

CG_INLINE CGRect CGRectChangeSize(CGRect rect, CGSize size)
{ return CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height); }

CG_INLINE CGRect CGRectChangeWidth(CGRect rect, CGFloat width)
{ return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height); }

CG_INLINE CGRect CGRectChangeHeight(CGRect rect, CGFloat height)
{ return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height); }

CG_INLINE CGRect CGRectChangeOrigin(CGRect rect, CGPoint origin)
{ return CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height); }

CG_INLINE CGRect CGRectChangeY(CGRect rect, CGFloat y)
{ return CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height); }

CG_INLINE CGRect CGRectChangeX(CGRect rect, CGFloat x)
{ return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height); }

CG_INLINE CGRect CGRectMakeFromOriginAndSize(CGPoint origin, CGSize size)
{ return CGRectMake(origin.x, origin.y, size.width, size.height); }

CG_INLINE CGSize CGSizeAspectFit(CGSize parentSize, CGSize childSize)
{
    return (parentSize.width / parentSize.height > childSize.width / childSize.height) ?
    CGSizeMake(childSize.width * parentSize.height / childSize.height, parentSize.height) :
    CGSizeMake(parentSize.width, childSize.height * parentSize.width / childSize.width);
}

CG_INLINE CGSize CGSizeAspectFill(CGSize parentSize, CGSize childSize)
{
    return (parentSize.width / parentSize.height > childSize.width / childSize.height) ?
    CGSizeMake(parentSize.width, childSize.height * parentSize.width / childSize.width) :
    CGSizeMake(childSize.width * parentSize.height / childSize.height, parentSize.height);
}

CG_INLINE CGRect CGRectAspectFit(CGRect parentRect, CGSize childSize)
{
    CGSize resultSize = CGSizeAspectFit(parentRect.size, childSize);
    CGPoint resultOrigin = CGPointMake(parentRect.origin.x + (parentRect.size.width - resultSize.width) / 2.0,
                                       parentRect.origin.y + (parentRect.size.height - resultSize.height) / 2.0);
    return CGRectMakeFromOriginAndSize(resultOrigin, resultSize);
}

CG_INLINE CGRect CGRectAspectFill(CGRect parentRect, CGSize childSize)
{
    CGSize resultSize = CGSizeAspectFill(parentRect.size, childSize);
    CGPoint resultOrigin = CGPointMake(parentRect.origin.x + (parentRect.size.width - resultSize.width) / 2.0,
                                       parentRect.origin.y + (parentRect.size.height - resultSize.height) / 2.0);
    return CGRectMakeFromOriginAndSize(resultOrigin, resultSize);
}

CG_INLINE CGSize CGSizeChangeHeigth(CGSize size, CGFloat height)
{ return CGSizeMake(size.width, height); }

CG_INLINE CGSize CGSizeChangeWidth(CGSize size, CGFloat width)
{ return CGSizeMake(width, size.height); }
