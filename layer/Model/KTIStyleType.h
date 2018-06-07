//
//  KTIStyleType.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 指标类型

//指标绘制类型
typedef NS_ENUM(NSUInteger,KTIIndexDrawType)
{
    KTIIndexDrawTypeCurveLine,    //曲线
    KTIIndexDrawTypeBand,         //带状(两条曲线组成的带状)
    KTIIndexDrawTypeKLine,        //K线
    KTIIndexDrawTypeCircle,       //圆
    KTIIndexDrawTypeRect,         //矩形
    KTIIndexDrawTypeText,         //文本
    KTIIndexDrawTypeIcon,         //图片
};

#pragma mark - 指标单元填充和绘制

//单元宽度类型
typedef NS_ENUM(NSUInteger,KTIIndexUnitType)
{
    KTIIndexUnitTypeUnitFix,  //宽度固定 , 默认
    KTIIndexUnitTypeSpaceFix, //间隔固定
    KTIIndexUnitTypeScale, //比例宽度比例,即单元绘制宽度与单元的占位宽度比例基本固定(宽度为像素，所以比例会在一定范围内浮动)
};

//单元填充类型
typedef NS_ENUM(NSUInteger,KTIIndexUnitFillType)
{
    KTIIndexUnitFillTypeFillOnly,   //只填充
    KTIIndexUnitFillTypeBoderOnly,      //只绘制边界
    KTIIndexUnitFillTypeBoth,           //填充并且绘制边界
};

#pragma mark - 指标颜色

//颜色类型
typedef NS_ENUM(NSUInteger,KTIIndexColorType)
{
    KTIIndexColorTypeLine,
    KTIIndexColorTypeRise,   //上涨时颜色
    KTIIndexColorTypeDown,  //下跌时颜色
    KTIIndexColorTypekline, //不涨不跌时的颜色
    KTIIndexColorTypeFilled,
    KTIIndexColorTypeBoder,
    KTIIndexColorTypeText, //文字颜色
};


//颜色委托
@protocol KTIUnitColorDelegate <NSObject>

@required
-(UIColor*)unitColorAt:(NSUInteger)index;

@end

#pragma mark - K线

//K线类型
typedef NS_ENUM(NSUInteger,KTIKLineDrawType)
{
    KTIKLineDrawTypeHollow,   //空心阳线,
    KTIKLineDrawTypeSolid, //实心阳线
    KTIKLineDrawTypeSlub, //竹节线
};
