//
//  KTKlineOper.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/14.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTKlineOper.h"
#import "KTCandleUnitDraw.h"
#import "KTCalcuLationOper.h"
#import "KTKlineData.h"

@implementation KTKlineOper

+(nonnull NSArray<__kindof KTCandleUnitDraw*>*)createCandleUnitCount:(NSUInteger)count unitArr:(nullable NSArray<__kindof KTCandleUnitDraw*>*)oldUnitArr
{
    //计算绘制K线的个数并且更新绘制单元个数
    if(oldUnitArr.count > count)
    {
        return [oldUnitArr subarrayWithRange:NSMakeRange(0, count)];
    }
    else
    {
        //补充不足的元素
        NSUInteger addCount = count - oldUnitArr.count;
        NSMutableArray<__kindof KTCandleUnitDraw*> *newUnitArr = [NSMutableArray array];
        if(oldUnitArr.count > 0)
        {
            [newUnitArr addObjectsFromArray:oldUnitArr];
        }
        for(NSUInteger i = 0 ; i < addCount;i++)
        {
            [newUnitArr addObject:[[KTCandleUnitDraw alloc] init]];
        }
        return [NSArray arrayWithArray:newUnitArr];
    }

}

+(void)setKlineDatas:(nonnull NSArray<__kindof KTKlineData*>*) klineDataArr toCandleUnits:(nonnull NSArray<__kindof KTCandleUnitDraw*>*)candleUnitArr CenterxArr:(nonnull NSArray<__kindof NSNumber*>*)centerXArr  Param:(nonnull KTKlineOperParam*)param;
{
    NSAssert(klineDataArr.count >= candleUnitArr.count, @"数据太少");
    NSAssert(centerXArr.count >= candleUnitArr.count, @"中心点太少");
    //计算绘制的范围
    for(NSUInteger i=0;i<candleUnitArr.count;i++)
    {
        KTCandleUnitDraw *draw = [candleUnitArr objectAtIndex:i];
        
        KTKlineData *data  = [klineDataArr objectAtIndex:i];
        draw.unitXcenter = [[centerXArr objectAtIndex:i] floatValue];
        [KTKlineOper updateCandleUnit:draw data:data Param:param];
    }
}

//该函数是不考虑绘制范围的改变的情况下调用
+(nonnull NSArray<__kindof KTCandleUnitDraw*>*)addNextKlineData:(nonnull KTKlineData*)klineData toCandleUnits:(nonnull NSArray<__kindof KTCandleUnitDraw*>*)candleUnitArr CenterxArr:(nonnull NSArray<__kindof NSNumber*>*)centerXArr  Param:(nonnull KTKlineOperParam*)param
{
    NSAssert(centerXArr.count >= candleUnitArr.count, @"中心点太少");
    NSMutableArray<__kindof KTCandleUnitDraw*> *newUnitArr = [NSMutableArray array];
    if(0 == candleUnitArr.count)
    {
        [newUnitArr addObject:[[KTCandleUnitDraw alloc] init]];
        newUnitArr.lastObject.unitXcenter = [centerXArr.firstObject doubleValue];
    }
    else if(candleUnitArr.count < centerXArr.count)
    {
        [newUnitArr addObjectsFromArray:candleUnitArr];
        [newUnitArr addObject:[candleUnitArr.lastObject copyDraw]];  //添加一个柱子
         newUnitArr.lastObject.unitXcenter = [[centerXArr objectAtIndex:newUnitArr.count - 1] doubleValue];
    }
    else
    {
        [newUnitArr addObjectsFromArray:candleUnitArr];
        [newUnitArr removeObjectAtIndex:0];
        [newUnitArr addObject:candleUnitArr.firstObject];
        for(NSUInteger i = 0; i < centerXArr.count;i++) //修改中心点
        {
            [newUnitArr objectAtIndex:i].unitXcenter = [[centerXArr objectAtIndex:i] doubleValue];
        }
    }
    //修改最后一根K线的数据
    [KTKlineOper updateCandleUnit:newUnitArr.lastObject data:klineData Param:param];
    return [NSArray arrayWithArray:newUnitArr];
}

//修改K线绘制的数据(修改最高，最低，颜色等，不修改绘制宽度,绘制中心点)
+(void)updateCandleUnit:(nonnull KTCandleUnitDraw*)draw data:(nonnull KTKlineData*)data Param :(nonnull KTKlineOperParam*)param
{
    draw.fHighPriceYpos = [KTKlineOper value2Pixel:data.dHighPrice Param:param]; //最高价所在点
    draw.fLowPriceYpos = [KTKlineOper value2Pixel:data.dLowPrice Param:param]; //最低价所在点
    draw.fOpenPriceYpos = [KTKlineOper value2Pixel:data.dOpenPrice Param:param]; //开盘价所在点
    draw.fClosePriceYpos = [KTKlineOper value2Pixel:data.dClosePrice Param:param]; //收盘价所在点
    draw.unitColor = param.customColor;
    if(data.dClosePrice > data.dOpenPrice)
    {
        draw.unitColor = param.riseColor;
    }
    else if(data.dClosePrice < data.dOpenPrice)
    {
        draw.unitColor = param.downColor;
    }
}

+(CGFloat)value2Pixel:(CGFloat)value Param:(nonnull KTKlineOperParam*)param
{
    return [KTCalcuLationOper valueToPixel:value minValue:param.minValue MaxValue:param.maxValue Rect:param.drawRect];
}

@end


#pragma mark - KTKlineOperParam

@implementation KTKlineOperParam

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.riseColor = [UIColor redColor];
        self.downColor = [UIColor greenColor];
        self.customColor = [UIColor grayColor];
    }
    return self;
}

@end
