//
//  KTIScrollTrendIndexView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIScrollTrendIndexView.h"
#import "KTITrendIndexView.h"


@interface KTIScrollTrendIndexView ()<KTIIndexViewDelegate,UIScrollViewDelegate>

@property(nonatomic,readonly,retain,nonnull) KTITrendIndexView *trendIndexView;
@property(nonatomic,readonly,retain,nonnull) UIScrollView *scrollView;  //用来进行滑动

@property(nonatomic,readonly) NSUInteger maxShowCount; //可以显示的最多的点的个数
@property(nonatomic,readonly) NSUInteger maxPointShow;

@end

@implementation KTIScrollTrendIndexView

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        self.distToEndWhenChanged = 0;
        self.bshowAvgPriceLine = NO;
        _moveEnable = YES;
        self.leftMoveCount = 30;
        _beginIndex = 0;
    }
    return self;
}

#pragma mark - public

-(void)setMaxShowTrendCount:(NSUInteger)maxShowTrendCount
{
    if(maxShowTrendCount == self.maxShowCount)
    {
        return;
    }
    _maxShowCount = maxShowTrendCount;
    if(maxShowTrendCount <= self.showPointCount)
    {
        //此时没有滚动视图
        if(nil != _scrollView)
        {
            [_scrollView removeFromSuperview];
            _scrollView = nil;
        }
    }
}

//清空分时
-(void)clear
{
    if(nil != _trendIndexView)
    {
        [self.trendIndexView clearDraw];
    }
    //此时滚动视图没有效果
    if(nil != _scrollView)
    {
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.scrollView.contentSize = self.scrollView.bounds.size;
    }
    _beginIndex = 0;
}

//刷新视图，重新计算
-(void)refresh
{
    if(nil == self.delegate)
    {
        return;
    }
    [self initScrollViewStart];
    [self.trendIndexView refreshDraw];
}

//更新最后count个分时点并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)update:(NSUInteger)count
{
    if(nil == self.delegate || NO == self.bshowNewestData)
    {
        return NO;
    }
    return [self.trendIndexView updateLastDraw:count];
}

//添加count个分时点并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNext:(NSUInteger)count
{
    if(nil == self.delegate || NO == self.bshowNewestData)
    {
        return NO;
    }
    if(YES == [self needMoveLeft:count])
    {
        //屏幕绘制已满，需要重新绘制
        [self refresh];
        return YES;
    }
    else
    {
        return [self.trendIndexView addNextDraw:count];
    }
    
}


#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos
{
    return [self.trendIndexView getIndexByDrawPosOfX:xpos];
}

//获取第index个分时的中心点位置(页面上的绘制的个数，不需要加上起点)
-(CGFloat)getCenterAtIndex:(NSUInteger)index
{
    return [self.trendIndexView getCenterAtIndex:index];
}

//如果越界，返回-1
-(CGFloat)getPriceDrawYposAtIndex:(NSUInteger)index
{
    return [self.trendIndexView getPriceDrawYposAtIndex:index];
}

//获取最后一个绘制的中心点
-(CGPoint)getLastPriceDrawCenter
{
    return [self.trendIndexView getLastPriceDrawCenter];
}

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type
{
    return [self.trendIndexView getVerOrgCoordByDrawPos:drawPos ViewType:type];
}

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type
{
    return [self.trendIndexView getVerDrawPosByOrgData:orgData ViewType:type];
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
    NSUInteger index = scrollView.contentOffset.x / self.trendIndexView.maxWidth;
    if(index != self.beginIndex)
    {
        [self scrollTrendViewToIndex:index];
        [self.trendIndexView refreshDraw];
        if(YES == [self.delegate respondsToSelector:@selector(KTIScrollTrendIndexViewDidScrolling:)])
        {
            __weak typeof(self) weakSelf = self;
            [self.delegate KTIScrollTrendIndexViewDidScrolling:weakSelf];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSUInteger index = round(targetContentOffset->x / self.trendIndexView.maxWidth); //防止微小的滑动导致的移动
    targetContentOffset->x = self.trendIndexView.maxWidth * index;
}

#pragma mark - getter and setter

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat cellWidth = 0;
    if(nil != _trendIndexView)
    {
        _trendIndexView.frame = self.bounds;
        cellWidth = _trendIndexView.maxWidth;
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
    if(nil != _trendIndexView)
    {
        self.trendIndexView.trendViewUpColor = backgroundColor;
        self.trendIndexView.backgroundColor = backgroundColor;
    }
}

-(void)setTrendViewColor:(UIColor *)trendViewColor
{
    _trendViewColor = trendViewColor;
    if(nil != _trendIndexView)
    {
        self.trendIndexView.trendViewColor = trendViewColor;
    }
}

@synthesize trendIndexView = _trendIndexView;
-(KTITrendIndexView*)trendIndexView
{
    if(nil == _trendIndexView)
    {
        _trendIndexView = [[KTITrendIndexView alloc] initWithFrame:self.bounds];
        _trendIndexView.bshowAvgPriceLine = self.bshowAvgPriceLine;
        _trendIndexView.trendViewColor = self.trendViewColor;
        _trendIndexView.trendViewUpColor = self.backgroundColor;
        _trendIndexView.backgroundColor = self.backgroundColor;
        _trendIndexView.showPointCount = self.showPointCount;
        _trendIndexView.delegate = self;
        [self addSubview:_trendIndexView];
    }
    return _trendIndexView;
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
        _scrollView.decelerationRate = 0.5;
        _scrollView.delegate = self;
        _scrollView.scrollEnabled = self.moveEnable;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

-(void)setShowPointCount:(NSUInteger)showPointCount
{
    _showPointCount = MAX(2,showPointCount);
    if(nil != _trendIndexView)
    {
        self.trendIndexView.showPointCount = showPointCount;
        [self refresh];
    }
}

-(void)setLeftMoveCount:(NSUInteger)leftMoveCount
{
    _leftMoveCount = MAX(10,leftMoveCount);
}

-(void)setBshowAvgPriceLine:(BOOL)bshowAvgPriceLine
{
    _bshowAvgPriceLine = bshowAvgPriceLine;
    if(nil != _trendIndexView)
    {
        _trendIndexView.bshowAvgPriceLine = bshowAvgPriceLine;
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


#pragma mark -dynamic

@dynamic bshowNewestData;
-(BOOL)bshowNewestData
{
    if(nil == _scrollView || nil == _trendIndexView)
    {
        return YES;
    }
    //屏幕没有绘制满是显示的一定是最新数据
    if(self.trendIndexView.realDrawCount < self.showPointCount)
    {
        return YES;
    }
    //屏幕绘制满了，但是右侧还是有数据
    CGFloat lastPtx = self.scrollView.contentOffset.x + self.scrollView.bounds.size.width;
    if(lastPtx + self.trendIndexView.maxWidth < self.scrollView.contentSize.width)
    {
        return  NO;
    }
    return YES;
}

@dynamic bDrawFinish;
-(BOOL)bDrawFinish
{
    if(nil == _trendIndexView)
    {
        return NO;
    }
    //已经绘制完了所以的数据
    if(self.trendIndexView.realDrawCount + self.beginIndex >= self.maxShowCount)
    {
        return YES;
    }
    return NO;
}

@dynamic trendMaxValue;
-(CGFloat)trendMaxValue
{
    if(nil == _trendIndexView)
    {
        return 0;
    }
    return self.trendIndexView.trendMaxValue;
}

@dynamic trendMinValue;
-(CGFloat)trendMinValue
{
    if(nil == _trendIndexView)
    {
        return 0;
    }
    return self.trendIndexView.trendMinValue;
}

@dynamic maxPointShow;
-(NSUInteger)maxPointShow
{
    if(self.distToEndWhenChanged < self.showPointCount)
    {
        return self.showPointCount - self.distToEndWhenChanged;
    }
    return self.showPointCount;
}

#pragma mark - private

-(BOOL)needMoveLeft:(NSUInteger)addCount
{
    if(self.beginIndex + self.trendIndexView.realDrawCount + addCount >= self.maxShowCount)
    {
        //此时已经是最后的数据了，不需要向左移动
        return NO;
    }
    return  self.trendIndexView.realDrawCount + addCount >= self.maxPointShow ? YES : NO;
}

-(void)initScrollViewStart
{
    //不需要滑动已经可以显示所有的内容了
    if(self.maxShowCount <= self.showPointCount)
    {
        return;
    }
    NSUInteger curDataCount = [self.delegate KTIScrollTrendIndexViewGetAllTrendDataCount];
    NSUInteger start = 0;
    if(curDataCount >= self.maxPointShow)
    {
        if(curDataCount + self.distToEndWhenChanged >= self.maxShowCount)
        {
            //当前显示的已经是快要收盘时的数据了
            start = self.maxShowCount - self.showPointCount;
        }
        else
        {
            NSUInteger showCount = curDataCount;  //当前显示的数据
            while (showCount >= self.maxPointShow)
            {
                showCount = showCount - self.leftMoveCount;
            }
            start = curDataCount - showCount;
        }
        
    }
    [self scrollTrendViewToIndex:start];
    if(nil != _scrollView)
    {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width + self.scrollView.contentOffset.x, self.scrollView.contentSize.height);
    }
}

-(void)scrollTrendViewToIndex:(NSUInteger)index
{
    if(index == self.beginIndex)
    {
        return;
    }
    _beginIndex = index;
    if(self.beginIndex > 0 )
    {
        CGFloat width = self.trendIndexView.maxWidth;
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
