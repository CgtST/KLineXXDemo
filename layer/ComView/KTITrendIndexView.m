//
//  KTITrendIndexView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTITrendIndexView.h"
#import "KTIIndexStyle.h"
#import "KTINodeData.h"
#import "KTITrendDrawView.h"
#import "KTICustomDataOper.h"

@interface KTITrendIndexView ()<KTIBaseIndexDrawViewDelegate>
{
    CGFloat m_trendMaxPrice;
    CGFloat m_trendMinPrice;
    NSLock* m_lock;
}
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSNumber*> *trendxCenterArr; //价格中心点数组
@property(nonatomic,readonly,retain,nonnull) KTITrendDrawView *trendView; //分时视图

@end


@implementation KTITrendIndexView

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        m_lock = [[NSLock alloc] init];
        _trendxCenterArr = [NSMutableArray array];
    }
    return self;
}


#pragma mark - 视图刷新

-(void)clearDraw
{
    if(nil != _trendView)
    {
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.trendView setNeedsDisplay];
            });
        };
        [self.trendView clearIndexDraws:block];
    }
    m_trendMaxPrice = 0;
    m_trendMinPrice = 0;
}

-(void)refreshDraw //刷新绘制
{
    if(nil == self.delegate)
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    FunctionFinishBlock block = ^(){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(YES == [weakSelf.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
            {
                [weakSelf.delegate KTIIndexViewType:KTIViewTypeMain FinishUpdated:KTIViewUpdateTypeRefresh];
            }
            [weakSelf.trendView setNeedsDisplay];
        });
    };
    //分时数据绘制
    [self refrehTrendView:block];
}

//更新最后几个的绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)updateLastDraw:(NSUInteger)count
{
    if(nil == self.delegate)
    {
        return NO;
    }
    NSUInteger start = 0;
    if(count < self.realDrawCount)
    {
        start = self.realDrawCount - count;
    }
    //分时更新
    {
        KTIIndexDataArr *trendData = [self getTrendDataFromStart:start MaxCount:count];
        BOOL bNeedRefresh = [self needRefreshTrendData:trendData ViewType:KTIViewTypeMain updateType:KTIViewUpdateTypeUpdate];
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(YES == [weakSelf.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
                {
                    [weakSelf.delegate KTIIndexViewType:KTIViewTypeMain FinishUpdated:YES == bNeedRefresh ?KTIViewUpdateTypeRefresh : KTIViewUpdateTypeUpdate];
                }
                [weakSelf.trendView setNeedsDisplay];
            });
        };
       
        if(YES == bNeedRefresh)
        {
            //最大值和最小值超出了范围
            [self refrehTrendView:block];
            return YES;
        }
        else
        {
            [self.trendView updateLastIndexDraws:trendData block:block];
        }
    }
    return NO;
}

//添加几个绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNextDraw:(NSUInteger)addCount
{
    if(nil == self.delegate)
    {
        return NO;
    }
    //增加分时数据
    {
        KTIIndexDataArr *trendData = [self getTrendDataFromStart:self.realDrawCount MaxCount:addCount];
        BOOL bNeedRefresh = [self needRefreshTrendData:trendData ViewType:KTIViewTypeMain updateType:KTIViewUpdateTypeAdd];
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(YES == [weakSelf.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
                {
                    [weakSelf.delegate KTIIndexViewType:KTIViewTypeMain FinishUpdated:YES == bNeedRefresh ?KTIViewUpdateTypeRefresh : KTIViewUpdateTypeAdd];
                }
                [weakSelf.trendView setNeedsDisplay];
            });
        };

       
        if(YES == bNeedRefresh)
        {
            //最大值和最小值超出了范围
            [self refrehTrendView:block];
            return YES;
        }
        else
        {
            [self.trendView addNextIndexDraws:trendData block:block];
        }
    }
    return NO;
}

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos
{
    //没有绘制数据
    if(0 == self.realDrawCount)
    {
        return NSNotFound;
    }
    
    CGRect trframe = self.trendView.frame;
    //点越界
    if(xpos < trframe.origin.x )
    {
        return 0;
    }
    
    //超出最后一个点的绘制范围
    if(xpos >= [self getLastPriceDrawCenter].x)
    {
        return  self.realDrawCount - 1;
    }
    
    NSArray<__kindof NSNumber*> *drawCenterArr = [self.trendxCenterArr subarrayWithRange:NSMakeRange(0, self.realDrawCount)];
    NSInteger index = [KTICustomDataOper searchXpos:xpos inArr:drawCenterArr precision:self.maxWidth/2 + 0.01]; //防止浮点型数据误差
    if(NSNotFound == index)
    {
        NSAssert(NSNotFound != index, @"查找算法有问题");
        return NSNotFound;
    }
    return index;

}

//获取第index个分时的中心点位置
-(CGFloat)getCenterAtIndex:(NSUInteger)index
{
    if(0 == self.showPointCount) //不显示数据时
    {
        return 0;
    }
    if(index >= self.trendxCenterArr.count)
    {
        return [self.trendxCenterArr.lastObject doubleValue];
    }
    return [self.trendxCenterArr[index] doubleValue];
}

//如果越界，返回-1
-(CGFloat)getPriceDrawYposAtIndex:(NSUInteger)index
{
    if(nil == _trendView)
    {
        return -1;
    }
    return [self.trendView getPriceDrawYposAtIndex:index];
}

//获取最后一个绘制的中心点
-(CGPoint)getLastPriceDrawCenter
{
    if(0 == self.showPointCount) //不显示数据时
    {
        return CGPointMake(0, 0);
    }
    NSUInteger curDrawPoint = self.trendView.curDrawPointCount;
    if(0 == curDrawPoint)
    {
        return CGPointMake(0, 0);
    }
    CGFloat xCenter = [self.trendxCenterArr[curDrawPoint - 1] doubleValue];
    return CGPointMake(xCenter, self.trendView.lastYpos);
}

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type
{
     return [KTICustomDataOper pixelToValue:drawPos minValue:m_trendMinPrice MaxValue:m_trendMaxPrice Rect:self.trendView.frame];
}

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type
{
    return [KTICustomDataOper valueToPixel:orgData minValue:m_trendMinPrice MaxValue:m_trendMaxPrice  Rect:self.trendView.frame];
}

#pragma mark - KTIBaseIndexDrawViewDelegate

//获取绘制的中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIBaseIndexDrawViewGetXcenter:(nonnull KTIBaseIndexDrawView*)baseView
{
    return self.trendxCenterArr;
}

//获取最大坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMax:(nonnull KTIBaseIndexDrawView*)baseView
{
    return m_trendMaxPrice;
}

//获取最小坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMin:(nonnull KTIBaseIndexDrawView*)baseView
{
    return m_trendMinPrice;
}

#pragma mark - getter and setter

-(void)setFrame:(CGRect)frame
{
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if(nil != _trendView)
    {
        self.trendView.frame = self.bounds;
    }
    BOOL bRefreshDraw = NO;
    if(fabs(self.frame.size.width - oldSize.width) > 1)  //最小宽度变化为1
    {
        //需要重新计算中心点
        [self calxCenter];
        bRefreshDraw = YES;
    }
    if(fabs(self.frame.size.height - oldSize.height) > 1) //最小高度变化为1
    {
        bRefreshDraw = YES;
    }
    if(nil != _trendView && YES == bRefreshDraw) //当前有视图，并且高度或者宽度发送变化时，重绘分时
    {
        [self refreshDraw];
    }
}

-(void)setTrendViewColor:(UIColor *)trendViewColor
{
    _trendViewColor = trendViewColor;
    if(nil != _trendView)
    {
        self.trendView.backgroundColor = trendViewColor;
    }
    
}

-(void)setTrendViewUpColor:(UIColor *)trendViewUpColor
{
    _trendViewUpColor = trendViewUpColor;
    if(nil != _trendView)
    {
        self.trendView.upAreaBackGround = trendViewUpColor;
    }
}

@synthesize trendView = _trendView;
-(KTITrendDrawView*)trendView
{
    if(nil == _trendView)
    {
        _trendView = [[KTITrendDrawView alloc] initWithFrame:self.bounds];
        _trendView.indexDelegate = self;
        _trendView.backgroundColor =  self.trendViewColor ;
        _trendView.upAreaBackGround = self.trendViewUpColor;
        _trendView.showCount = self.showPointCount;
        [self addSubview:_trendView];
    }
    return _trendView;
}

-(void)setShowPointCount:(NSUInteger)showPointCount
{
    NSUInteger oldCount = _showPointCount;
    _showPointCount = showPointCount;
    if(nil != _trendView)
    {
        self.trendView.showCount = showPointCount;
    }
    //需要重新计算绘制中心点
    if(oldCount != self.showPointCount)
    {
        [self calxCenter];
    }
}

#pragma mark -

@dynamic realDrawCount;
-(NSUInteger)realDrawCount
{
    if(nil == _trendView)
    {
        return 0;
    }
    return self.trendView.curDrawPointCount;
}

@dynamic trendMaxValue;
-(CGFloat)trendMaxValue
{
    return m_trendMaxPrice;
}

@dynamic trendMinValue;
-(CGFloat)trendMinValue
{
    return m_trendMinPrice;
}


#pragma mark - private

-(void)calxCenter
{
    [m_lock lock];
    [self.trendxCenterArr removeAllObjects];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    __block CGFloat maxWidth;
    dispatch_async([KTICustomDataOper shareQueue], ^{
        NSArray *arr = [KTICustomDataOper createCenterXWidth:weakSelf.bounds.size.width Count:weakSelf.showPointCount MinWidth:NULL MaxWidth:&maxWidth];
        [weakSelf.trendxCenterArr addObjectsFromArray:arr];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    _maxWidth = maxWidth;
    if(3 == [KTICustomDataOper mainScreenScale])
    {
        //防止出现无线循环小数
        _maxWidth = round(_maxWidth * 2)/2;
    }
    [m_lock unlock];
    
}

-(BOOL)needRefreshTrendData:(KTIIndexDataArr*)trendData ViewType:(KTIViewType)type updateType:(KTIViewUpdateType)updateType
{
    if(0 == trendData.nodeCount)
    {
        return NO;
    }
    //获取最大值，最小值
    __block CGFloat minValue = 0;
    __block CGFloat maxValue = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async([KTICustomDataOper shareQueue], ^{
        
        [KTICustomDataOper getMinMaxValueOfIndexArr:trendData.indexDataArr MinValue:&minValue MaxValue:&maxValue];
         dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //修改最大值，最小值
    [self.delegate KTIIndexViewModifyCoordMax:&maxValue Min:&minValue ViewType:type updatedType:updateType];
    
    //最大值和最小值没有改变
    if(m_trendMinPrice < minValue && m_trendMaxPrice > maxValue)
    {
        return NO;
    }
    return YES;

}

-(void)refrehTrendView:(nullable FunctionFinishBlock)finishblock
{
    KTIIndexDataArr *trendData = [self getTrendDataFromStart:0 MaxCount:self.showPointCount];
    //最大值，最小值
    CGFloat minValue = 0 , maxValue = 0;
    if(trendData.nodeCount > 0)
    {
         [KTICustomDataOper getMinMaxValueOfIndexArr:trendData.indexDataArr MinValue:&minValue MaxValue:&maxValue];
    }
    m_trendMinPrice = minValue;
    m_trendMaxPrice = maxValue;
    if(YES == [self.delegate KTIIndexViewModifyCoordMax:&maxValue Min:&minValue ViewType:KTIViewTypeMain updatedType: KTIViewUpdateTypeRefresh])
    {
        m_trendMinPrice = minValue < m_trendMinPrice ? minValue : m_trendMinPrice;
        m_trendMaxPrice = maxValue > m_trendMaxPrice ? maxValue : m_trendMaxPrice;
    }
    [self.trendView refreshIndexDraws:trendData block:finishblock];
}

-(KTIIndexDataArr*)getTrendDataFromStart:(NSUInteger)start MaxCount:(NSUInteger)count
{
    KTIIndexDataArr *trendData = [[KTIIndexDataArr alloc] init];
    KTIIndexData *newPriceData = [self.delegate KTIIndexViewGetIndexDatasByStyle:[KTIIndexStyle shareTrendNewPriceIndexSyle] ViewType:KTIViewTypeMain start:start MaxCount:count];
    NSAssert(newPriceData.nodeDataArr.count <= count, @"获取分时最新价数据错误");
     [trendData addIndexData:newPriceData];
    if(YES == self.bshowAvgPriceLine)
    {
        KTIIndexData *avgPriceData = [self.delegate KTIIndexViewGetIndexDatasByStyle:[KTIIndexStyle shareTrendAvgPriceIndexSyle] ViewType:KTIViewTypeMain start:start MaxCount:count];
        NSAssert(avgPriceData.nodeDataArr.count <= count, @"获取分时均价数据错误");
        [trendData addIndexData:avgPriceData];
    }
    return trendData;
}


@end
