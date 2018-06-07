//
//  KTITextUnitDraw.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/4/25.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTITextUnitDraw.h"

@implementation KTITextUnitDraw

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
}

-(void)setExtrendData:(nonnull NSData*) extrendData //设置额外绘制数据
{
    
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    KTITextUnitDraw *unitDraw = (KTITextUnitDraw*)[super copyWithZone:zone];
    return unitDraw;
}


@end
