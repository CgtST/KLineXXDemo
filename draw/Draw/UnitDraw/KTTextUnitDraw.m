//
//  KTTextUnitDraw.m
  
//
//  Created by 段鸿仁 on 16/4/22.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTTextUnitDraw.h"

@implementation KTTextUnitDraw

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
    }
    return self;
}

#pragma mark - KTUnitDrawDelegate

-(void)draw:(nonnull CGContextRef)context
{
    CGContextSaveGState(context);

    CGContextRestoreGState(context);
}

-(nonnull id<KTUnitDrawDelegate>)copyDraw
{
    KTTextUnitDraw *draw = [[KTTextUnitDraw alloc] init];
    draw.unitColor = self.unitColor;
    draw.unitWidth = self.unitWidth;
    draw.unitXcenter = self.unitXcenter;
    

    return draw;
    
}




@end
