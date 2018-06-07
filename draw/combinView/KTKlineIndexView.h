//
//  KTKlineIndexView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/12/28.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTKlineData;
@class KTIndexData;
@protocol KTKlineIndexViewDelegate;

typedef NS_ENUM(NSUInteger,KTKlineIndexViewType)
{
    KTKlineIndexViewTypeMainKline,  //主图
    KTTrendIndexViewTypeSubIndex, //副图
};

@interface KTKlineIndexView : UIView

@property(nonatomic,retain,nonnull) UIColor *riseColor; //上涨颜色,默认为红色
@property(nonatomic,retain,nonnull) UIColor *downColor; //下跌颜色,默认为绿色
@property(nonatomic,retain,nonnull) UIColor *custColor; //不涨不跌时的颜色,默认为黑色

@property(nonatomic) BOOL bDrawKline; //是否绘制K线，默认为YES
@property(nonatomic) NSUInteger startShowLocation; //开始显示的位置
@property(nonatomic) NSUInteger showKlineCount;  //K线显示的条数，默认为60条
@property(nonatomic,readonly) NSUInteger maxShowCount; //最大显示的K线条数
@property(nonatomic,readonly) NSUInteger drawKlineCount; //实际绘制的K线个数
@property(nonatomic,readonly) CGFloat candleWidth; //每根K线的绘制宽度
@property(nonatomic,readonly) CGFloat unitWidth; //每根K线的绘制宽度 + 间隔
@property(nonatomic,readonly) CGFloat klineIndexSpace; //K线分时之间的间隔(默认为20.00)

@property(nonatomic,copy,nonnull) NSString *mainIndexName;  //主图指标
@property(nonatomic,copy,nonnull) NSString *subIndexName; //副图指标


@property(nonatomic,weak,nullable) id<KTKlineIndexViewDelegate> delegate;

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

-(void)updateLastKlineIndexData;

-(void)addNextKlineIndexData; //会自动将起点修改

@end

@protocol KTKlineIndexViewDelegate <NSObject>

@required
-(nullable KTKlineData*)getKlineDataAtIndex:(NSUInteger) index; //index表示K线位置(已经加上了startShowPos)

-(nonnull NSArray<__kindof KTIndexData*> *)KTKlineIndexViewGetIndexData:(KTKlineIndexViewType)type;


-(CGFloat)KTKlineIndexViewGetMainViewMaxCoord:(BOOL)bmaxCoord; //获取主图的绘制范围

-(CGFloat)KTKlineIndexViewGetSubViewMaxCoord:(BOOL)bmaxCoord; //获取附图的绘制范围

@end