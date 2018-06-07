//
//  KTIScrollTrendIndexView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTIIndexViewDelegate.h"

@protocol  KTIScrollTrendIndexViewDelegate;

@interface KTIScrollTrendIndexView : UIControl

@property(nonatomic,retain,nullable) UIColor *trendViewColor; //分时区域背景颜色
@property(nonatomic) BOOL bshowAvgPriceLine; //是否显示均线
@property(nonatomic) NSUInteger showPointCount;  // 显示的点的个数
@property(nonatomic) NSUInteger distToEndWhenChanged; //距离终点有多少个点时，视图进行了移动，默认为0
@property(nonatomic) NSUInteger leftMoveCount; //数据到达右侧时，每次向左边移动多少个点，默认为30
@property(nonatomic) BOOL moveEnable; //分时是否可以移动,默认为YES
@property(nonatomic,weak,nullable) id<KTIScrollTrendIndexViewDelegate> delegate;
@property(nonatomic,readonly) NSUInteger beginIndex; //开始的起点
@property(nonatomic,readonly) BOOL bshowNewestData;//是否显示了最新的一条数据
@property(nonatomic,readonly) BOOL bDrawFinish; //所有的点已经绘制完成,此时结束绘制
@property(nonatomic,readonly) CGFloat trendMaxValue;
@property(nonatomic,readonly) CGFloat trendMinValue;

//设置分时可以显示的最大分时个数
-(void)setMaxShowTrendCount:(NSUInteger)maxShowTrendCount;

//清空分时
-(void)clear;

//刷新视图，重新计算
-(void)refresh;

//更新最后count分时点并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)update:(NSUInteger)count;

//添加count个分时点并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNext:(NSUInteger)count;

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos;

//获取第index个分时的中心点位置(页面上的绘制的个数，不需要加上起点)
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


@protocol  KTIScrollTrendIndexViewDelegate<KTIIndexViewDelegate>

//获取所有的分时数据的个数
-(NSUInteger)KTIScrollTrendIndexViewGetAllTrendDataCount;

@optional
//正在滑动时触发的事件
-(void)KTIScrollTrendIndexViewDidScrolling:(nonnull KTIScrollTrendIndexView*)scrollTrendView;

@end
