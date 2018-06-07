//
//  KTITrendDrawView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIBaseIndexDrawView.h"

//分时绘制，默认第一条是价格线，第二条是均线(如果有的话)
@interface KTITrendDrawView : KTIBaseIndexDrawView

@property(nonatomic,readonly) CGFloat lastYpos; //最后一个点的Y坐标
@property(nonatomic,readonly) NSUInteger curDrawPointCount;  //当前绘制的点的个数
@property(nonatomic,retain,nullable) UIColor *upAreaBackGround; //最新价格上面一部分的背景颜色

//如果越界，返回-1
-(CGFloat)getPriceDrawYposAtIndex:(NSUInteger)index;

@end
