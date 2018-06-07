//
//  KTIKlineIndexView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTIIndexViewDelegate.h"

@interface KTIKlineIndexView : UIView

@property(nonatomic,readonly) CGFloat maxWidth; //K线柱子之间的最大间隔
@property(nonatomic) NSUInteger willShowCount; //希望显示多少根K线
@property(nonatomic,readonly) NSUInteger realDrawCount; //已经显示了多少根K线
@property(nonatomic,readonly) NSUInteger canShowMaxCount; //可以最多显示多少根K线
@property(nonatomic,weak,nullable) id<KTIIndexViewDelegate> delegate;
@property(nonatomic,readonly) CGFloat klineMaxValue;
@property(nonatomic,readonly) CGFloat klineMinValue;

#pragma mark - public

-(void)clearDraw;

-(void)refreshDraw; //刷新绘制

//更新最后几个的绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)updateLastDraw:(NSUInteger)count;

//添加几个绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNextDraw:(NSUInteger)addCount;

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos;

//获取第index个分时的中心点位置
-(CGFloat)getCenterAtIndex:(NSUInteger)index;

-(CGFloat)getLastKlineDrawXCenter;  //获取最后一根K线的绘制中心

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type;

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type;

@end
