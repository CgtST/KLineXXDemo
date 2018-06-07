//
//  KTindexOper.h
  
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTUnitDrawDelegate.h"
#import "KTIndexStyle.h"

@class KTCombinIndexDraw;
@class KTIndexOperParam;
@class KTCurveIndexDraw;
@class KTSepIndexDraw;

@interface KTindexOper : NSObject

//构造绘制单元时优先重用 oldIndexDraw 中的对象
+(nonnull NSArray<__kindof id<KTIndexDelegate>>*)createDrawDelegate:(nonnull NSArray<__kindof KTIndexStyle*>*) indexStyleArr from:(nonnull NSArray<__kindof id<KTIndexDelegate>>*)oldIndexDraw;

#pragma mark - 曲线

//曲线数据的设置
+(void)setCuverData:(nonnull NSArray<__kindof KTIndexOneNodeData*> *)indexDataArr toCurveDraw:(nonnull KTCurveIndexDraw*)curveDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTIndexOperParam*)param;

//更新最后一个绘制点，不考虑绘制范围的改变
+(void)updateLastPoint:(nonnull KTCurveIndexDraw*)curveDraw NewValue:(CGFloat)value Param:(nonnull KTIndexOperParam*)param ;

//添加一个绘制点，不考虑绘制范围的改变,count表示无效值的个数（曲线绘制可能在前面有无效值）
+(void)addNextPoint:(nonnull KTCurveIndexDraw*)curveDraw NewValue:(CGFloat)value CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)allCenterX  Param:(nonnull KTIndexOperParam*)param ;

#pragma mark - 特殊绘制

//特殊指标数据的设置
+(void)setData:(nonnull NSArray<__kindof KTIndexOneNodeData*> *)indexDataArr toSepDraw:(nonnull KTSepIndexDraw*)sepDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTIndexOperParam*)param;

+(void)updateLastNode:(nonnull KTIndexOneNodeData*) nodeData toSepDraw:(nonnull KTSepIndexDraw*)sepDraw  Param:(nonnull KTIndexOperParam*)param;

+(void)addNextNode:(nonnull KTIndexOneNodeData*) nodeData toSepDraw:(nonnull KTSepIndexDraw*)sepDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)allCenterX Param:(nonnull KTIndexOperParam*)param;

#pragma mark - 组合

//创建组合指标的绘制单元
+(void)createUnit:(nonnull KTCombinIndexDraw*)comDraw IndexDraw:(nonnull KTIndexStyle*)indexStyle Count:(NSUInteger)count;

//设置数据到组合视图
+(void)setIndexData:(nonnull NSArray<__kindof KTIndexOneNodeData*>*)nodeDataArr CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)CenterXArr toComDraw:(nonnull KTCombinIndexDraw*)comDraw Param:(nonnull KTIndexOperParam*)param;

//更新最后一个绘制单元，不考虑绘制范围的改变
+(void)updateLastUnit:(nonnull id<KTUnitDrawDelegate>)lastUnit nodeData:(nonnull KTIndexOneNodeData*)nodeData Param:(nonnull KTIndexOperParam*)param;

//添加一个绘制单元，不考虑绘制范围的改变
+(void)addNextUnittoComDraw:(nonnull KTCombinIndexDraw*)comDraw  nodeData:(nonnull KTIndexOneNodeData*)nodeData CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)CenterXArr  Param:(nonnull KTIndexOperParam*)param;

@end


#pragma mark - KTIndexOperParam

@interface KTIndexOperParam : NSObject

@property(nonatomic) CGRect drawRect; //绘制范围
@property(nonatomic) CGFloat maxValue; //最大刻度
@property(nonatomic) CGFloat minValue; //最小刻度
@end