//
//  KTICustomDataOper.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTICustomDataOper.h"
#import "KTINodeData.h"

#define K_InvalidValue     -111111000000
#define K_plusValue        -111111

@implementation KTICustomDataOper

+(CGFloat)mainScreenScale
{
    static CGFloat scale = -1;
    if(scale < 0)
    {
        scale = [UIScreen mainScreen].scale;
    }
    return scale;
}

+(nonnull dispatch_queue_t)shareQueue
{
    static dispatch_queue_t custQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      custQueue = dispatch_queue_create("KTICustomDataOper", DISPATCH_QUEUE_CONCURRENT);
                  });
    return custQueue;
}

#pragma mark - 坐标转换

//对节点数据进行转换,nodeData为合法值
+(nonnull NSArray<__kindof NSNumber*>*)values2DrawPoints:(nonnull KTINodeData*)nodeData MinValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds
{
    NSMutableArray<__kindof NSNumber*> *nodeArr = [NSMutableArray array];
    for(NSNumber *num in nodeData.allValues)
    {
        CGFloat value = [[self class] valueToPixel:[num doubleValue] minValue:minvalue MaxValue:maxValue Rect:bounds];
        [nodeArr addObject:@(value)];
    }
    return [NSArray arrayWithArray:nodeArr];
}

//对线的数据进行转换
+(nonnull NSArray<__kindof NSNumber*>*)values2LineDrawPoints:(nonnull KTIIndexData*)klineData MinValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds
{
    NSMutableArray<__kindof NSNumber*> *lineDataArr = [NSMutableArray array];
    for(KTINodeData *nodeData in klineData.nodeDataArr)
    {
        if(YES == nodeData.isNumValid)
        {
            CGFloat value = [[self class] valueToPixel:[nodeData.allValues.firstObject doubleValue] minValue:minvalue MaxValue:maxValue Rect:bounds];
            [lineDataArr addObject:@(value)];
        }
        else
        {
            [lineDataArr addObject:@(K_InvalidValue + K_plusValue)];
        }
    }
    return [NSArray arrayWithArray:lineDataArr];

}

//是否为合法值
+(BOOL)isValidValue:(nonnull NSNumber*)number
{
    if([number doubleValue] <= K_InvalidValue)
    {
        return YES;
    }
    return NO;
}

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
    NSInteger index = NSNotFound;
    index = [[self class] search:xpos inArr:numsArr precision:pre];
    
    //以index为中心带你进行遍历,已弥补二分查找法的不足
    int searchRange = 5;
    NSUInteger startIndex = index <= searchRange ? 0 : index - 5;
    NSUInteger endIndex = index + searchRange >= numsArr.count ? numsArr.count - 1 : index + searchRange;
    CGFloat minDist = CGFLOAT_MAX;
    //从后向前搜素
    for(NSUInteger i = endIndex ;i > startIndex;i--)
    {
        CGFloat xCenter = [numsArr[i - 1] doubleValue];
        CGFloat dist = fabs(xCenter - xpos);
        if( dist < minDist)
        {
            minDist = dist;
            index = i - 1;
            if(dist < 0.01) //已经找到最小的点
            {
                break;
            }
        }
    }
    return index;
}

+(NSInteger)search:(CGFloat)pos inArr:(nonnull NSArray<__kindof NSNumber*>*)numsArr precision:(CGFloat)pre
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
    if(fabs(halfValue - pos) <= pre) //已经查找到对象了
    {
        return halfLocation;
    }
    else
    {
        if(pos > halfValue) //在后半部分查找
        {
            NSArray *arr = [numsArr subarrayWithRange:NSMakeRange(halfLocation + 1, numsArr.count - halfLocation - 1)];
            NSInteger integer = [self search:pos inArr:arr precision:pre];
            return integer + halfLocation + 1;
        }
        else
        {
            if(0 == halfLocation)
            {
                return 0;
            }
            NSArray *arr = [numsArr subarrayWithRange:NSMakeRange(0, halfLocation)];
            NSInteger integer = [self search:pos inArr:arr precision:pre];
            return integer;
        }
    }
}


#pragma mark - 中心点计算

//重新创建中心点 minDist（返回值）表示相邻两个不同的点之间的最小距离
+(nonnull NSArray<__kindof NSNumber*>*)createCenterXWidth:(CGFloat)width Count:(NSUInteger)count MinWidth:(nullable CGFloat*)minDist  MaxWidth:(nullable CGFloat*)maxDist
{
    if(0 == count || width < count * 0.01)
    {
        if(NULL != minDist)
        {
            *minDist = width;
        }
        if(NULL != maxDist)
        {
            *maxDist = width;
        }
        return [NSArray array];
    }
    
    CGFloat minWidth = CGFLOAT_MAX;
    CGFloat maxWidth = 0;
    NSArray<__kindof NSNumber*> *retArr= [NSArray array];
    CGFloat spaceWidth = width/count; //计算的平均间隔
    NSMutableArray<__kindof NSNumber*> *centerXArr = [NSMutableArray array];
    //添加第一个元素
    {
        CGFloat centerX = ((int)(spaceWidth/2 * [[self class] mainScreenScale])) /[[self class] mainScreenScale]; //绘制位置像素化
        [centerXArr addObject:@(centerX)];
    }
    CGFloat lastcenter = [centerXArr.firstObject doubleValue];
    for(NSUInteger i = 1 ; i < count;i++)
    {
        CGFloat centerX = spaceWidth * (i + 0.5);
        centerX = ((int)(centerX * [[self class] mainScreenScale])) /[[self class] mainScreenScale]; //绘制位置像素化
        [centerXArr addObject:@(centerX)];
        if(centerX - lastcenter > 0.01) //前后两个间隔不相等
        {
            minWidth = MIN(minWidth, (centerX - lastcenter));
            maxWidth =  MAX(maxWidth,(centerX - lastcenter));
        }
        lastcenter = centerX;
    }
    retArr = [NSArray arrayWithArray:centerXArr];
    if(NULL != minDist)
    {
        *minDist = minWidth;
    }
    if(NULL != maxDist)
    {
        *maxDist = maxWidth;
    }
    return retArr;
}

//用给定的中心点重新计算中心点，并且每两个不同的中心点之间的距离最小为minDist。返回的个数与传入的个数相同，并且返回数组中的值是传入值得子集
+(nonnull NSArray<__kindof NSNumber*>*)displayCenters:(nonnull NSArray<__kindof NSNumber*>*)oldCenter WithMinDist:(CGFloat)minDist;
{
    if(0 == oldCenter.count)
    {
        return oldCenter;
    }
    NSMutableArray<__kindof NSNumber*> *centersArr = [NSMutableArray array];
    
    //查找第一个元素
    CGFloat firstCenter = round([[self class] mainScreenScale] * minDist/2)/[[self class] mainScreenScale];
    for(NSUInteger i = 0; i < oldCenter.count;i++)
    {
        NSNumber *curCenter = oldCenter[i];
        if([curCenter doubleValue] > firstCenter)
        {
            if(0 == i)
            {
                [centersArr addObject:oldCenter.firstObject];
            }
            else
            {
                //后一个点距离中心点比较近
                if(firstCenter - [oldCenter[i-1] doubleValue] > [curCenter doubleValue] - firstCenter)
                {
                    [centersArr addObject:curCenter];
                }
                else
                {
                    [centersArr addObject:oldCenter[i-1]];
                }
            }
            
            break;
        }
    }
    //查找后面的元素
    for(NSUInteger i = 1;i < oldCenter.count;i++)
    {
        NSNumber *lastCenter = centersArr.lastObject ;
        NSNumber *curCenter = oldCenter[i];
        if([curCenter doubleValue] - [lastCenter doubleValue] >= minDist)
        {
            [centersArr addObject:curCenter];
        }
        else
        {
            [centersArr addObject:lastCenter];
        }
    }
    return  [NSArray arrayWithArray:centersArr];
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

#pragma mark - 获取指标数据中的最大值和最小值

+(void)getMinMaxValueOfNodeArr:(nonnull NSArray<__kindof KTINodeData*>*)values MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue
{
    CGFloat retMax = INT_MIN;
    CGFloat retMin = INT_MAX;
    for(KTINodeData *indexData in values)
    {
        if(YES == indexData.isNumValid) //值合法
        {
            if(indexData.maxValue > retMax)
            {
                retMax = indexData.maxValue;
            }
            if(indexData.minValue < retMin)
            {
                retMin = indexData.minValue;
            }
        }
    }
    if(NULL != minValue)
    {
        *minValue = retMin;
    }
    if(NULL != maxValue)
    {
        *maxValue = retMax;
    }
    
}

+(void)getMinMaxValueOfIndex:(nonnull KTIIndexData*)indexData MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue
{
    return [[self class] getMinMaxValueOfNodeArr:indexData.nodeDataArr MinValue:minValue MaxValue:maxValue];
}

+(void)getMinMaxValueOfIndexArr:(nonnull NSArray<__kindof KTIIndexData*>*)indexDataArr MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue
{
    CGFloat retMax = INT_MIN;
    CGFloat retMin = INT_MAX;
    for(KTIIndexData * indexData in indexDataArr)
    {
        CGFloat subindexMax = 0;
        CGFloat subindexMin = 0;
        [[self class] getMinMaxValueOfIndex:indexData MinValue:&subindexMin MaxValue:&subindexMax];
        if(subindexMax > retMax)
        {
            retMax = subindexMax;
        }
        if(subindexMin < retMin)
        {
            retMin = subindexMin;
        }
    }
    if(NULL != minValue)
    {
        *minValue = retMin;
    }
    if(NULL != maxValue)
    {
        *maxValue = retMax;
    }
}

@end
