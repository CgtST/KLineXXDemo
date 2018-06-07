//
//  KTTrendMainView.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/27.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTTrendMainView.h"

#import "KTCalcuLationOper.h"
#import "KTDraw.h"
#import "KTTrendOper.h"


@interface KTTrendMainView ()

@property(nonatomic) CGFloat maxPrice; //最高价,默认为0
@property(nonatomic) CGFloat minPrice; //最低价,默认为0

@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof NSNumber*>* trendCenterxPos;  //分时绘制的中心点

@property(nonatomic,readonly,retain,nonnull) KTCurveIndexDraw *trendLineDraw; //分时线绘制
@property(nonatomic,readonly,retain,nonnull) KTCurveIndexDraw *avgLineDraw; //均线绘制

@end

@implementation KTTrendMainView

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
   
    self.maxPrice = 0.0;
    self.minPrice = 0.0;
    self.rightDistSpace = 8.0;
    _maxWidth = self.frame.size.width;
    
    _trendLineDraw = [[KTCurveIndexDraw alloc] init];
    self.trendLineDraw.lineColor = [UIColor colorWithRed:1.0/255.0 green:217.0/255.0 blue:1.0 alpha:1.0];

    
    _avgLineDraw = [[KTCurveIndexDraw alloc] init];
    self.avgLineDraw.lineColor = [UIColor colorWithRed:208.0/255.0 green:156.0/255.0 blue:69.0/255.0 alpha:1.0];
    self.trendAreaLineColor = nil;

    self.tradeTimeArr = [NSArray array]; //交易时间
}


#pragma mark - 数据获取

-(nonnull NSArray<__kindof NSNumber*>*)getAllPriceValueXCenter  //获取所有价格分量值的中心点(X轴方向)
{
    return [NSArray arrayWithArray:self.trendCenterxPos];
}

//NSNotFound表示没有找到数据
-(NSInteger)getDataIndexByXPos:(CGFloat)xpos  //获取X轴坐标xpos在分时图中的绘制位置
{
    if(xpos < 0 || xpos > self.bounds.size.width) //越界处理
    {
        return NSNotFound;
    }
    if(0 == self.trendLineDraw.pointValues.count ||  0 == self.trendCenterxPos.count ) //没有绘制数据
    {
        return NSNotFound;
    }

    if(xpos >= [self getLastValuePt].x) //超出范围
    {
        return self.trendLineDraw.pointValues.count - 1;
    }
    NSArray<__kindof NSNumber*> *drawCenterArr = [self.trendCenterxPos subarrayWithRange:NSMakeRange(0, self.trendLineDraw.pointValues.count)];
    NSInteger index = [KTCalcuLationOper searchXpos:xpos inArr:drawCenterArr precision:self.maxWidth/2 + 0.01]; //防止浮点型数据误差
    if(NSNotFound == index)
    {
         NSAssert(NSNotFound != index, @"查找算法有问题");
        return NSNotFound;
    }
    //以index为中心带你进行遍历,已弥补二分查找法的不足
    int searchRange = 5;
    NSUInteger startIndex = index <= searchRange ? 0 : index - 5;
    NSUInteger endIndex = index + searchRange >= drawCenterArr.count ? drawCenterArr.count - 1 : index + searchRange;
    CGFloat minDist = self.bounds.size.width;
    //从后向前搜素
    for(NSUInteger i = endIndex ;i > startIndex;i--)
    {
        CGFloat xCenter = [[self.trendCenterxPos objectAtIndex:i - 1] doubleValue];
        CGFloat dist = fabs(xCenter - xpos);
        if( dist < minDist)
        {
            minDist = dist;
            index = i - 1;
            if(dist < 0.01) //已经找到最小的点
            {
                break;
            }
        }
    }
    return index;
}

-(CGFloat)getCenterAtIndex:(NSUInteger)index
{
    if(0 == self.trendCenterxPos.count)
    {
        return 0.0;
    }
    if(index >= self.trendCenterxPos.count)
    {
        return [self.trendCenterxPos.lastObject doubleValue];
    }
    return [[self.trendCenterxPos objectAtIndex:index] doubleValue];
}

-(int)getTrendTimeByXpos:(CGFloat)xpos  //获取X轴坐标xpos在分时图中代表的分时时间,如果没有时间分量,则返回INT32_MIN
{
    if(0 == self.tradeTimeArr.count || 0 == self.trendCenterxPos.count)  //没有任何时间分量
    {
        return INT32_MIN;
    }
    else if(xpos < 0)
    {
        return self.tradeTimeArr.firstObject.startTime;
    }
    else if(xpos > self.bounds.size.width)
    {
        return self.tradeTimeArr.lastObject.endTime;
    }
    NSInteger index = [self getDataIndexByXPos:xpos];
    return [KTTrendOper getTrendTime:self.tradeTimeArr AtIndex:index];
}

-(CGFloat)getLocationXByTime:(int)time //计算时间在X轴上的位置
{
    if(0 == self.tradeTimeArr.count || 0 == self.trendCenterxPos.count) //没有任何时间分量
    {
        return 0;
    }
    NSUInteger indexNum = [KTTrendOper indexOfTime:time tradeTime:self.tradeTimeArr];
    if(indexNum >= self.trendCenterxPos.count)
    {
        return [self.trendCenterxPos.lastObject doubleValue];
    }
    return [[self.trendCenterxPos objectAtIndex:indexNum] doubleValue];
}

-(CGFloat)getPriceByYPos:(CGFloat)ypos //计算ypos代表的价格
{
    if(nil == self.trendDelegate)
    {
        return 0;
    }
    return [KTCalcuLationOper pixelToValue:ypos minValue:self.minPrice MaxValue:self.maxPrice Rect:self.bounds];
}

-(CGPoint)getLastValuePt //获取最后一个值的绘制点
{
    if(self.trendLineDraw.pointValues.count >0)
    {
        NSValue *lastPoint = self.trendLineDraw.pointValues.lastObject;
        return [lastPoint CGPointValue];
    }
    return CGPointZero;
}

#pragma mark - 设置数据

-(void)clearAllDraw //清除所有的绘制
{
    self.trendLineDraw.pointValues = [NSArray array];
    self.avgLineDraw.pointValues = [NSArray array];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

-(void)refreshTrendDraw //刷新分时绘制
{
    if(nil == self.trendDelegate)
    {
        return;
    }
    self.minPrice = [self.trendDelegate KTTrendMainViewgetMinValue];
    self.maxPrice = [self.trendDelegate KTTrendMainViewgetMaxValue];
    KTTrendOperParam *dataParam = [[KTTrendOperParam alloc] init];
    dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    dataParam.minValue = self.minPrice;
    dataParam.maxValue = self.maxPrice;
    dataParam.tradeTimeArr = self.tradeTimeArr;
    NSArray<__kindof KTTrendData*> *trendDataArr = [self.trendDelegate KTTrendMainViewGetAllTrendData];
    [KTTrendOper setTrendData:trendDataArr toCuverDraw:[NSArray arrayWithObjects:self.trendLineDraw,self.avgLineDraw, nil] XCenter:self.trendCenterxPos Param:dataParam];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}




//修改最后一个分时数据,如果返回NO,表示修改失败,修改失败表示不是最后一个分时数据
-(void)modifyLastTrendData:(nonnull KTTrendData*)trendData
{
    BOOL bmofiyMinMaxPrice = NO;
    //最高价或者最低价发生改变
    if(trendData.dCurPrice > self.maxPrice || trendData.dCurPrice < self.minPrice
       || trendData.dAvg > self.maxPrice || trendData.dAvg < self.minPrice)
    {
        bmofiyMinMaxPrice = YES;
    }
    if(NO == bmofiyMinMaxPrice ) //此时只需要更新数据
    {
        //更新数据
        KTTrendOperParam *dataParam = [[KTTrendOperParam alloc] init];
        dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
        dataParam.minValue = self.minPrice;
        dataParam.maxValue = self.maxPrice;
        dataParam.tradeTimeArr = self.tradeTimeArr;
        [KTTrendOper updateLastPoint:[NSArray arrayWithObjects:self.trendLineDraw,self.avgLineDraw, nil] trendData:trendData Param:dataParam];
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self refreshTrendDraw];
    }
}

//添加分时数据
-(void)addNextTrendData:(nonnull KTTrendData*)trendData
{
    //最高价或者最低价发生改变
    BOOL bmofiyMinMaxPrice = NO;
    if(trendData.dCurPrice > self.maxPrice || trendData.dCurPrice < self.minPrice
       || trendData.dAvg > self.maxPrice || trendData.dAvg < self.minPrice)
    {
        bmofiyMinMaxPrice = YES;
    }
    
    if(bmofiyMinMaxPrice)
    {
        [self refreshTrendDraw];
    }
    else
    {
  
        KTTrendOperParam *dataParam = [[KTTrendOperParam alloc] init];
        dataParam.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
        dataParam.minValue = self.minPrice;
        dataParam.maxValue = self.maxPrice;
        dataParam.tradeTimeArr = self.tradeTimeArr;
        [KTTrendOper addNextPoint: [NSArray arrayWithObjects:self.trendLineDraw,self.avgLineDraw, nil]trendData:[NSArray arrayWithObject:trendData] XCenter:self.trendCenterxPos Param:dataParam];

        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - 重写绘制

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(nil != self.trendAreaLineColor && self.trendLineDraw.pointValues.count > 0)
    {
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 2);
        CGContextSetStrokeColorWithColor(context, self.trendAreaLineColor.CGColor);
        NSUInteger lastX= 1;
        for(NSUInteger i = 0 ; i<self.trendLineDraw.pointValues.count;i++)
        {
            CGPoint pt = [[self.trendLineDraw.pointValues objectAtIndex:i] CGPointValue];
            for(;lastX <= (NSUInteger)pt.x;lastX++)
            {
                CGContextMoveToPoint(context, lastX, pt.y);
                CGContextAddLineToPoint(context, lastX, self.bounds.size.height + self.frame.origin.x);
                CGContextSetAllowsAntialiasing(context, false);
                CGContextStrokePath(context);
                CGContextSetAllowsAntialiasing(context, true);
            }
          
        }
        CGContextRestoreGState(context);
    }
    [self.trendLineDraw draw:context];
    [self.avgLineDraw draw:context];
}


#pragma mark - 重写setter和getter函数

-(void)setFrame:(CGRect)frame
{
    CGRect lastFrame = self.frame;
    [super setFrame:frame];
    if(!CGRectEqualToRect(lastFrame, frame))
    {
        [self createCenterX:self.trendCenterxPos.count];
        [self refreshTrendDraw];
    }
}

@dynamic trendLineColor;
-(void)setTrendLineColor:(UIColor *)trendLineColor
{
    self.trendLineDraw.lineColor = trendLineColor;
}
-(UIColor*)trendLineColor
{
    return self.trendLineDraw.lineColor;
}

@dynamic avgLineColor;
-(void)setAvgLineColor:(UIColor *)avgLineColor
{
    self.avgLineDraw.lineColor = avgLineColor;
}
-(UIColor*)avgLineColor
{
    return self.avgLineDraw.lineColor;
}

-(void)setTradeTimeArr:(NSArray<__kindof KTTradeTime *> *)tradeTimeArr
{
    _tradeTimeArr = tradeTimeArr;
    [self createCenterX:[KTTrendOper getTimeWeightCount:tradeTimeArr]];
}

@dynamic drawCount;
-(NSUInteger)drawCount
{
    return self.trendLineDraw.pointValues.count;
}

#pragma mark - private
//重新创建中心点
-(void)createCenterX:(NSUInteger)count
{
    _trendCenterxPos = [KTCalcuLationOper createCenterXWidth:self.bounds.size.width - self.rightDistSpace Count:count MinWidth:&_maxWidth];
    //self.trendLineDraw.bRemoveRepeatPoint = self.trendCenterxPos.count > self.bounds.size.width * [UIScreen mainScreen].scale ? YES : NO;  //点过密时进行抽稀
    self.avgLineDraw.bRemoveRepeatPoint =  self.trendLineDraw.bRemoveRepeatPoint;
}

@end
