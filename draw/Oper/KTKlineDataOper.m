//
//  KTKlineDataOper.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTKlineDataOper.h"

#define FLOAT_MIN			1.175494351e-38F
#define FLOAT_MAX			3.402823466e+38F

@implementation KTKlineDataOper

//获取K线中最小值和最大值所在的位置，第一个存放的是最小值位置，第二个存放的是最大值位置
+(nonnull NSArray<__kindof NSNumber*>*)getPosOfMinMaxValueInKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr
{
    CGFloat fValueMin = FLOAT_MAX;
    CGFloat fValueMax = FLOAT_MIN;
    NSUInteger maxValueIndex = 0;
    NSUInteger minValueIndex = 0;
    for(NSUInteger i=0;i<valueArr.count;i++)
    {
        KTKlineData *lineData = [valueArr objectAtIndex:i];
        if(lineData.dLowPrice < fValueMin)
        {
            fValueMin = lineData.dLowPrice;
            minValueIndex = i;
        }
        if(lineData.dHighPrice > fValueMax)
        {
            fValueMax = lineData.dHighPrice;
            maxValueIndex = i;
        }
    }

    return [NSArray arrayWithObjects:@(minValueIndex),@(maxValueIndex), nil];

}

#pragma mark - 获取最大值和最小值

//第一个存放的是最小值，第二个存放的是最大值
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue:(nonnull NSArray<__kindof NSNumber*>*) valueArr
{
    CGFloat fValueMin = FLOAT_MAX;
    CGFloat fValueMax = FLOAT_MIN;
    for(NSUInteger i=0;i<valueArr.count;i++)
    {
        CGFloat num = [[valueArr objectAtIndex:i] doubleValue];
        if(num< fValueMin)
        {
            fValueMin = num;
        }
        if(num > fValueMax)
        {
            fValueMax = num;
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueIn2DimArr:(nonnull NSArray<__kindof KTIndexOneNodeData*>*) valueArr
{
    CGFloat fValueMin = FLOAT_MAX;
    CGFloat fValueMax = FLOAT_MIN;
    for(NSUInteger i=0;i<valueArr.count;i++)
    {
        NSArray<__kindof NSNumber*> *minMaxValue = [KTKlineDataOper getMinMaxValue:[[valueArr objectAtIndex:i] getAllData]];
        if([minMaxValue.firstObject doubleValue] < fValueMin)
        {
            fValueMin = [minMaxValue.firstObject doubleValue] ;
        }
        if([minMaxValue.lastObject doubleValue]  > fValueMax)
        {
            fValueMax = [minMaxValue.lastObject doubleValue] ;
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

//K线
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr
{
    return [KTKlineDataOper getMinMaxValueOfKlineData:valueArr startPos:0 count:valueArr.count];
}

+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr startPos:(NSUInteger)start count:(NSUInteger)count
{
    CGFloat fValueMin = FLOAT_MAX;
    CGFloat fValueMax = 0;
    NSUInteger dataCount = valueArr.count > start ? valueArr.count - start : 0;
    dataCount = MIN(count, dataCount);
    for(NSUInteger i = 0;i < dataCount;i++)
    {
        //价格不可能为0值和负数
        KTKlineData *lineData = [valueArr objectAtIndex:i + start];
        if(lineData.dLowPrice > 0)
        {
            fValueMin = MIN(fValueMin,lineData.dLowPrice);
        }
        if(lineData.dHighPrice > 0)
        {
            fValueMax = MAX(fValueMax, lineData.dHighPrice);
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

//分时
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfTrendData:(nonnull NSArray<__kindof KTTrendData*>*) valueArr
{
    CGFloat fValueMin = FLOAT_MAX;
    CGFloat fValueMax = 0;
    for(NSUInteger i=0;i<valueArr.count;i++)
    {
        //价格不可能为0值和负数
        KTTrendData *trendData = [valueArr objectAtIndex:i];
        if(trendData.dCurPrice > 0)
        {
            fValueMin = MIN(fValueMin,trendData.dCurPrice);
            fValueMax = MAX(fValueMax, trendData.dCurPrice);
        }
        if(trendData.dAvg > 0)
        {
            
            fValueMin = MIN(fValueMin,trendData.dAvg);
            fValueMax = MAX(fValueMax, trendData.dAvg);
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

@end
