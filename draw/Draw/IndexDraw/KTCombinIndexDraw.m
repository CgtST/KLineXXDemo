//
//  KTCombinIndexDraw.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/28.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTCombinIndexDraw.h"

@interface KTCombinIndexDraw ()

@property(nonatomic,retain,nonnull) NSMutableArray<__kindof id<KTUnitDrawDelegate>> *muintDrawArr;

@end

@implementation KTCombinIndexDraw

-(instancetype) init
{
    self = [super init];
    if(nil != self)
    {
        self.muintDrawArr = [NSMutableArray array];
        self.bshow = YES;
    }
    return self;
}

#pragma mark - public

-(void)draw:(nonnull CGContextRef)context
{
    if(NO == self.bshow)
    {
        return;
    }
    for(id<KTUnitDrawDelegate> draw in self.muintDrawArr)
    {
        [draw draw:context];
    }
}

-(void)setUnitDrawArr:(nonnull NSArray<__kindof id<KTUnitDrawDelegate>>*) drawArr
{
    self.muintDrawArr = [NSMutableArray arrayWithArray:drawArr];
}

-(void)addUnitDraw:(nonnull id<KTUnitDrawDelegate>)draw
{
    draw.unitWidth = self.unitWidth;
    [self.muintDrawArr addObject:draw];
}

-(nullable id<KTUnitDrawDelegate>) getUnitAt:(NSUInteger)index
{
    if(index >= self.drawCount)
    {
        return nil;
    }
    return [self.muintDrawArr objectAtIndex:index];
}

-(nullable id<KTUnitDrawDelegate>) removeFirstDrawUnit
{
    if(0 == self.drawCount)
    {
        return nil;
    }
    id<KTUnitDrawDelegate> draw = self.muintDrawArr.firstObject;
    [self.muintDrawArr removeObjectAtIndex:0];
    return draw;
}

-(nullable id<KTUnitDrawDelegate>) removeLastDrawUnit
{
    if(0 == self.drawCount)
    {
        return nil;
    }
    id<KTUnitDrawDelegate> draw = self.muintDrawArr.lastObject;
    [self.muintDrawArr removeLastObject];
    return draw;
}

-(void)removeAllDrawUnit
{
    [self.muintDrawArr removeAllObjects];
}

-(void)mofiyColor:(nonnull UIColor*)color AtIndex:(NSUInteger) index
{
    if(index >= self.muintDrawArr.count)
    {
        return;
    }
    id<KTUnitDrawDelegate> uint = [self.muintDrawArr objectAtIndex:index];
    [uint setUnitColor:color];
}

-(nullable UIColor*) getColorAtUnitIndex:(NSUInteger) index //获取指定单元的绘制颜色
{
    if(index >= self.muintDrawArr.count)
    {
        return nil;
    }
    id<KTUnitDrawDelegate> uint = [self.muintDrawArr objectAtIndex:index];
 
    return uint.unitColor;
}

#pragma mark - 重写setter和getter函数

@dynamic drawCount;
-(NSUInteger)drawCount
{
    return self.muintDrawArr.count;
}

-(void)setUnitWidth:(CGFloat)unitWidth
{
    _unitWidth = unitWidth;
    for(id<KTUnitDrawDelegate> draw in self.muintDrawArr)
    {
        draw.unitWidth = unitWidth;
    }
}

@synthesize bshow = _bshow;


@end
