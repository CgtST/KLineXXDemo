//
//  KTKlineDataOper.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KTKlineData.h"
#import "KTIndexData.h"
#import "KTTrendData.h"

@interface KTKlineDataOper : NSObject


//获取K线中最小值和最大值所在的位置，第一个存放的是最小值位置，第二个存放的是最大值位置
+(nonnull NSArray<__kindof NSNumber*>*)getPosOfMinMaxValueInKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr;

#pragma mark - 获取最大值和最小值

//第一个存放的是最小值，第二个存放的是最大值
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue:(nonnull NSArray<__kindof NSNumber*>*) valueArr;

//指标
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueIn2DimArr:(nonnull NSArray<__kindof KTIndexOneNodeData*>*) valueArr;

//K线
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr;

+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfKlineData:(nonnull NSArray<__kindof KTKlineData*>*) valueArr startPos:(NSUInteger)start count:(NSUInteger)count;

//分时
+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueOfTrendData:(nonnull NSArray<__kindof KTTrendData*>*) valueArr;

@end
