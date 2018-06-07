//
//  KTIndexCalculationInput.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexCalculationInput.h"

@implementation KTIndexCalculationInput

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.indexName = @"";
        self.klineType = 0;
        self.klineDetailDatas = [NSArray array];
    }
    return self;
}


-(nonnull NSDictionary*)toDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.indexName forKey:@"IndexName"];
    [dic setValue:[@(self.klineType) stringValue] forKey:@"LType"];
    NSMutableArray<NSDictionary *> *klinedata = [NSMutableArray array];
    for(KTKlineData *data in self.klineDetailDatas)
    {
        [klinedata addObject:[data toDictionary]];
    }
    [dic setValue:klinedata forKey:@"KLine"];
    return dic;
}

@end
