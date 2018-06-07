//
//  KTIndexData.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTIndexStyle.h"


//指标数据（由T_IndexOut结构体转换来）
@interface KTIndexData : NSObject

@property(nonatomic,retain,readonly,nonnull) KTIndexStyle *indexStyle;  //指标样式

@property(nonatomic,readonly) NSUInteger nodeDataCount; //指标线每个节点内的数据个数
@property(nonatomic,readonly) NSUInteger nodeCount; //节点的个数

#pragma mark - 方法

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic;

//修改第index个节点的数据
-(BOOL)modifyNodeData:(nonnull KTIndexOneNodeData *)nodeData atIndex:(NSUInteger)index;

//添加节点数据到最后,返回NO表示添加失败(此时没有添加任何节点)
-(BOOL)addNodeDatasToLast:(nonnull NSArray<__kindof KTIndexOneNodeData*>*) nodeDataArr;

//获取第index个节点的数据
-(nullable KTIndexOneNodeData *)getNodeDataAtIndex:(NSUInteger)index;

-(nonnull NSArray<__kindof KTIndexOneNodeData*> *)getIndexDatabeginPos:(NSUInteger)begin Count:(NSUInteger)count;

//获取最大值和最小值
-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValue;

-(nonnull NSArray<__kindof NSNumber*>*)getMinMaxValueStart:(NSUInteger)start Count:(NSUInteger)count;

#pragma mark - static

+(nonnull NSArray<__kindof NSNumber*>*)getMinMaxIndexValue:(nonnull NSArray<__kindof KTIndexData*> *)indexDataArr Start:(NSUInteger)start Count:(NSUInteger)count;

@end

