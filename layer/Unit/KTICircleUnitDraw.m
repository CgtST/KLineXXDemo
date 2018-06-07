//
//  KTICircleUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/4/25.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTICircleUnitDraw.h"

@interface KTICircleUnitDraw ()

@property(nonatomic) CGFloat yposOfCenter;

@end

@implementation KTICircleUnitDraw

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.yposOfCenter = - 100;
    }
    return self;
}

#pragma mark - override

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;
{
    CGContextSaveGState(context);
    CGRect rect = CGRectMake(xCenter - self.unitWidth/2, self.yposOfCenter - self.unitWidth/2,self.unitWidth, self.unitWidth);
    if(nil != self.fillColor)
    {
        [self.fillColor setFill];
        CGContextAddEllipseInRect(context, rect);
        CGContextDrawPath(context, kCGPathFill);
    }
    if(nil != self.lineColor)
    {
        [self.lineColor setStroke];
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetAllowsAntialiasing(context, true);
        CGContextDrawPath(context, kCGPathStroke);
        CGContextSetAllowsAntialiasing(context, false);

    }
    CGContextRestoreGState(context);
}

-(void)resetdata
{
    [super resetdata];
    self.yposOfCenter = - 100;
}


-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData  //设置绘制数据
{
    if(nodeDrawData.count < 1)
    {
        NSAssert(false, @"KTICircleUnitDraw的数据有问题");
        return;
    }
    self.yposOfCenter = [nodeDrawData[0] doubleValue];
}


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTICircleUnitDraw *unitDraw = (KTICircleUnitDraw*)[super copyWithZone:zone];
    unitDraw.yposOfCenter = self.yposOfCenter;
    return unitDraw;
}

@end
