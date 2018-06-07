//
//  KTIconUnitDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/4/22.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIconUnitDraw.h"

@implementation KTIconUnitDraw

@synthesize unitWidth = _unitWidth;
@synthesize unitColor = _unitColor;
@synthesize unitXcenter = _unitXcenter;

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.unitColor = [UIColor yellowColor];
        self.unitWidth = 1.0;
        self.yPosCenter = 0;
        self.unitXcenter = 0;
        self.bValid = YES;
    }
    return self;
}

#pragma mark - KTUnitDrawDelegate

-(void)draw:(nonnull CGContextRef)context
{
    if(NO == self.bValid)
    {
        return;
    }
    CGContextSaveGState(context);
    CGRect rect = CGRectMake(self.unitXcenter - self.unitWidth/2, self.yPosCenter - self.unitWidth/2,self.unitWidth, self.unitWidth);
    [self.unitColor setFill];
    [self.unitColor setStroke];
    CGContextAddEllipseInRect(context, rect);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextSetAllowsAntialiasing(context, false);
    CGContextRestoreGState(context);
}

-(nonnull id<KTUnitDrawDelegate>)copyDraw
{
    KTIconUnitDraw *draw = [[KTIconUnitDraw alloc] init];
    draw.unitColor = self.unitColor;
    draw.unitWidth = self.unitWidth;
    draw.unitXcenter = self.unitXcenter;
    
    draw.yPosCenter = self.yPosCenter;
    return draw;
}

@end
