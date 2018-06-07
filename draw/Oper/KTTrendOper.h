//
//  KTTrendOper.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KTTrendData;
@class KTTradeTime;
@class KTTrendOperParam;
@class KTCurveIndexDraw;
@interface KTTrendOper : NSObject

//传入绘制数组的第一个是分时，第二个是均线
+(void)setTrendData:(nonnull NSArray<__kindof KTTrendData*>*)trendDataArr toCuverDraw:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr  XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTTrendOperParam*)param;

//传入绘制数组的第一个是分时，第二个是均线(不考虑绘制范围的改变)
+(void)updateLastPoint:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr trendData:(nonnull KTTrendData*)trenddata Param:(nonnull KTTrendOperParam*)param ;

//传入绘制数组的第一个是分时，第二个是均线(不考虑绘制范围的改变)
+(void)addNextPoint:(nonnull NSArray<__kindof KTCurveIndexDraw*>*)curDrawArr trendData:(nonnull NSArray<__kindof KTTrendData*>*)addTrendDataArr  XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTTrendOperParam*)param ;

#pragma mark - 时间相关

//获取时间（分钟数）所在的位置
+(NSUInteger)indexOfTime:(int)time tradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr;

//获取时间数组中对应位置的时间值（分钟数）
+(int)getTrendTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr AtIndex:(NSUInteger)index;

//是否是开盘第一笔数据
+(BOOL)isOpenTimeData:(int)time inTradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr;

//时间是否为交易时间
+(BOOL)isTime:(int)time inTradeTime:(nonnull NSArray<__kindof KTTradeTime*>*) tradeTimeArr;

//获取时间中时间单元的个数（分钟数）
+(NSUInteger)getTimeWeightCount:(nonnull NSArray<__kindof KTTradeTime*>*)tradeTimeArr;

@end

#pragma mark - KTTrendOperParam

@interface KTTrendOperParam : NSObject

@property(nonatomic) CGRect drawRect; //绘制范围
@property(nonatomic) CGFloat maxValue; //最大刻度
@property(nonatomic) CGFloat minValue; //最小刻度
@property(nonatomic,retain,nonnull)  NSArray<__kindof KTTradeTime*>* tradeTimeArr;
@end