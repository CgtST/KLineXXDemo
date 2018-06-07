//
//  KTITrendDrawView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTITrendDrawView.h"
#import "KTINodeData.h"
#import "KTICustomDataOper.h"
#import "KTIIndexStyle.h"

@interface KTITrendDrawView ()
{
    NSLock *m_lock;
}
@property(nonatomic,readonly,retain,nonnull) dispatch_queue_t trendQueue;
@property(nonatomic,readonly,retain,nonnull) CAShapeLayer *upAreaLayer;
@property(nonatomic,readonly,retain,nonnull) CAShapeLayer *backGroundAreaLayer;
@property(nonatomic,readonly,retain,nonnull) CAShapeLayer *newpriceShape;
@property(nonatomic,readonly,retain,nonnull) CAShapeLayer *avgPriceShape;
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSNumber*> *newpriceArr;
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSNumber*> *avgpriceArr;
@property(nonatomic,readonly) BOOL hadShowAvgPriceLine; //是否显示均线
@property(nonatomic) CGFloat minValue;
@property(nonatomic) CGFloat maxValue;

@property(nonatomic,retain,nullable) UIBezierPath* upAreaPath;
@property(nonatomic,retain,nullable) UIBezierPath* backGroundAreaPath;
@property(nonatomic,retain,nullable) UIBezierPath* newpricePath;
@property(nonatomic,retain,nullable) UIBezierPath* avgPricePath;
@property(nonatomic,readonly) BOOL needSetPath;

@end

@implementation KTITrendDrawView

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
    _trendQueue = [[self class] shareTrendQuote];
    _newpriceArr = [NSMutableArray array];
    _avgpriceArr = [NSMutableArray array];
    m_lock = [[NSLock alloc] init];
}


-(void)drawRect:(CGRect)rect
{
    if(YES == self.needSetPath)
    {
        [self updateLayerPath];
    }
}

#pragma mark - public

-(CGFloat)getPriceDrawYposAtIndex:(NSUInteger)index
{
    __block CGFloat lastPrice = -1;
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.trendQueue, ^{
        if(index < weakSelf.newpriceArr.count)
        {
            lastPrice = [weakSelf.newpriceArr[index] doubleValue];
        }
    });
    return lastPrice;
}

-(void)clearIndexDraws:(nullable FunctionFinishBlock)finishblock //清空绘制
{
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(self.trendQueue, ^{
        [weakSelf clearTrendDraw];
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
    
    //设置线的颜色
    UIColor *newpriceColor = [[KTIIndexStyle shareTrendNewPriceIndexSyle] getColor:KTIIndexColorTypeLine];
    self.newpriceShape.strokeColor = newpriceColor.CGColor;
    self.newpriceShape.lineWidth = [KTIIndexStyle shareTrendNewPriceIndexSyle].lineWidth;
    if(allData.indexDataArr.count > 1)
    {
        UIColor *avgpriceColor = [[KTIIndexStyle shareTrendAvgPriceIndexSyle] getColor:KTIIndexColorTypeLine];
        self.avgPriceShape.strokeColor = avgpriceColor.CGColor;
        self.avgPriceShape.lineWidth = [KTIIndexStyle shareTrendAvgPriceIndexSyle].lineWidth;
    }
    else
    {
        _avgPriceShape = nil;
    }

    
    NSArray *xCenterArr = [self.indexDelegate KTIBaseIndexDrawViewGetXcenter:weakSelf];
    //计算数据
    dispatch_barrier_async(self.trendQueue, ^{
        KTIIndexData *newpriceData = allData.indexDataArr.firstObject;
        NSArray<__kindof NSNumber*> *newpriceArr = [KTICustomDataOper values2LineDrawPoints:newpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        NSArray<__kindof NSNumber*> *avgriceArr = nil;
        if(YES == weakSelf.hadShowAvgPriceLine)
        {
            KTIIndexData *avgpriceData = allData.indexDataArr.lastObject;
            avgriceArr = [KTICustomDataOper values2LineDrawPoints:avgpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        }
        [weakSelf clearTrendDraw];
        [weakSelf addLineDataNewPrice:newpriceArr AvgPrice:avgriceArr];
        [weakSelf calPath:xCenterArr NewPrice:weakSelf.newpriceArr AvgPrice:weakSelf.avgpriceArr];
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

    __weak typeof(self) weakSelf = self;
    NSArray *xCenterArr = [self.indexDelegate KTIBaseIndexDrawViewGetXcenter:weakSelf];
    //计算数据
    dispatch_barrier_async(self.trendQueue, ^{
        KTIIndexData *newpriceData = updateData.indexDataArr.firstObject;
        NSArray<__kindof NSNumber*> *newpriceArr = [KTICustomDataOper values2LineDrawPoints:newpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        NSArray<__kindof NSNumber*> *avgriceArr = nil;
        if(YES == weakSelf.hadShowAvgPriceLine)
        {
            KTIIndexData *avgpriceData = updateData.indexDataArr.lastObject;
            avgriceArr = [KTICustomDataOper values2LineDrawPoints:avgpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        }
        [weakSelf removeDataFromEnd:newpriceArr.count];
        [weakSelf addLineDataNewPrice:newpriceArr AvgPrice:avgriceArr];
        [weakSelf calPath:xCenterArr NewPrice:weakSelf.newpriceArr AvgPrice:weakSelf.avgpriceArr];
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
    __weak typeof(self) weakSelf = self;
    NSArray *xCenterArr = [self.indexDelegate KTIBaseIndexDrawViewGetXcenter:weakSelf];
    //计算数据
    dispatch_barrier_async(self.trendQueue, ^{
        KTIIndexData *newpriceData = addData.indexDataArr.firstObject;
        NSArray<__kindof NSNumber*> *newpriceArr = [KTICustomDataOper values2LineDrawPoints:newpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        NSArray<__kindof NSNumber*> *avgriceArr = nil;
        if(YES == weakSelf.hadShowAvgPriceLine)
        {
            KTIIndexData *avgpriceData = addData.indexDataArr.lastObject;
            avgriceArr = [KTICustomDataOper values2LineDrawPoints:avgpriceData MinValue:weakSelf.minValue MaxValue:weakSelf.maxValue Rect:weakSelf.bounds];
        }
        if(weakSelf.newpriceArr.count + addData.nodeCount > weakSelf.showCount)
        {
            NSUInteger removeCount = addData.nodeCount + weakSelf.newpriceArr.count - weakSelf.showCount;
            [weakSelf removeDataFromEnd:removeCount];
        }
       
        [weakSelf addLineDataNewPrice:newpriceArr AvgPrice:avgriceArr];
        [weakSelf calPath:xCenterArr NewPrice:weakSelf.newpriceArr AvgPrice:weakSelf.avgpriceArr];
        if(nil != finishblock)
        {
            finishblock();
        }
    });
}


#pragma mark - getter and setter

@synthesize newpriceShape = _newpriceShape;
-(CAShapeLayer*)newpriceShape
{
    if(nil == _newpriceShape)
    {
        _newpriceShape = [CAShapeLayer layer];
        _newpriceShape.drawsAsynchronously = YES;
        _newpriceShape.lineCap = kCALineCapRound;
        _newpriceShape.fillColor = nil;
        [self.layer addSublayer:_newpriceShape];
    }
    return _newpriceShape;
}

@synthesize avgPriceShape = _avgPriceShape;
-(CAShapeLayer*)avgPriceShape
{
    if(nil == _avgPriceShape)
    {
        _avgPriceShape = [CAShapeLayer layer];
        _avgPriceShape.drawsAsynchronously = YES;
        _avgPriceShape.lineCap = kCALineCapRound;
        _avgPriceShape.fillColor = nil;
        [self.layer addSublayer:_avgPriceShape];
    }
    return _avgPriceShape;
}

@synthesize upAreaLayer = _upAreaLayer;
-(CAShapeLayer*)upAreaLayer
{
    if(nil == _upAreaLayer)
    {
        _upAreaLayer = [CAShapeLayer layer];
        _upAreaLayer.drawsAsynchronously = YES;
        [self.layer insertSublayer:_upAreaLayer atIndex:0];
    }
    return _upAreaLayer;
}

@synthesize backGroundAreaLayer = _backGroundAreaLayer;
-(CAShapeLayer*)backGroundAreaLayer
{
    if(nil == _backGroundAreaLayer)
    {
        _backGroundAreaLayer = [CAShapeLayer layer];
        _backGroundAreaLayer.drawsAsynchronously = YES;
        [self.layer insertSublayer:_backGroundAreaLayer below:self.upAreaLayer];
    }
    return _backGroundAreaLayer;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backGroundAreaLayer.fillColor = backgroundColor.CGColor;
}

-(UIColor*)backgroundColor
{
    if(nil == self.backGroundAreaLayer.fillColor)
    {
        return nil;
    }
    return  [UIColor colorWithCGColor:self.backGroundAreaLayer.fillColor];
}

#pragma mark -

@dynamic upAreaBackGround;
-(void)setUpAreaBackGround:(UIColor *)upAreaBackGround
{
    [super setBackgroundColor:upAreaBackGround];
    self.upAreaLayer.fillColor = upAreaBackGround.CGColor;
}

-(UIColor*)upAreaBackGround
{
    if(nil == self.upAreaLayer.fillColor)
    {
        return nil;
    }
    return  [UIColor colorWithCGColor:self.upAreaLayer.fillColor];
}

#pragma mark -

@dynamic curDrawPointCount;
-(NSUInteger)curDrawPointCount
{
    //如果用队列，会出现死锁？？？？？
    [m_lock lock];
    NSUInteger drawCount = self.newpriceArr.count;
    [m_lock unlock];
    
    return drawCount;
}

@dynamic hadShowAvgPriceLine;
-(BOOL)hadShowAvgPriceLine
{
    if(nil == _avgPriceShape)
    {
        return NO;
    }
    return YES;
}

@dynamic lastYpos;
-(CGFloat)lastYpos
{
    //如果用队列，会出现死锁？？？？？
    [m_lock lock];
    CGFloat lastPrice = [self.newpriceArr.lastObject doubleValue];
    [m_lock unlock];
    return lastPrice;
}

#pragma mark - private



-(void)clearTrendDraw
{
    [m_lock lock];
    [self.newpriceArr removeAllObjects];
    [self.avgpriceArr removeAllObjects];
    [m_lock unlock];
    
    [self calPath:@[@(0),@(0)] NewPrice:@[@(0),@(0)] AvgPrice:@[@(0),@(0)]];
}

//移除开头的count个数据
-(void)removeDataFromStart:(NSUInteger)count
{
    [m_lock lock];
    NSRange range = NSMakeRange(0, count);
    if(count > self.newpriceArr.count)
    {
        range.length = self.newpriceArr.count;
    }
    [self.newpriceArr removeObjectsInRange:range];
    if(self.avgpriceArr.count >= range.length)
    {
        [self.avgpriceArr removeObjectsInRange:range];
    }
    [m_lock unlock];
}

//移除末尾的count个数据
-(void)removeDataFromEnd:(NSUInteger)count
{
    [m_lock lock];
    NSUInteger start = count > self.newpriceArr.count ? 0 : self.newpriceArr.count - count;
    NSUInteger length = self.newpriceArr.count - start;
    NSRange range = NSMakeRange(start, length);
    [self.newpriceArr removeObjectsInRange:range];
    if(self.avgpriceArr.count >= range.length)
    {
        [self.avgpriceArr removeObjectsInRange:range];
    }
    [m_lock unlock];
}

//添加数据
-(void)addLineDataNewPrice:(nonnull NSArray<__kindof NSNumber*>*)newpriceDataArr AvgPrice:(nullable NSArray<__kindof NSNumber*>*)avgpriceDataArr
{
    [m_lock lock];
    [self.newpriceArr addObjectsFromArray:newpriceDataArr];
    if(nil != avgpriceDataArr)
    {
        [self.avgpriceArr addObjectsFromArray:avgpriceDataArr];
    }
    [m_lock unlock];
}

//计算路径
-(void)calPath:(nonnull NSArray<__kindof NSNumber*>*)centerArr NewPrice:(nonnull NSArray<__kindof NSNumber*>*)newpriceArr AvgPrice:(nonnull NSArray<__kindof NSNumber*>*)avgpriceArr
{
    if(centerArr.count < 2 || newpriceArr.count < 2)
    {
        return;
    }
    //最新价格
    UIBezierPath *newpricePath =  [[self class] createPath:newpriceArr Xcenter:centerArr];
    //均价
    UIBezierPath *avgPricePath = nil;
    if(YES == self.hadShowAvgPriceLine)
    {
        avgPricePath = [[self class] createPath:avgpriceArr Xcenter:centerArr];
    }
    //上部区域path
    UIBezierPath *upareaPath = nil;
    if(nil != _upAreaLayer)
    {
        CGFloat lastCenterX = [centerArr.lastObject doubleValue];
        if(newpriceArr.count < centerArr.count)
        {
            lastCenterX = [centerArr[newpriceArr.count - 1] doubleValue];
        }
        upareaPath = [UIBezierPath bezierPathWithCGPath:newpricePath.CGPath];
        [upareaPath addLineToPoint:CGPointMake(lastCenterX, self.bounds.origin.y)]; //上部点
        [upareaPath addLineToPoint:self.bounds.origin]; //起点
        [upareaPath addLineToPoint:CGPointMake(self.bounds.origin.x, [newpriceArr.firstObject doubleValue])];
        [upareaPath closePath];
    }
    //背景区域path
    UIBezierPath *backgroundAreaPath = nil;
    if(nil != _backGroundAreaLayer)
    {
        CGFloat lastCenterX = [centerArr.lastObject doubleValue];
        if(newpriceArr.count < centerArr.count)
        {
            lastCenterX = [centerArr[self.newpriceArr.count - 1] doubleValue];
        }
        backgroundAreaPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, lastCenterX, self.bounds.size.height)];
    }
    
    [self updateupAreaPath:upareaPath backGroundAreaPath:backgroundAreaPath newpricePath:newpricePath avgPricePath:avgPricePath];
}

-(void)updateupAreaPath:(UIBezierPath*)upAreaPath backGroundAreaPath:(UIBezierPath*) backGroundAreaPath newpricePath:(UIBezierPath*) newpricePath avgPricePath:(UIBezierPath*) avgPricePath
{
    [m_lock lock];
    _needSetPath = YES;
    self.upAreaPath = upAreaPath;
    self.backGroundAreaPath = backGroundAreaPath;
    self.newpricePath = newpricePath;
    self.avgPricePath = avgPricePath;
    [m_lock unlock];
}

-(void)updateLayerPath
{
    [m_lock lock];
    _needSetPath = NO;
    self.newpriceShape.path = self.newpricePath.CGPath;
    if(nil != self.avgPricePath)
    {
        self.avgPriceShape.path = self.avgPricePath.CGPath;
    }
    if(nil != self.upAreaPath)
    {
        self.upAreaLayer.path = self.upAreaPath.CGPath;
    }
    if(nil != self.backGroundAreaPath)
    {
        self.backGroundAreaLayer.path = self.backGroundAreaPath.CGPath;
    }
    [m_lock unlock];
}

+(UIBezierPath*)createPath:(NSArray<__kindof NSNumber*>*)yValues Xcenter:(NSArray<__kindof NSNumber*>*)centerArr
{
    if(yValues.count < 2)
    {
        return nil;
    }
    //最新价格
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake([centerArr.firstObject doubleValue],[yValues.firstObject doubleValue])];
    for(NSUInteger i = 1; i < MIN(centerArr.count, yValues.count);i++)
    {
        [bezierPath addLineToPoint:CGPointMake([centerArr[i] doubleValue], [yValues[i] doubleValue])];
    }
    return bezierPath;
}

+(dispatch_queue_t)shareTrendQuote
{
    static dispatch_queue_t queue;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        queue = dispatch_queue_create("trendQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

@end
