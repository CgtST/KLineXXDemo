//
//  KTTrendData.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/27.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//分时数据
@interface KTTrendData : NSObject

@property(nonatomic) UInt32 uday; //分时所在的日期
@property(nonatomic,readonly) int time; ////格林威治时间分钟数,处理过后的时间，小于-1440
@property(nonatomic) int dataTime; //格林威治时间分钟数,夜盘隔天会大于-1440
@property(nonatomic) CGFloat dCurPrice; //最新价格
@property(nonatomic) CGFloat dAvg; //均价
@property(nonatomic) CGFloat dVolume; //成交量
@property(nonatomic) CGFloat dAmount;	//单成交额或总持仓

//时间不相同时会拷贝失败
-(BOOL)copyDataFrom:(nonnull KTTrendData*)trendData;

-(nonnull KTTrendData*)getCopyData; //获取一份拷贝对象

@end


#pragma mark - 

@interface KTTradeTime: NSObject

@property(nonatomic) int startTime; //格林威治时间分钟数
@property(nonatomic) int endTime; //格林威治时间分钟数

-(NSUInteger)getTimeUintCount; //获取取时间分量的个数

-(NSInteger)indexOfTime:(int)time; //获取时间在该节点中的位置,如果时间不在该节点内，则返回-1

-(int)getTimeAtIndex:(NSUInteger)index; //获取第index个位置的分量

-(BOOL)bInTradeTime:(int)time; //是否在该时间节点内

@end