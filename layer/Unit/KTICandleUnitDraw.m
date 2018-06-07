//
//  KTICandleUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/4/25.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTICandleUnitDraw.h"

@interface KTICandleUnitDraw()

@property(nonatomic) CGFloat yposOfHighPrice;
@property(nonatomic) CGFloat yposOfLowPrice;
@property(nonatomic) CGFloat yposOfOpenPrice;
@property(nonatomic) CGFloat yposOfClosePrice;

@end


@implementation KTICandleUnitDraw

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.candleStyle = KTIKLineDrawTypeSolid;
        self.yposOfHighPrice = 0;
        self.yposOfLowPrice = 0;
        self.yposOfOpenPrice = 0;
        self.yposOfClosePrice = 0;
    }
    return self;
}

#pragma mark - override

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;
{
    CGContextSaveGState(context);
    if(KTIKLineDrawTypeSolid == self.candleStyle)
    {
        [self drawSolid:context Center:xCenter];
    }
    else if(KTIKLineDrawTypeHollow == self.candleStyle)
    {
        if(self.yposOfClosePrice < self.yposOfOpenPrice)  //阳线（收盘价格大于开盘价格，此时绘制坐标刚好相反）
        {
            [self drawHollow:context Center:xCenter];
        }
        else
        {
            [self drawSolid:context Center:xCenter];
        }
    }
    else
    {
        [self drawSlub:context Center:xCenter];
    }
    CGContextRestoreGState(context);
}

-(void)resetdata
{
    [super resetdata];
    self.yposOfHighPrice = 0;
    self.yposOfLowPrice = 0;
    self.yposOfOpenPrice = 0;
    self.yposOfClosePrice = 0;
}

-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData  //设置绘制数据
{
    if(nodeDrawData.count < 4)
    {
        NSAssert(false, @"K线蜡烛图的数据错误");
        return;
    }
    self.yposOfHighPrice = [nodeDrawData[0] doubleValue];
    self.yposOfLowPrice = [nodeDrawData[1] doubleValue];
    self.yposOfOpenPrice = [nodeDrawData[2] doubleValue];
    self.yposOfClosePrice = [nodeDrawData[3] doubleValue];
}


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTICandleUnitDraw *unitDraw = (KTICandleUnitDraw*)[super copyWithZone:zone];
    unitDraw.yposOfOpenPrice = self.yposOfOpenPrice;
    unitDraw.yposOfClosePrice = self.yposOfClosePrice;
    unitDraw.yposOfHighPrice = self.yposOfHighPrice;
    unitDraw.yposOfLowPrice = self.yposOfLowPrice;
    return unitDraw;
}


#pragma mark - setter and geter

-(void)setUnitWidth:(CGFloat)unitWidth
{
    [super setUnitWidth:unitWidth];
    self.lineWidth = self.unitWidth > 2.0 ? 1.0 : 0.5;
}

-(void)setFillColor:(UIColor *)fillColor
{
    [super setFillColor:fillColor];
    [super setLineColor:fillColor];
}

-(void)setLineColor:(UIColor *)lineColor  //保证线的颜色和填充色一致
{
    self.fillColor = lineColor;
}


#pragma mark - private

-(void)drawHollow:(CGContextRef)context Center:(CGFloat)xCenter
{
    [self.lineColor setStroke];
    CGContextSetLineWidth(context, self.lineWidth);
    
    //计算矩形
    CGRect rect = CGRectZero;
    {
        CGFloat height = fabs(self.yposOfOpenPrice - self.yposOfClosePrice); //柱子的高度
        NSUInteger pix = height * [UIScreen mainScreen].scale;
        pix = MAX(2, pix);
        height = pix/[UIScreen mainScreen].scale;
        CGFloat minyStart = MIN(self.yposOfOpenPrice, self.yposOfClosePrice); //柱子的起点
        rect = CGRectMake(xCenter - self.unitWidth/2,minyStart,self.unitWidth,height);
    }
    
    //绘制矩形
    {
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeRect(context, rect);
        CGContextSetAllowsAntialiasing(context, true);
    }

    CGPoint points[2];  //计算上下阴影线
    {
        points[0] = CGPointMake(xCenter, MIN(self.yposOfHighPrice, self.yposOfLowPrice));
        points[1] = CGPointMake(xCenter, MAX(self.self.yposOfHighPrice, self.yposOfLowPrice));
    }
    //绘制线
    {
        CGContextStrokeRect(context, rect);
        //上面部分
        CGPoint linePt[2];
        linePt[0] = points[0];
        linePt[1] = CGPointMake(xCenter, rect.origin.y);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,linePt, 2);
        CGContextSetAllowsAntialiasing(context, true);
        //下面部分
        linePt[0] = CGPointMake(xCenter, rect.origin.y + rect.size.height);
        linePt[1] = points[1];
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,linePt, 2);
        CGContextSetAllowsAntialiasing(context, true);
    }
}

-(void)drawSolid:(CGContextRef)context Center:(CGFloat)xCenter
{
    [self.fillColor setStroke];
    [self.fillColor setFill];
    
    //绘制矩形
    {
        CGRect rect = CGRectZero;
        CGFloat height = fabs(self.yposOfOpenPrice - self.yposOfClosePrice); //柱子的高度
        NSUInteger pix = height * [UIScreen mainScreen].scale;
        pix = MAX(2, pix);
        height = pix/[UIScreen mainScreen].scale;
        CGFloat minyStart = MIN(self.yposOfOpenPrice, self.yposOfClosePrice); //柱子的起点
        rect = CGRectMake(xCenter - self.unitWidth/2,minyStart,self.unitWidth,height);
        //UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);
        CGContextFillRect(context, rect);
    }
    //绘制线
    {
        CGContextSetLineWidth(context, self.lineWidth);
        CGPoint points[2];
        points[0] = CGPointMake(xCenter, MIN(self.yposOfHighPrice, self.yposOfLowPrice));
        points[1] = CGPointMake(xCenter, MAX(self.self.yposOfHighPrice, self.yposOfLowPrice));
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,points, 2);
        CGContextSetAllowsAntialiasing(context, true);
    }
    
}

-(void)drawSlub:(CGContextRef)context  Center:(CGFloat)xCenter //竹节线，收盘价花在右方
{
    [self.lineColor setStroke];
    CGContextSetLineWidth(context, self.lineWidth);
    //绘制线
    {
        CGPoint points[2];
        points[0] = CGPointMake(xCenter, MIN(self.yposOfHighPrice, self.yposOfLowPrice));
        points[1] = CGPointMake(xCenter, MAX(self.self.yposOfHighPrice, self.yposOfLowPrice));
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,points, 2);
        CGContextSetAllowsAntialiasing(context, true);
    }
    //绘制收盘价（右侧）
    {
        CGPoint points[2];
        points[0] = CGPointMake(xCenter, self.yposOfClosePrice);
        points[1] = CGPointMake(xCenter + self.unitWidth/2, self.yposOfClosePrice);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,points, 2);
        CGContextSetAllowsAntialiasing(context, true);
    }
    
    //绘制开盘价
    {
        CGPoint points[2];
        points[0] = CGPointMake(xCenter - self.unitWidth/2, self.yposOfOpenPrice);
        points[1] = CGPointMake(xCenter, self.yposOfOpenPrice);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,points, 2);
        CGContextSetAllowsAntialiasing(context, true);

    }

}

@end
