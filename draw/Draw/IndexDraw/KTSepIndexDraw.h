//
//  KTSepIndexDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 16/6/30.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KTUnitDrawDelegate.h"


@interface KTSepIndexDraw : NSObject<KTIndexDelegate>

@property(nonatomic) NSUInteger startPos; //特殊指标第一个点所在的位置，默认为0
@property(nonatomic,readonly) NSUInteger validCount; //有效值

-(void)setData:(nonnull NSArray<__kindof NSValue*>*)firstArr sDataArr:(nonnull NSArray<__kindof NSValue*>*)secondArr;

-(void)updateLastData:(CGFloat)firstValue secondData:(CGFloat)secondValue;

-(void)addNextData:(CGPoint)firstPt secondData:(CGPoint)secondPt;

-(nonnull NSArray<__kindof NSValue*>*)getFirstDataArr;

-(nonnull NSArray<__kindof NSValue*>*)getSecondDataArr;

@end
