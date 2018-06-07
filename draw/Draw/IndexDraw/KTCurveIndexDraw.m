//
//  KTCurveIndexDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTCurveIndexDraw.h"
#import "KTCalcuLationOper.h"
#import "KTIndexStyle.h"

@interface KTCurveIndexDraw ()

@property(nonatomic,retain,nonnull) NSMutableArray<__kindof UIBezierPath*> *m_curvePathArr;

@end


@implementation KTCurveIndexDraw

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.lineColor = [UIColor yellowColor];
        _pointValues = [NSArray array];
        self.startPos = 0;
        self.bRemoveRepeatPoint = NO;
        self.m_curvePathArr = [NSMutableArray array];
        self.lineWidth = 1/[UIScreen mainScreen].scale;
        self.bshow = YES;
    }
    return self;
}

-(void)draw:(nonnull CGContextRef)context
{
    if(NO == self.bshow)
    {
        return;
    }
    [self.lineColor setStroke];
    for(UIBezierPath *path in self.m_curvePathArr)
    {
        path.lineWidth = self.lineWidth;
        [path stroke];
    }
}

#pragma mark - 重写setter和getter函数

-(void)setPointValues:(NSArray<__kindof NSValue *> *)pointValues
{
    _pointValues = pointValues;
    [self.m_curvePathArr removeAllObjects];
    if(pointValues.count < 1)
    {
        return;
    }
    if(NO == self.bRemoveRepeatPoint)
    {
        [self resetPathData:pointValues];
    }
    else
    {
        NSArray * drawPointArr = [KTCalcuLationOper removeRepeatPointAtX:pointValues];
        [self resetPathData:drawPointArr];
    }
}


@synthesize bshow = _bshow;

#pragma mark - private

-(void)resetPathData:(NSArray<__kindof NSValue *> *)pointValues
{
    UIBezierPath *beiPath = nil;
    BOOL bFirst = YES;
    for(NSUInteger i = 0; i< pointValues.count;i++)
    {
        CGPoint pt = [[pointValues objectAtIndex:i] CGPointValue];
        if(pt.y > KT_INDEX_INVALID_VALUE) //无效值不绘制
        {
            bFirst = YES;
            continue;
        }
        else
        {
            if(YES == bFirst)
            {
                if(nil != beiPath)
                {
                    [self.m_curvePathArr addObject:beiPath];
                }
                beiPath = [UIBezierPath bezierPath];
                [beiPath moveToPoint:pt];
                bFirst = NO;
            }
            else
            {
                [beiPath addLineToPoint:pt];
            }
        }
    }
    if(nil != beiPath)
    {
        [self.m_curvePathArr addObject:beiPath];
    }
}

@end
