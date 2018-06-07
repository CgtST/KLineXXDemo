//
//  KTCandleUnitDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"

//K线单个柱子的画法（目前只支持一种画法）
@interface KTCandleUnitDraw : NSObject<KTUnitDrawDelegate>

@property(nonatomic) CGFloat fHighPriceYpos; //最高价所在点,默认为0
@property(nonatomic) CGFloat fLowPriceYpos; //最低价所在点,默认为0
@property(nonatomic) CGFloat fOpenPriceYpos; //开盘价所在点,默认为0
@property(nonatomic) CGFloat fClosePriceYpos; //收盘价所在点,默认为0

@end

