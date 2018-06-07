//
//  KTIndexDescription.m
//  KlineTrend
//
//  Created by 段鸿仁 on 15/11/25.
//  Copyright © 2015年 zscf. All rights reserved.
//

#import "KTIndexDescription.h"

#pragma mark - KTIndexDescription

@interface KTIndexDescription ()

@property(nonatomic,readwrite,copy,nonnull) NSString *indexName; //指标名称
@property(nonatomic,readwrite,copy,nonnull) NSString *indexDescription; //指标描述（注释）
@property(nonatomic,readwrite) NSUInteger indexFlag; //指标标签
@property(nonatomic,readwrite) BOOL bCheckPower; //是否要校验权限

@end

@implementation KTIndexDescription

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.indexName = [dataDic objectForKey:@"IndexName"];
        self.indexDescription = [dataDic objectForKey:@"Desc"];
        self.indexFlag = (NSUInteger)[[dataDic objectForKey:@"Flag"] integerValue];
        self.bCheckPower = [[dataDic objectForKey:@"CheckRight"] integerValue];
    }
    return self;
}

@end

#pragma mark - KTIndexGroup

//指标组
@interface KTIndexGroup ()

@property(nonatomic,readwrite,copy,nonnull) NSString *groupName;
@property(nonatomic,readwrite,retain,nonnull) NSArray<__kindof KTIndexDescription*> *indexList;


@end

@implementation KTIndexGroup

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        self.groupName = [dataDic objectForKey:@"GName"];
        NSMutableArray<__kindof KTIndexDescription*> *indexArr = [NSMutableArray array];
        NSMutableArray<__kindof NSDictionary*> *dataArr = [dataDic objectForKey:@"Index"];
        for(NSDictionary *dic  in dataArr)
        {
            KTIndexDescription *desc = [[KTIndexDescription alloc] initWithDic:dic];
            if(nil != desc)
            {
                [indexArr addObject:desc];
            }
        }
        self.indexList = [NSArray arrayWithArray:indexArr];
       
    }
    return self;
}

@end