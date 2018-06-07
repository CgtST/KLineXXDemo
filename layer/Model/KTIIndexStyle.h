//
//  KTIIndexStyle.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTIStyleType.h"

extern NSString  * _Nonnull const KTIKineStyleSign;   //K线
extern NSString  * _Nonnull const KTITrendNewPriceStyleSign; //分时最新价
extern NSString  * _Nonnull const KTITrendAvgPriceStyleSign; //分时均价

@interface KTIIndexStyle : NSObject<NSCopying>

@property(nonatomic,readonly,copy,nonnull) NSString *indexName;
@property(nonatomic,readonly) KTIIndexDrawType drawType;  //绘制类型
@property(nonatomic) CGFloat lineWidth; //线宽

@property(nonatomic,readonly) KTIIndexUnitType unitType; //单元宽度类型
@property(nonatomic) KTIIndexUnitFillType unitFillType; //单元填充类型

#pragma mark - 颜色

+(nonnull instancetype)initWithDrawType:(KTIIndexDrawType)drawType IndexName:(nonnull NSString*)indexName;

-(void)setColor:(nonnull UIColor*)color ColorType:(KTIIndexColorType)type;

-(nullable UIColor*)getColor:(KTIIndexColorType)type;

-(void)setColorDelegate:(nonnull id<KTIUnitColorDelegate>)colorDelegate ColorType:(KTIIndexColorType)type;

-(nullable id<KTIUnitColorDelegate>)getColorDelegate:(KTIIndexColorType)type;

#pragma mark - 单元绘制宽度

-(void)setSpaceWidth:(CGFloat)spaceWidth;

-(void)setUintWidth:(CGFloat)unitWidth;

-(void)setUnitScale:(CGFloat)unitScale;

//获取单元的绘制宽度，传入的是单元的占位宽度
-(CGFloat)getUnitDrawWidth:(CGFloat)cellWidth;

#pragma mark -

-(void)setKlineDrawType:(KTIKLineDrawType)type;

-(KTIKLineDrawType)getKlineDrawType;

-(nonnull NSString*)uniqueSignStr;  //唯一标识

#pragma mark - 特殊指标

//单例模式，构造特殊指标(不允许拷贝) - K线
+(nonnull KTIIndexStyle*)shareKlineIndexSyle;

//单例模式，构造特殊指标(不允许拷贝) - 分时最新价
+(nonnull KTIIndexStyle*)shareTrendNewPriceIndexSyle;

//单例模式，构造特殊指标(不允许拷贝) - 分时均价
+(nonnull KTIIndexStyle*)shareTrendAvgPriceIndexSyle;

@end
