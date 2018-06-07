//
//  KTIndexCalculationInput.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTKlineData.h"

typedef NS_ENUM(NSUInteger ,KTKLineType)
{
    KTKLineTypeOneMinute = 1, //1分钟
    KTKLineTypeThreeMinute = 2, //3分钟
    KTKLineTypeFiveMinute = 3, //5分钟
    KTKLineTypeFifteenMinute = 4, //15分钟
    KTKLineTypeThirtyMinute = 5, //30分钟
    KTKLineTypeSixtyMinute = 6, //60分钟
    KTKLineTypeDay = 7, //日线
    KTKLineTypeWeek = 8, //周线
    KTKLineTypeMonth = 9, //月线
    KTKLineTypeMutiMinute = 10, //多分钟线
    KTKLineTypeMutiDay = 11 //多日线
};

//指标请求
@interface KTIndexCalculationInput : NSObject

@property(nonatomic,retain,nonnull) NSString* indexName; //指标名称
@property(nonatomic) KTKLineType klineType;

@property(nonatomic,retain,nonnull) NSArray<__kindof KTKlineData*> *klineDetailDatas; //K线明细

-(nonnull NSDictionary*)toDictionary;

@end
