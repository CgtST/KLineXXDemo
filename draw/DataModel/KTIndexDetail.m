//
//  KTIndexDetail.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/26.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexDetail.h"

@interface KTIndexDetail ()

@property(nonatomic,readwrite,copy,nonnull) NSString *indexName; //指标名称
@property(nonatomic,readwrite,copy,nonnull) NSString *indexDescription; //指标描述（注释）
@property(nonatomic,readwrite,copy,nonnull) NSString *lockPassword; //加锁密码
@property(nonatomic,readwrite,copy,nonnull) NSString *hotKey; //快捷键
@property(nonatomic,readwrite) NSUInteger indexFlag; //指标类型(指标适用周期,及主、副图)

@property(nonatomic,readwrite) BOOL bOften; //是否常用指标
@property(nonatomic,readwrite,copy,nonnull) NSString *indexFormula; //指标公式
@property(nonatomic,readwrite,copy,nonnull) NSString *helpDoc; //帮助文档

@property(nonatomic,readwrite) NSUInteger tryDays; //试用天数
@property(nonatomic,readwrite,copy,nonnull) NSString *startTryTime; //开始试用时间

@property(nonatomic,readwrite,retain,nonnull) NSArray<__kindof KTIndexParam*> *indexParamArr; //指标参数

@end

@implementation KTIndexDetail

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.indexName = [dataDic objectForKey:@"IndexName"];
        self.indexDescription = [dataDic objectForKey:@"Desc"];
        self.lockPassword = [dataDic objectForKey:@"Pwd"];
        self.hotKey = [dataDic objectForKey:@"HotKey"];
        self.indexFlag = (NSUInteger)[[dataDic objectForKey:@"Flag"] integerValue];
        self.bOften = [[dataDic objectForKey:@"Often"] boolValue];
        self.indexFormula = [dataDic objectForKey:@"Content"];
        self.helpDoc = [dataDic objectForKey:@"Help"];
        self.tryDays = (NSUInteger)[[dataDic objectForKey:@"ETime"] integerValue];
        self.startTryTime = [dataDic objectForKey:@"STime"];
        NSMutableArray<__kindof KTIndexParam*> *paramArr = [NSMutableArray array];
        NSArray<__kindof NSDictionary*> *dataArr = [dataDic objectForKey:@"Param"];
        for(NSDictionary *dic in dataArr)
        {
            KTIndexParam *param = [[KTIndexParam alloc] initWithDic:dic];
            if(nil != self)
            {
                [paramArr addObject:param];
            }
        }
        self.indexParamArr = [NSArray arrayWithArray:paramArr];
        
    }
    return self;
}

-(nonnull NSDictionary*)toDictionary
{
    NSMutableDictionary *retDic = [NSMutableDictionary dictionary];
    [retDic setValue:self.indexName forKey:@"IndexName"];
    [retDic setValue:self.indexDescription forKey:@"Desc"];
    [retDic setValue:self.lockPassword forKey:@"Pwd"];
    [retDic setValue:self.hotKey forKey:@"HotKey"];
    [retDic setValue:[@(self.indexFlag) stringValue] forKey:@"Flag"];
    [retDic setValue:(YES == self.bOften ? @"1" : @"0") forKey:@"Often"];
    [retDic setValue:self.indexFormula forKey:@"Content"];
    [retDic setValue:self.helpDoc forKey:@"Help"];
    [retDic setValue:[@(self.tryDays) stringValue] forKey:@"ETime"];
    [retDic setValue:self.startTryTime forKey:@"STime"];
    NSMutableArray<__kindof NSDictionary*> *arr = [NSMutableArray array];
    for(KTIndexParam *param in self.indexParamArr)
    {
        [arr addObject:[param toDictionary]];
    }
    [retDic setValue:arr forKey:@"Param"];
    return retDic;
}

@end
