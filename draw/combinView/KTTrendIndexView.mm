//
//  KTTrendIndexView.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/12/22.
//  Copyright © 2015年 zscf. All rights reserved.
//
/*

#import "KTTrendIndexView.h"
#import "KTTrendMainView.h"
#import "KTIndexMainView.h"
#import "KTTrendData.h"

#import "KTCalcuLationOper.h"
#import "KTTrendOper.h"
#import "KTindexOper.h"

#define K_IndexPixWidth  3  //指标视图绘制的宽度
#define K_TopBotInset  1  //绘制时上下的缩进，目的是防止边界覆盖在指标等的绘制上面


@interface KTTrendIndexView ()<KTIndexMainViewDelegate,KTTrendMainViewDelegate>
{
    KTTrendMainView *m_trendMainView;
    KTIndexMainView *m_indexMainView;
    KTIndexOperParam *m_indexParam;
    KTTrendOperParam *m_trendParam;
}
@property(nonatomic,retain,nonnull) NSArray<__kindof NSNumber*> *indexCenterArr;
@property(nonatomic,retain,nonnull) NSArray<__kindof NSNumber*> *trendCenterArr;
@end

@implementation KTTrendIndexView

#pragma mark - 初始化相关

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        self.riseColor = [UIColor redColor];
        self.downColor = [UIColor greenColor];
        self.indexCenterArr = [NSArray array];
        _lastTrendTime = - 1440;
        //分时指标
        {
            m_trendMainView = [[KTTrendMainView alloc] initWithFrame:[self trendFrame]];
            m_trendMainView.trendDelegate = self;
            m_trendMainView.backgroundColor = [UIColor clearColor];
            [self addSubview:m_trendMainView];
            m_trendParam.drawRect = UIEdgeInsetsInsetRect(m_trendMainView.bounds, UIEdgeInsetsMake(K_TopBotInset, 0, K_TopBotInset, 0));
        }
        
        //指标
        {
            m_indexMainView = [[KTIndexMainView alloc] initWithFrame:[self indexFrame]];
            m_indexMainView.backgroundColor = [UIColor clearColor];
            m_indexMainView.indexDelegate = self;
            [self addSubview:m_indexMainView];
            m_indexParam.drawRect = UIEdgeInsetsInsetRect(m_indexMainView.bounds, UIEdgeInsetsMake(K_TopBotInset, 0, K_TopBotInset, 0));
        }
        _subIndexName = @"MACD";
    }
    return self;
}

#pragma mark - 对指标，分时接口的封装

-(void)setTradeTimes:(nonnull NSArray<__kindof KTTradeTime*>*)tradeTimeArr
{
    m_trendParam.tradeTimeArr = tradeTimeArr;
    m_trendMainView.tradeTimeArr = tradeTimeArr;
    
    //计算指标中心点位置
    int trendPix = (int)(m_trendMainView.maxWidth * [UIScreen mainScreen].scale);
    if(trendPix >= K_IndexPixWidth) //分时点足够密集
    {
        m_indexMainView.bRemoveRepeatPoint = NO;
    }
    else
    {
        m_indexMainView.bRemoveRepeatPoint = YES;
        CGFloat minDist = K_IndexPixWidth / [UIScreen mainScreen].scale;
        NSMutableArray<__kindof NSNumber*> *centersArr = [NSMutableArray array];
        NSArray <__kindof NSNumber*> *trendXCenter = [m_trendMainView getAllPriceValueXCenter];
        [centersArr addObject:trendXCenter.firstObject];
        for(NSUInteger i = 1;i < trendXCenter.count;i++)
        {
            NSNumber *lastCenter = centersArr.lastObject ;
            NSNumber *curCenter = [trendXCenter objectAtIndex:i];
            if([curCenter doubleValue] - [lastCenter doubleValue] >= minDist)
            {
                [centersArr addObject:curCenter];
            }
            else
            {
                [centersArr addObject:lastCenter];
            }
        }
        self.indexCenterArr = centersArr;
    }
}

-(int)getTrendTimeByXpos:(CGFloat)xpos  //获取X轴坐标xpos在分时图中代表的分时时间，如果没有时间分量,则返回INT32_MIN
{
    CGFloat xValueInTrendView= xpos - m_trendMainView.frame.origin.x;
    return [m_trendMainView getTrendTimeByXpos:xValueInTrendView];
}

-(CGFloat)getLocationXByTime:(int)time //计算时间在X轴上的位置
{
    CGFloat xpos = [m_trendMainView getLocationXByTime:time];
    return xpos + m_trendMainView.frame.origin.x;
}

-(CGPoint)getLastValuePt //获取最后一个值的绘制点
{
    CGPoint pt = [m_trendMainView getLastValuePt];
    return [self convertPoint:pt fromView:m_trendMainView];
}

-(CGFloat)getTrendPriceByYPos:(CGFloat)ypos //计算ypos代表的价格
{
    CGFloat yosInTrend = ypos - m_trendMainView.frame.origin.y;
    return [KTCalcuLationOper pixelToValue:yosInTrend minValue:m_trendParam.minValue MaxValue:m_trendParam.maxValue Rect:m_trendParam.drawRect];
}

-(CGFloat)getsubIndexValueByYPos:(CGFloat)ypos //计算ypos代表的值
{
    CGFloat yosInIndex = ypos - m_indexMainView.frame.origin.y;
    return [KTCalcuLationOper pixelToValue:yosInIndex minValue:m_indexParam.minValue MaxValue:m_indexParam.maxValue Rect:m_indexParam.drawRect];
}

#pragma mark - 布局

-(CGRect)trendFrame //分时绘制范围
{
    NSUInteger height = (NSUInteger)(self.frame.size.height * 0.65);
    return CGRectMake(0, 0, self.frame.size.width, height);
}

-(CGRect)indexFrame //指标绘制范围
{
    CGRect trendFrame = [self trendFrame];
    CGFloat orignY = trendFrame.origin.y + trendFrame.size.height;
    return CGRectMake(0, 0,orignY +1, self.frame.size.height - orignY + 1);
}

-(void)settrendIndexBorderWidth:(CGFloat)borderWidth
{
    m_trendMainView.layer.borderWidth = borderWidth;
    m_indexMainView.layer.borderWidth = borderWidth;
}

-(void)settrendIndexBorderColor:(nonnull UIColor*)borderColor
{
    m_trendMainView.layer.borderColor = borderColor.CGColor;
    m_indexMainView.layer.borderColor = borderColor.CGColor;
}

#pragma mark - 分时指标重绘

-(void)clearDraw //清除绘制
{
    [m_trendMainView clearAllDraw];
    [m_indexMainView clearAllDraw];
}

-(void)refreshAllTrendAndIndexDraw //刷新整个视图
{
    if(nil == self.delegate)
    {
        return;
    }
    NSArray<__kindof KTTrendData*> *trendDataArr = [self.delegate KTTrendIndexViewGetAllTrendData];
    if(0 == trendDataArr.count)
    {
        [m_trendMainView clearAllDraw];
        [m_indexMainView clearAllDraw];
        return;
    }
    _lastTrendTime = trendDataArr.lastObject.time;
    //分时
    {
        NSArray<__kindof NSNumber*> *minMaxValue = [KTCalcuLationOper getMinMaxValueOfTrendData:trendDataArr];
        m_trendParam.minValue = [minMaxValue.firstObject doubleValue];
        m_trendParam.maxValue = [minMaxValue.lastObject doubleValue];
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMaxCoord:Type:)])
        {
            m_trendParam.maxValue = [self.delegate KTTrendIndexViewModifyMaxCoord:m_trendParam.maxValue Type:KTTrendIndexViewRangeTypeTrend];
        }
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMinCoord:Type:)])
        {
            m_trendParam.minValue = [self.delegate KTTrendIndexViewModifyMinCoord:m_trendParam.minValue Type:KTTrendIndexViewRangeTypeTrend];
        }
        [m_trendMainView refreshTrendDraw];
        
    }
    //指标
    {
        m_indexMainView.showCount = trendDataArr.count;
        
        NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *nodeDatas = [self KTIndexViewGetIndexDrawData:m_indexMainView start:0 Count:trendDataArr.count];
        
        //计算最大值和最小值
        NSArray<__kindof NSNumber*> *indexMinMaxValue = [KTCalcuLationOper getMinMaxValueOfNodeDatas:nodeDatas];
        
        m_indexParam.minValue = [indexMinMaxValue.firstObject doubleValue];
        m_indexParam.maxValue = [indexMinMaxValue.lastObject doubleValue];
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMaxCoord:Type:)])
        {
            m_indexParam.maxValue = [self.delegate KTTrendIndexViewModifyMaxCoord:m_indexParam.maxValue Type:KTTrendIndexViewRangeTypeSubIndex];
        }
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMinCoord:Type:)])
        {
            m_indexParam.minValue = [self.delegate KTTrendIndexViewModifyMinCoord:m_indexParam.minValue Type:KTTrendIndexViewRangeTypeSubIndex];
        }

        [m_indexMainView refreshIndexDraw];
        
    }
}

-(void)updateLastTrendIndexData //更新最后一个分时指标
{
    if(nil == self.delegate)
    {
        return;
    }
}

-(void)addNextTrendIndexData //添加一个分时指标
{
    if(nil == self.delegate)
    {
        return;
    }

}

#pragma mark -  KTTrendMainViewDelegate

-(nonnull NSArray<__kindof KTTrendData*>*)KTTrendMainViewGetAllTrendData
{
    return [self.delegate KTTrendIndexViewGetAllTrendData];
}

-(CGFloat)KTTrendMainViewgetMinValue; //获取最小值
{
    return m_trendParam.minValue;
}

-(CGFloat)KTTrendMainViewgetMaxValue //获取最大值
{
    return m_trendParam.maxValue;
}

#pragma mark -  KTIndexMainViewDelegate

//最小值
-(CGFloat)KTIndexMainViewgetMinValue:(nonnull KTIndexMainView*)indexView
{
    return m_indexParam.minValue;
}

//最大值
-(CGFloat)KTIndexMainViewgetMaxValue:(nonnull KTIndexMainView*)indexView
{
    return m_indexParam.maxValue;
}

//获取X轴上的绘制中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIndexMainViewGetDrawCenterXArr:(nonnull KTIndexMainView*)indexView
{
    return self.indexCenterArr;
}

-(nonnull NSArray<__kindof KTIndexStyle*> *)KTIndexViewGetIndexStyle:(nonnull KTIndexMainView*)indexView//获取指标绘制样式
{
    NSUInteger count = [self.delegate KTTrendIndexViewSubIndexCount];
    NSMutableArray<__kindof KTIndexStyle*> *arr = [NSMutableArray array];
    for(NSUInteger i=0; i < count;i++)
    {
        [arr addObject:[self.delegate KTTrendIndexViewSubIndexStyleAtIndex:i]];
    }
    return arr;
}

-(nonnull NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *)KTIndexViewGetIndexDrawData:(nonnull KTIndexMainView*)indexView start:(NSUInteger)start Count:(NSUInteger)count
{
    NSUInteger allData = [self.delegate KTTrendIndexViewSubIndexCount];
    NSMutableArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *arr = [NSMutableArray array];
    for(NSUInteger i=0; i < allData;i++)
    {
        NSArray<__kindof KTIndexOneNodeData*>* nodeDataArr = [self.delegate KTTrendIndexViewGetSubIndexAtIndex:i];
        NSUInteger thisCount = count;
        if(start + thisCount >= nodeDataArr.count)
        {
            thisCount = nodeDataArr.count > start ? nodeDataArr.count - start : 0;
        }
        if(thisCount > 0)
        {
            [arr addObject:[nodeDataArr subarrayWithRange:NSMakeRange(start, thisCount)]];
        }
        else
        {
            [arr addObject:[NSArray array]];
        }
    }
    return arr;;
}

//设置指标的绘制宽度，否则默认为默认线宽
-(CGFloat)getIndexWidth:(nonnull KTIndexStyle*)indexData
{
    if(KTIndexDrawTypeCurve == indexData.indexDrawType)
    {
        return 1/ [UIScreen mainScreen].scale;
    }
    return (K_IndexPixWidth - 1) / [UIScreen mainScreen].scale;
}

-(BOOL)isIndexNeedChangeUintColor:(nonnull KTIndexStyle*)indexStyle //是否需要修改颜色
{
    if(KTIndexDrawTypeVol == indexStyle.indexDrawType || KTIndexDrawTypeColorStick == indexStyle.indexDrawType)
    {
        return YES;
    }
    return NO;
}


//获取修改的指标颜色(要求返回的个数与传入的个数相同)
-(nonnull NSArray<__kindof UIColor*>*)modifyUnitColorIndex:(nonnull KTIndexStyle*)indexStyle WithData:(nonnull  NSArray<__kindof KTIndexOneNodeData*>*) indexDataArr start:(NSUInteger)start
{
    NSArray<__kindof KTTrendData*> *trendDataArr = [self KTTrendMainViewGetAllTrendData];
    NSMutableArray<__kindof UIColor*> *colorArr = [NSMutableArray array];
    for(NSUInteger i = 0; i < indexDataArr.count;i++)
    {
        if(KTIndexDrawTypeVol == indexStyle.indexDrawType)
        {
            KTTrendData *data = [trendDataArr objectAtIndex:i];
            CGFloat lastPrice = self.lastClosePrice;
            if(index > 0)
            {
                lastPrice = [trendDataArr objectAtIndex:i - 1].dCurPrice;
            }
            UIColor*color = data.dCurPrice > lastPrice ? self.riseColor : self.downColor;
            [colorArr addObject:color];
        }
        else if(KTIndexDrawTypeColorStick == indexStyle.indexDrawType)
        {
            CGFloat numb = [[indexDataArr objectAtIndex:i].firstData doubleValue];
            UIColor*color = numb >= 0 ? self.riseColor : self.downColor;
            [colorArr addObject:color];
        }
        else
        {
            [colorArr addObject:self.riseColor];
        }
    }
    return colorArr;
}

#pragma mark - 重写setter和getter函数

-(void)setSubIndexName:(NSString *)subIndexName
{
    _subIndexName = subIndexName;
    if(nil == self.delegate)
    {
        return;
    }
    NSArray<__kindof KTTrendData*> *trendDataArr = [self.delegate KTTrendIndexViewGetAllTrendData];
    if(0 == trendDataArr.count)
    {
        [m_trendMainView clearAllDraw];
        [m_indexMainView clearAllDraw];
        return;
    }
    //指标
    {
        m_indexMainView.showCount = trendDataArr.count;
        
        NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *nodeDatas = [self KTIndexViewGetIndexDrawData:m_indexMainView start:0 Count:trendDataArr.count];
        
        //计算最大值和最小值
        NSArray<__kindof NSNumber*> *indexMinMaxValue = [KTCalcuLationOper getMinMaxValueOfNodeDatas:nodeDatas];
        
        m_indexParam.minValue = [indexMinMaxValue.firstObject doubleValue];
        m_indexParam.maxValue = [indexMinMaxValue.lastObject doubleValue];
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMaxCoord:Type:)])
        {
            m_indexParam.maxValue = [self.delegate KTTrendIndexViewModifyMaxCoord:m_indexParam.maxValue Type:KTTrendIndexViewRangeTypeSubIndex];
        }
        if(YES == [self.delegate respondsToSelector:@selector(KTTrendIndexViewModifyMinCoord:Type:)])
        {
            m_indexParam.minValue = [self.delegate KTTrendIndexViewModifyMinCoord:m_indexParam.minValue Type:KTTrendIndexViewRangeTypeSubIndex];
        }
        
        [m_indexMainView refreshIndexDraw];
        
    }

}

@dynamic mainViewMaxValue;
-(CGFloat)mainViewMaxValue
{
    return m_trendParam.maxValue;
}

@dynamic mainViewMinValue;
-(CGFloat)mainViewMinValue
{
    return m_trendParam.minValue;
}

@dynamic subViewMaxValue;
-(CGFloat)subViewMaxValue
{
    return m_indexParam.maxValue;
}

@dynamic subViewMinValue;
-(CGFloat)subViewMinValue
{
    return m_indexParam.minValue;
}

@end
*/