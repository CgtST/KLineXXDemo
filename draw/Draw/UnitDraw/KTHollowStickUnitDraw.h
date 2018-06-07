//
//  KTHollowStickUnitDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"

//空心柱子的画法
@interface KTHollowStickUnitDraw : NSObject<KTUnitDrawDelegate>

@property(nonatomic) CGFloat startyPos; //y轴上的起点,默认为0
@property(nonatomic) CGFloat endyPos; //y轴上的结束点,默认为0
@property(nonatomic) BOOL bValid;

@end
