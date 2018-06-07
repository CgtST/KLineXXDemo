//
//  KTIndexMainView.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/28.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexMainView.h"
#import "KTCurveIndexDraw.h"
#import "KTCombinIndexDraw.h"
#import "KTSepIndexDraw.h"
#import "KTCalcuLationOper.h"
#import "KTKlineDataOper.h"
#import "KTindexOper.h"

@interface KTIndexMainView ()

@property(nonatomic) CGFloat maxValue; //最大值，默认为0
@property(nonatomic) CGFloat minValue; //最小值,默认为0

@property(nonatomic,retain,nonnull) NSArray<id<KTIndexDelegate>> *indexDrawArr; //指标绘制

@end

@implementation KTIndexMainView

#pragma mark - 初始化

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
    self.maxValue = 0.0;
    self.minValue = 0.0;
    self.bRemoveRepeatPoint = NO;
    
    //绘制
    self.indexDrawArr = [NSArray array];
}

#pragma mark - public

-(nonnull NSArray<__kindof UIColor*>*)getIndexColorAtIndex:(NSUInteger)index 
{
    NSMutableArray<__kindof UIColor*> *arr = [NSMutableArray array];
    NSAssert(index < self.showCount, @"index错误");
    for(id<KTIndexDelegate> indexDraw in self.indexDrawArr)
    {
        UIColor *color = [UIColor redColor];
        if(YES == [indexDraw isKindOfClass:[KTCurveIndexDraw class]])
        {
            color = ((KTCurveIndexDraw*)indexDraw).lineColor;
        }
        else if(YES == [indexDraw isKindOfClass:[KTCombinIndexDraw class]])
        {
            color = [((KTCombinIndexDraw*)indexDraw) getColorAtUnitIndex:index];
            if(nil == color)
            {
                color = [UIColor redColor];
            }
        }
        else if(YES == [indexDraw isKindOfClass:[KTSepIndexDraw class]])
        {
            
        }
        [arr addObject:color];
    }
    return [NSArray arrayWithArray:arr];
}

#pragma mark - 指标绘制更新

-(void)clearAllDraw //清除所有的绘制
{
    self.indexDrawArr = [NSArray array];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

//更新指标绘制
-(void)refreshIndexDraw
{
    if(nil == self.indexDelegate)
    {
        return;
    }
    //获取委托数据
    __unsafe_unretained KTIndexMainView *indexView = self;
    self.maxValue = [self.indexDelegate KTIndexMainViewgetMaxValue:indexView];
    self.minValue = [self.indexDelegate KTIndexMainViewgetMinValue:indexView];
    
    NSArray<__kindof KTIndexStyle*> *indexStyleArr = [self.indexDelegate KTIndexViewGetIndexStyle:indexView];
    NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *allIndexData = [self.indexDelegate KTIndexViewGetIndexDrawData:indexView start:self.startShowPos Count:self.showCount];
    NSAssert(indexStyleArr.count >= 0, @"没有指标绘制");
    NSAssert(indexStyleArr.count == allIndexData.count,@"指标绘制数据不对");
    
    NSArray<__kindof NSNumber*> *centerXArr = [self.indexDelegate KTIndexMainViewGetDrawCenterXArr:indexView];
    
    //创建绘制类
    self.indexDrawArr = [KTindexOper createDrawDelegate:indexStyleArr from:self.indexDrawArr];
    NSAssert(self.indexDrawArr.count == indexStyleArr.count, @"创建的指标绘制不对");
    
    //获取颜色
    NSMutableArray<__kindof NSArray<__kindof UIColor*>*> *allIndexColor = [NSMutableArray array];
    if(YES == [self.indexDelegate respondsToSelector:@selector(isIndexNeedChangeUintColor:)])
    {
        for(NSUInteger i = 0 ; i < indexStyleArr.count;i++)
        {
            KTIndexStyle *indexSyle = [indexStyleArr objectAtIndex:i];
            if(YES == [self.indexDelegate isIndexNeedChangeUintColor:indexSyle])
            {
                id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
                if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]]
                   && YES == [self.indexDelegate respondsToSelector:@selector(modifyLineColor:)])
                {
                    UIColor *color = [self.indexDelegate modifyLineColor:indexSyle];
                    [allIndexColor addObject:[NSArray arrayWithObject:color]];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]]
                        && YES == [self.indexDelegate respondsToSelector:@selector(modifyUnitColorIndex:WithData:start:)])
                {
                    NSArray<__kindof UIColor*> *unitColorArr = [self.indexDelegate modifyUnitColorIndex:indexSyle WithData:[allIndexData objectAtIndex:i] start:self.startShowPos];
                    [allIndexColor addObject:unitColorArr];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
                {
                    
                }
                else
                {
                    [allIndexColor addObject:[NSArray array]];
                }
            }
            else
            {
                [allIndexColor addObject:[NSArray array]];
            }
        }
    }
    
    //获取线宽
    NSMutableArray<__kindof NSNumber*> *lineWidthArr = [NSMutableArray array];
    for(KTIndexStyle *style in indexStyleArr)
    {
        [lineWidthArr addObject:@([self.indexDelegate getIndexWidth:style])];
    }
    
    KTIndexOperParam *dataParam = [[KTIndexOperParam alloc] init];
    dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    dataParam.maxValue = self.maxValue;
    dataParam.minValue = self.minValue;
    //更新创建绘制内容
    {
        for(NSUInteger i = 0; i < self.indexDrawArr.count ; i++)
        {
            NSArray<__kindof KTIndexOneNodeData*> *indexData = [allIndexData objectAtIndex:i];
            id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
            if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]])
            {
                KTCurveIndexDraw *curveDraw = (KTCurveIndexDraw*)drawDelegate;
                curveDraw.lineWidth = [[lineWidthArr objectAtIndex:i] doubleValue];
                if([allIndexColor objectAtIndex:i].count > 0)
                {
                    curveDraw.lineColor = [allIndexColor objectAtIndex:i].firstObject;
                }
                [KTindexOper setCuverData:indexData toCurveDraw:curveDraw XCenter:centerXArr Param:dataParam];
                curveDraw.startPos = indexData.count - curveDraw.pointValues.count;
                
            }
            else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]])
            {
                KTCombinIndexDraw *comDraw = (KTCombinIndexDraw*)drawDelegate;
                comDraw.unitWidth = [[lineWidthArr objectAtIndex:i] doubleValue];
                [KTindexOper createUnit:comDraw IndexDraw:[indexStyleArr objectAtIndex:i] Count:indexData.count];
                NSArray<__kindof UIColor*> *unitColorArr = [allIndexColor objectAtIndex:i];
                if(unitColorArr.count > 0)
                {
                    for(NSUInteger colorIndex = 0; colorIndex < unitColorArr.count;colorIndex++)
                    {
                        [comDraw mofiyColor:[unitColorArr objectAtIndex:colorIndex] AtIndex:colorIndex];
                    }
                }
                [KTindexOper setIndexData:indexData CenterXArr:centerXArr toComDraw:comDraw Param:dataParam];
            }
            else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
            {
                KTSepIndexDraw *sepDraw = (KTSepIndexDraw*)drawDelegate;
                [KTindexOper setData:indexData toSepDraw:sepDraw XCenter:centerXArr Param:dataParam];
                sepDraw.startPos = indexData.count - sepDraw.validCount;

            }
            else
            {
                NSAssert(false, @"目前没有这种绘制组合");
            }
        }
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
   
}

//修改最后一个指标数据
-(BOOL)updateLastIndexData:(nonnull NSArray<__kindof KTIndexOneNodeData*> *)lastIndexData
{
    if(lastIndexData.count != self.indexDrawArr.count)
    {
        return NO;
    }
    //最大值或者最小值发送改变
    NSArray<__kindof NSNumber*> *minMaxValue = [KTKlineDataOper getMinMaxValueIn2DimArr:lastIndexData];
    if([minMaxValue.firstObject doubleValue] < self.minValue || [minMaxValue.lastObject doubleValue] > self.maxValue)
    {
        return NO;
    }
    
    //获取颜色
    __unsafe_unretained KTIndexMainView *indexView = self;
    NSArray<__kindof KTIndexStyle*> *indexStyleArr = [self.indexDelegate KTIndexViewGetIndexStyle:indexView];
    NSMutableArray<__kindof NSArray<__kindof UIColor*>*> *allIndexColor = [NSMutableArray array];
    if(YES == [self.indexDelegate respondsToSelector:@selector(isIndexNeedChangeUintColor:)])
    {
        for(NSUInteger i = 0 ; i < indexStyleArr.count;i++)
        {
            KTIndexStyle *indexSyle = [indexStyleArr objectAtIndex:i];
            if(YES == [self.indexDelegate isIndexNeedChangeUintColor:indexSyle])
            {
                id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
                if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]]
                   && YES == [self.indexDelegate respondsToSelector:@selector(modifyLineColor:)])
                {
                    UIColor *color = [self.indexDelegate modifyLineColor:indexSyle];
                    [allIndexColor addObject:[NSArray arrayWithObject:color]];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]]
                        && YES == [self.indexDelegate respondsToSelector:@selector(modifyUnitColorIndex:WithData:start:)])
                {
                    NSArray<__kindof UIColor*> *unitColorArr = [self.indexDelegate modifyUnitColorIndex:indexSyle WithData:[NSArray arrayWithObject:[lastIndexData objectAtIndex:i]] start:self.startShowPos];
                    [allIndexColor addObject:unitColorArr];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
                {
                    
                }
                else
                {
                    [allIndexColor addObject:[NSArray array]];
                }
            }
            else
            {
                [allIndexColor addObject:[NSArray array]];
            }
        }
    }
    
    KTIndexOperParam *dataParam = [[KTIndexOperParam alloc] init];
    dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    dataParam.maxValue = self.maxValue;
    dataParam.minValue = self.minValue;
    
    
    
    for(NSUInteger i = 0 ; i < self.indexDrawArr.count;i++)
    {
        KTIndexOneNodeData *nodeData = [lastIndexData objectAtIndex:i];
        id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
        if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]])
        {
            [KTindexOper updateLastPoint:(KTCurveIndexDraw*)drawDelegate NewValue:[nodeData.firstData doubleValue] Param:dataParam];
        }
        else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]])
        {
            KTCombinIndexDraw *comDraw = (KTCombinIndexDraw*)drawDelegate;
            id<KTUnitDrawDelegate> unitDraw = [comDraw getUnitAt:comDraw.drawCount - 1];
            [KTindexOper updateLastUnit:unitDraw nodeData:nodeData Param:dataParam];
            NSArray<__kindof UIColor*> *unitColorArr = [allIndexColor objectAtIndex:i];
            if(unitColorArr.count > 0)
            {
                unitDraw.unitColor = unitColorArr.firstObject;
            }
        }
        else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
        {
            KTSepIndexDraw *sepDraw = (KTSepIndexDraw*)drawDelegate;
            [KTindexOper updateLastNode:nodeData toSepDraw:sepDraw Param:dataParam];
        }
        else
        {
            NSAssert(false, @"目前没有这种绘制组合");
        }
    }
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    return YES;
}

//新增一个指标数据的绘制
-(BOOL)addNextIndexData:(nonnull  NSArray<__kindof KTIndexOneNodeData*> *)nextIndexData
{
    if(nextIndexData.count != self.indexDrawArr.count)
    {
        return NO;
    }
    //最大值或者最小值发送改变
    NSArray<__kindof NSNumber*> *minMaxValue = [KTKlineDataOper getMinMaxValueIn2DimArr:nextIndexData];
    if([minMaxValue.firstObject doubleValue] < self.minValue || [minMaxValue.lastObject doubleValue] > self.maxValue)
    {
        return NO;
    }
    
    //获取颜色
    __unsafe_unretained KTIndexMainView *indexView = self;
    NSArray<__kindof KTIndexStyle*> *indexStyleArr = [self.indexDelegate KTIndexViewGetIndexStyle:indexView];
    NSMutableArray<__kindof NSArray<__kindof UIColor*>*> *allIndexColor = [NSMutableArray array];
    if(YES == [self.indexDelegate respondsToSelector:@selector(isIndexNeedChangeUintColor:)])
    {
        for(NSUInteger i = 0 ; i < indexStyleArr.count;i++)
        {
            KTIndexStyle *indexSyle = [indexStyleArr objectAtIndex:i];
            if(YES == [self.indexDelegate isIndexNeedChangeUintColor:indexSyle])
            {
                id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
                if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]]
                   && YES == [self.indexDelegate respondsToSelector:@selector(modifyLineColor:)])
                {
                    UIColor *color = [self.indexDelegate modifyLineColor:indexSyle];
                    [allIndexColor addObject:[NSArray arrayWithObject:color]];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]]
                        && YES == [self.indexDelegate respondsToSelector:@selector(modifyUnitColorIndex:WithData:start:)])
                {
                    NSArray<__kindof UIColor*> *unitColorArr = [self.indexDelegate modifyUnitColorIndex:indexSyle WithData:[NSArray arrayWithObject: [nextIndexData objectAtIndex:i]] start:self.startShowPos];
                    [allIndexColor addObject:unitColorArr];
                }
                else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
                {
                    
                }
                else
                {
                    [allIndexColor addObject:[NSArray array]];
                }
            }
            else
            {
                [allIndexColor addObject:[NSArray array]];
            }
        }
    }
    
    //添加第一个点
    NSArray<__kindof NSNumber*> *centerXArr = [self.indexDelegate KTIndexMainViewGetDrawCenterXArr:indexView];

    KTIndexOperParam *dataParam = [[KTIndexOperParam alloc] init];
    dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    dataParam.maxValue = self.maxValue;
    dataParam.minValue = self.minValue;
    
    for(NSUInteger i = 0 ; i < self.indexDrawArr.count;i++)
    {
        KTIndexOneNodeData *lastValue = [nextIndexData objectAtIndex:i];
        id<KTIndexDelegate> drawDelegate = [self.indexDrawArr objectAtIndex:i];
        if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]])
        {
            [KTindexOper addNextPoint:(KTCurveIndexDraw*)drawDelegate NewValue:[lastValue.firstData doubleValue] CenterXArr:centerXArr Param:dataParam];
            
        }
        else if(YES == [drawDelegate isKindOfClass:[KTCombinIndexDraw class]])
        {
            KTCombinIndexDraw *comDraw = (KTCombinIndexDraw*)drawDelegate;
            [KTindexOper addNextUnittoComDraw:comDraw nodeData:lastValue CenterXArr:centerXArr Param:dataParam];
            NSArray<__kindof UIColor*> *unitColorArr = [allIndexColor objectAtIndex:i];
            if(unitColorArr.count > 0)
            {
               [comDraw mofiyColor:unitColorArr.firstObject AtIndex:comDraw.drawCount - 1];
            }
        }
        else if(YES == [drawDelegate isKindOfClass:[KTSepIndexDraw class]])
        {
            KTSepIndexDraw *sepDraw = (KTSepIndexDraw*)drawDelegate;
            [KTindexOper addNextNode:lastValue toSepDraw:sepDraw XCenter:centerXArr Param:dataParam];
        }
        else
        {
            NSAssert(false, @"目前没有这种绘制组合");
        }
    }
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];

    return YES;
}

#pragma mark - 重写绘制

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(id<KTIndexDelegate> indexDraw in self.indexDrawArr)
    {
        [indexDraw draw:context];
    }
}

#pragma mark - 重写setter和getter函数

-(void)setFrame:(CGRect)frame
{
    CGRect lastFrame = self.frame;
    [super setFrame:frame];
    if(!CGRectEqualToRect(lastFrame, frame))
    {
        [self refreshIndexDraw];
    }
}

-(void)setBRemoveRepeatPoint:(BOOL)bRemoveRepeatPoint
{
    _bRemoveRepeatPoint = bRemoveRepeatPoint;
    for(id<KTIndexDelegate> indexDraw in self.indexDrawArr)
    {
        if(YES == [indexDraw isKindOfClass:[KTCurveIndexDraw class]])
        {
            ((KTCurveIndexDraw*)indexDraw).bRemoveRepeatPoint = bRemoveRepeatPoint;
        }
    }

}

@end
