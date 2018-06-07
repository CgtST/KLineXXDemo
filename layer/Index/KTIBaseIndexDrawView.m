//
//  KTIBaseIndexDrawView.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIBaseIndexDrawView.h"

@implementation KTIBaseIndexDrawView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(nil != self)
    {
        //默认关闭用户交互
        self.userInteractionEnabled = NO;
        self.showCount = INT_MAX;
    }
    return self;
}

-(void)clearIndexDraws:(nullable FunctionFinishBlock)finishblock //清空绘制
{
    
}

//刷新绘制
-(void)refreshIndexDraws:(nonnull KTIIndexDataArr*)allData block:(nullable FunctionFinishBlock)finishblock
{
    
}

//更新最后几个绘制数据
-(void)updateLastIndexDraws:(nonnull KTIIndexDataArr*)updateData block:(nullable FunctionFinishBlock)finishblock
{
    
}

//添加新的绘制数据
-(void)addNextIndexDraws:(nonnull KTIIndexDataArr*)addData block:(nullable FunctionFinishBlock)finishblock
{
    
}

@end
