//
//  KTIndexDetail.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTIndexParam.h"


//指标详情
@interface KTIndexDetail : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString *indexName; //指标名称
@property(nonatomic,readonly,copy,nonnull) NSString *indexDescription; //指标描述（注释）
@property(nonatomic,readonly,copy,nonnull) NSString *lockPassword; //加锁密码
@property(nonatomic,readonly,copy,nonnull) NSString *hotKey; //快捷键
@property(nonatomic,readonly) NSUInteger indexFlag; //指标类型(指标适用周期,及主、副图)

@property(nonatomic,readonly) BOOL bOften; //是否常用指标
@property(nonatomic,readonly,copy,nonnull) NSString *indexFormula; //指标公式
@property(nonatomic,readonly,copy,nonnull) NSString *helpDoc; //帮助文档

@property(nonatomic,readonly) NSUInteger tryDays; //试用天数
@property(nonatomic,readonly,copy,nonnull) NSString *startTryTime; //开始试用时间

@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof KTIndexParam*> *indexParamArr; //指标参数


-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

-(nonnull NSDictionary*)toDictionary;

@end
