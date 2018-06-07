//
//  KTTrendIndexView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/12/22.
//  Copyright © 2015年 zscf. All rights reserved.
//

/*
#import <UIKit/UIKit.h>

@class KTTrendData;
@class KTIndexOneNodeData;
@class KTIndexStyle;
@class KTTradeTime;
@protocol KTTrendIndexViewDelegate;

typedef NS_ENUM(NSUInteger,KTTrendIndexViewRangeType)
{
    KTTrendIndexViewRangeTypeTrend,
    KTTrendIndexViewRangeTypeSubIndex,
};

//分时指标视图
@interface KTTrendIndexView : UIView

@property(nonatomic,retain,nonnull) UIColor *riseColor; //上涨颜色,默认为红色
@property(nonatomic,retain,nonnull) UIColor *downColor; //下跌颜色,默认为绿色
@property(nonatomic) CGFloat lastClosePrice; //昨收价

@property(nonatomic,copy,nonnull) NSString *subIndexName; //副图指标
@property(nonatomic,weak) id<KTTrendIndexViewDelegate> delegate;
@property(nonatomic,readonly) CGFloat mainViewMaxValue; //主图最大值
@property(nonatomic,readonly) CGFloat mainViewMinValue; //主图最小值
@property(nonatomic,readonly) CGFloat subViewMaxValue;  //副图最大值
@property(nonatomic,readonly) CGFloat subViewMinValue; //副图最小值
@property(nonatomic,readonly) int lastTrendTime;  //最后一根分时数据的时间

#pragma mark - 对指标，分时接口的封装

-(void)setTradeTimes:(nonnull NSArray<__kindof KTTradeTime*>*)tradeTimeArr;

-(int)getTrendTimeByXpos:(CGFloat)xpos;  //获取X轴坐标xpos在分时图中代表的分时时间，如果没有时间分量,则返回INT32_MIN

-(CGFloat)getLocationXByTime:(int)time; //计算时间在X轴上的位置

-(CGPoint)getLastValuePt; //获取最后一个值的绘制点

-(CGFloat)getTrendPriceByYPos:(CGFloat)ypos; //计算ypos代表的价格

-(CGFloat)getsubIndexValueByYPos:(CGFloat)ypos; //计算ypos代表的值

#pragma mark - 布局

-(CGRect)trendFrame; //分时绘制范围

-(CGRect)indexFrame; //指标绘制范围

-(void)settrendIndexBorderWidth:(CGFloat)borderWidth;

-(void)settrendIndexBorderColor:(nonnull UIColor*)borderColor;

#pragma mark - 分时指标重绘

-(void)clearDraw; //清除绘制

-(void)refreshAllTrendAndIndexDraw; //刷新整个视图

-(void)updateLastTrendIndexDataCount:(NSUInteger)count; //更新最后几个分时指标数据

-(void)addNextTrendIndexData:(NSUInteger)count; //添加几个分时指标数据

@end

@protocol KTTrendIndexViewDelegate <NSObject>

@required

-(nullable NSArray<__kindof KTTrendData*> *)KTTrendIndexViewGetAllTrendData; //获取所有的分时数据

-(NSUInteger)KTTrendIndexViewSubIndexCount; //副图指标的个数

-(nonnull KTIndexStyle*)KTTrendIndexViewSubIndexStyleAtIndex:(NSUInteger)index;  //获取副图的指标绘制样式

-(nonnull NSArray<__kindof KTIndexOneNodeData*>*)KTTrendIndexViewGetSubIndexAtIndex:(NSUInteger)index;  //获取副图指标数据

@optional

//修改最大值
-(CGFloat)KTTrendIndexViewModifyMaxCoord:(CGFloat)maxValue Type:(KTTrendIndexViewRangeType)type;

//修改最小值
-(CGFloat)KTTrendIndexViewModifyMinCoord:(CGFloat)minValue Type:(KTTrendIndexViewRangeType)type;

@end
*/