//
//  KTKlineData.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTKlineData.h"

@implementation KTKlineData

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.time = 0;  //K线时间
        self.riseHomeNum = @"0";  //指数的上涨家数(BTI指标用到)
        self.downHoneNum = @"0"; //指数的下跌家数(BTI指标用到)
    }
    return self;
}

-(nonnull NSDictionary*)toDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[@(self.time) stringValue] forKey:@"Time"];
    [dic setValue:[@(self.dOpenPrice) stringValue] forKey:@"Open"];
    [dic setValue:[@(self.dClosePrice) stringValue] forKey:@"Close"];
    [dic setValue:[@(self.dHighPrice) stringValue] forKey:@"High"];
    [dic setValue:[@(self.dLowPrice) stringValue] forKey:@"Low"];
    [dic setValue:[@(self.vol) stringValue] forKey:@"Vol"];
    [dic setValue:[@(self.dAmo) stringValue] forKey:@"Amo"];
    
    [dic setValue:[@(self.dHold)  stringValue] forKey:@"Hold"];
    [dic setValue:self.riseHomeNum forKey:@"Up"];
    [dic setValue:self.downHoneNum forKey:@"Down"];
    return dic;
}

-(BOOL)copyDataFrom:(nonnull KTKlineData*)klinData
{
    if(self.time != klinData.time)
    {
        return NO;
    }
    self.dOpenPrice = klinData.dOpenPrice;
    self.dClosePrice = klinData.dClosePrice;
    self.dLowPrice = klinData.dLowPrice;
    self.dHighPrice = klinData.dHighPrice;
    self.vol = klinData.vol;
    self.dAmo = klinData.dAmo;
    self.riseHomeNum = [klinData.riseHomeNum copy];
    self.downHoneNum = [klinData.downHoneNum copy];
    return YES;
}

@end
