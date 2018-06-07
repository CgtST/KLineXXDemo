//
//  KTIIconUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/4/25.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIIconUnitDraw.h"

@implementation KTIIconUnitDraw

-(instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        
    }
    return self;
}

#pragma mark - override

-(void)draw:(nonnull CGContextRef)context Center:(CGFloat)xCenter;
{
    CGContextSaveGState(context);
    CGContextRestoreGState(context);
}

-(void)resetdata
{
    [super resetdata];
}


-(void)setDrawData:(nonnull NSArray<__kindof NSNumber*>*) nodeDrawData  //设置绘制数据
{
    if(nodeDrawData.count < 1)
    {
        NSAssert(false, @"KTIIconUnitDraw的数据有问题");
        return;
    }
}

-(void)setExtrendData:(nonnull NSData*) extrendData //设置额外绘制数据
{
    
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTIIconUnitDraw *unitDraw = (KTIIconUnitDraw*)[super copyWithZone:zone];
    return unitDraw;
}


@end
