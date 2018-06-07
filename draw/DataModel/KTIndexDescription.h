//
//  KTIndexDescription.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - KTIndexDescription

//指标描述
@interface KTIndexDescription : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString *indexName; //指标名称
@property(nonatomic,readonly,copy,nonnull) NSString *indexDescription; //指标描述（注释）
@property(nonatomic,readonly) NSUInteger indexFlag; //指标标签
@property(nonatomic,readonly) BOOL bCheckPower; //是否要校验权限

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

@end

#pragma mark - KTIndexGroup

//指标组
@interface KTIndexGroup : NSObject

@property(nonatomic,readonly,copy,nonnull) NSString *groupName;
@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof KTIndexDescription*> *indexList;

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

@end