//
//  KTIIndexDrawView.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/24.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIBaseIndexDrawView.h"

@class KTIIndexStyle;

//指标绘制
@interface KTIIndexDrawView : KTIBaseIndexDrawView

//设置指标类型
-(void)setIndexStyle:(nonnull NSArray<__kindof KTIIndexStyle*>*) indexTypesArr;

@end
