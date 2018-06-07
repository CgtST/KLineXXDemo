//
//  KTIndexCalculationResult.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexCalculationResult.h"

@interface KTIndexCalculationResult ()

@property(nonatomic,readwrite,copy,nonnull) NSString* indexName; //指标名称
@property(nonatomic,readwrite,retain,nonnull) NSArray<__kindof KTIndexData*> *indexDataList; //指标结果集

@end

@implementation KTIndexCalculationResult

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.indexName = [dataDic objectForKey:@"IndexName"];
        NSMutableArray<__kindof KTIndexData*> *datalist = [NSMutableArray array];
        NSArray<__kindof NSDictionary*> *dataArr = [dataDic objectForKey:@"Lines"];
        for(NSDictionary *dic in dataArr)
        {
            NSString *str = [dic objectForKey:@"LName"];
            if(self.indexName.length > 0 &&(0 == str.length || YES == [str isEqualToString:@" "]))//特殊处理：指标名称
            {
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [mutDic setValue:self.indexName forKey:@"LName"];
                KTIndexData *indexdata = [[KTIndexData alloc] initWithDic:mutDic];
                if(nil != indexdata)
                {
                    [datalist addObject:indexdata];
                }
            }
            else
            {
                KTIndexData *indexdata = [[KTIndexData alloc] initWithDic:dic];
                if(nil != indexdata)
                {
                    [datalist addObject:indexdata];
                }
            }
        }
        self.indexDataList = datalist;
    }
    return self;
}


-(nonnull NSArray<__kindof NSString*>*)getAllIndexName //获取指标名称
{
    NSMutableArray<__kindof NSString*> *arr = [NSMutableArray array];
    for(KTIndexData *data in self.indexDataList)
    {
        [arr addObject:data.indexStyle.indexLineName];
    }
    return [NSArray arrayWithArray:arr];
}

-(nonnull NSArray<__kindof KTIndexStyle*>*)getAllDrawStyle //获取所有的绘制类型
{
    NSMutableArray<__kindof KTIndexStyle*> *arr = [NSMutableArray array];
    for(KTIndexData *data in self.indexDataList)
    {
        [arr addObject:data.indexStyle];
    }
    return [NSArray arrayWithArray:arr];
}

-(nonnull NSArray<__kindof KTIndexOneNodeData*>*)getAllNodeDataAt:(NSUInteger)index;
{
    NSMutableArray<__kindof KTIndexOneNodeData*> *arr = [NSMutableArray array];
    for(KTIndexData *data in self.indexDataList)
    {
        KTIndexOneNodeData *nodeData = [data getNodeDataAtIndex:index];
        if(nil != nodeData)
        {
            [arr addObject:nodeData];
        }
    }
    return [NSArray arrayWithArray:arr];

}

-(void)addIndexDataByIndex:(nonnull KTIndexCalculationResult*)indexReult Count:(NSUInteger)count
{
     NSAssert(self.indexDataList.count == indexReult.indexDataList.count, @"修改指标错误");
    if(0 == self.indexDataList.count)
    {
        return;
    }
    for(NSUInteger i=0;i < self.indexDataList.count;i++)
    {
        KTIndexData *curIndexData = [self.indexDataList objectAtIndex:i];
        KTIndexData *addIndexData = [indexReult.indexDataList objectAtIndex:i];
        NSUInteger addCount =  MIN(count,addIndexData.nodeCount);
        NSUInteger begin = addIndexData.nodeCount - addCount;
        
        NSArray<__kindof KTIndexOneNodeData*> *nodeDataArr = [addIndexData getIndexDatabeginPos:begin Count:count];
        [curIndexData addNodeDatasToLast:nodeDataArr];
    }
}

-(void)modifyLastOrgIndexDataByIndex:(KTIndexCalculationResult*)indexReult
{
    NSAssert(self.indexDataList.count == indexReult.indexDataList.count, @"修改指标错误");
    for(NSUInteger i=0;i < self.indexDataList.count;i++)
    {
        KTIndexData *curIndexData = [self.indexDataList objectAtIndex:i];
        KTIndexData *addIndexData = [indexReult.indexDataList objectAtIndex:i];
        KTIndexOneNodeData *modiyData = [addIndexData getNodeDataAtIndex:addIndexData.nodeCount - 1];
        if(modiyData.nodeDataCount  == curIndexData.nodeDataCount)
        {
            [curIndexData modifyNodeData:modiyData atIndex:(curIndexData.nodeCount - 1)];
        }
    }
}

-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    for(KTIndexData *data in self.indexDataList)
    {
        if(NO == data.indexStyle.bshow) //不显示，则不列入最大值和最小值的计算
        {
            continue;
        }
        NSArray<__kindof NSNumber*> *minMax = [data getMinMaxValue];
        if([minMax.firstObject doubleValue] < fValueMin)
        {
            fValueMin = [minMax.firstObject doubleValue] ;
        }
        if([minMax.lastObject doubleValue]  > fValueMax)
        {
            fValueMax = [minMax.lastObject doubleValue] ;
        }
    }
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

//获取最大值和最小值
-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueStart:(NSUInteger)start Count:(NSUInteger)count
{
    return [KTIndexData getMinMaxIndexValue:self.indexDataList Start:start Count:count];
}



@end
