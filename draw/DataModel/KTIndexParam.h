//
//  KTIndexParam.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>

//指标参数
@interface KTIndexParam : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString* paramName; //参数名称
@property(nonatomic,readonly,copy,nonnull) NSString* paramDescription; //参数描述

@property(nonatomic,readonly) NSInteger paramType; //参数类型

@property(nonatomic,readonly) NSUInteger maxValue;  //最大值
@property(nonatomic,readonly) NSUInteger minValue;  //最小值
@property(nonatomic,readonly) NSUInteger defaultValue; //默认值

@property(nonatomic) NSUInteger curValue; //当前值（可修改）

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

-(nonnull NSDictionary*)toDictionary;

@end
