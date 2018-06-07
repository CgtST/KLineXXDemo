//
//  KTIFlashingIndexView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIFlashingIndexView.h"
#import "KTITrendIndexView.h"
#import "KTINodeData.h"


@interface KTIFlashingIndexView ()<KTIIndexViewDelegate>
{
    CADisplayLink *m_displayLink;
    NSLock *m_dataLock;
}
@property(nonatomic,readonly,retain,nonnull) KTITrendIndexView *trendIndexView;
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSNumber*> *flashData; //闪电图数据

@property(nonatomic,readonly) NSUInteger maxPointShow;

@end

@implementation KTIFlashingIndexView

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        self.distToEndWhenChanged = 0;
        m_dataLock = [[NSLock alloc] init];
        _flashData = [NSMutableArray array];
        _leftMoveCount = 60;
    }
    return self;
}

//清空闪电图
-(void)clear
{
    [self clearData];
    if(nil != _trendIndexView)
    {
        [self.trendIndexView clearDraw];
    }
}

//刷新视图，重新计算
-(void)refresh
{
    if(nil == self.delegate)
    {
        return;
    }
    [self clearData];
    [self.trendIndexView refreshDraw];
}

//手动更新
-(void)update
{
    [self updateFlashView];
}

//开始更新绘制
-(void)startUpdate
{
    if(nil == m_displayLink)
    {
        m_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFlashView)];
        m_displayLink.frameInterval = 30; //执行更新的频率
        [m_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

//结束更新绘制
-(void)stopUpdate
{
    if(nil != m_displayLink)
    {
        [m_displayLink invalidate];
        m_displayLink = nil;
    }
}

//是否正在更新
-(BOOL)isUpdate
{
    return nil == m_displayLink ? NO : YES;
}

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos
{
    return [self.trendIndexView getIndexByDrawPosOfX:xpos];
}

//获取第index个分时的中心点位置
-(CGFloat)getCenterAtIndex:(NSUInteger)index
{
    return [self.trendIndexView getCenterAtIndex:index];
}

//获取最后一个绘制的中心点
-(CGPoint)getLastPriceDrawCenter
{
    return [self.trendIndexView getLastPriceDrawCenter];
}

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos
{
    return [self.trendIndexView getVerOrgCoordByDrawPos:drawPos ViewType:KTIViewTypeMain];
}

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData
{
    return [self.trendIndexView getVerDrawPosByOrgData:orgData ViewType:KTIViewTypeMain];
}

#pragma mark - action

-(void)updateFlashView
{
    KTIFlashingDataType type = [self.delegate KTIFlashingIndexViewGetLastDataType];
    if(KTIFlashingDataTypeNone == type)
    {
        return;
    }
    //获取最后一条数据
    NSNumber *number = [self.delegate KTIFlashingIndexViewGetLastTrendDataCount:1].firstObject;
    if(nil == number)
    {
        return;
    }
    if(KTIFlashingDataTypeUpdate == type)
    {
        [self updateLastData:number];
        [self.trendIndexView updateLastDraw:1];
    }
    else if(KTIFlashingDataTypeAdd == type)
    {
        [self addLastData:number];
        
        //数据超过了一屏
        if(self.flashData.count > self.maxPointShow)
        {
            //丢掉前面的数据后重新绘制
            [self removeHeadHalfData];
            [self.trendIndexView refreshDraw];
            return;
        }
        [self.trendIndexView addNextDraw:1];
    }
}

#pragma mark - KTIIndexViewDelegate


//获取对应指标的绘制数据，start表示数据开始时的位置,maxcount表示返回数据中允许的最大个数
-(nonnull KTIIndexData*)KTIIndexViewGetIndexDatasByStyle:(nonnull KTIIndexStyle*)indexstyle ViewType:(KTIViewType)type start:(NSUInteger)start MaxCount:(NSUInteger)maxcount
{
    KTIIndexData *indexData = [[KTIIndexData alloc] init];
    //刷新
    if(0 == self.flashData.count)
    {
        //获取更新数据
        NSArray<__kindof NSNumber*>* flashDataArr = [self.delegate KTIFlashingIndexViewGetLastTrendDataCount:self.showCount];
        [self setFlashData:flashDataArr];
        for(NSNumber *data in flashDataArr)
        {
            [indexData addNodeData:[KTINodeData transToNodeData:[data doubleValue]]];
        }
    }
    else if(1 == maxcount )
    {
        NSAssert(self.flashData.count >=1, @"闪电图数据错误");
        //数据刷新
        NSNumber *data = self.flashData.lastObject;
        [indexData addNodeData:[KTINodeData transToNodeData:[data doubleValue]]];
    }
    else
    {
        //此时数据的改变是由于上下边界发生了改变引起的，不是真正的刷新数据
        for(NSNumber *data in self.flashData)
        {
            [indexData addNodeData:[KTINodeData transToNodeData:[data doubleValue]]];
        }

    }
    
    return indexData;
}

//坐标的修改
-(BOOL)KTIIndexViewModifyCoordMax:(nonnull CGFloat*)maxValue Min:(nonnull CGFloat*)minValue ViewType:(KTIViewType)type updatedType:(KTIViewUpdateType)updateType
{
    return  [self.delegate KTIFlashingIndexViewModifyCoordMax:maxValue Min:minValue isReDraw:KTIViewUpdateTypeRefresh == updateType];
}

-(void)KTIIndexViewType:(KTIViewType)type FinishUpdated:(KTIViewUpdateType)updateType
{
    [self.delegate KTIFlashingIndexViewFinshDraw:KTIViewUpdateTypeRefresh == updateType];
}

#pragma mark - getter and setter

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if(nil != _trendIndexView)
    {
        _trendIndexView.frame = self.bounds;
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if(nil != _trendIndexView)
    {
        self.trendIndexView.backgroundColor = backgroundColor;
        self.trendIndexView.trendViewUpColor = self.backgroundColor;
    }
}

-(void)setFlashViewColor:(UIColor *)flashViewColor
{
    _flashViewColor = flashViewColor;
    if(nil != _trendIndexView)
    {
        self.trendIndexView.trendViewColor = flashViewColor;
    }
}

-(void)setShowCount:(NSUInteger)showCount
{
    _showCount = showCount;
    if(nil != _trendIndexView)
    {
        self.trendIndexView.showPointCount = showCount;
    }
}

-(void)setLeftMoveCount:(NSUInteger)leftMoveCount
{
    _leftMoveCount = MAX(10, leftMoveCount);
}

@synthesize trendIndexView = _trendIndexView;
-(KTITrendIndexView*)trendIndexView
{
    if(nil == _trendIndexView)
    {
        _trendIndexView = [[KTITrendIndexView alloc] initWithFrame:self.bounds];
        _trendIndexView.bshowAvgPriceLine = NO;
        _trendIndexView.trendViewColor = self.flashViewColor;
        _trendIndexView.trendViewUpColor = self.backgroundColor;
        _trendIndexView.backgroundColor = self.backgroundColor;
        _trendIndexView.showPointCount = self.showCount;
        _trendIndexView.delegate = self;
        [self addSubview:_trendIndexView];
    }
    return _trendIndexView;
}

#pragma mark -

@dynamic maxPointShow;
-(NSUInteger)maxPointShow
{
    if(self.distToEndWhenChanged < self.showCount)
    {
        return self.showCount - self.distToEndWhenChanged;
    }
    return self.showCount;
}

@dynamic flashingMaxValue;
-(CGFloat)flashingMaxValue
{
    if(nil == _trendIndexView)
    {
        return 0;
    }
    return self.trendIndexView.trendMaxValue;
}

@dynamic flashingMinValue;
-(CGFloat)flashingMinValue
{
    if(nil == _trendIndexView)
    {
        return 0;
    }
    return self.trendIndexView.trendMinValue;
}

@dynamic realDrawCount;
-(NSUInteger)realDrawCount
{
    if(nil == _trendIndexView)
    {
        return 0;
    }
    return self.trendIndexView.realDrawCount;
}

#pragma mark - private

-(void)clearData
{
    [m_dataLock lock];
    [self.flashData removeAllObjects];
    [m_dataLock unlock];
}

-(void)setFlashData:(nonnull NSArray<__kindof NSNumber*>*)dataArr
{
    [m_dataLock lock];
    [self.flashData removeAllObjects];
    [self.flashData addObjectsFromArray:dataArr];
    [m_dataLock unlock];
}

-(void)updateLastData:(nonnull NSNumber*)num
{
    [m_dataLock lock];
    [self.flashData removeLastObject];
    [self.flashData addObject:num];
    [m_dataLock unlock];
}

-(void)addLastData:(nonnull NSNumber*)num
{
    [m_dataLock lock];
    [self.flashData addObject:num];
    [m_dataLock unlock];
}

//去掉前面一半的数据
-(void)removeHeadHalfData
{
    if(self.flashData.count <= self.leftMoveCount)
    {
        return;
    }
    [m_dataLock lock];
    [self.flashData removeObjectsInRange:NSMakeRange(0, self.leftMoveCount)];
    [m_dataLock unlock];
}

@end
