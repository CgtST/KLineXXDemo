//
//  KTCircleUnitDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/5.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"

@interface KTCircleUnitDraw : NSObject<KTUnitDrawDelegate>

@property(nonatomic) CGFloat yPosCenter; //圆心在y方向上的值
@property(nonatomic) BOOL bValid;

@end
