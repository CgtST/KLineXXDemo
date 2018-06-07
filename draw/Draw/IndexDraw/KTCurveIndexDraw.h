//
//  KTCurveIndexDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KTUnitDrawDelegate.h"

//曲线，折线(直线)的绘制
@interface KTCurveIndexDraw : NSObject<KTIndexDelegate>

@property(nonatomic) CGFloat lineWidth;
@property(nonatomic,retain,nonnull) UIColor *lineColor; //默认为yellowColor
@property(nonatomic,retain,nonnull) NSArray<__kindof NSValue*> *pointValues; //绘制的点
@property(nonatomic) NSUInteger startPos; //曲线第一个点所在的位置，默认为0
@property(nonatomic) BOOL bRemoveRepeatPoint; //是否移除重复的点(默认为NO)

@end
