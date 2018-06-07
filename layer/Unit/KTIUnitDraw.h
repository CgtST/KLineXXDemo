//
//  KTIUnitDraw.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(UInt32,KTIUnitDrawType)
{
    KTIUnitDrawTypeInvalid, //不合法的绘制
    KTIUnitDrawTypeCandle,  //蜡烛图
    KTIUnitDrawTypeCIRCLE,  //圆
    KTIUnitDrawTypeRect,    //矩形
    KTIUnitDrawTypeText,   //文字
    KTIUnitDrawTypeICON,    //图形
};

@interface KTIUnitDraw : NSObject<NSCopying>

@property(nonatomic) CGFloat unitWidth;  //单元宽度
@property(nonatomic) CGFloat lineWidth;  //线宽，在K线绘制时不需要设置，会自动计算
@property(nonatomic,retain,nullable) UIColor* fillColor;
@property(nonatomic,retain,nullable) UIColor* lineColor;

+(nonnull KTIUnitDraw*)KTIUnitDrawWithType:(KTIUnitDrawType)unitType;

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;

-(void)resetdata;  //清空数据

-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData;  //设置绘制数据

-(void)setExtrendData:(nonnull NSData*) extrendData; //设置额外绘制数据

@end
