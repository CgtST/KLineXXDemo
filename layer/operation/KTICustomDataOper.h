//
//  KTICustomDataOper.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/21.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KTINodeData;
@class KTIIndexData;
//数据操作类
@interface KTICustomDataOper : NSObject

+(CGFloat)mainScreenScale;

+(nonnull dispatch_queue_t)shareQueue;

#pragma mark - 坐标转换

//对节点数据进行转换,nodeData为合法值
+(nonnull NSArray<__kindof NSNumber*>*)values2DrawPoints:(nonnull KTINodeData*)nodeData MinValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

//对线的数据进行转换
+(nonnull NSArray<__kindof NSNumber*>*)values2LineDrawPoints:(nonnull KTIIndexData*)klineData MinValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

//是否为合法值
+(BOOL)isValidValue:(nonnull NSNumber*)number;

//将值转换为点,bounds底部表示最小值，头部表示最大值
+(CGFloat)valueToPixel:(CGFloat)fValue minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

//将点转换为值
+(CGFloat)pixelToValue:(CGFloat)location minValue:(CGFloat)minvalue MaxValue:(CGFloat)maxValue Rect:(CGRect)bounds;

#pragma mark - 查找

//通过二分法查找点xpos 在numsArr中的位置,pre表示查找精度
+(NSInteger)searchXpos:(CGFloat)xpos inArr:(nonnull NSArray<__kindof NSNumber*>*)numsArr precision:(CGFloat)pre;

#pragma mark - 中心点计算

//重新创建中心点 minDist（返回值）表示相邻两个不同的点之间的最小距离
+(nonnull NSArray<__kindof NSNumber*>*)createCenterXWidth:(CGFloat)width Count:(NSUInteger)count  MinWidth:(nullable CGFloat*)minDist MaxWidth:(nullable CGFloat*)maxDist;

//用给定的中心点重新计算中心点，并且每两个不同的中心点之间的距离最小为minDist。返回的个数与传入的个数相同，并且返回数组中的值是传入值得子集
+(nonnull NSArray<__kindof NSNumber*>*)displayCenters:(nonnull NSArray<__kindof NSNumber*>*)oldCenter WithMinDist:(CGFloat)minDist;

#pragma mark - 去掉重复的点

//去掉X轴方向上重复的点
+(nonnull NSArray<__kindof NSValue*>*)removeRepeatPointAtX:(nonnull NSArray<__kindof NSValue*>*) pointDatas;


#pragma mark - 获取指标数据中的最大值和最小值

+(void)getMinMaxValueOfNodeArr:(nonnull NSArray<__kindof KTINodeData*>*)values MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue;

+(void)getMinMaxValueOfIndex:(nonnull KTIIndexData*)indexData MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue;

+(void)getMinMaxValueOfIndexArr:(nonnull NSArray<__kindof KTIIndexData*>*)indexDataArr MinValue:(nullable CGFloat*)minValue MaxValue:(nullable CGFloat*)maxValue;

@end
