//
//  KTIRectUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/4/25.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIRectUnitDraw.h"

@interface KTIRectUnitDraw ()

@property(nonatomic) CGFloat yposOfStart;
@property(nonatomic) CGFloat yposOfEnd;

@end

@implementation KTIRectUnitDraw

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.yposOfEnd = 0;
        self.yposOfStart = 0;
    }
    return self;
}

#pragma mark - override

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;
{
    CGContextSaveGState(context);
    CGRect rect = CGRectMake(xCenter - self.unitWidth/2, MIN(self.yposOfStart,self.yposOfEnd),self.unitWidth, fabs(self.yposOfStart - self.yposOfEnd));
    if(nil != self.fillColor)
    {
        [self.fillColor setFill];
        UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);
        CGContextRestoreGState(context);
    }
    if(nil != self.lineColor)
    {
        [self.lineColor setStroke];
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextStrokeRect(context, rect);
        CGContextSetAllowsAntialiasing(context, true);
    }
    CGContextRestoreGState(context);
}

-(void)resetdata
{
    [super resetdata];
    self.yposOfEnd = 0;
    self.yposOfStart = 0;
}

-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData  //设置绘制数据
{
    if(nodeDrawData.count < 2)
    {
        NSAssert(false, @"KTIRectUnitDraw的数据有问题");
        return;
    }
    self.yposOfStart = [nodeDrawData[0] doubleValue];
    self.yposOfEnd = [nodeDrawData[1] doubleValue];
}


#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTIRectUnitDraw *unitDraw = (KTIRectUnitDraw*)[super copyWithZone:zone];
    unitDraw.yposOfStart = self.yposOfStart;
    unitDraw.yposOfEnd = self.yposOfEnd;
    return unitDraw;
}



@end
