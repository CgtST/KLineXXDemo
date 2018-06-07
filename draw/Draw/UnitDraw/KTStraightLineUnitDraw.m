//
//  KTStraightLineUnitDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTStraightLineUnitDraw.h"

@implementation KTStraightLineUnitDraw
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
        self.startyPos = 0;
        self.endyPos = 0;
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
    CGRect rect = CGRectMake(self.unitXcenter - self.unitWidth/2, MIN(self.startyPos,self.endyPos),self.unitWidth, fabs(self.startyPos - self.endyPos));
    if(0 == rect.size.height)
    {
        rect.size.height = 1.0 /[UIScreen mainScreen].scale;
    }
    [self.unitColor setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
    CGContextRestoreGState(context);
}

-(nonnull id<KTUnitDrawDelegate>)copyDraw
{
    KTStraightLineUnitDraw *draw = [[KTStraightLineUnitDraw alloc] init];
    draw.unitColor = self.unitColor;
    draw.unitWidth = self.unitWidth;
    draw.unitXcenter = self.unitXcenter;
    
    draw.startyPos = self.startyPos;
    draw.endyPos = self.endyPos;
    draw.bValid = self.bValid;
    return draw;
    
}


@end
