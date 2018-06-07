//
//  KTIIndexViewDelegate.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KTIIndexStyle;
@class KTIIndexData;

typedef NS_ENUM(NSUInteger,KTIViewType)
{
    KTIViewTypeMain, //主图
    KTIViewTypeSub,  //副图
};

typedef NS_ENUM(NSUInteger,KTIViewUpdateType)
{
    KTIViewUpdateTypeRefresh, //刷新
    KTIViewUpdateTypeAdd,  //增量
    KTIViewUpdateTypeUpdate, //更新
};

@protocol KTIIndexViewDelegate <NSObject>

@required
//获取对应指标的绘制数据，start表示数据开始时的位置,maxcount表示返回数据中允许的最大个数
-(nonnull KTIIndexData*)KTIIndexViewGetIndexDatasByStyle:(nonnull KTIIndexStyle*)indexstyle ViewType:(KTIViewType)type start:(NSUInteger)start MaxCount:(NSUInteger)maxcount;

//坐标的修改
-(BOOL)KTIIndexViewModifyCoordMax:(nonnull CGFloat*)maxValue Min:(nonnull CGFloat*)minValue ViewType:(KTIViewType)type updatedType:(KTIViewUpdateType)updateType;

@optional

//获取对应指标样式，每个图上最多放一个指标 ， 分时K线为特殊指标，不调用该函数
-(nullable NSArray<__kindof KTIIndexStyle*>*)KTIIndexViewGetAllIndexStylesWithViewType:(KTIViewType)type;

//视图已经跟新完成
-(void)KTIIndexViewType:(KTIViewType)type FinishUpdated:(KTIViewUpdateType)updateType;

@end
