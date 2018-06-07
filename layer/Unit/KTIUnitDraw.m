//
//  KTIUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIUnitDraw.h"
#import "KTICandleUnitDraw.h"
#import "KTICircleUnitDraw.h"
#import "KTIRectUnitDraw.h"
#import "KTITextUnitDraw.h"
#import "KTIIconUnitDraw.h"

@implementation KTIUnitDraw

+(nonnull KTIUnitDraw*)KTIUnitDrawWithType:(KTIUnitDrawType)unitType
{
    if(KTIUnitDrawTypeCandle == unitType) //蜡烛图
    {
        return [[KTICandleUnitDraw alloc] init];
    }
    else if(KTIUnitDrawTypeCIRCLE == unitType) //圆
    {
        return [[KTICircleUnitDraw alloc] init];
    }
    else if (KTIUnitDrawTypeRect == unitType)  //矩形
    {
        return [[KTIRectUnitDraw alloc] init];
    }
    else if(KTIUnitDrawTypeText == unitType) //文字
    {
        return [[KTITextUnitDraw alloc] init];
    }
    else if(KTIUnitDrawTypeICON == unitType)//图形
    {
        return [[KTIIconUnitDraw alloc] init];
    }
    else
    {
        return [[KTIUnitDraw alloc] init];
    }
}


-(instancetype) init
{
    self = [super init];
    if(nil != self)
    {
        [self initData];
    }
    return self;
}

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;
{
    
}

-(void)resetdata
{
    [self initData];
}

-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData  //设置绘制数据
{
    
}

-(void)setExtrendData:(nonnull NSData*) extrendData //设置额外绘制数据
{
    
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTIUnitDraw *unit = [[[self class] allocWithZone:zone] init];
    unit.unitWidth = self.unitWidth;
    unit.lineWidth = self.lineWidth;

    unit.fillColor = self.fillColor;
    unit.lineColor = self.lineColor;
    return unit;
}

#pragma mark - private

-(void)initData
{
    self.unitWidth = 1;
    self.lineWidth = 1;
    self.fillColor = nil;
    self.lineColor = nil;
    
}


@end
