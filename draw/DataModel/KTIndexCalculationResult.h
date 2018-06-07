//
//  KTIndexCalculationResult.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTIndexData.h"

//指标计算结果
@interface KTIndexCalculationResult : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString* indexName; //指标名称
@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof KTIndexData*> *indexDataList; //指标结果集

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

-(nonnull NSArray<__kindof NSString*>*)getAllIndexName; //获取指标名称

-(nonnull NSArray<__kindof KTIndexStyle*>*)getAllDrawStyle; //获取所有的绘制类型

-(nonnull NSArray<__kindof KTIndexOneNodeData*>*)getAllNodeDataAt:(NSUInteger)index;

//将indexReult的最后count数据添加到当前指标集
-(void)addIndexDataByIndex:(nonnull KTIndexCalculationResult*)indexReult Count:(NSUInteger)count;

//将indexReult的最后一个数据更新到当前指标集
-(void)modifyLastOrgIndexDataByIndex:(nonnull KTIndexCalculationResult*)indexReult;

//获取最大值和最小值
-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue;

-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueStart:(NSUInteger)start Count:(NSUInteger)count;


@end
