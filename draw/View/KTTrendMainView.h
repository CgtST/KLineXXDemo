//
//  KTTrendMainView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/27.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTTrendData.h"

@protocol KTTrendMainViewDelegate;
//分时视图
@interface KTTrendMainView : UIView

@property(nonatomic,weak,nullable) id<KTTrendMainViewDelegate> trendDelegate;
@property(nonatomic,retain,nonnull) UIColor *trendLineColor; //分时线颜色,默认RGB(1,217,255)
@property(nonatomic,retain,nonnull) UIColor *avgLineColor; //均线颜色，默认为RGB(208,156,69)
@property(nonatomic,retain,nullable) UIColor *trendAreaLineColor; //分时区域的颜色，默认为nil表示不绘制;

@property(nonatomic,copy,nonnull) NSArray<__kindof KTTradeTime*>* tradeTimeArr; //交易时间

@property(nonatomic,readonly) CGFloat maxWidth; //每个点可以绘制的最大宽度(由tradeTimeArr和视图大小确定)
@property(nonatomic,readonly) NSUInteger drawCount;  //绘制的分时的个数
@property(nonatomic) NSUInteger rightDistSpace; //绘制时右侧的留白，默认为8

#pragma mark - 数据获取

-(nonnull NSArray<__kindof NSNumber*>*)getAllPriceValueXCenter;  //获取所有价格分量值的中心点(X轴方向)

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSInteger)getDataIndexByXPos:(CGFloat)xpos;

-(CGFloat)getCenterAtIndex:(NSUInteger)index; //获取中心点

-(int)getTrendTimeByXpos:(CGFloat)xpos;  //获取X轴坐标xpos在分时图中代表的分时时间，如果没有时间分量,则返回INT32_MIN

-(CGFloat)getLocationXByTime:(int)time; //计算时间在X轴上的位置

-(CGFloat)getPriceByYPos:(CGFloat)ypos; //计算ypos代表的价格

-(CGPoint)getLastValuePt; //获取最后一个值的绘制点

#pragma mark - 设置数据

-(void)clearAllDraw; //清除所有的绘制

-(void)refreshTrendDraw; //刷新分时绘制

//修改最后一个分时数据
-(void)modifyLastTrendData:(nonnull KTTrendData*)trendData;

//添加分时数据(不考虑分时数据是否正确)
-(void)addNextTrendData:(nonnull KTTrendData*)trendData;

@end

@protocol KTTrendMainViewDelegate <NSObject>

@required

-(nonnull NSArray<__kindof KTTrendData*>*)KTTrendMainViewGetAllTrendData;

-(CGFloat)KTTrendMainViewgetMinValue; //获取最小值

-(CGFloat)KTTrendMainViewgetMaxValue; //获取最大值

@end