//
//  KTTrendData.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/27.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTTrendData.h"

@implementation KTTrendData

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        _dataTime = 0;
        _time = 0;  //分时时间
    }
    return self;
}

-(BOOL)copyDataFrom:(nonnull KTTrendData*)trendData
{
    if(self.time != trendData.time)
    {
        return NO;
    }
    self.dCurPrice = trendData.dCurPrice;
    self.dAvg = trendData.dAvg;
    self.dVolume = trendData.dVolume;
    self.dAmount = trendData.dAmount;
    return YES;
}

-(nonnull KTTrendData*)getCopyData //获取一份拷贝对象
{
    KTTrendData *trendData = [[KTTrendData alloc] init];
    trendData.dataTime = self.dataTime;
    trendData.dCurPrice = self.dCurPrice;
    trendData.dAvg = self.dAvg;
    trendData.dVolume = self.dVolume;
    trendData.dAmount = self.dAmount;
    return trendData;
}

-(void)setDataTime:(int)dataTime
{
    _dataTime = dataTime;
    _time = dataTime;
    while (_time < -1440) //夜盘时间的处理，去掉跨天
    {
        _time +=1440;
    }
}
@end

#pragma mark -

@implementation KTTradeTime

-(NSUInteger)getTimeUintCount //获取取时间分量的个数
{
    return self.endTime - self.startTime + 1;
}

-(NSInteger)indexOfTime:(int)time //获取时间在该节点中的位置,如果时间不在该节点内，则返回-1
{
    if(NO == [self bInTradeTime:time])
    {
        return -1;
    }
    return time - self.startTime;
}

-(int)getTimeAtIndex:(NSUInteger)index //获取第index个位置的分量
{
    if(0 == index)
    {
        return self.startTime;
    }
    else if(index >= [self getTimeUintCount])
    {
        return self.endTime;
    }
    else
    {
        return self.startTime + (int)index;
    }
}

-(BOOL)bInTradeTime:(int)time; //是否在该时间节点内
{
    if(time < self.startTime || time > self.endTime)
    {
        return NO;
    }
    return YES;
}

@end