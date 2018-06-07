//
//  KTIndexMainView.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/28.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTIndexOneNodeData;
@class KTIndexStyle;
@protocol KTIndexMainViewDelegate;

@interface KTIndexMainView : UIView

@property(nonatomic) NSUInteger startShowPos; //开始显示的位置
@property(nonatomic) NSUInteger showCount; //显示的条数(如果显示的数据不够，则不绘制)
@property(nonatomic) NSUInteger nodeWith; //指标宽度

@property(nonatomic,weak,nullable) id<KTIndexMainViewDelegate> indexDelegate;
@property(nonatomic) BOOL bRemoveRepeatPoint; //是否对曲线点进行抽稀(在部分商品的分时图副图指标中需要对过密的点进行处理，默认为NO)

#pragma mark -

//获取指标中第index个点的绘制颜色(传入的是绘制单元的位置)（预留接口）
-(nonnull NSArray<__kindof UIColor*>*)getIndexColorAtIndex:(NSUInteger)index;

#pragma mark - 指标绘制更新

-(void)clearAllDraw; //清除所有的绘制

//更新指标绘制
-(void)refreshIndexDraw;

//修改最后一个指标数据
-(BOOL)updateLastIndexData:(nonnull NSArray<__kindof KTIndexOneNodeData*>*)lastIndexData;

//新增一个指标数据的绘制
-(BOOL)addNextIndexData:(nonnull  NSArray<__kindof KTIndexOneNodeData*> *)nextIndexData;

@end

@protocol KTIndexMainViewDelegate <NSObject>

@required

//最小值
-(CGFloat)KTIndexMainViewgetMinValue:(nonnull KTIndexMainView*)indexView;

//最大值
-(CGFloat)KTIndexMainViewgetMaxValue:(nonnull KTIndexMainView*)indexView;

//获取X轴上的绘制中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIndexMainViewGetDrawCenterXArr:(nonnull KTIndexMainView*)indexView;

-(nonnull NSArray<__kindof KTIndexStyle*> *)KTIndexViewGetIndexStyle:(nonnull KTIndexMainView*)indexView;//获取指标绘制样式

//获取指标绘制数据,返回的个数可能小于count
-(nonnull NSArray<__kindof NSArray<__kindof KTIndexOneNodeData*>*> *)KTIndexViewGetIndexDrawData:(nonnull KTIndexMainView*)indexView start:(NSUInteger)start Count:(NSUInteger)count;

//设置指标的绘制宽度，否则默认为默认线宽
-(CGFloat)getIndexWidth:(nonnull KTIndexStyle*)indexStyle;

@optional

-(BOOL)isIndexNeedChangeUintColor:(nonnull KTIndexStyle*)indexStyle; //是否需要修改颜色

-(nonnull UIColor*)modifyLineColor:(nonnull KTIndexStyle*)indexStyle; //修改线的颜色

//获取修改的指标颜色(要求返回的个数与传入的个数相同)
-(nonnull NSArray<__kindof UIColor*>*)modifyUnitColorIndex:(nonnull KTIndexStyle*)indexStyle WithData:(nonnull  NSArray<__kindof KTIndexOneNodeData*>*) indexDataArr start:(NSUInteger)start;

@end