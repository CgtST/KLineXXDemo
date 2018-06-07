//
//  KTITrendIndexView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTIIndexViewDelegate.h"

@interface KTITrendIndexView : UIView

@property(nonatomic,retain,nullable) UIColor *trendViewUpColor; //分时区域上部分的背景颜色
@property(nonatomic,retain,nullable) UIColor *trendViewColor; //分时区域背景颜色
@property(nonatomic,readonly) CGFloat maxWidth; //分时点之间的最大间隔
@property(nonatomic) BOOL bshowAvgPriceLine; //是否显示均线,默认为NO
@property(nonatomic) NSUInteger showPointCount;  // 显示的点的个数
@property(nonatomic,readonly) NSUInteger realDrawCount; //已经绘制了的个数
@property(nonatomic,weak,nullable) id<KTIIndexViewDelegate> delegate;
@property(nonatomic,readonly) CGFloat trendMaxValue;
@property(nonatomic,readonly) CGFloat trendMinValue;

#pragma mark - public

//清空视图
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

//如果越界，返回-1
-(CGFloat)getPriceDrawYposAtIndex:(NSUInteger)index;

//获取最后一个绘制的中心点
-(CGPoint)getLastPriceDrawCenter;

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type;

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type;


@end
