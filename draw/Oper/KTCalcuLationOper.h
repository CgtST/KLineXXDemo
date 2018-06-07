//
//  KTCalcuLationOper.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/14.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KTKlineData;
@class KTIndexOneNodeData;
@class KTTrendData;

//计算相关
@interface KTCalcuLationOper : NSObject

#pragma mark - 坐标转换

//将值转换为点,bounds底部表示最小值，头部表示最大值
+(CGFloat)valueToPixel:(CGFloat)fValue minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

//将点转换为值
+(CGFloat)pixelToValue:(CGFloat)location minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

#pragma mark - 查找

//通过二分法查找点xpos 在numsArr中的位置,pre表示查找精度
+(NSInteger)searchXpos:(CGFloat)xpos inArr:(nonnull NSArray<__kindof NSNumber*>*)numsArr precision:(CGFloat)pre;

#pragma mark - 中心点计算

//重新创建中心点 minDist（返回值）表示相邻两个点之间的最小距离
+(nonnull NSArray<__kindof NSNumber*>*)createCenterXWidth:(CGFloat)width Count:(NSUInteger)count  MinWidth:(nullable CGFloat*)minDist;

#pragma mark - 去掉重复的点

//去掉X轴方向上重复的点
+(nonnull NSArray<__kindof NSValue*>*)removeRepeatPointAtX:(nonnull NSArray<__kindof NSValue*>*) pointDatas;

#pragma mark - 获取最大值和最小值,第一个存放的是最小值，第二个存放的是最大值

//指标
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfNodeDatas:(nonnull NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*>*) valueArr;

//K线
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr;

//分时
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfTrendData:(nonnull NSArray<__kindof KTTrendData*>*) valueArr;

@end
