//
//  KTKlineIndexsView.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/2/1.
//  Copyright © 2016年 zscf. All rights reserved.
//
/*
#import "KTKlineIndexsView.h"
#import "KTKlineMainView.h"
#import "KTIndexMainView.h"
#import "KTKlineData.h"
#import "KTCalcuLationOper.h"
#import "KTIndexStyle.h"
#import "KTIndexData.h"
#import "KTindexOper.h"
#import "KTKlineOper.h"

#define K_IndexKlineSpace 20.00
#define K_TopBotInset  1  //绘制时上下的缩进，目的是防止边界覆盖在指标等的绘制上面

@interface KTKlineIndexsView ()<KTIndexMainViewDelegate,KTKlineMainViewDelegate>
{
    KTKlineMainView *m_klineMainView;
    KTIndexMainView *m_klineIndexView; //主图指标
    KTIndexMainView *m_indexMainView;
    KTIndexOperParam *m_indexParam;
    KTKlineOperParam *m_klineParam;
}
@end

@implementation KTKlineIndexsView

#pragma mark - 初始化相关

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        //主图
        {
            
            m_klineMainView = [[KTKlineMainView alloc] initWithFrame:[self klineFrame]];
            m_klineMainView.klineDelegate = self;
            m_klineMainView.backgroundColor = [UIColor clearColor];
            [self addSubview:m_klineMainView];
            m_klineParam.drawRect = UIEdgeInsetsInsetRect(m_klineMainView.bounds, UIEdgeInsetsMake(K_TopBotInset, 0, K_TopBotInset, 0));
            
            //主图指标
            m_klineIndexView = [[KTIndexMainView alloc] initWithFrame:m_klineMainView.frame];
            m_klineIndexView.backgroundColor = [UIColor clearColor];
            m_klineIndexView.indexDelegate = self;
            [self addSubview:m_klineIndexView];
        }
        
        //副图
        {
            //副图指标
            m_indexMainView = [[KTIndexMainView alloc] initWithFrame:[self indexFrame]];
            m_indexMainView.backgroundColor = [UIColor clearColor];
            m_indexMainView.indexDelegate = self;
            [self addSubview:m_indexMainView];
            m_indexParam.drawRect = UIEdgeInsetsInsetRect(m_indexMainView.bounds, UIEdgeInsetsMake(K_TopBotInset, 0, K_TopBotInset, 0));
        }
        _klineIndexSpace = m_indexMainView.frame.origin.y - (m_klineMainView.frame.origin.y + m_klineMainView.frame.size.height);
        self.mainIndexName = @"MA";
        self.subIndexName = @"VOL";
    }
    return self;
}

#pragma mark - 对指标，K线接口的封装

//获取视图中K线数据对应的柱子, NSNotFound表示没有对应的柱子
-(NSInteger)getDrawDataIndexByXPos:(CGFloat)xpos
{
    CGFloat pointInKlineView = xpos - m_klineMainView.frame.origin.x;
    return [m_klineMainView getDrawDataIndexByXPos:pointInKlineView];
}

-(CGFloat)getCandleCenterAt:(NSUInteger)index
{
    if(index >= m_klineMainView.klineCenterxPos.count)
    {
        return [m_klineMainView.klineCenterxPos.lastObject doubleValue] + m_klineIndexView.frame.origin.x;
    }
    return [[m_klineMainView.klineCenterxPos objectAtIndex:index] doubleValue] + m_klineIndexView.frame.origin.x;
}

-(CGFloat)getLastKlineDrawCenter  //获取最后一根K线的绘制中心
{
    return [m_klineMainView getLastKlineDrawCenter] + m_klineIndexView.frame.origin.x;
}

-(CGFloat)getMainPriceByYpos:(CGFloat)ypos //获取价格分量
{
    CGFloat yosInMain = ypos - m_klineMainView.frame.origin.y;
    return [KTCalcuLationOper pixelToValue:yosInMain minValue:m_klineParam.minValue MaxValue:m_klineParam.maxValue Rect:m_klineParam.drawRect];
}

-(CGFloat)getsubIndexValueByYPos:(CGFloat)ypos //计算ypos代表的值
{
    CGFloat yosInIndex = ypos - m_indexMainView.frame.origin.y;
    return [KTCalcuLationOper pixelToValue:yosInIndex minValue:m_indexParam.minValue MaxValue:m_indexParam.maxValue Rect:m_indexParam.drawRect];
}

#pragma mark - 布局

-(CGRect)klineFrame //K线绘制范围
{
    CGFloat viewHeight = self.frame.size.height - K_IndexKlineSpace;
    return CGRectMake(0, 0, self.frame.size.width, (NSUInteger)(viewHeight * 0.65));
}

-(CGRect)indexFrame //指标绘制范围
{
    CGRect klineFrame = [self klineFrame];
    CGFloat height = (self.frame.size.height - K_IndexKlineSpace) -klineFrame.size.height;
    return CGRectMake(0, klineFrame.size.height + K_IndexKlineSpace,self.frame.size.width , height);
}


-(void)setklineindexBorderWidth:(CGFloat)borderWidth
{
    m_klineMainView.layer.borderWidth = borderWidth;
    m_indexMainView.layer.borderWidth = borderWidth;
}

-(void)setklineindexBorderColor:(nonnull UIColor*)borderColor
{
    m_klineMainView.layer.borderColor = borderColor.CGColor;
    m_indexMainView.layer.borderColor = borderColor.CGColor;
}
#pragma mark - K指标重绘

-(void)clearDraw //清除绘制
{
    [m_klineMainView clearAllDraw];
    [m_klineIndexView clearAllDraw];
    [m_indexMainView clearAllDraw];
}

-(void)refreshAllKlineAndIndexDraw
{
    if(nil == self.delegate)
    {
        return;
    }
//    m_mainRange.minValue =[self.delegate KTKlineIndexViewGetMainViewMaxCoord:NO];
//    m_mainRange.maxValue = [self.delegate KTKlineIndexViewGetMainViewMaxCoord:YES];
//    m_subRange.minValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:NO];
//    m_subRange.maxValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:YES];
    [m_klineMainView refreshKlineDraw];
    [m_klineIndexView refreshIndexDraw];
    [m_indexMainView refreshIndexDraw];
}

-(void)updateLastKlineIndexData
{
    if(nil == self.delegate)
    {
        return;
    }
    
    NSUInteger modifyIndex = m_klineMainView.startShowPos + m_klineMainView.curDrawCount - 1;
//    //主图
//    {
//        KTKlineData *lastKineData = [self.delegate getKlineDataAtIndex:modifyIndex];
//        NSAssert(nil != lastKineData, @"不会获取不到最后一个K线绘制的数据");
//        BOOL bChangeMainRange = lastKineData.dHighPrice > m_mainRange.maxValue || lastKineData.dLowPrice < m_mainRange.minValue;
//        if(NO == bChangeMainRange)
//        {
//            NSArray<__kindof KTIndexData*> *mainIndex = [self.delegate KTKlineIndexViewGetIndexData:KTKlineIndexsViewTypeMainKline];
//            NSArray<__kindof NSNumber*> *minMaxValue = [KTIndexData getMinMaxIndexValue:mainIndex Start:modifyIndex Count:1];
//            if([minMaxValue.firstObject doubleValue] < m_mainRange.minValue || [minMaxValue.lastObject doubleValue] > m_mainRange.maxValue)
//            {
//                bChangeMainRange = YES;
//            }
//            else
//            {
//                //主图绘制范围没有改变
//                NSMutableArray<__kindof KTIndexOneNodeData *> *lastIndexArr = [NSMutableArray array];
//                for(KTIndexData *indexData in mainIndex)
//                {
//                    [lastIndexArr addObject:[indexData getNodeDataAtIndex:modifyIndex] ];
//                }
//                [m_klineMainView updateLastKlineData:lastKineData];
//                [m_klineIndexView updateLastIndexData:lastIndexArr];
//                
//            }
//        }
//        if(YES == bChangeMainRange) //主图指标或者K线绘制范围改变了
//        {
//            m_mainRange.minValue =[self.delegate KTKlineIndexViewGetMainViewMaxCoord:NO];
//            m_mainRange.maxValue = [self.delegate KTKlineIndexViewGetMainViewMaxCoord:YES];
//            [m_klineMainView refreshKlineDraw];
//            [m_klineIndexView refreshIndexDraw];
//        }
//    }
//    
//    //副图
//    {
//        NSArray<__kindof KTIndexData*> *subIndexArr = [self.delegate KTKlineIndexViewGetIndexData:KTTrendIndexsViewTypeSubIndex];
//        NSArray<__kindof NSNumber*> *minMaxValue =  [KTIndexData getMinMaxIndexValue:subIndexArr Start:modifyIndex Count:1];
//        if([minMaxValue.firstObject doubleValue] < m_subRange.minValue || [minMaxValue.lastObject doubleValue] > m_subRange.maxValue) //绘制范围该变了
//        {
//            m_subRange.minValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:NO];
//            m_subRange.maxValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:YES];
//            [m_indexMainView refreshIndexDraw];
//        }
//        else
//        {
//            NSMutableArray<__kindof KTIndexOneNodeData *> *lastIndexArr = [NSMutableArray array];
//            for(KTIndexData *indexData in subIndexArr)
//            {
//                [lastIndexArr addObject:[indexData getNodeDataAtIndex:modifyIndex]];
//            }
//            [m_indexMainView updateLastIndexData:lastIndexArr];
//            
//        }
//    }
}

-(void)addNextKlineIndexData
{
    if(nil == self.delegate)
    {
        return;
    }
//    NSUInteger addIndex = m_klineMainView.startShowPos + m_klineMainView.curDrawCount;
//    if(m_klineMainView.curDrawCount == m_klineMainView.showCount) //已经满格绘制了
//    {
//        m_klineMainView.startShowPos +=1;
//    }
//    //主图
//    {
//        KTKlineData *addKineData = [self.delegate getKlineDataAtIndex:addIndex];
//        NSAssert(nil != addKineData, @"不会获取不到最后一个K线绘制的数据");
//        BOOL bChangeMainRange = addKineData.dHighPrice > m_mainRange.maxValue || addKineData.dLowPrice < m_mainRange.minValue;
//        if(NO == bChangeMainRange)
//        {
//            NSArray<__kindof KTIndexData*> *mainIndex = [self.delegate KTKlineIndexViewGetIndexData:KTKlineIndexsViewTypeMainKline];
//            NSArray<__kindof NSNumber*> *minMaxValue =  [KTIndexData getMinMaxIndexValue:mainIndex Start:addIndex Count:1];
//            if([minMaxValue.firstObject doubleValue] < m_mainRange.minValue || [minMaxValue.lastObject doubleValue] > m_mainRange.maxValue)
//            {
//                bChangeMainRange = YES;
//            }
//            else
//            {
//                //主图绘制范围没有改变
//                NSMutableArray<__kindof KTIndexOneNodeData *> *lastIndexArr = [NSMutableArray array];
//                for(KTIndexData *indexData in mainIndex)
//                {
//                    [lastIndexArr addObject:[indexData getNodeDataAtIndex:addIndex]];
//                }
//                [m_klineMainView addNextKlineData:addKineData];
//                [m_klineIndexView addNextIndexData:lastIndexArr];
//                
//            }
//        }
//        if(YES == bChangeMainRange) //主图指标或者K线绘制范围改变了
//        {
//            m_mainRange.minValue =[self.delegate KTKlineIndexViewGetMainViewMaxCoord:NO];
//            m_mainRange.maxValue = [self.delegate KTKlineIndexViewGetMainViewMaxCoord:YES];
//            [m_klineMainView refreshKlineDraw];
//            [m_klineIndexView refreshIndexDraw];
//        }
//    }
//    
//    //副图
//    {
//        NSArray<__kindof KTIndexData*> *subIndexArr = [self.delegate KTKlineIndexViewGetIndexData:KTTrendIndexsViewTypeSubIndex];
//        NSArray<__kindof NSNumber*> *minMaxValue =  [KTIndexData getMinMaxIndexValue:subIndexArr Start:addIndex Count:1];
//        if([minMaxValue.firstObject doubleValue] < m_subRange.minValue || [minMaxValue.lastObject doubleValue] > m_subRange.maxValue) //绘制范围该变了
//        {
//            m_subRange.minValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:NO];
//            m_subRange.maxValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:YES];
//            [m_indexMainView refreshIndexDraw];
//        }
//        else
//        {
//            NSMutableArray<__kindof KTIndexOneNodeData *> *lastIndexArr = [NSMutableArray array];
//            for(KTIndexData *indexData in subIndexArr)
//            {
//                [lastIndexArr addObject:[indexData getNodeDataAtIndex:addIndex]];
//            }
//            [m_indexMainView addNextIndexData:lastIndexArr];
//            
//        }
//    }
    
}


#pragma mark - KTKlineMainViewDelegate

//index表示K线位置(已经加上了startShowPos)
-(nullable KTKlineData*)getKlineDataAtIndex:(NSUInteger) index
{
    return nil;
}

//改变显示的最小价格范围
-(CGFloat)KTKlineMainViewGetMinPrice:(CGFloat)lastMinValue
{
    return m_klineParam.minValue;
}

//改变显示的最大价格范围
-(CGFloat)KTKlineMainViewGetMaxPrice:(CGFloat)lastMaxValue
{
    return m_klineParam.maxValue;
}


#pragma mark - KTIndexMainViewDelegate

//最小值
-(CGFloat)KTIndexMainViewgetMinValue:(nonnull KTIndexMainView*)indexView
{
    if(indexView == m_klineIndexView)
    {
        return m_klineParam.minValue;
    }
    return m_indexParam.minValue;
}

//最大值
-(CGFloat)KTIndexMainViewgetMaxValue:(nonnull KTIndexMainView*)indexView
{
    if(indexView == m_klineIndexView)
    {
        return m_klineParam.maxValue;
    }
    return m_indexParam.maxValue;
}

//获取X轴上的绘制中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIndexMainViewGetDrawCenterXArr:(nonnull KTIndexMainView*)indexView
{
    return m_klineMainView.klineCenterxPos;
}

-(nonnull NSArray<__kindof KTIndexStyle*> *)KTIndexViewGetIndexStyle:(nonnull KTIndexMainView*)indexView//获取指标绘制样式
{
    NSArray<__kindof KTIndexData*>  *indexDataArr = nil;
//    if(indexView == m_klineIndexView)
//    {
//        indexDataArr =  [self.delegate KTKlineIndexViewGetIndexData:KTKlineIndexsViewTypeMainKline];
//    }
//    else
//    {
//        indexDataArr = [self.delegate KTKlineIndexViewGetIndexData:KTTrendIndexsViewTypeSubIndex];
//    }
    NSMutableArray<__kindof KTIndexStyle*> *indexStyleArr = [NSMutableArray array];
    for(KTIndexData *data in indexDataArr)
    {
        [indexStyleArr addObject:data.indexStyle];
    }
    return indexStyleArr;
}

-(nonnull NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *)KTIndexViewGetIndexDrawData:(nonnull KTIndexMainView*)indexView start:(NSUInteger)start Count:(NSUInteger)count
{
    NSArray<__kindof KTIndexData*>  *indexDataArr = nil;
//    if(indexView == m_klineIndexView)
//    {
//        indexDataArr =  [self.delegate KTKlineIndexViewGetIndexData:KTKlineIndexsViewTypeMainKline];
//    }
//    else
//    {
//        indexDataArr = [self.delegate KTKlineIndexViewGetIndexData:KTTrendIndexsViewTypeSubIndex];
//    }
    NSMutableArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *nodeDataArr = [NSMutableArray array];
    for(KTIndexData *data in indexDataArr)
    {
        [nodeDataArr addObject:[data getIndexDatabeginPos:start Count:count]];
    }
    return nodeDataArr;
}


//设置指标的绘制宽度，否则默认为默认线宽
-(CGFloat)getIndexWidth:(nonnull KTIndexStyle*)indexStyle
{
    if(KTIndexDrawTypeColorStick == indexStyle.indexDrawType)
    {
        return MIN(m_klineMainView.candleWidth, 1);
    }
    if(KTIndexDrawTypeCurve != indexStyle.indexDrawType)
    {
        return m_klineMainView.candleWidth;
    }
    return 2 / [UIScreen mainScreen].scale;;
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
    NSMutableArray<__kindof UIColor*> *colorArr = [NSMutableArray array];
    for(NSUInteger i = 0; i < indexDataArr.count;i++)
    {
        NSInteger klineIndex = m_klineMainView.startShowPos + i;
        if(KTIndexDrawTypeVol == indexStyle.indexDrawType)
        {
            KTKlineData *data = [self getKlineDataAtIndex:klineIndex];
            NSAssert(nil != data, @"K线绘制数据不可能为空");
            UIColor *color = data.dClosePrice > data.dOpenPrice ? m_klineMainView.riseColor : m_klineMainView.downColor;
            [colorArr addObject:color];
        }
        else if(KTIndexDrawTypeColorStick == indexStyle.indexDrawType)
        {
            CGFloat numb = [[indexDataArr objectAtIndex:i].firstData doubleValue];
            UIColor *color = numb >= 0 ? m_klineMainView.riseColor : m_klineMainView.downColor;
            [colorArr addObject:color];
        }
        else
        {
            [colorArr addObject:m_klineMainView.custColor];
        }
    }
    return colorArr;
    
}

#pragma mark - 重写setter和getter函数

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(nil != m_klineMainView)
    {
        m_klineMainView.frame = [self klineFrame];
        m_klineIndexView.frame = [self klineFrame];
        m_indexMainView.frame = [self indexFrame];
    }
}

-(void)setSubIndexName:(NSString *)subIndexName
{
    NSString *lastIndexName = self.subIndexName;
    _subIndexName = subIndexName;
    if(NO == [lastIndexName isEqualToString:subIndexName] && nil != self.delegate) //切换了指标
    {
//        m_subRange.minValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:NO];
//        m_subRange.maxValue = [self.delegate KTKlineIndexViewGetSubViewMaxCoord:YES];
        [m_indexMainView refreshIndexDraw];
    }
}

-(void)setMainIndexName:(NSString *)mainIndexName
{
    NSString *lastIndexName = self.mainIndexName;
    _mainIndexName = mainIndexName;
    if(NO == [lastIndexName isEqualToString:mainIndexName] && nil != self.delegate) //切换了指标
    {
//        m_mainRange.minValue =[self.delegate KTKlineIndexViewGetMainViewMaxCoord:NO];
//        m_mainRange.maxValue = [self.delegate KTKlineIndexViewGetMainViewMaxCoord:YES];
        [m_klineMainView refreshKlineDraw];
        [m_klineIndexView refreshIndexDraw];    }
    
}

@dynamic showKlineCount;
-(void)setShowKlineCount:(NSUInteger)showKlineCount
{
    if(nil != m_klineMainView)
    {
        m_klineMainView.showCount = showKlineCount;
        m_klineIndexView.showCount = showKlineCount;
        m_indexMainView.showCount = showKlineCount;
    }
}

-(NSUInteger)showKlineCount
{
    return m_klineMainView.showCount;
}

@dynamic startShowLocation;
-(void)setStartShowLocation:(NSUInteger)startShowLocation
{
    m_klineMainView.startShowPos = startShowLocation;
    m_klineIndexView.startShowPos = startShowLocation;
    m_indexMainView.startShowPos = startShowLocation;
}

-(NSUInteger)startShowLocation
{
    return m_klineIndexView.startShowPos;
}

@dynamic maxShowCount;
-(NSUInteger)maxShowCount
{
    return m_klineMainView.maxShowKlineCount;
}

@dynamic drawKlineCount;
-(NSUInteger)drawKlineCount
{
    return m_klineMainView.curDrawCount;
}

@dynamic candleWidth;
-(CGFloat)candleWidth
{
    return m_klineMainView.candleWidth;
}

@dynamic riseColor;
-(void)setRiseColor:(UIColor *)riseColor
{
    m_klineMainView.riseColor = riseColor;
}

-(UIColor*)riseColor
{
    return m_klineMainView.riseColor;
}

@dynamic downColor;
-(void)setDownColor:(UIColor *)downColor
{
    m_klineMainView.downColor = downColor;
}

-(UIColor*)downColor
{
    return m_klineMainView.downColor;
}

@dynamic custColor;
-(void)setCustColor:(UIColor *)custColor
{
    m_klineMainView.custColor = custColor;
}
-(UIColor*)custColor
{
    return m_klineMainView.custColor;
}

#pragma mark - private


@end
*/