//
//  KTKlineMainView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTKlineData;
@protocol KTKlineMainViewDelegate;

//K线主图
@interface KTKlineMainView : UIScrollView

@property(nonatomic,retain,nonnull) UIColor *riseColor; //上涨颜色,默认为红色
@property(nonatomic,retain,nonnull) UIColor *downColor; //下跌颜色,默认为绿色
@property(nonatomic,retain,nonnull) UIColor *custColor; //不涨不跌时的颜色,默认为黑色

@property(nonatomic,readonly) NSUInteger maxShowKlineCount; //该视图显示的最大K线数量（用于保证图K线的显示质量）
@property(nonatomic) NSUInteger startShowPos; //开始显示的位置
@property(nonatomic) NSUInteger showCount; //该视图可以显示的K线条数
@property(nonatomic,readonly) CGFloat candleWidth; //每根K线的绘制宽度
@property(nonatomic,readonly) CGFloat unitWidth; //每根K线的绘制所占用的屏幕宽度
@property(nonatomic,readonly) NSUInteger curDrawCount;  //绘制的K线个数
@property(nonatomic) NSUInteger rightDistSpace; //绘制时右侧的留白，默认为8
@property(nonatomic) BOOL bDrawKline; //是否绘制K线，默认为YES

@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof NSNumber*>* klineCenterxPos;

@property(nonatomic,weak,nullable) id<KTKlineMainViewDelegate> klineDelegate;


#pragma mark - 数据获取

//获取视图中K线数据对应的柱子, NSNotFound表示没有对应的柱子
-(NSInteger)getDrawDataIndexByXPos:(CGFloat)xpos;

-(CGFloat)getLastKlineDrawCenter;  //获取最后一根K线的绘制中心

#pragma mark - K线相关

-(void)clearAllDraw;

//更新绘制
-(void)refreshKlineDraw;

//修改最后一根K线的数据,如果返回NO,表示修改失败,此时最高价或者最低价发生改变
-(BOOL)updateLastKlineData:(nonnull KTKlineData *)lastKineData ;

//增加一根K线数据到最后,如果返回NO,表示修改失败,此时最高价或者最低价发生改变
-(BOOL)addNextKlineData:(nonnull KTKlineData *)lastKineData;



@end

#pragma mark - KTKlineMainViewDelegate

@protocol KTKlineMainViewDelegate <NSObject>

@required

//index表示K线位置(已经加上了startShowPos)
-(nullable KTKlineData*)getKlineDataAtIndex:(NSUInteger) index;

//改变显示的最小价格范围
-(CGFloat)KTKlineMainViewGetMinPrice:(CGFloat)lastMinValue;

//改变显示的最大价格范围
-(CGFloat)KTKlineMainViewGetMaxPrice:(CGFloat)lastMaxValue;

@end

