//
//  KTIKlineDrawView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIBaseIndexDrawView.h"

@interface KTIKlineDrawView : KTIBaseIndexDrawView

@property(nonatomic,readonly) NSUInteger curKlineDrawCount;  //当前绘制的K线个数

@property(nonatomic) BOOL bshow; //非主图叠加指标时，不绘制K线
@property(nonatomic) CGFloat unitCellWidth; //每根K线的绘制所占用的屏幕宽度

@end
