//
//  KTKlineIndexsView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/2/1.
//  Copyright © 2016年 zscf. All rights reserved.
//
/*
#import <UIKit/UIKit.h>

@class KTKlineData;
@class KTIndexOneNodeData;
@class KTIndexStyle;
@protocol KTKlineIndexsViewDelegate;

typedef NS_ENUM(NSUInteger,KTKlineIndexsViewType)
{
    KTKlineIndexsViewTypeMainKline,  //主图
    KTTrendIndexsViewTypeSubIndex, //副图
};

@interface KTKlineIndexsView : UIView

@property(nonatomic,retain,nonnull) UIColor *riseColor; //上涨颜色,默认为红色
@property(nonatomic,retain,nonnull) UIColor *downColor; //下跌颜色,默认为绿色
@property(nonatomic,retain,nonnull) UIColor *custColor; //不涨不跌时的颜色,默认为黑色

@property(nonatomic) NSUInteger startShowLocation; //开始显示的位置
@property(nonatomic) NSUInteger showKlineCount;  //K线显示的条数，默认为60条
@property(nonatomic,readonly) NSUInteger maxShowCount; //最大显示的K线条数
@property(nonatomic,readonly) NSUInteger drawKlineCount; //实际绘制的K线个数
@property(nonatomic,readonly) CGFloat candleWidth; //每根K线的绘制宽度
@property(nonatomic,readonly) CGFloat klineIndexSpace; //K线分时之间的间隔(默认为20.00)

@property(nonatomic,copy,nonnull) NSString *mainIndexName;  //主图指标
@property(nonatomic,copy,nonnull) NSString *subIndexName; //副图指标


@property(nonatomic,weak) id<KTKlineIndexsViewDelegate> delegate;

#pragma mark - 对指标，K线接口的封装

//获取视图中K线数据对应的柱子, NSNotFound表示没有对应的柱子
-(NSInteger)getDrawDataIndexByXPos:(CGFloat)xpos;

-(CGFloat)getCandleCenterAt:(NSUInteger)index;

-(CGFloat)getLastKlineDrawCenter;  //获取最后一根K线的绘制中心

-(CGFloat)getMainPriceByYpos:(CGFloat)ypos; //获取价格分量


-(CGFloat)getsubIndexValueByYPos:(CGFloat)ypos; //计算ypos代表的值

#pragma mark - 布局

-(CGRect)klineFrame; //K线绘制范围

-(CGRect)indexFrame; //指标绘制范围

-(void)setklineindexBorderWidth:(CGFloat)borderWidth;

-(void)setklineindexBorderColor:(nonnull UIColor*)borderColor;

#pragma mark - K指标重绘

-(void)clearDraw; //清除绘制

-(void)refreshAllKlineAndIndexDraw; //刷新整个视图

-(void)updateLastKlineIndexDataCount:(NSUInteger)count; //更新最后几个K线指标数据

-(void)addNextKlineIndexDataCount:(NSUInteger)count; //更新最后几个K线指标数据，会自动将起点修改

@end

@protocol KTKlineIndexsViewDelegate <NSObject>

@required
//获取所有的K线数据
-(nonnull NSArray<__kindof KTKlineData*>*)KTKlineIndexsGetAllKlineData;

-(NSUInteger)KTKlineIndexsViewIndexCount:(KTKlineIndexsViewType)type; //指标的个数

-(nonnull KTIndexStyle*)KTKlineIndexsViewType:(KTKlineIndexsViewType)type IndexStyleAt:(NSUInteger)index ;  //获取指标绘制样式

//获取指标数据,styleIndex表示第几个指标
-(nonnull NSArray<__kindof KTIndexOneNodeData*>*)KTKlineIndexsViewType:(KTKlineIndexsViewType)type IndexsDataArrAt:(NSUInteger)styleIndex;

@optional

//修改最大值
-(CGFloat)KTTrendIndexViewModifyMaxCoord:(CGFloat)maxValue Type:(KTKlineIndexsViewType)type;

//修改最小值
-(CGFloat)KTTrendIndexViewModifyMinCoord:(CGFloat)minValue Type:(KTKlineIndexsViewType)type;

@end
*/