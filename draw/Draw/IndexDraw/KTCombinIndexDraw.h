//
//  KTCombinIndexDraw.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/28.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KTUnitDrawDelegate.h"

//组合绘制，由绘制单元组成
@interface KTCombinIndexDraw: NSObject<KTIndexDelegate>

@property(nonatomic,readonly) NSUInteger drawCount; //绘制的单元个数
@property(nonatomic) CGFloat unitWidth;  //单元宽度

-(void)setUnitDrawArr:(nonnull NSArray<__kindof id<KTUnitDrawDelegate>>*) drawArr;

-(void)addUnitDraw:(nonnull id<KTUnitDrawDelegate>)draw;

-(nullable id<KTUnitDrawDelegate>) getUnitAt:(NSUInteger)index;

-(nullable id<KTUnitDrawDelegate>) removeFirstDrawUnit;

-(nullable id<KTUnitDrawDelegate>) removeLastDrawUnit;

-(void)removeAllDrawUnit;

-(void)mofiyColor:(nonnull UIColor*)color AtIndex:(NSUInteger) index;

-(nullable UIColor*) getColorAtUnitIndex:(NSUInteger) index; //获取指定单元的绘制颜色

@end
