//
//  KTIScrollKlineIndexView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTIIndexViewDelegate.h"

@protocol  KTIScrollKlineIndexViewDelegate;

@interface KTIScrollKlineIndexView : UIControl

@property(nonatomic) NSUInteger showKlineCount;  //K线显示的条数，默认为60条
@property(nonatomic) NSUInteger minShowCount; //缩放时显示的最少K线个数，默认为1
@property(nonatomic,weak,nullable) id<KTIScrollKlineIndexViewDelegate> delegate;
@property(nonatomic,readonly) BOOL bshowNewestData;//是否显示了最新的一条数据
@property(nonatomic,readonly) NSUInteger realDrawCount; //已经显示了多少根K线
@property(nonatomic,readonly) NSUInteger canShowMaxCount; //可以最多显示多少根K线
@property(nonatomic,readonly) NSUInteger beginIndex; //开始绘制的点
@property(nonatomic,readonly) NSUInteger curTotalDataCountForShow; //当前有多少条数据可以用于显示
@property(nonatomic) BOOL zoomEnable; //K线是否可以缩放,默认为YES
@property(nonatomic) BOOL moveEnable; //K线是否可以移动,默认为YES
@property(nonatomic,readonly) CGFloat klineMaxValue;
@property(nonatomic,readonly) CGFloat klineMinValue;

//更新显示的数据的条数
-(void)updateTotalShowCount:(NSUInteger)count;

//会重新刷新视图
-(void)scrollToIndex:(NSUInteger)index animated:(BOOL)banimated;

//清空K线
-(void)clear;

//刷新视图，重新计算
-(void)refresh;

//更新最后count根K线并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)update:(NSUInteger)count;

//添加count根K线并刷新绘制,返回值表示最大值和最小值是否发生了改变
-(BOOL)addNext:(NSUInteger)count;

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos;

//获取第indexK线的中心点位置(页面上的绘制的个数，不需要加上起点)
-(CGFloat)getCenterAtIndex:(NSUInteger)index;

//获取最后一根K线的绘制中心;
-(CGFloat)getLastKlineDrawXCenter;

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos ViewType:(KTIViewType)type;

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData ViewType:(KTIViewType)type;

@end

@protocol  KTIScrollKlineIndexViewDelegate<KTIIndexViewDelegate>

@required
//通过位置获取时间
-(UInt64)KTIScrollKlineIndexViewGetTheTimerOfIndex:(NSUInteger)index;

//通过时间获取位置
-(NSUInteger)KTIScrollKlineIndexViewGetIndexOfTime:(UInt64)time;

@optional

//每次滑动结束时，会调用该函数
-(void)KTIScrollKlineIndexViewDidEndScrollToStart:(NSUInteger)index;

//正在滑动时触发的事件
-(void)KTIScrollKlineIndexViewDidScrolling:(nonnull KTIScrollKlineIndexView*)scrollKlineView;

@end
