//
//  KTKlineOper.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/14.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KTCandleUnitDraw;
@class KTKlineData;
@class KTKlineOperParam;

@interface KTKlineOper : NSObject

//创建KTCandleUnitDraw时优先从 oldUnitArr 获取已有的对象
+(nonnull NSArray<__kindof KTCandleUnitDraw*>*)createCandleUnitCount:(NSUInteger)count unitArr:(nullable NSArray<__kindof KTCandleUnitDraw*>*)oldUnitArr;

//设置绘制单元的值
+(void)setKlineDatas:(nonnull NSArray<__kindof KTKlineData*>*) klineDataArr toCandleUnits:(nonnull NSArray<__kindof KTCandleUnitDraw*>*)candleUnitArr CenterxArr:(nonnull NSArray<__kindof NSNumber*>*)centerXArr  Param:(nonnull KTKlineOperParam*)param;

//该函数是不考虑绘制范围的改变的情况下调用
+(nonnull NSArray<__kindof KTCandleUnitDraw*>*)addNextKlineData:(nonnull KTKlineData*)klineData toCandleUnits:(nonnull NSArray<__kindof KTCandleUnitDraw*>*)candleUnitArr CenterxArr:(nonnull NSArray<__kindof NSNumber*>*)centerXArr  Param:(nonnull KTKlineOperParam*)param;

//修改K线绘制的数据(修改最高，最低，颜色等，不修改绘制宽度,绘制中心点)
+(void)updateCandleUnit:(nonnull KTCandleUnitDraw*)draw data:(nonnull KTKlineData*)data Param :(nonnull KTKlineOperParam*)param;

@end

#pragma mark - KTKlineOperParam

@interface KTKlineOperParam : NSObject

@property(nonatomic,retain,nonnull) UIColor *riseColor;
@property(nonatomic,retain,nonnull) UIColor *downColor;
@property(nonatomic,retain,nonnull) UIColor *customColor;
@property(nonatomic) CGRect drawRect; //绘制范围
@property(nonatomic) CGFloat maxValue; //最大刻度
@property(nonatomic) CGFloat minValue; //最小刻度

@end