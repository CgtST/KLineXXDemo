//
//  KTKlineMainView.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTKlineMainView.h"
#import "KTKlineData.h"
#import "KTCalcuLationOper.h"
#import "KTKlineOper.h"
#import "KTDraw.h"

#define K_MaxSpacePix      6  //每两根K线柱子之间的最大宽度(像素)
#define K_MinSpacePix      1  //每两根K线柱子之间的最小宽度(像素)

#define K_CandleDefaultPix  9 //每根K线绘制的默认宽度(像素)

#define K_KlineMinPix  4 //每个K线的最小绘制宽度(像素)


@interface KTKlineMainView ()

@property(nonatomic) CGFloat maxPrice; //最高价,默认为0
@property(nonatomic) CGFloat minPrice; //最低价,默认为0

@property(nonatomic,readwrite) CGFloat candleWidth; ////每根K线的绘制宽度，默认为K_CandleMinPix个像素的宽度

@property(nonatomic,readwrite) CGFloat candleSpace; //每两个K线图之间的间隔,默认为K_SpacePix个像素

@property(nonatomic,readwrite) CGFloat unitWidth;

@property(nonatomic,readwrite,retain,nonnull) NSArray<__kindof NSNumber*>* klineCenterxPos;

@property(nonatomic,retain,nonnull) NSMutableArray<__kindof KTCandleUnitDraw*> *candleDrawList;//K线绘制

@end

@implementation KTKlineMainView

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
        _maxShowKlineCount = (NSUInteger)(self.bounds.size.width * [UIScreen mainScreen].scale / K_KlineMinPix);  //向下取整
        self.showCount = 60;
    }
    return self;
}

-(void)initValue
{
    self.riseColor = [UIColor redColor];
    self.downColor = [UIColor greenColor];
    self.custColor = [UIColor blackColor];
    self.rightDistSpace = 8.0;
    self.bDrawKline = YES;
    
    self.maxPrice = CGFLOAT_MIN;
    self.minPrice = CGFLOAT_MAX;
    self.candleWidth = K_CandleDefaultPix/[UIScreen mainScreen].scale;
    self.candleSpace = K_MaxSpacePix/[UIScreen mainScreen].scale;
    
    self.klineCenterxPos = [NSArray array];
    
    //绘制
    self.candleDrawList = [NSMutableArray array];
}

#pragma mark -

-(NSInteger)getDrawDataIndexByXPos:(CGFloat)xpos //获取视图中K线数据对应的柱子, NSNotFound表示没有对应
{
    if(xpos > [self getLastKlineDrawCenter])
    {
        if(0 == self.curDrawCount)
        {
            return NSNotFound;
        }
        return self.curDrawCount - 1;
    }
    if(0 == self.curDrawCount) //没有任何K线柱子
    {
        return NSNotFound;
    }
    NSInteger index = [KTCalcuLationOper searchXpos:xpos inArr:self.klineCenterxPos precision:(self.candleWidth + self.candleSpace)/2]; //防止浮点型数据误差
    if(index < 0 || index >= self.klineCenterxPos.count)
    {
        return NSNotFound;
    }
    
    //判断当前位置是否满足条件
    CGFloat centerx = [[self.klineCenterxPos objectAtIndex:index] doubleValue];
    CGFloat dist = fabs(centerx - xpos);
    if(dist <= (self.candleWidth + self.candleSpace)/2)
    {
        return index;
    }
    //以index为中心带你进行遍历,已弥补二分查找法的不足
    int searchRange = 5;
    NSUInteger startIndex = index <= searchRange  ? 0 : index - 5;
    NSUInteger endIndex = index + searchRange >= self.curDrawCount ? self.curDrawCount - 1 : index + searchRange;
    CGFloat minDist = self.bounds.size.width;
    //从后向前搜素
    for(NSUInteger i = endIndex ;i > startIndex;i--)
    {
        CGFloat xCenter = [[self.klineCenterxPos objectAtIndex:i - 1] doubleValue];
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

-(CGFloat)getLastKlineDrawCenter  //获取最后一根K线的绘制中心
{
    if(0 == self.candleDrawList.count)
    {
        return 0;
    }
    return self.candleDrawList.lastObject.unitXcenter;
}


#pragma mark - K线相关

-(void)clearAllDraw
{
    [self.candleDrawList removeAllObjects];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

//修改最后一根K线的数据,如果返回NO,表示修改失败
-(BOOL)updateLastKlineData:(nonnull KTKlineData *)lastKineData
{
    if(0 == self.showCount || 0 == self.candleDrawList.count)
    {
        return NO;
    }
    //最高价或者最低价发生改变
    if(lastKineData.dHighPrice > self.maxPrice || lastKineData.dLowPrice < self.minPrice)
    {
        return NO;
    }
    if(nil == self.klineDelegate)
    {
        return NO;
    }
    

    //更新数据
    KTKlineData *lastData = [self.klineDelegate getKlineDataAtIndex:(self.startShowPos + self.candleDrawList.count - 1)];
    if(YES == [lastData copyDataFrom:lastKineData])
    {
        KTKlineOperParam *param = [[KTKlineOperParam alloc] init];
        param.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
        param.minValue = self.minPrice;
        param.maxValue = self.maxPrice;
        param.riseColor = self.riseColor;
        param.downColor = self.downColor;
        param.customColor = self.custColor;
        
        [KTKlineOper updateCandleUnit:self.candleDrawList.lastObject data:lastData Param:param];
        
        [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
        return YES;
    }
    return NO;
}

//增加一根K线数据到最后,如果返回NO,表示修改失败,此时最高价或者最低价发生改变
-(BOOL)addNextKlineData:(nonnull KTKlineData *)lastKineData
{
    if(0 == self.showCount || 0 == self.candleDrawList.count)
    {
        return NO;
    }
    //最高价或者最低价发生改变
    if(lastKineData.dHighPrice > self.maxPrice || lastKineData.dLowPrice < self.minPrice)
    {
        return NO;
    }
    if(nil == self.klineDelegate)
    {
        return NO;
    }
    
    KTKlineOperParam *param = [[KTKlineOperParam alloc] init];
    param.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    param.minValue = self.minPrice;
    param.maxValue = self.maxPrice;
    param.riseColor = self.riseColor;
    param.downColor = self.downColor;
    param.customColor = self.custColor;
    
    self.candleDrawList = [NSMutableArray arrayWithArray:[KTKlineOper addNextKlineData:lastKineData toCandleUnits:self.candleDrawList CenterxArr:self.klineCenterxPos Param:param]];
    
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    return YES;
}

//计算绘制位置
-(void)refreshKlineDraw
{
    if(nil == self.klineDelegate)
    {
        return;
    }
    
    self.minPrice = [self.klineDelegate KTKlineMainViewGetMinPrice:self.minPrice];
    self.maxPrice = [self.klineDelegate KTKlineMainViewGetMaxPrice:self.maxPrice];
    
    //获取绘制数据
    NSMutableArray<__kindof KTKlineData*> *klineDataArr = [NSMutableArray array];
    for(NSUInteger i = 0;i < self.showCount ; i++)
    {
        KTKlineData *data  = [self.klineDelegate getKlineDataAtIndex:self.startShowPos + i];
        if(nil == data) //此时表示后面没有绘制数据
        {
            break;
        }
        else
        {
            [klineDataArr addObject:data];
        }
    }
    
    //计算绘制K线的个数并且更新绘制单元个数
    NSUInteger showCount = MIN(self.showCount, klineDataArr.count);
    self.candleDrawList = [NSMutableArray arrayWithArray:[KTKlineOper createCandleUnitCount:showCount unitArr:self.candleDrawList]];
    for(KTCandleUnitDraw *unit in self.candleDrawList)
    {
        unit.unitWidth = self.candleWidth;
    }
    
    KTKlineOperParam *param = [[KTKlineOperParam alloc] init];
    param.drawRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1, 0, 1, 0));
    param.minValue = self.minPrice;
    param.maxValue = self.maxPrice;
    param.riseColor = self.riseColor;
    param.downColor = self.downColor;
    param.customColor = self.custColor;
    
    [KTKlineOper setKlineDatas:klineDataArr toCandleUnits:self.candleDrawList CenterxArr:self.klineCenterxPos Param:param];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    
}

#pragma mark - 重写绘制

-(void)drawRect:(CGRect)rect
{
    if(NO == self.bDrawKline)
    {
        return;
    }
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(KTCandleUnitDraw *candle in self.candleDrawList)
    {
        [candle draw:context];
    }
}

#pragma mark - 重新setter和getter函数

@dynamic curDrawCount;
-(NSUInteger)curDrawCount
{
    return self.candleDrawList.count;
}

-(void)setShowCount:(NSUInteger)showCount
{
    showCount = MIN(showCount, self.maxShowKlineCount);
    if(_showCount == showCount)
    {
        return;
    }
    _showCount = showCount;
    if(self.showCount != self.klineCenterxPos.count)  //更改绘制中心
    {
        [self createDrawCenterx]; //创建绘制中心点
    }
    
    
}

-(void)setFrame:(CGRect)frame
{
    CGRect lastFrame = self.frame;
    [super setFrame:frame];
    
    if(!CGRectEqualToRect(lastFrame, frame))
    {
        _maxShowKlineCount = (NSUInteger)(self.bounds.size.width * [UIScreen mainScreen].scale / K_KlineMinPix);  //向下取整
        [self createDrawCenterx]; //创建绘制中心点
        [self updateDrawUintCenter];
    }
}

#pragma mark - private

-(void)updateDrawUintCenter
{
    NSUInteger count = MIN(self.candleDrawList.count, self.klineCenterxPos.count);
    for (NSUInteger i = 0; i < count; i++)
    {
        KTCandleUnitDraw *draw = [self.candleDrawList objectAtIndex:i];
        draw.unitXcenter = [[self.klineCenterxPos objectAtIndex:i] floatValue];
        draw.unitWidth = self.candleWidth;
    }
}

//计算绘制参数
-(void)createDrawCenterx
{
    NSUInteger count = self.showCount;
    if(self.showCount > self.maxShowKlineCount)
    {
        count = self.maxShowKlineCount;
    }
    CGFloat minDist = 0;
    self.klineCenterxPos = [KTCalcuLationOper createCenterXWidth:self.bounds.size.width - self.rightDistSpace  Count:count MinWidth:&minDist];
    self.unitWidth = minDist + 1 /[UIScreen mainScreen].scale;
    if(self.klineCenterxPos.count > 0)
    {
        CGFloat minPix = minDist * [UIScreen mainScreen].scale;//每根K线柱子和空白处占用的空间
        CGFloat spacePix = minPix * 0.4;
        spacePix = MIN(spacePix, K_MaxSpacePix);
        spacePix = MAX(spacePix, K_MinSpacePix);
        
        if(spacePix < K_MinSpacePix)
        {
            self.candleWidth = minDist;
            self.candleSpace = 0;
        }
        else
        {
            self.candleSpace = ((int)spacePix)/[UIScreen mainScreen].scale;
            self.candleWidth = minDist - self.candleSpace;
        }
    }
    else
    {
        self.candleWidth = K_CandleDefaultPix/[UIScreen mainScreen].scale;
        self.candleSpace = 0;
    }
}


-(CGFloat)value2Pixel:(CGFloat)value
{
    return [KTCalcuLationOper valueToPixel:value minValue:self.minPrice MaxValue:self.maxPrice Rect:self.bounds];
}

@end
