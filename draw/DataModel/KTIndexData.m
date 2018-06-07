//
//  KTIndexData.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexData.h"

@interface KTIndexData ()


@property(nonatomic,retain,readwrite,nonnull) KTIndexStyle *indexStyle;

@property(nonatomic,readwrite) NSUInteger nodeDataCount; //指标线每个节点内的数据个数

@property(nonatomic,readwrite,retain,nonnull) NSMutableArray<__kindof KTIndexOneNodeData*> *nodeDatas; //节点数据(内部数组存放的是每个节点的数据)

@end

@implementation KTIndexData

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.indexStyle = [[KTIndexStyle alloc] initWithDic:dataDic];
        self.nodeDataCount = (NSUInteger)[[dataDic objectForKey:@"ValueNum"] integerValue];

        NSMutableArray<__kindof KTIndexOneNodeData*> *nodes = [NSMutableArray array];
        NSArray<__kindof NSDictionary*> *dataArr = [dataDic objectForKey:@"Data"];
        for(NSDictionary *dic in dataArr)
        {
            [nodes addObject:[[KTIndexOneNodeData alloc] initWithDic:dic Count:self.nodeDataCount]];
        }
        
        self.nodeDatas = nodes;
    }
    return self;
}

//修改第index个节点的数据
-(BOOL)modifyNodeData:(nonnull KTIndexOneNodeData *)nodeData atIndex:(NSUInteger)index
{
    if(index >= self.nodeCount)
    {
        return NO;
    }
    if(nodeData.nodeDataCount != self.nodeDataCount)
    {
        return NO;
    }
    [self.nodeDatas insertObject:nodeData atIndex:index];
    [self.nodeDatas removeObjectAtIndex:index + 1];
    return YES;
}

//添加节点数据到最后,返回NO表示添加失败(此时没有添加任何节点)
-(BOOL)addNodeDatasToLast:(nonnull NSArray<__kindof KTIndexOneNodeData*>*) nodeDataArr
{
    for(KTIndexOneNodeData *data in nodeDataArr)
    {
        if(data.nodeDataCount != self.nodeDataCount)
        {
            return NO;
        }
    }
    if(nodeDataArr.count > 0)
    {
        [self.nodeDatas addObjectsFromArray:nodeDataArr];
    }
    return YES;
}


//获取第index个节点的数据
-(nullable KTIndexOneNodeData*)getNodeDataAtIndex:(NSUInteger)index
{
    if(index >= self.nodeCount)
    {
        return nil;
    }
    return [self.nodeDatas objectAtIndex:index];
}

-(nonnull NSArray<__kindof KTIndexOneNodeData*> *)getIndexDatabeginPos:(NSUInteger)begin Count:(NSUInteger)count
{
    NSMutableArray<__kindof KTIndexOneNodeData*> *retArr = [NSMutableArray array];
    if(begin >= self.nodeCount)
    {
        return retArr;
    }
    NSUInteger dataCount = MIN(self.nodeCount - begin, count);
    for(NSUInteger i = begin;i<begin + dataCount;i++)
    {
        [retArr addObject:[self.nodeDatas objectAtIndex:i]];
    }
    return retArr;
}

//获取最大值和最小值
-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue
{
    return [self getMinMaxValueStart:0 Count:self.nodeCount];
}

-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueStart:(NSUInteger)start Count:(NSUInteger)count
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    NSUInteger lastCount = MIN(start + count,self.nodeCount);
    for(NSUInteger nodeIndex = start; nodeIndex < lastCount;nodeIndex++)
    {
        KTIndexOneNodeData *nodeData = [self.nodeDatas objectAtIndex:nodeIndex];
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
    return [NSArray arrayWithObjects:@(fValueMin),@(fValueMax), nil];
}

#pragma mark - static

+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxIndexValue:(nonnull NSArray<__kindof KTIndexData*> *)indexDataArr Start:(NSUInteger)start Count:(NSUInteger)count
{
    CGFloat fValueMin = CGFLOAT_MAX;
    CGFloat fValueMax = CGFLOAT_MIN;
    for(KTIndexData *data in indexDataArr)
    {
        if(NO == data.indexStyle.bshow) //不显示，则不列入最大值和最小值的计算
        {
            continue;
        }
        NSArray<__kindof NSNumber*> *minMax = [data getMinMaxValueStart:start Count:count];
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


#pragma mark - 重写setter和getter

@dynamic nodeCount;
-(NSUInteger)nodeCount
{
    return self.nodeDatas.count;
}

@end
