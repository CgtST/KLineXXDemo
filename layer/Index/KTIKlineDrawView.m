//
//  KTIKlineDrawView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIKlineDrawView.h"
#import "KTICandleUnitDraw.h"
#import "KTINodeData.h"
#import "KTICustomDataOper.h"
#import "KTIIndexStyle.h"

@interface KTIKlineDrawView ()
{
    NSLock *m_lock;
}
@property(nonatomic) CGFloat minValue;
@property(nonatomic) CGFloat maxValue;
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof KTICandleUnitDraw*> *candleDrawList;//K线绘制
@property(nonatomic,readonly,retain,nonnull) dispatch_queue_t klineQueue;
@end

@implementation KTIKlineDrawView

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        [self initValue];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        [self initValue];
    }
    return self;
}
-(void)initValue
{

    self.maxValue = INT_MIN;
    self.minValue = INT_MAX;
    self.bshow = YES;

    m_lock = [[NSLock alloc] init];
    _klineQueue = [[self class] shareKlineQuote];
    
    //绘制
    _candleDrawList = [NSMutableArray array];
    self.showCount = 0;
}

#pragma mark - public

-(void)clearIndexDraws:(nullable FunctionFinishBlock)finishblock //清空绘制
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.klineQueue, ^{
        [weakSelf clearCandleDraw];
        if(nil != finishblock)
        {
            finishblock();
        }
    });
}

//刷新绘制
-(void)refreshIndexDraws:(nonnull KTIIndexDataArr*)allData block:(nullable FunctionFinishBlock)finishblock
{
    if(nil == self.indexDelegate)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    //仅仅在刷新数据时才更新最大值和最小值，其他情况下默认最大值和最小值不变
    self.maxValue = [self.indexDelegate KTIBaseIndexDrawViewGetYposOfMax:weakSelf];
    self.minValue = [self.indexDelegate KTIBaseIndexDrawViewGetYposOfMin:weakSelf];
    KTIKLineDrawType klineType = [[KTIIndexStyle shareKlineIndexSyle] getKlineDrawType];
    CGFloat unitWidth = [[KTIIndexStyle shareKlineIndexSyle] getUnitDrawWidth:self.unitCellWidth];
    unitWidth = unitWidth < 1 ? 1 : unitWidth;
    UIColor *riseColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeRise];
    UIColor *downColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeDown];
    UIColor *klineColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypekline];
    //计算数据
    dispatch_barrier_async(self.klineQueue, ^{
        KTIIndexData *indexData = allData.indexDataArr.firstObject;
        NSMutableArray<__kindof KTICandleUnitDraw*> *uintArr = [NSMutableArray array];
         NSMutableArray<__kindof KTICandleUnitDraw*> *oldDrawArr = [weakSelf.candleDrawList mutableCopy];
        //创建绘制单元并更新数据
        for(NSUInteger i = 0; i < indexData.nodeDataArr.count;i++)
        {
            KTICandleUnitDraw *draw = oldDrawArr.lastObject;
            if(nil != draw)
            {
                [oldDrawArr removeLastObject];
            }
            else
            {
                draw = [[KTICandleUnitDraw alloc] init];
            }
            draw.candleStyle = klineType;
            draw.unitWidth = unitWidth;
            draw.fillColor = [[weakSelf class] getColor:indexData.nodeDataArr[i] RiseColor:riseColor DownColor:downColor KlineColor:klineColor];
            NSArray<__kindof NSNumber*> *numArr = [KTICustomDataOper values2DrawPoints:indexData.nodeDataArr[i] MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
            [draw setDrawData:numArr];
            [uintArr addObject:draw];
        }
        
        [weakSelf clearCandleDraw];
        [weakSelf addUnitArr:uintArr];
        if(nil != finishblock)
        {
            finishblock();
        }
    });
}

//更新最后几个绘制数据
-(void)updateLastIndexDraws:(nonnull KTIIndexDataArr*)updateData block:(nullable FunctionFinishBlock)finishblock
{
    if(nil == self.indexDelegate || updateData.nodeCount < 1)
    {
        return;
    }

    UIColor *riseColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeRise];
    UIColor *downColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeDown];
    UIColor *klineColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypekline];
    
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.klineQueue, ^{
        KTIIndexData *indexData = updateData.indexDataArr.firstObject;
        NSUInteger start = weakSelf.candleDrawList.count > indexData.nodeDataArr.count ? weakSelf.candleDrawList.count - indexData.nodeDataArr.count : 0;
        //更新数据到绘制单元
        for(NSUInteger i = 0; i <indexData.nodeDataArr.count && i + start < weakSelf.candleDrawList.count;i++)
        {
            KTICandleUnitDraw *draw = weakSelf.candleDrawList[i + start];
            draw.fillColor = [[weakSelf class] getColor:indexData.nodeDataArr[i] RiseColor:riseColor DownColor:downColor KlineColor:klineColor];
            NSArray<__kindof NSNumber*> *numArr = [KTICustomDataOper values2DrawPoints:indexData.nodeDataArr[i] MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
            [draw setDrawData:numArr];
        }
        if(nil != finishblock)
        {
            finishblock();
        }

    });
    
    
}

//添加新的绘制数据
-(void)addNextIndexDraws:(nonnull KTIIndexDataArr*)addData block:(nullable FunctionFinishBlock)finishblock
{
    if(nil == self.indexDelegate || addData.nodeCount < 1)
    {
        return;
    }
    
    //仅仅在刷新数据时才更新最大值和最小值，其他情况下默认最大值和最小值不变
    KTIKLineDrawType klineType = [[KTIIndexStyle shareKlineIndexSyle] getKlineDrawType];
    CGFloat unitWidth = [[KTIIndexStyle shareKlineIndexSyle] getUnitDrawWidth:self.unitCellWidth];
    UIColor *riseColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeRise];
    UIColor *downColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypeDown];
    UIColor *klineColor = [[KTIIndexStyle shareKlineIndexSyle] getColor:KTIIndexColorTypekline];

    //计算数据
    __weak typeof(self) weakSelf = self;
    //计算数据
    dispatch_barrier_async(self.klineQueue, ^{
        
        NSMutableArray *oldDrawArr = [NSMutableArray array];
        //移除前面的数据
        if(addData.nodeCount + weakSelf.candleDrawList.count > weakSelf.showCount)
        {
            NSUInteger removeCount = addData.nodeCount + weakSelf.candleDrawList.count - weakSelf.showCount;
            [oldDrawArr addObjectsFromArray: [weakSelf removeKlineFromStart:removeCount]];
        }
        KTIIndexData *indexData = addData.indexDataArr.firstObject;
         NSMutableArray<__kindof KTICandleUnitDraw*> *uintArr = [NSMutableArray array];
        //创建绘制单元并更新数据
        for(NSUInteger i = 0; i < indexData.nodeDataArr.count;i++)
        {
            KTICandleUnitDraw *draw = oldDrawArr.lastObject;
            if(nil != draw)
            {
                [oldDrawArr removeLastObject];
            }
            else
            {
                draw = [[KTICandleUnitDraw alloc] init];
            }
            draw.candleStyle = klineType;
            draw.unitWidth = unitWidth;
            draw.fillColor = [[weakSelf class] getColor:indexData.nodeDataArr[i] RiseColor:riseColor DownColor:downColor KlineColor:klineColor];
            NSArray<__kindof NSNumber*> *numArr = [KTICustomDataOper values2DrawPoints:indexData.nodeDataArr[i] MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
            [draw setDrawData:numArr];
            [uintArr addObject:draw];
        }
        [weakSelf addUnitArr:uintArr];
        if(nil != finishblock)
        {
            finishblock();
        }
    });

}

#pragma mark - 重写绘制

-(void)drawRect:(CGRect)rect
{
    if(NO == self.bshow || nil == self.indexDelegate)
    {
        return;
    }
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    __weak typeof(self) weakSelf = self;
    NSArray<__kindof NSNumber*> *centerArr = [self.indexDelegate KTIBaseIndexDrawViewGetXcenter:weakSelf];
    [m_lock lock];
    NSArray *canleArr = [self.candleDrawList copy];
    [m_lock unlock];
    for(NSUInteger i = 0; i < MIN(centerArr.count, canleArr.count);i++)
    {
        CGFloat center = [centerArr[i] floatValue];
        [canleArr[i] draw:context Center:center];
    }
}

#pragma mark - getter and setter

@dynamic curKlineDrawCount;
-(NSUInteger)curKlineDrawCount
{
    __block NSUInteger drawCount = 0;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.klineQueue, ^{
        drawCount = weakSelf.candleDrawList.count;
        if(drawCount > weakSelf.showCount)
        {
            //在进行缩小时，可能绘制还没来得及更新
            drawCount = weakSelf.showCount;
        }
    });
    return drawCount;
}

#pragma mark - private

-(void)addUnitArr:(NSArray<__kindof KTICandleUnitDraw*>*)unitArr
{
    [m_lock lock];
    [self.candleDrawList addObjectsFromArray:unitArr];
    [m_lock unlock];
}

-(void)clearCandleDraw
{
    [m_lock lock];
    [self.candleDrawList removeAllObjects];
    [m_lock unlock];
}

-(NSArray<__kindof KTICandleUnitDraw*>*)removeKlineFromStart:(NSUInteger)count
{
    [m_lock lock];
    NSRange range = NSMakeRange(0, count);
    if(count > self.candleDrawList.count)
    {
        range.length = self.candleDrawList.count;
    }
    NSArray<__kindof KTICandleUnitDraw*> *retObj = [self.candleDrawList subarrayWithRange:range];
    [self.candleDrawList removeObjectsInRange:range];
    [m_lock unlock];
    return retObj;
}

+(UIColor*)getColor:(KTINodeData*)nodeData RiseColor:(UIColor*)riseColor DownColor:(UIColor*)downColor KlineColor:(UIColor*)klineColor
{
    if(nodeData.allValues.count < 4)
    {
        return klineColor;
    }
    CGFloat closePrice = [nodeData.allValues.lastObject doubleValue];
    CGFloat openPrice = [nodeData.allValues[2] doubleValue];
    if(closePrice > openPrice)
    {
        return riseColor;
    }
    else if(closePrice < openPrice)
    {
        return downColor;
    }
    return klineColor;
}

+(dispatch_queue_t)shareKlineQuote
{
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        queue = dispatch_queue_create("klineQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

@end
