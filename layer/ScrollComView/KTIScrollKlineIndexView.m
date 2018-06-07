//
//  KTIScrollKlineIndexView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIScrollKlineIndexView.h"
#import "KTIKlineIndexView.h"

@interface KTIScrollKlineIndexView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,KTIIndexViewDelegate>
{
    NSUInteger m_lastShowKineCount; //缩放是用到
    NSUInteger m_lastStartIndex; //上次的起点位置
}
@property(nonatomic,readonly,retain,nonnull) KTIKlineIndexView *klineIndexView;
@property(nonatomic,readonly,retain,nonnull) UIScrollView *scrollView;  //用来进行滑动
@property(nonatomic,readonly,retain,nonnull) UIPinchGestureRecognizer *pinchGesture;

@property(nonatomic,readonly) UInt64 startTime;
@property(nonatomic,readonly) NSUInteger totalCount;


@end

@implementation KTIScrollKlineIndexView

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        _beginIndex = 0;
        _showKlineCount = 60;
        self.minShowCount = 1;
        _moveEnable = YES;
        _zoomEnable = YES;
        
        //缩放手势
        [self addGestureRecognizer:self.pinchGesture];
    }
    return self;
}

#pragma mark - public

//更新显示的数据的条数
-(void)updateTotalShowCount:(NSUInteger)count
{
    [self setTheTotalCount:count];
    //需要修改起点位置
    if(nil != self.delegate && self.startTime > 10)
    {
        _beginIndex = [self.delegate KTIScrollKlineIndexViewGetIndexOfTime:self.startTime];
    }
    [self modifyScrollOffset]; //如果添加的是历史数据，则需要修改scrollView的起点位置
}

//会重新刷新视图
-(void)scrollToIndex:(NSUInteger)index animated:(BOOL)banimated
{
    NSUInteger maxScrollIndex = self.totalCount > self.showKlineCount ? self.totalCount - self.showKlineCount : 0;
    index = index > maxScrollIndex ? maxScrollIndex : index;
    CGPoint offset = CGPointMake(index * self.klineIndexView.maxWidth,0);
    [self.scrollView setContentOffset:offset animated:banimated];
    
}

//清空K线
-(void)clear
{
    if(nil != _klineIndexView)
    {
        [self.klineIndexView clearDraw];
    }
    //此时滚动视图没有效果
    [self setTheTotalCount:0];
    _beginIndex = 0;
    _startTime = 0;
    
}


//刷新视图，重新计算
-(void)refresh
{
    if(nil == self.delegate)
    {
        return;
    }
    NSUInteger start = self.totalCount > self.showKlineCount ? self.totalCount - self.showKlineCount : 0;
    [self scrollKlineViewToIndex:start]; //更新起始点
    [self modifyScrollOffset];
    [self.klineIndexView refreshDraw]; //绘制
}

//更新最后count根K线并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)update:(NSUInteger)count
{
    if(nil == self.delegate || NO == self.bshowNewestData)
    {
        return NO;
    }
    return  [self.klineIndexView updateLastDraw:count];
}

//添加count根K线并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNext:(NSUInteger)count
{
    BOOL bshowNew = self.bshowNewestData;

    [self setTheTotalCount:self.totalCount + count]; //更新滑动范围
    if(nil == self.delegate || NO == bshowNew)
    {
        return NO;
    }
    
    BOOL ret = [self.klineIndexView addNextDraw:count]; //绘制
    [self scrollKlineViewToIndex:self.beginIndex + count]; //更新起始点
    [self modifyScrollOffset];
    return ret;
    
}

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos
{
    return [self.klineIndexView getIndexByDrawPosOfX:xpos];
}

//获取第indexK线的中心点位置(页面上的绘制的个数，不需要加上起点)
-(CGFloat)getCenterAtIndex:(NSUInteger)index
{
    return [self.klineIndexView getCenterAtIndex:index];
}

//获取最后一根K线的绘制中心;
-(CGFloat)getLastKlineDrawXCenter
{
    return [self.klineIndexView getLastKlineDrawXCenter];
}

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type
{
    return [self.klineIndexView getVerDrawPosByOrgData:drawPos ViewType:type];
}

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type
{
    return [self.klineIndexView getVerDrawPosByOrgData:orgData ViewType:type];
}

#pragma mark - action

//进行缩放
-(void)zoomKline:(UIPinchGestureRecognizer*)pinGesture
{
    if(UIGestureRecognizerStateBegan == pinGesture.state)
    {
        m_lastShowKineCount = self.showKlineCount;
        m_lastStartIndex = self.beginIndex;
    }
    else if(UIGestureRecognizerStateChanged == pinGesture.state)
    {
        //将要显示的K线条数
        NSInteger willShowCount = m_lastShowKineCount / pinGesture.scale;
        willShowCount = MAX(self.minShowCount, willShowCount);
        willShowCount = MIN(willShowCount, self.canShowMaxCount);
        NSUInteger start = [self calZoomStart:willShowCount];
        self.showKlineCount = willShowCount;
        [self setTheTotalCount:self.totalCount]; //刷新整个滑动区域
        [self scrollKlineViewToIndex:start];
        [self modifyScrollOffset];
        [self.klineIndexView refreshDraw]; //绘制
        if(YES == [self.delegate respondsToSelector:@selector(KTIScrollKlineIndexViewDidScrolling:)])
        {
            __weak typeof(self) weakSelf = self;
            [self.delegate KTIScrollKlineIndexViewDidScrolling:weakSelf];
        }
    }
    else if(UIGestureRecognizerStateEnded == pinGesture.state)
    {
        //放大时
        if(self.showKlineCount > m_lastShowKineCount && YES == [self.delegate respondsToSelector:@selector(KTIScrollKlineIndexViewDidEndScrollToStart:)])
        {
            [self.delegate KTIScrollKlineIndexViewDidEndScrollToStart:self.beginIndex];
        }
    }
}

//计算缩放起始点
-(NSUInteger)calZoomStart:(NSUInteger)willShowCount
{
    if(self.totalCount < willShowCount)
    {
        //数据不够，全部显示
        return 0;
    }
    //回到初始状态
    if(willShowCount == m_lastShowKineCount)
    {
        return m_lastStartIndex;
    }
    //数据足够
    NSInteger start = m_lastStartIndex;
    //计算需要增加显示的数据（可以为负值，负值时表示减少显示的个数）
    NSInteger addCount = willShowCount - m_lastShowKineCount;
    if(addCount > 0)
    {
        //放大，需要增加显示的数据
        if(YES == self.bshowNewestData)
        {
            //显示的是最新数据，缩放历史数据
            start = start > addCount ? start - addCount : 0;
            if(start + willShowCount > self.totalCount) //可以显示最后一条K线时，修改起点
            {
                start = self.totalCount - willShowCount;
            }
        }
        else
        {
            //显示了历史数据，两边向中间收缩
            NSInteger halfCount = (addCount + 1)/2;
            start = start - halfCount > 0 ? start - halfCount : 0;
            if(start + willShowCount > self.totalCount) //可以显示最后一条K线时，修改起点
            {
                start = self.totalCount - willShowCount;
            }
        }
    }
    else
    {
        //缩小，需要减少显示的数据
        if(YES == self.bshowNewestData)
        {
            //显示的是最新数据，缩放是必须优先保证显示的是最新数据
            start = self.totalCount - willShowCount;
        }
        else
        {
            //显示了历史数据，保持中间不变，向两边扩展
            NSInteger halfCount = (abs((int)addCount) + 1)/2;
            start = start > halfCount ? start - halfCount : 0;
            //可以显示最后一条K线时，修改起点
            if(start + willShowCount > self.totalCount)
            {
                start = self.totalCount - willShowCount;
            }
        }

    }
    return start;
}

#pragma mark - KTIIndexViewDelegate


//获取对应指标的绘制数据，start表示数据开始时的位置,maxcount表示返回数据中允许的最大个数
-(nonnull KTIIndexData*)KTIIndexViewGetIndexDatasByStyle:(nonnull KTIIndexStyle*)indexstyle ViewType:(KTIViewType)type start:(NSUInteger)start MaxCount:(NSUInteger)maxcount
{
    return [self.delegate KTIIndexViewGetIndexDatasByStyle:indexstyle ViewType:type start:self.beginIndex + start MaxCount:maxcount];

}

//坐标的修改
-(BOOL)KTIIndexViewModifyCoordMax:(nonnull CGFloat*)maxValue Min:(nonnull CGFloat*)minValue ViewType:(KTIViewType)type updatedType:(KTIViewUpdateType)updateType
{
    return [self.delegate KTIIndexViewModifyCoordMax:maxValue Min:minValue ViewType:type updatedType:updateType];
}

//获取对应指标样式，每个图上最多放一个指标 ， 分时K线为特殊指标，不调用该函数
-(nullable NSArray<__kindof KTIIndexStyle*>*)KTIIndexViewGetAllIndexStylesWithViewType:(KTIViewType)type
{
    if(YES == [self.delegate respondsToSelector:@selector(KTIIndexViewGetAllIndexStylesWithViewType:)])
    {
        return [self.delegate KTIIndexViewGetAllIndexStylesWithViewType:type];
    }
    return nil;
}

//视图已经跟新完成
-(void)KTIIndexViewType:(KTIViewType)type FinishUpdated:(KTIViewUpdateType)updateType
{
    if(YES == [self.delegate respondsToSelector:@selector(KTIIndexViewType:FinishUpdated:)])
    {
        [self.delegate KTIIndexViewType:type FinishUpdated:updateType];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x < 0)
    {
        return;
    }
    NSUInteger index = scrollView.contentOffset.x / self.klineIndexView.maxWidth;
    if(index != self.beginIndex)
    {
        [self scrollKlineViewToIndex:index]; //更新起始点
        [self.klineIndexView refreshDraw]; //绘制
        if(YES == [self.delegate respondsToSelector:@selector(KTIScrollKlineIndexViewDidScrolling:)])
        {
            __weak typeof(self) weakSelf = self;
            [self.delegate KTIScrollKlineIndexViewDidScrolling:weakSelf];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSUInteger index = round(targetContentOffset->x / self.klineIndexView.maxWidth); //防止微小的滑动导致了K线的移动
    targetContentOffset->x = self.klineIndexView.maxWidth * index;
    //向左滑动时
    if(index <= self.beginIndex && YES == [self.delegate respondsToSelector:@selector(KTIScrollKlineIndexViewDidEndScrollToStart:)])
    {
        [self.delegate KTIScrollKlineIndexViewDidEndScrollToStart:index];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - getter and setter

@synthesize klineIndexView = _klineIndexView;
-(KTIKlineIndexView*)klineIndexView
{
    if(nil == _klineIndexView)
    {
        _klineIndexView = [[KTIKlineIndexView alloc] initWithFrame:self.bounds];
        _klineIndexView.backgroundColor = self.backgroundColor;
        _klineIndexView.willShowCount = self.showKlineCount;
        _klineIndexView.delegate = self;
        [self addSubview:_klineIndexView];
        
    }
    return _klineIndexView;
}

@synthesize scrollView = _scrollView;
-(UIScrollView*)scrollView
{
    if(nil == _scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.contentSize = self.bounds.size;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;        //不显示横竖滚动条
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = self.moveEnable;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

@synthesize pinchGesture = _pinchGesture;
-(UIPinchGestureRecognizer*)pinchGesture
{
    if(nil == _pinchGesture)
    {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomKline:)];
        self.pinchGesture.delegate =self;
        self.pinchGesture.enabled = self.zoomEnable;
    }
    return _pinchGesture;
}

#pragma mark -

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat cellWidth = 0;
    if(nil != _klineIndexView)
    {
        _klineIndexView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        cellWidth = _klineIndexView.maxWidth;
        
    }
    if(nil != _scrollView)
    {
        _scrollView.frame = self.bounds;
        _scrollView.contentOffset = CGPointMake(self.beginIndex *cellWidth, 0);
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if(nil != _klineIndexView)
    {
        self.klineIndexView.backgroundColor = backgroundColor;
    }
}

-(void)setShowKlineCount:(NSUInteger)showKlineCount
{
    _showKlineCount = showKlineCount;
    if(nil != _klineIndexView)
    {
        self.klineIndexView.willShowCount = showKlineCount;
    }
}

-(void)setZoomEnable:(BOOL)zoomEnable
{
    _zoomEnable = zoomEnable;
    if(nil != _pinchGesture)
    {
        self.pinchGesture.enabled = zoomEnable;
    }
}

-(void)setMoveEnable:(BOOL)moveEnable
{
    _moveEnable = moveEnable;
    if(nil != _scrollView)
    {
        self.scrollView.scrollEnabled = moveEnable;
    }
}

#pragma mark -

@dynamic bshowNewestData;
-(BOOL)bshowNewestData
{
    if(nil == _scrollView)
    {
        return YES;
    }
    //屏幕没有绘制满是显示的一定是最新数据
    if(self.realDrawCount < self.showKlineCount)
    {
        return YES;
    }
    CGFloat lastPtx = self.scrollView.contentOffset.x + self.scrollView.bounds.size.width;
    if(lastPtx + self.klineIndexView.maxWidth < self.scrollView.contentSize.width)
    {
        return  NO;
    }
    return YES;
}

@dynamic realDrawCount;
-(NSUInteger)realDrawCount
{
    if(nil == _klineIndexView)
    {
        return 0;
    }
    return self.klineIndexView.realDrawCount;
}

@dynamic curTotalDataCountForShow; //当前有多少条数据可以用于显示
-(NSUInteger)curTotalDataCountForShow
{
    return self.totalCount;
}

@dynamic canShowMaxCount;
-(NSUInteger)canShowMaxCount
{
    return self.klineIndexView.canShowMaxCount;
}

@dynamic klineMaxValue;
-(CGFloat)klineMaxValue
{
    if(nil == _klineIndexView)
    {
        return 0;
    }
    return self.klineIndexView.klineMaxValue;
}

@dynamic klineMinValue;
-(CGFloat)klineMinValue
{
    if(nil == _klineIndexView)
    {
        return 0;
    }
    return self.klineIndexView.klineMinValue;
}


#pragma mark - private

-(void)setTheTotalCount:(NSUInteger)totalCount
{
    _totalCount = totalCount;
    if(totalCount < self.showKlineCount)
    {
        //此时没有滚动视图
        if(nil != _scrollView)
        {
            [_scrollView removeFromSuperview];
            _scrollView = nil;
        }
    }
    if(self.totalCount <= self.showKlineCount)  //没有滑动
    {
        return;
    }
    CGFloat width = self.klineIndexView.maxWidth * (self.totalCount - self.showKlineCount) + self.scrollView.bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(width, self.scrollView.bounds.size.height);
}


-(void)scrollKlineViewToIndex:(NSUInteger)index
{
    if(index == self.beginIndex)
    {
        return;
    }
    _beginIndex = index;
    _startTime = [self.delegate KTIScrollKlineIndexViewGetTheTimerOfIndex:self.beginIndex];
}

-(void)modifyScrollOffset
{
    if(self.beginIndex > 0 )
    {
        CGFloat width = self.klineIndexView.maxWidth;
        CGFloat value = self.beginIndex * width;
        CGPoint pt = CGPointMake(value, 0);
        self.scrollView.delegate = nil;
        self.scrollView.contentOffset = pt;
        self.scrollView.delegate = self;
    }
    else if(nil != _scrollView)
    {
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }
}

@end
