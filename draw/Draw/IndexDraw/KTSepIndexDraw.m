//
//  KTSepIndexDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/6/30.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTSepIndexDraw.h"

#define  K_riseColor [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]
#define  K_downColor [UIColor colorWithRed:0 green:1.0 blue:0 alpha:0.5]

@interface KTSepIndexDraw()

@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSValue*> *firstOrgDataArr;  //原始数据
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof NSValue*> *secondOrgDataArr; //原始数据
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof UIBezierPath*> *areaArr; //绘制区域
@property(nonatomic,readonly,retain,nonnull) NSMutableArray<__kindof UIColor*> *areaFillColorArr; //交叉区域颜色

@property(nonatomic) BOOL bLastLineJoin; //最后两条线是否相交
@property(nonatomic,retain,nullable) NSValue *lastJoinPt; //最后相交的点
@property(nonatomic) NSUInteger lastJoinPtIndex; //最后相交的点的两条线段的后一个点的位置

@end

@implementation KTSepIndexDraw
@synthesize bshow;

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.bshow = YES;
        _firstOrgDataArr = [NSMutableArray array];
        _secondOrgDataArr = [NSMutableArray array];
        _areaArr = [NSMutableArray array];
        _areaFillColorArr = [NSMutableArray array];
        self.bLastLineJoin = NO;
    }
    return self;
}

-(void)draw:(nonnull CGContextRef)context
{
    if(NO == self.bshow)
    {
        return;
    }
    for(NSUInteger i = 0; i < self.areaArr.count ; i++)
    {
        UIBezierPath *path = self.areaArr[i];
        UIColor *fillColor = self.areaFillColorArr[i];
        [fillColor setFill];
        [path fill];
    }
}

-(void)setData:(nonnull NSArray<__kindof NSValue*>*)firstArr sDataArr:(nonnull NSArray<__kindof NSValue*>*)secondArr
{
    NSAssert(firstArr.count == secondArr.count, @"计算有误，传入的指标个数必须相同");
    [self.firstOrgDataArr removeAllObjects];
    [self.secondOrgDataArr removeAllObjects];
    [self.areaArr removeAllObjects];
    [self.areaFillColorArr removeAllObjects];
    [self.firstOrgDataArr addObjectsFromArray:firstArr];
    [self.secondOrgDataArr addObjectsFromArray:secondArr];
    if(firstArr.count < 2)
    {
        return;
    }
    NSValue *joinValue = [[self class] isJoinBetweenLine:[self.firstOrgDataArr[self.firstOrgDataArr.count - 2] CGPointValue]
                                                   EndPt:[self.firstOrgDataArr[self.firstOrgDataArr.count - 1] CGPointValue]
                                                 AndLine:[self.secondOrgDataArr[self.firstOrgDataArr.count - 2]CGPointValue]
                                                   EndPt:[self.secondOrgDataArr[self.secondOrgDataArr.count - 1] CGPointValue]];
    self.bLastLineJoin = nil != joinValue;
    
    //创建绘制区域
    NSInteger lastJoin = [self addAreaWith:firstArr SecondDataArr:secondArr LastJoin:nil];
    if(lastJoin > 0)
    {
        self.lastJoinPtIndex = lastJoin;
    }
}

-(void)updateLastData:(CGFloat)firstValue secondData:(CGFloat)secondValue
{
    if(0 == self.firstOrgDataArr.count)
    {
        return;
    }
    //更新最后一个数据
    CGFloat lastCenterX = [self.firstOrgDataArr.lastObject CGPointValue].x;
    [self.firstOrgDataArr removeLastObject];
    [self.secondOrgDataArr removeLastObject];
    [self.firstOrgDataArr addObject:[NSValue valueWithCGPoint:CGPointMake(lastCenterX, firstValue)]];
    [self.secondOrgDataArr addObject:[NSValue valueWithCGPoint:CGPointMake(lastCenterX, secondValue)]];
    
    NSValue *joinValue = [[self class] isJoinBetweenLine:[self.firstOrgDataArr[self.firstOrgDataArr.count - 2] CGPointValue]
                                                   EndPt:[self.firstOrgDataArr[self.firstOrgDataArr.count - 1] CGPointValue]
                                                 AndLine:[self.secondOrgDataArr[self.firstOrgDataArr.count - 2]CGPointValue]
                                                   EndPt:[self.secondOrgDataArr[self.secondOrgDataArr.count - 1] CGPointValue]];
    BOOL bJoin = nil != joinValue;
    if(self.bLastLineJoin == bJoin) //最后一个点的相交性不变
    {
        //仅仅修改最后一个绘制区域的绘制范围
        [self.areaArr removeLastObject];
        [self.areaFillColorArr removeLastObject];
        NSArray *firstArr = [self getLastAreaDataOfFirst];
        NSArray *sencondArr = [self getLastAreaDataOfSecond];
        [self addAreaWith:firstArr SecondDataArr:sencondArr LastJoin:self.lastJoinPt];
    }
    else
    {
        [self setData:[NSArray arrayWithArray:self.firstOrgDataArr] sDataArr:[NSArray arrayWithArray:self.secondOrgDataArr]];
    }
}

-(void)addNextData:(CGPoint)firstPt secondData:(CGPoint)secondPt
{
    [self.firstOrgDataArr addObject:[NSValue valueWithCGPoint:firstPt]];
    [self.secondOrgDataArr addObject:[NSValue valueWithCGPoint:secondPt]];
    
    NSValue *joinValue = [[self class] isJoinBetweenLine:[self.firstOrgDataArr[self.firstOrgDataArr.count - 2] CGPointValue]
                                                   EndPt:[self.firstOrgDataArr[self.firstOrgDataArr.count - 1] CGPointValue]
                                                 AndLine:[self.secondOrgDataArr[self.firstOrgDataArr.count - 2]CGPointValue]
                                                   EndPt:[self.secondOrgDataArr[self.secondOrgDataArr.count - 1] CGPointValue]];
    self.bLastLineJoin = nil != joinValue;

    
    //仅仅修改最后一个绘制区域的绘制范围
    [self.areaArr removeLastObject];
    [self.areaFillColorArr removeLastObject];
    NSArray *firstArr = [self getLastAreaDataOfFirst];
    NSArray *sencondArr = [self getLastAreaDataOfSecond];
    NSInteger lastJoin = [self addAreaWith:firstArr SecondDataArr:sencondArr LastJoin:self.lastJoinPt];
    if(lastJoin > 0)
    {
        self.lastJoinPtIndex += lastJoin;
    }
}

-(nonnull NSArray<__kindof NSValue*>*)getFirstDataArr
{
    return self.firstOrgDataArr;
}

-(nonnull NSArray<__kindof NSValue*>*)getSecondDataArr
{
    return self.secondOrgDataArr;
}

#pragma mark - private

//返回负值表示没有交点
-(NSInteger)addAreaWith:(NSArray<__kindof NSValue*>*)firstArr SecondDataArr:(NSArray<__kindof NSValue*>*)secondArr LastJoin:(NSValue*)joinValue
{
    NSInteger lastJoint = -1;
    NSMutableArray<__kindof NSValue*> *firstCurLineArr = [NSMutableArray array];
    NSMutableArray<__kindof NSValue*> *secondCurLineArr = [NSMutableArray array];
    [firstCurLineArr addObject:firstArr.firstObject];
    [secondCurLineArr addObject:secondArr.firstObject];
    NSValue *lastJoinValue = joinValue;
    for(NSUInteger i = 1; i < firstArr.count;i++)
    {
        CGPoint startPt0 = [firstCurLineArr.lastObject CGPointValue];
        CGPoint endPt0 = [firstArr[i] CGPointValue];
        CGPoint startPt1 = [secondCurLineArr.lastObject CGPointValue];
        CGPoint endPt1 = [secondArr[i] CGPointValue];
        NSValue *curJoinValue = [[self class] isJoinBetweenLine:startPt0 EndPt:endPt0 AndLine:startPt1 EndPt:endPt1];
        if(nil != curJoinValue)
        {
            lastJoint = i;
            UIBezierPath *path = nil;
            UIColor *color = nil;
            [[self class] createClosePathStartJoinPt:lastJoinValue endJoinPt:curJoinValue firstCurLine:firstCurLineArr secondCurLine:secondCurLineArr Path:&path fillColor:&color];
            [firstCurLineArr removeAllObjects];
            [secondCurLineArr removeAllObjects];
            lastJoinValue = curJoinValue;
            if(nil != path && nil != color)
            {
                [self.areaArr addObject:path];
                [self.areaFillColorArr addObject:color];
            }
        }
        [firstCurLineArr addObject:firstArr[i]];
        [secondCurLineArr addObject:secondArr[i]];
    }
    self.lastJoinPt = lastJoinValue;
    //最后一个绘制区域
    UIBezierPath *path = nil;
    UIColor *color = nil;
    [[self class] createClosePathStartJoinPt:lastJoinValue endJoinPt:nil firstCurLine:firstCurLineArr secondCurLine:secondCurLineArr Path:&path fillColor:&color];
    if(nil != path && nil != color)
    {
        [self.areaArr addObject:path];
        [self.areaFillColorArr addObject:color];
    }
    return lastJoint;
}

-(nonnull NSArray<__kindof NSValue*>*)getLastAreaDataOfFirst
{
    NSRange range = NSMakeRange(self.lastJoinPtIndex, self.firstOrgDataArr.count - self.lastJoinPtIndex);
    return [self.firstOrgDataArr subarrayWithRange:range];
}

-(nonnull NSArray<__kindof NSValue*>*)getLastAreaDataOfSecond
{
    NSRange range = NSMakeRange(self.lastJoinPtIndex, self.secondOrgDataArr.count - self.lastJoinPtIndex);
    return [self.secondOrgDataArr subarrayWithRange:range];
}

#pragma mark - getter and setter

@dynamic validCount;
-(NSUInteger)validCount
{
    return self.firstOrgDataArr.count;
}

#pragma mark - 计算公式

//返回值为nil表示不相交
+(nullable NSValue*)isJoinBetweenLine:(CGPoint)startPt1 EndPt:(CGPoint)endPt1 AndLine:(CGPoint)startPt2 EndPt:(CGPoint)endPt2
{
    /* 由点(x0,y0),(x1,y1)组成的直线为：（y0 - y1）* X + (x1 - x0) * Y + (x0 * y1 - x1 * y0) = 0;
     a0 * x + b0 * y + c0 = 0 , a1 * x + b1 * y + c1 = 0 两条直线的交点为：
     x = (b0 * c1 - b1 * c0) / (a0 * b1 - a1 * b0)
     y = (a1 * c0 - a0 * c1) / (a0 * b1 - a1 * b0)
     
     */
    //由于在本指标中，两条线段的X轴相同，所以可以先简单判断下Y轴之间是否有重合关系，如果没有，则一定没有交点
    //第一条线段的在Y轴上的范围
    BOOL bYJoin = YES;
    {
        CGFloat maxY1 = startPt1.y > endPt1.y ? startPt1.y : endPt1.y;
        CGFloat minY1 = startPt1.y < endPt1.y ? startPt1.y : endPt1.y;
        
        CGFloat maxY2 = startPt2.y > endPt2.y ? startPt2.y : endPt2.y;
        CGFloat minY2 = startPt2.y < endPt2.y ? startPt2.y : endPt2.y;
        
        if(minY1 > maxY2 || minY2 > maxY1)
        {
            bYJoin = NO;
        }
    }
    if(NO == bYJoin)
    {
        return nil;
    }


    
    //Y轴有相交点,此时可能是平行线或者重合
    CGFloat a0 = startPt1.y - endPt1.y;
    CGFloat b0 = endPt1.x - startPt1.x;
    
    CGFloat a1 = startPt2.y - endPt2.y;
    CGFloat b1 = endPt2.x - startPt2.x;

    CGFloat value = a0 * b1 - a1 * b0;
    if(0 == value)
    {
        //两条线段重合
        if(fabs(startPt1.y - startPt2.y) < 0.1)
        {
            CGPoint pt = CGPointMake((startPt1.x + endPt1.x)/2, (startPt1.y + endPt1.y)/2);
            return [NSValue valueWithCGPoint:pt];
        }
        return nil; //两条线段平行
    }
    CGFloat c0 = startPt1.x * endPt1.y - endPt1.x * startPt1.y;
    CGFloat c1 = startPt2.x * endPt2.y - endPt2.x * startPt2.y;
    CGFloat x = (b0 * c1 - b1 * c0) / value;
    
    //由于点的X轴坐标相同，所以只求一个就可以了
    CGFloat maxX = startPt1.x > endPt1.x ? startPt1.x : endPt1.x;
    CGFloat minX = startPt1.x < endPt1.x ? startPt1.x : endPt1.x;
    if(x > maxX || x < minX)
    {
        //直线相交，但是线段不相交
        return nil;
    }

    CGFloat y = (a1 * c0 - a0 * c1) / value;
    
    return [NSValue valueWithCGPoint:CGPointMake(x, y)];
}

+(void)createClosePathStartJoinPt:(nullable NSValue *)startJoinValue endJoinPt:(nullable NSValue *)endoinValue firstCurLine:(nonnull NSArray<__kindof NSValue*>*)firstCurLine secondCurLine:(nonnull NSArray<__kindof NSValue*>*)secondCurLine Path:(UIBezierPath**)outpath fillColor:(UIColor**)outfillColor;
{
    NSAssert(firstCurLine.count == secondCurLine.count, @"计算有误，不可能个数不一样");
    NSUInteger totalPtCount = firstCurLine.count * 2;
    if(nil != startJoinValue)
    {
        totalPtCount +=1;
    }
    if(nil != endoinValue)
    {
        totalPtCount += 1;
    }
    if(totalPtCount < 3)
    {
        //点的个数构成不了区域
        return;
    }
    
   
    //颜色
    {
        CGFloat y0Sum = 0;
        CGFloat y1Sum = 0;
        for(NSUInteger i = 0; i < firstCurLine.count;i++)
        {
            y0Sum += [firstCurLine[i] CGPointValue].y;
            y1Sum += [secondCurLine[i] CGPointValue].y;
        }
        *outfillColor = y0Sum > y1Sum ? K_riseColor :K_downColor;
    }
    
    //区域
    {
        NSMutableArray<__kindof NSValue*> *closeArea = [NSMutableArray array];
        
        if(nil != startJoinValue)
        {
            [closeArea addObject:startJoinValue];
        }
        [closeArea addObjectsFromArray:firstCurLine];
 
        if(nil != endoinValue)
        {
            [closeArea addObject:endoinValue];
        }
        for(NSUInteger i = secondCurLine.count;i > 0;i--)
        {
            NSValue *value = secondCurLine[i - 1];
            [closeArea addObject:value];
        }
        if(nil != startJoinValue)
        {
            [closeArea addObject:startJoinValue];
        }
        else
        {
            [closeArea addObject:firstCurLine.firstObject];
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[closeArea.firstObject CGPointValue]];
        for(NSUInteger i = 1; i< closeArea.count;i++)
        {
            CGPoint pt = [[closeArea objectAtIndex:i] CGPointValue];
            [path addLineToPoint:pt];
        }
        [path closePath];
        *outpath = path;
    }
    
}

@end
