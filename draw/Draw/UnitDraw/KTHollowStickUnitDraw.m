//
//  KTHollowStickUnitDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTHollowStickUnitDraw.h"

@implementation KTHollowStickUnitDraw
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
        self.unitXcenter = 0;
        self.startyPos = 0;
        self.endyPos = 0;
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
    [self.unitColor setStroke];
    CGFloat height = fabs(self.startyPos - self.endyPos);
    CGFloat yStart = MIN(self.startyPos, self.endyPos);
    CGRect rect = CGRectMake(self.unitXcenter - self.unitWidth/2, yStart, self.unitWidth, height);
    CGContextSetLineWidth(context, MAX(1/[UIScreen mainScreen].scale, MIN(self.unitWidth/4, 1)));
    CGContextStrokeRect(context, rect);
}

-(nonnull id<KTUnitDrawDelegate>)copyDraw
{
    KTHollowStickUnitDraw *draw = [[KTHollowStickUnitDraw alloc] init];
    draw.unitColor = self.unitColor;
    draw.unitWidth = self.unitWidth;
    draw.unitXcenter = self.unitXcenter;
    
    draw.startyPos = self.startyPos;
    draw.endyPos = self.endyPos;
    draw.bValid = self.bValid;
    return draw;

}

@end
