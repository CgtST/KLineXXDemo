//
//  KTIBaseIndexDrawView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KTIIndexDataArr;
@protocol  KTIBaseIndexDrawViewDelegate;

typedef void (^FunctionFinishBlock)(void); //函数执行完成后的回调

//指标绘制视图
@interface KTIBaseIndexDrawView : UIView

@property(nonatomic,weak,nullable) id<KTIBaseIndexDrawViewDelegate> indexDelegate;

@property(nonatomic) NSUInteger showCount; //默认可以显示的数据的个数，在addNextIndexDraws时需要用到

-(void)clearIndexDraws:(nullable FunctionFinishBlock)finishblock; //清空绘制

//刷新绘制
-(void)refreshIndexDraws:(nonnull KTIIndexDataArr*)allData block:(nullable FunctionFinishBlock)finishblock;

//更新最后几个绘制数据
-(void)updateLastIndexDraws:(nonnull KTIIndexDataArr*)updateData block:(nullable FunctionFinishBlock)finishblock;

//添加新的绘制数据
-(void)addNextIndexDraws:(nonnull KTIIndexDataArr*)addData block:(nullable FunctionFinishBlock)finishblock;

@end

#pragma mark - protocol

@protocol  KTIBaseIndexDrawViewDelegate<NSObject>

//获取绘制的中心点
-(nonnull NSArray<__kindof NSNumber*>*)KTIBaseIndexDrawViewGetXcenter:(nonnull KTIBaseIndexDrawView*)baseView;

//获取最大坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMax:(nonnull KTIBaseIndexDrawView*)baseView;

//获取最小坐标
-(CGFloat)KTIBaseIndexDrawViewGetYposOfMin:(nonnull KTIBaseIndexDrawView*)baseView;


@end
