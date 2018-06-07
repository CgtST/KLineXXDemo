//
//  KTIndexParam.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexParam.h"

@interface KTIndexParam ()

@property(nonatomic,readwrite,copy,nonnull) NSString* paramName; //参数名称
@property(nonatomic,readwrite,copy,nonnull) NSString* paramDescription; //参数描述

@property(nonatomic,readwrite) NSInteger paramType; //参数类型

@property(nonatomic,readwrite) NSUInteger maxValue;  //最大值
@property(nonatomic,readwrite) NSUInteger minValue;  //最小值
@property(nonatomic,readwrite) NSUInteger defaultValue; //默认值

@end

@implementation KTIndexParam

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.paramName = [dataDic objectForKey:@"Name"];
        self.paramDescription = [dataDic objectForKey:@"Desc"];
        self.paramType = [[dataDic objectForKey:@"LType"] integerValue];
        self.maxValue = [[dataDic objectForKey:@"Max"] integerValue];
        self.minValue = [[dataDic objectForKey:@"Min"] integerValue];
        self.defaultValue = [[dataDic objectForKey:@"Def"] integerValue];
        self.curValue = [[dataDic objectForKey:@"Cur"] integerValue];
    }
    return self;
}

-(nonnull NSDictionary*)toDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.paramName forKey:@"Name"];
    [dic setValue:self.paramDescription forKey:@"Desc"];
    [dic setValue:[@(self.paramType) stringValue] forKey:@"LType"];
    [dic setValue:[@(self.maxValue) stringValue] forKey:@"Max"];
    [dic setValue:[@(self.minValue) stringValue] forKey:@"Min"];
    [dic setValue:[@(self.defaultValue) stringValue] forKey:@"Def"];
    [dic setValue:[@(self.curValue) stringValue] forKey:@"Cur"];
    return dic;
}
@end
