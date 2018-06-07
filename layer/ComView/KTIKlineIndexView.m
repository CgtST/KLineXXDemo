//
//  KTIKlineIndexView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIKlineIndexView.h"
#import "KTIIndexStyle.h"
#import "KTINodeData.h"
#import "KTIKlineDrawView.h"
#import "KTICustomDataOper.h"

#define K_KlineMinPix  4 //每个K线的最小绘制宽度(像素)

@interface KTIKlineIndexView ()<KTIBaseIndexDrawViewDelegate>
{
    CGFloat m_klineMaxPrice;
    CGFloat m_klineMinPrice;
    NSLock *m_lock;
}
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSNumber*> *klineCenterArr; //K线中心点数组
@property(nonatomic,readonly,retain,nonnull) KTIKlineDrawView *klineView; //K线视图

@end

@implementation KTIKlineIndexView

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        m_lock = [[NSLock alloc] init];
        _klineCenterArr = [NSMutableArray array];
    }
    return self;
}

-(CGRect)klineFrame
{
    return self.bounds;
}

#pragma mark - public

-(void)clearDraw
{
    if(nil != _klineView)
    {
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.klineView setNeedsDisplay];
            });
        };
        [self.klineView clearIndexDraws:block];
    }
    m_klineMaxPrice = 0;
    m_klineMinPrice = 0;
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
            [weakSelf.klineView setNeedsDisplay];
        });
    };
    //K线数据绘制
    [self refrehKlineView:block];
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
    //K线更新
    {
        KTIIndexDataArr *klineData = [self getKlineDataFromStart:start MaxCount:count];
        BOOL bNeedRefresh = [self needRefreshTrendData:klineData ViewType:KTIViewTypeMain];
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(YES == [weakSelf.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
                {
                    [weakSelf.delegate KTIIndexViewType:KTIViewTypeMain FinishUpdated:YES == bNeedRefresh ?KTIViewUpdateTypeRefresh : KTIViewUpdateTypeUpdate];
                }
                [weakSelf.klineView setNeedsDisplay];
            });
        };

        if(YES == bNeedRefresh)
        {
            //最大值和最小值超出了范围
            [self refrehKlineView:block];
            return YES;
        }
        else
        {
            [self.klineView updateLastIndexDraws:klineData block:block];
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
    //增加K线数据
    {
        
        KTIIndexDataArr *klineData = [self getKlineDataFromStart:self.realDrawCount MaxCount:addCount];
        BOOL bNeedRefresh = [self needRefreshTrendData:klineData ViewType:KTIViewTypeMain];
        __weak typeof(self) weakSelf = self;
        FunctionFinishBlock block = ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(YES == [weakSelf.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
                {
                    [weakSelf.delegate KTIIndexViewType:KTIViewTypeMain FinishUpdated:YES == bNeedRefresh ?KTIViewUpdateTypeRefresh : KTIViewUpdateTypeAdd];
                }
                [weakSelf.klineView setNeedsDisplay];
            });
        };
        if(YES == bNeedRefresh)
        {
            //最大值和最小值超出了范围
            [self refrehKlineView:block];
            return YES;
        }
        else
        {
            [self.klineView addNextIndexDraws:klineData block:block];
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
    
    CGRect trframe = [self klineFrame];
    //点越界
    if(xpos < trframe.origin.x )
    {
        return 0;
    }
    //超出最后一个点的绘制范围
    if(xpos >= [self getLastKlineDrawXCenter])
    {
        return self.realDrawCount - 1;
    }
    
    NSArray<__kindof NSNumber*> *drawCenterArr = [self.klineCenterArr subarrayWithRange:NSMakeRange(0, self.realDrawCount)];
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
    if(0 == self.willShowCount) //不显示数据时
    {
        return 0;
    }
    if(index >= self.klineCenterArr.count)
    {
        return [self.klineCenterArr.lastObject doubleValue];
    }
    return [self.klineCenterArr[index] doubleValue];
}

-(CGFloat)getLastKlineDrawXCenter  //获取最后一根K线的绘制中心
{
    if(0 == self.willShowCount)
    {
        return self.bounds.size.width/2;
    }
    if(nil == _klineView || 0 == self.klineView.curKlineDrawCount)
    {
        return [self.klineCenterArr.firstObject doubleValue];
    }
    return [self.klineCenterArr[self.klineView.curKlineDrawCount - 1] doubleValue];
}

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type
{
    return [KTICustomDataOper pixelToValue:drawPos minValue:m_klineMinPrice MaxValue:m_klineMaxPrice Rect:[self klineFrame]];
}

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type
{
    return [KTICustomDataOper valueToPixel:orgData minValue:m_klineMinPrice MaxValue:m_klineMaxPrice  Rect:[self klineFrame]];
}

#pragma mark - KTIBaseIndexDrawViewDelegate

//获取绘制的中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIBaseIndexDrawViewGetXcenter:(nonnull KTIBaseIndexDrawView*)baseView
{
    return self.klineCenterArr;
}

//获取最大坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMax:(nonnull KTIBaseIndexDrawView*)baseView
{
    return m_klineMaxPrice;
}

//获取最小坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMin:(nonnull KTIBaseIndexDrawView*)baseView
{
    return m_klineMinPrice;
}

#pragma mark - getter and setter

-(void)setFrame:(CGRect)frame
{
    CGSize oldSize = self.frame.size;
    [super setFrame:frame];
    if(nil != _klineView)
    {
        self.klineView.frame = [self klineFrame];
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
    if(nil != _klineView && YES == bRefreshDraw) //当前有视图，并且高度或者宽度发送变化时，重绘K线
    {
        [self refreshDraw];
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if(nil != _klineView)
    {
        self.klineView.backgroundColor = backgroundColor;
    }
}

@synthesize klineView = _klineView;
-(KTIKlineDrawView*)klineView
{
    if(nil == _klineView)
    {
        _klineView = [[KTIKlineDrawView alloc] initWithFrame:[self klineFrame]];
        _klineView.indexDelegate = self;
        _klineView.backgroundColor = self.backgroundColor;
        _klineView.showCount = self.willShowCount;
        [self addSubview:_klineView];
    }
    return _klineView;
}

-(void)setWillShowCount:(NSUInteger)willShowCount
{
    NSUInteger oldCount = _willShowCount;
    _willShowCount = willShowCount;
    if(nil != _klineView)
    {
        self.klineView.showCount = willShowCount;
    }
    //需要重新计算绘制中心点
    if(oldCount != self.willShowCount)
    {
        [self calxCenter];
    }
}

#pragma mark -

@dynamic realDrawCount;
-(NSUInteger)realDrawCount
{
    if(nil == _klineView)
    {
        return 0;
    }
    return self.klineView.curKlineDrawCount;
}

@dynamic canShowMaxCount;
-(NSUInteger)canShowMaxCount
{
    return  (NSUInteger)([self klineFrame].size.width * [KTICustomDataOper mainScreenScale] / K_KlineMinPix);  //向下取整
}

@dynamic klineMaxValue;
-(CGFloat)klineMaxValue
{
    return m_klineMaxPrice;
}

@dynamic klineMinValue;
-(CGFloat)klineMinValue
{
    return m_klineMinPrice;
}


#pragma mark - private

-(void)calxCenter
{
    [m_lock lock];
    [self.klineCenterArr removeAllObjects];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __weak typeof(self) weakSelf = self;
    __block CGFloat maxWidth;
    dispatch_async([KTICustomDataOper shareQueue], ^{
        CGFloat minWidth = 0;
        NSArray *arr = [KTICustomDataOper createCenterXWidth:weakSelf.bounds.size.width Count:weakSelf.willShowCount MinWidth:&minWidth MaxWidth:&maxWidth];
        weakSelf.klineView.unitCellWidth = minWidth;
        [weakSelf.klineCenterArr addObjectsFromArray:arr];
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

-(BOOL)needRefreshTrendData:(KTIIndexDataArr*)trendData ViewType:(KTIViewType)type
{
    if(0 == trendData.nodeCount)
    {
        return NO;
    }
    //获取最大值，最小值
    __block CGFloat minValue ;
    __block CGFloat maxValue;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async([KTICustomDataOper shareQueue], ^{
        
        [KTICustomDataOper getMinMaxValueOfIndexArr:trendData.indexDataArr MinValue:&minValue MaxValue:&maxValue];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //最大值和最小值没有改变
    if(m_klineMinPrice < minValue && m_klineMaxPrice > maxValue)
    {
        return NO;
    }
    return YES;
    
}

-(void)refrehKlineView:(nullable FunctionFinishBlock)finishblock
{
    KTIIndexDataArr *klineData = [self getKlineDataFromStart:0 MaxCount:self.willShowCount];
    //最大值，最小值
    CGFloat minValue = 0 , maxValue = 0;
    if(klineData.nodeCount > 0)
    {
        [KTICustomDataOper getMinMaxValueOfIndexArr:klineData.indexDataArr MinValue:&minValue MaxValue:&maxValue];
    }
    m_klineMinPrice = minValue;
    m_klineMaxPrice = maxValue;
    if(YES == [self.delegate KTIIndexViewModifyCoordMax:&maxValue Min:&minValue ViewType:KTIViewTypeMain updatedType:KTIViewUpdateTypeRefresh])
    {
        m_klineMinPrice = minValue < m_klineMinPrice ? minValue : m_klineMinPrice;
        m_klineMaxPrice = maxValue > m_klineMaxPrice ? maxValue : m_klineMaxPrice;
    }
    [self.klineView refreshIndexDraws:klineData block:finishblock];
}
-(KTIIndexDataArr*)getKlineDataFromStart:(NSUInteger)start MaxCount:(NSUInteger)count
{
    KTIIndexDataArr *klineData = [[KTIIndexDataArr alloc] init];
    KTIIndexData *klineIndexData = [self.delegate KTIIndexViewGetIndexDatasByStyle:[KTIIndexStyle shareKlineIndexSyle] ViewType:KTIViewTypeMain start:start MaxCount:count];
    [klineData addIndexData:klineIndexData];
    NSAssert(klineData.nodeCount <= count, @"获取K线数据错误");
    return klineData;
}


@end
