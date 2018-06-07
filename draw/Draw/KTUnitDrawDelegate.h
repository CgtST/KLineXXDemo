//
//  KTUnitDrawDelegate.h
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import <UIKit/UIKit.h>

//绘制委托
@protocol KTUnitDrawDelegate <NSObject>

@required

@property(nonatomic) CGFloat unitWidth; //单元宽度
@property(nonatomic,retain,nonnull) UIColor *unitColor; //单元颜色颜色
@property(nonatomic) CGFloat unitXcenter; //x轴上绘制的中心点,默认为0

-(void)draw:(nonnull CGContextRef)context;

-(nonnull id<KTUnitDrawDelegate>)copyDraw;

@end


@protocol KTIndexDelegate <NSObject>

@required

@property(nonatomic) BOOL bshow; //是否显示

-(void)draw:(nonnull CGContextRef)context;

@end