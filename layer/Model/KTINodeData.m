//
//  KTINodeData.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTINodeData.h"

@implementation KTINodeData

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.isNumValid = NO;
        _minValue = INT_MAX;
        _maxValue = INT_MIN;
        _allValues = nil;
        _extendData = nil;
    }
    return self;
}
+(nonnull KTINodeData*)transToNodeData:(CGFloat)value
{
    KTINodeData *node = [[KTINodeData alloc] init];
    node.isNumValid = YES;
    node.allValues = @[@(value)];
    return node;
}

+(nonnull KTINodeData*)transKlineData2NodeDataHighPrice:(CGFloat)highPrice LowPrice:(CGFloat)lowPrice OpenPrice:(CGFloat)openPrice ClosePrice:(CGFloat)closePrice
{
    KTINodeData *node = [[KTINodeData alloc] init];
    node.isNumValid = YES;
    node.allValues = @[@(highPrice),@(lowPrice),@(openPrice),@(closePrice)];
    return node;
}


#pragma mark - getter and setter

-(void)setAllValues:(NSArray<__kindof NSNumber *> *)allValues
{
    _allValues = allValues;
    CGFloat minValue = INT_MAX;
    CGFloat maxValue = INT_MIN;
    for(NSNumber *num in allValues)
    {
        CGFloat value = [num doubleValue];
        if(value > maxValue)
        {
            maxValue = value;
        }
        if(value < minValue)
        {
            minValue = value;
        }
    }
    _maxValue = maxValue;
    _minValue = minValue;
}


@end

@interface KTIIndexData ()
{
    NSMutableArray<__kindof KTINodeData*> *m_nodeDataArr;
}
@property(nonatomic,readonly) NSUInteger invalidValueNum; //不合法值得个数
@property(nonatomic,readonly) NSUInteger validValueNum; //合法值个数
@end

@implementation KTIIndexData

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        m_nodeDataArr = [NSMutableArray array];
        _invalidValueNum = 0;
    }
    return self;
}

+(nonnull KTIIndexData*)IndexWith:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr
{
    KTIIndexData *indexData = [[KTIIndexData alloc] init];
    [indexData setNodeData:nodeDataArr];
    return indexData;
}

+(nonnull KTIIndexData*)transPrice2Index:(nonnull NSArray<__kindof NSNumber*>*) priceArr;
{
    KTIIndexData *priceIndexData = [[KTIIndexData alloc] init];
    for(NSUInteger i = 0; i < priceArr.count;i++)
    {
        KTINodeData *newPricenode = [[KTINodeData alloc] init];
        newPricenode.allValues = @[priceArr[i]];
        [priceIndexData addNodeData:newPricenode];
    }
    return  priceIndexData;
}

-(void)addNodeData:(nonnull KTINodeData*)nodeData
{
    [m_nodeDataArr addObject:nodeData];
}

-(void)addNodeDataFromArr:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr
{
    [m_nodeDataArr addObjectsFromArray:nodeDataArr];
}

-(void)setNodeData:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr
{
    [m_nodeDataArr removeAllObjects];
    [m_nodeDataArr addObjectsFromArray:nodeDataArr];
}

-(void)clearAllNodeData
{
    [m_nodeDataArr removeAllObjects];
}

//获取指标中不合法的值
+(NSUInteger)getInvaildValueCountInIndex:(nonnull NSArray<__kindof KTINodeData*>*)values
{
    NSUInteger invaildValueCount = 0;
    for(KTINodeData *node in values)
    {
        if(NO == node.isNumValid)
        {
            invaildValueCount ++;
        }
    }
    return invaildValueCount;
}

#pragma mark - getter and setter

@dynamic nodeDataArr;
-(NSArray<__kindof KTINodeData*> *)nodeDataArr
{
    return m_nodeDataArr;
}

@end

@interface KTIIndexDataArr ()
{
    NSMutableArray<__kindof KTIIndexData*> *m_indexDataArr;
}
@end

@implementation KTIIndexDataArr

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        m_indexDataArr = [NSMutableArray array];
    }
    return self;
}



+(nonnull KTIIndexDataArr*)IndexWith:(nonnull KTIIndexData*)nodeDataArr
{
    KTIIndexDataArr *indexArr = [[KTIIndexDataArr alloc] init];
    [indexArr addIndexData:nodeDataArr];
    return indexArr;
}


-(BOOL)addIndexData:(nonnull KTIIndexData*)indexData
{
    if(m_indexDataArr.count > 0 && self.nodeCount != indexData.nodeDataArr.count)
    {
        NSAssert(false, @"同一个指标内，每个子指标的数据个数不相等");
        return NO;
    }
    [m_indexDataArr addObject:indexData];
    return YES;
}

-(void)clearAllIndexData
{
    [m_indexDataArr removeAllObjects];
}

#pragma mark - getter and setter

@dynamic nodeCount;
-(NSUInteger)nodeCount
{
    KTIIndexData *indexData = m_indexDataArr.firstObject;
    return indexData.nodeDataArr.count;
}

@dynamic indexDataArr;
-(NSArray<__kindof KTIIndexData*>*)indexDataArr
{
    return m_indexDataArr;
}


@end
