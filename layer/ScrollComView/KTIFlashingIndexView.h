//
//  KTIFlashingIndexView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/27.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,KTIFlashingDataType)
{
    KTIFlashingDataTypeNone, //不需要做任何操作
    KTIFlashingDataTypeUpdate, //更新数据
    KTIFlashingDataTypeAdd, //添加数据
};

@protocol KTIFlashingIndexViewDelegate;

//闪电图
@interface KTIFlashingIndexView : UIControl

@property(nonatomic,weak,nullable) id<KTIFlashingIndexViewDelegate> delegate;
@property(nonatomic) NSUInteger showCount; //显示的分时点的个数
@property(nonatomic) NSUInteger distToEndWhenChanged; //距离终点有多少个点时，视图进行了移动，默认为0
@property(nonatomic) NSUInteger leftMoveCount; //数据到达右侧时，每次向左边移动多少个点,默认为60
@property(nonatomic,retain,nullable) UIColor *flashViewColor; //分时区域背景颜色
@property(nonatomic,readonly) CGFloat flashingMaxValue;
@property(nonatomic,readonly) CGFloat flashingMinValue;
@property(nonatomic,readonly) NSUInteger realDrawCount;  //当前绘制的点的个数

//清空闪电图
-(void)clear;

//刷新视图，重新计算
-(void)refresh;

//手动更新
-(void)update;

//开始更新绘制
-(void)startUpdate;

//结束更新绘制
-(void)stopUpdate;

//是否正在更新
-(BOOL)isUpdate;

#pragma mark - 数据获取

//获取X轴坐标xpos在分时图中的绘制位置,NSNotFound表示没有找到数据
-(NSUInteger)getIndexByDrawPosOfX:(CGFloat)xpos;

//获取第index个分时的中心点位置
-(CGFloat)getCenterAtIndex:(NSUInteger)index;

//获取最后一个绘制的中心点
-(CGPoint)getLastPriceDrawCenter;

//获取垂直方向上的对应绘制点的原始坐标
-(CGFloat)getVerOrgCoordByDrawPos:(CGFloat)drawPos;

//获取对应数据在垂直方向上的绘制点
-(CGFloat)getVerDrawPosByOrgData:(CGFloat)orgData;

@end

@protocol KTIFlashingIndexViewDelegate <NSObject>

//获取闪电图数据，maxCount表示最多获取多少条数据
-(nonnull NSArray<__kindof NSNumber*>*)KTIFlashingIndexViewGetLastTrendDataCount:(NSUInteger)maxCount;

//修改最大值和最小值
-(BOOL)KTIFlashingIndexViewModifyCoordMax:(nonnull CGFloat*)maxValue Min:(nonnull CGFloat*)minValue isReDraw:(BOOL)reDraw;

//获取最后一条数据的状态
-(KTIFlashingDataType)KTIFlashingIndexViewGetLastDataType;

-(void)KTIFlashingIndexViewFinshDraw:(BOOL)reDraw;

@end

