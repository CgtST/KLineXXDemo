//
//  KTStraightLineUnitDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"

//直线或者柱状图绘制
@interface KTStraightLineUnitDraw : NSObject<KTUnitDrawDelegate>

@property(nonatomic) CGFloat startyPos; //y轴上的起点,默认为0
@property(nonatomic) CGFloat endyPos; //y轴上的结束点,默认为0
@property(nonatomic) BOOL bValid;

@end
