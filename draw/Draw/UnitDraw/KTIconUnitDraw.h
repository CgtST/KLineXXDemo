//
//  KTIconUnitDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/4/22.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"

@interface KTIconUnitDraw : NSObject<KTUnitDrawDelegate>

@property(nonatomic) CGFloat yPosCenter; //圆心在y方向上的值
@property(nonatomic) BOOL bValid;

@end
