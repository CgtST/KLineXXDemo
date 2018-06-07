//
//  KTTrendOper.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTTrendOper.h"
#import "KTTrendData.h"
#import "KTCalcuLationOper.h"
#import "KTCurveIndexDraw.h"

@implementation KTTrendOper

//传入绘制数组的第一个是分时，第二个是均线
+(void)setTrendData:(nonnull NSArray<__kindof KTTrendData*>*)trendDataArr toCuverDraw:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr  XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTTrendOperParam*)param
{
    NSAssert(2 == curDrawArr.count, @"传入的分时绘制错误");
    NSMutableArray<__kindof NSValue*> *trendPoints = [NSMutableArray array]; //分时
    NSMutableArray<__kindof NSValue*> *avgPoints = [NSMutableArray array]; //均线

    for(NSUInteger i=0; i< centerPosx.count && i < trendDataArr.count;i++)
    {
        KTTrendData *data = [trendDataArr objectAtIndex:i];
        CGFloat curPriceYpos = [KTTrendOper value2Pixel:data.dCurPrice Param:param];
        CGFloat avgPriceYpos = [KTTrendOper value2Pixel:data.dAvg Param:param];
        
        CGFloat xpos = [[centerPosx objectAtIndex:i] doubleValue];
        [trendPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, curPriceYpos)]];
        [avgPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, avgPriceYpos)]];
        
    }
    curDrawArr.firstObject.pointValues = trendPoints;
    curDrawArr.lastObject.pointValues = avgPoints;
    
}
//传入绘制数组的第一个是分时，第二个是均线(不考虑绘制范围的改变)
+(void)updateLastPoint:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr trendData:(nonnull KTTrendData*)trenddata Param:(nonnull KTTrendOperParam*)param
{
    NSAssert(2 == curDrawArr.count, @"传入的分时绘制错误");
    NSMutableArray<__kindof NSValue*> *trendPoints = [NSMutableArray arrayWithArray:curDrawArr.firstObject.pointValues]; //分时
    NSMutableArray<__kindof NSValue*> *avgPoints = [NSMutableArray arrayWithArray:curDrawArr.lastObject.pointValues]; //均线
    if(trendPoints.count - 1 != [KTTrendOper indexOfTime:trenddata.time tradeTime:param.tradeTimeArr])
    {
       //NSAssert(false, @"传入的分时数据时间错误");
    }
    CGFloat xpos = [trendPoints.lastObject CGPointValue].x;
    //修改最后一个点的纵坐标
    {
        [trendPoints removeLastObject];
        [avgPoints removeLastObject];
        CGFloat curPriceYpos = [KTTrendOper value2Pixel:trenddata.dCurPrice Param:param];
        CGFloat avgPriceYpos = [KTTrendOper value2Pixel:trenddata.dAvg Param:param];
        [trendPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, curPriceYpos)]];
        [avgPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, avgPriceYpos)]];
    }
    curDrawArr.firstObject.pointValues = trendPoints;
    curDrawArr.lastObject.pointValues = avgPoints;
}
//传入绘制数组的第一个是分时，第二个是均线(不考虑绘制范围的改变)
+(void)addNextPoint:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr trendData:(nonnull NSArray<__kindof KTTrendData*>*)addTrendDataArr  XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTTrendOperParam*)param
{
    NSAssert(2 == curDrawArr.count, @"传入的分时绘制错误");
    NSMutableArray<__kindof NSValue*> *trendPoints = [NSMutableArray arrayWithArray:curDrawArr.firstObject.pointValues]; //分时
    NSMutableArray<__kindof NSValue*> *avgPoints = [NSMutableArray arrayWithArray:curDrawArr.lastObject.pointValues]; //均线
    NSAssert(centerPosx.count >= trendPoints.count, @"分时传入的中心点不正确");
    //更新绘制
    for(NSUInteger i = 0; i < addTrendDataArr.count;i++)
    {
        KTTrendData *addTrendData = [addTrendDataArr objectAtIndex:i];
        CGFloat curPriceYpos = [KTTrendOper value2Pixel:addTrendData.dCurPrice Param:param];
        CGFloat avgPriceYpos = [KTTrendOper value2Pixel:addTrendData.dAvg Param:param];
        CGFloat xpos = [[centerPosx objectAtIndex:trendPoints.count] doubleValue]; //下一个绘制点
        [trendPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, curPriceYpos)]];
        [avgPoints addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, avgPriceYpos)]];
    }
    curDrawArr.firstObject.pointValues = trendPoints;
    curDrawArr.lastObject.pointValues = avgPoints;
}

#pragma mark - 时间相关

//获取时间（分钟数）所在的位置
+(NSUInteger)indexOfTime:(int)time tradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr
{
    NSUInteger indexNum = 0;
    for(KTTradeTime *tradeTime in tradeTimeArr)
    {
        if([tradeTime indexOfTime:time] < 0)
        {
            if(tradeTime.startTime > time) //在收盘和开盘价之间
            {
                return indexNum;
            }
            indexNum += [tradeTime getTimeUintCount];
            
        }
        else
        {
            indexNum +=[tradeTime indexOfTime:time];
            break;
        }
    }
    return indexNum;
}

//获取时间数组中对应位置的时间值（分钟数）
+(int)getTrendTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr AtIndex:(NSUInteger)index
{
    NSAssert(tradeTimeArr.count > 0, @"没有分时时间");

    NSUInteger indexNum = 0;
    for(KTTradeTime *tradeTime in tradeTimeArr)
    {
        if((indexNum + [tradeTime getTimeUintCount]) >= index)
        {
            return [tradeTime getTimeAtIndex:(index - indexNum)];
        }
        indexNum += [tradeTime getTimeUintCount];
    }
    return tradeTimeArr.lastObject.startTime;
}

//是否是开盘第一笔数据
+(BOOL)isOpenTimeData:(int)time inTradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr
{
    if(0 == tradeTimeArr.count)
    {
        return NO;
    }
    //当日开盘时间
    KTTradeTime *firstTradeTime = tradeTimeArr.firstObject;
    return firstTradeTime.startTime == time;
}

//时间是否为交易时间
+(BOOL)isTime:(int)time inTradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr
{
    for(KTTradeTime *tradeTime in tradeTimeArr)
    {
        if(YES == [tradeTime bInTradeTime:time])
        {
            return YES;
        }
    }
    return NO;
}
//获取时间中时间单元的个数（分钟数）
+(NSUInteger)getTimeWeightCount:(nonnull NSArray<__kindof KTTradeTime*>*)tradeTimeArr
{
    NSUInteger indexNum = 0;
    for(KTTradeTime *tradeTime in tradeTimeArr)
    {
        indexNum += [tradeTime getTimeUintCount];
    }
    return indexNum;
}

#pragma mark - private

+(CGFloat)value2Pixel:(CGFloat)value Param:(nonnull KTTrendOperParam*)param
{
    return [KTCalcuLationOper valueToPixel:value minValue:param.minValue MaxValue:param.maxValue Rect:param.drawRect];
}
@end

#pragma mark - KTIndexOperParam

@implementation KTTrendOperParam

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.tradeTimeArr = [NSArray array];
    }
    return self;
}

@end

