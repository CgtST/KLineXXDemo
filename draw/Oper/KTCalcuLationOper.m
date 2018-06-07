//
//  KTCalcuLationOper.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/14.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTCalcuLationOper.h"
#import "KTTrendData.h"
#import "KTKlineData.h"
#import "KTIndexStyle.h"

@implementation KTCalcuLationOper

#pragma mark - 坐标转换

//将值转换为点,bounds底部表示最小值，头部表示
+(CGFloat)valueToPixel:(CGFloat)fValue minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds
{
    if (0 == maxValue - minvalue)
    {
        return bounds.origin.y;
    }
    
    //计算距离最小值的距离(像素)
    double dist2MinValue = round(bounds.size.height * (fValue - minvalue) / (maxValue - minvalue));
    
    //计算位置,最小值在底部
    return  bounds.origin.y +  bounds.size.height  - dist2MinValue ;
    
}

+(CGFloat)pixelToValue:(CGFloat)location minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds
{
    if(location <= bounds.origin.y)
    {
        return maxValue;
    }
    if(location >= bounds.origin.y + bounds.size.height)
    {
        return minvalue;
    }
    
    if(0 == bounds.size.height)
    {
        return minvalue;
    }
    return maxValue - (maxValue - minvalue) * (location - bounds.origin.y)/bounds.size.height;
}

#pragma mark - 查找

+(NSInteger)searchXpos:(CGFloat)xpos inArr:(nonnull NSArray<__kindof NSNumber*>*)numsArr precision:(CGFloat)pre
{
    if(0 == numsArr.count)
    {
        return NSNotFound;
    }
    if(1 == numsArr.count)
    {
        return 0;
    }
    NSUInteger halfLocation = (numsArr.count - 1)/2 ;
    CGFloat halfValue = [[numsArr objectAtIndex:halfLocation] doubleValue];
    if(fabs(halfValue - xpos) <= pre) //已经查找到对象了
    {
        return halfLocation;
    }
    else
    {
        if(xpos > halfValue) //在后半部分查找
        {
            NSArray *arr = [numsArr subarrayWithRange:NSMakeRange(halfLocation + 1, numsArr.count - halfLocation - 1)];
            NSInteger integer = [self searchXpos:xpos inArr:arr precision:pre];
            return integer + halfLocation + 1;
        }
        else
        {
            if(0 == halfLocation)
            {
                return 0;
            }
            NSArray *arr = [numsArr subarrayWithRange:NSMakeRange(0, halfLocation)];
            NSInteger integer = [self searchXpos:xpos inArr:arr precision:pre];
            return integer;
        }
    }
}

#pragma mark - 中心点计算

//重新创建中心点
+(nonnull NSArray<__kindof NSNumber*>*)createCenterXWidth:(CGFloat)width Count:(NSUInteger)count MinWidth:(nullable CGFloat*)minDist
{
    if(0 == count || width < count * 0.01)
    {
        if(NULL != minDist)
        {
            *minDist = 0;
        }
        return [NSArray array];
    }
    
    CGFloat spaceWidth = width/count; //计算的平均间隔
    CGFloat minWidth = width;
    CGFloat lastcenter = -width;
    NSMutableArray<__kindof NSNumber*> *centerXArr = [NSMutableArray array];
    for(NSUInteger i = 0 ; i < count;i++)
    {
        CGFloat centerX = spaceWidth * (i + 0.5);
        centerX = ((int)(centerX * [UIScreen mainScreen].scale)) / [UIScreen mainScreen].scale; //绘制位置像素化
        [centerXArr addObject:@(centerX)];
        if(centerX - lastcenter > 0.01) //前后两个间隔不相等
        {
            minWidth = MIN(minWidth, (centerX - lastcenter));
        }
        lastcenter = centerX;
    }
    if(NULL != minDist)
    {
        *minDist = minWidth;
    }
    return centerXArr;
}

#pragma mark - 去掉重复的点

//去掉X轴方向上重复的点
+(nonnull NSArray<__kindof NSValue*>*)removeRepeatPointAtX:(nonnull NSArray<__kindof NSValue*>*) pointDatas
{
    NSMutableArray *lineDataArr = [NSMutableArray array];
    if(0 == pointDatas.count)
    {
        return lineDataArr;
    }
    CGPoint lastpoint = [pointDatas.firstObject CGPointValue];
    for(NSUInteger i = 0;i<pointDatas.count;i++)
    {
        CGPoint point = [[pointDatas objectAtIndex:i] CGPointValue];
        if(point.x - lastpoint.x > 0.01)
        {
            [lineDataArr addObject:[NSValue valueWithCGPoint:lastpoint]];
            lastpoint = point;
        }
    }
    [lineDataArr addObject:[NSValue valueWithCGPoint:lastpoint]];
    return lineDataArr;
}

#pragma mark - 获取最大值和最小值,第一个存放的是最小值，第二个存放的是最大值
//指标
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfNodeDatas:(nonnull NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*>*) valueArr
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    for(NSUInteger i = 0;i < valueArr.count;i++)
    {
        NSArray<__kindof KTIndexOneNodeData*> *nodeDataArr = [valueArr objectAtIndex:i];
        for(NSUInteger nodeIndex = 0; nodeIndex < nodeDataArr.count;nodeIndex ++)
        {
            KTIndexOneNodeData *nodeData = [nodeDataArr objectAtIndex:nodeIndex];
            if(nodeData.maxValue > KT_INDEX_INVALID_VALUE || nodeData.minValue > KT_INDEX_INVALID_VALUE)
            {
                continue;  //有无效值，过滤掉
            }
            if(nodeData.minValue < fValueMin)
            {
                fValueMin = nodeData.minValue;
            }
            if(nodeData.maxValue > fValueMax)
            {
                fValueMax = nodeData.maxValue;
            }
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];

}

//K线
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    for(NSUInteger i = 0;i < valueArr.count;i++)
    {
        KTKlineData *lineData = [valueArr objectAtIndex:i];
        fValueMin = MIN(fValueMin,lineData.dLowPrice);
        fValueMax = MAX(fValueMax, lineData.dHighPrice);
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

//分时
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfTrendData:(nonnull NSArray<__kindof KTTrendData*>*) valueArr
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    for(NSUInteger i=0;i<valueArr.count;i++)
    {
        KTTrendData *trendData = [valueArr objectAtIndex:i];
        fValueMin = MIN(fValueMin,trendData.dCurPrice);
        fValueMin = MIN(fValueMin,trendData.dAvg);
        fValueMax = MAX(fValueMax, trendData.dCurPrice);
        fValueMax = MAX(fValueMax, trendData.dAvg);
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

@end
