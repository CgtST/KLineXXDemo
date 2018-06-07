//
//  KTIndexStyle.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KT_INDEX_INVALID_VALUE  (UINT32_MAX / 4)   //定义无效值（既如果大于这个值，则为无效）

typedef NS_ENUM(NSUInteger , KTIndexDrawType)
{
    KTIndexDrawTypeCurve, //绘制曲线
    KTIndexDrawTypeVol = 1,  //成交量
    KTIndexDrawTypeCircle = 3, //画点
    KTIndexDrawTypeColorStick = 6,  //直线或实心柱状图
    KTIndexDrawTypeHollowStick = 11, //空心柱子的画法
    KTIndexDrawTypeIcon = 12 , //特殊图形的绘制
    KTIndexDrawTypeText = 13 , //文字的绘制
    KTIndexDrawTypeAreaSep = 20,
    
};

//指标类型
@interface KTIndexStyle : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString *indexLineName; //指标线名称
@property(nonatomic,readonly) KTIndexDrawType indexDrawType;
@property(nonatomic,readonly) NSInteger klineDrawStype; //指标线绘制样式 (drawkline2时绘制K线的方式 0-普通空心阳 1-实心阳 2-美国线)
@property(nonatomic) CGFloat nodeWidth; //节点指标的宽度
@property(nonatomic) NSUInteger width;
@property(nonatomic,retain,nullable) UIColor *indexColor; //指标的绘制颜色
@property(nonatomic,readonly) BOOL buserRiseDownColor; //是否使用涨跌颜色计算
@property(nonatomic) BOOL bshow;

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

@end

#pragma mark - KTIndexOneNodeData

//指标一个节点的数据
@interface KTIndexOneNodeData : NSObject

@property(nonatomic,readonly) NSUInteger nodeDataCount;
@property(nonatomic,readonly,retain,nonnull) NSNumber* firstData;
@property(nonatomic,readonly,retain,nullable) NSNumber* secondData;
@property(nonatomic,readonly) CGFloat minValue;  //没有考虑无效值
@property(nonatomic,readonly) CGFloat maxValue;  //没有考虑无效值
@property(nonatomic,readonly,copy,nullable) NSString *extraData;//额外数据

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic Count:(NSUInteger) dataCount;

-(nonnull NSArray<__kindof NSNumber*>*)getAllData;


@end
