//
//  KTKlineData.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//K线数据
@interface KTKlineData : NSObject

@property(nonatomic) UInt32  time;  //K线时间
@property(nonatomic) CGFloat dOpenPrice; //开盘价格
@property(nonatomic) CGFloat dClosePrice; //收盘价
@property(nonatomic) CGFloat dHighPrice; //最高价
@property(nonatomic) CGFloat dLowPrice; //最低价

@property(nonatomic) NSUInteger vol; //成交量
@property(nonatomic) CGFloat dAmo; // 成交额或总持仓

@property(nonatomic) CGFloat dHold; //持仓
@property(nonatomic,retain,nonnull) NSString* riseHomeNum;  //指数的上涨家数(BTI指标用到)
@property(nonatomic,retain,nonnull) NSString* downHoneNum; //指数的下跌家数(BTI指标用到)

-(nonnull NSDictionary*)toDictionary;

//时间不相同时会拷贝失败
-(BOOL)copyDataFrom:(nonnull KTKlineData*)klinData;

@end
