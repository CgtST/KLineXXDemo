//
//  KTCandleUnitDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTCandleUnitDraw.h"

@implementation KTCandleUnitDraw

@synthesize unitWidth = _unitWidth;
@synthesize unitColor = _unitColor;
@synthesize unitXcenter = _unitXcenter;

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.unitColor = [UIColor redColor];
        self.unitWidth = 1.0;
        
        self.fHighPriceYpos = 0;
        self.fLowPriceYpos = 0;
        self.fOpenPriceYpos = 0;
        self.fClosePriceYpos = 0;
        self.unitXcenter = 0;
    }
    return self;
}

#pragma mark - KTUnitDrawDelegate

-(void)draw:(nonnull CGContextRef)context
{
    [self.unitColor setStroke];
    [self.unitColor setFill];
    if(self.unitWidth > 2.0)
    {
        CGContextSetLineWidth(context, 1.0);
    }
    else
    {
        CGContextSetLineWidth(context, 0.5);
    }
    //绘制矩形
    CGRect rect = CGRectZero;
    {
        CGFloat height = fabs(self.fOpenPriceYpos - self.fClosePriceYpos); //柱子的高度
        NSUInteger pix = height * [UIScreen mainScreen].scale;
        pix = MAX(2, pix);
        height = pix/[UIScreen mainScreen].scale;
        CGFloat minyStart = MIN(self.fOpenPriceYpos, self.fClosePriceYpos); //柱子的起点
        rect = CGRectMake(self.unitXcenter - self.unitWidth/2,minyStart,self.unitWidth,height);
    }
    UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);
    //绘制线
    {
        CGPoint points[2];
        points[0] = CGPointMake(self.unitXcenter, MIN(self.fHighPriceYpos, self.fLowPriceYpos));
        points[1] = CGPointMake(self.unitXcenter, MAX(self.fHighPriceYpos, self.fLowPriceYpos));
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeLineSegments(context,points, 2);
        CGContextSetAllowsAntialiasing(context, true);
    }
}

-(nonnull id<KTUnitDrawDelegate>)copyDraw
{
    KTCandleUnitDraw *draw = [[KTCandleUnitDraw alloc] init];
    draw.unitColor = self.unitColor;
    draw.unitWidth = self.unitWidth;
    draw.unitXcenter = self.unitXcenter;
    
    draw.fHighPriceYpos = self.fHighPriceYpos;
    draw.fLowPriceYpos = self.fLowPriceYpos;
    draw.fOpenPriceYpos = self.fOpenPriceYpos;
    draw.fClosePriceYpos = self.fClosePriceYpos;
    return draw;
}

@end
