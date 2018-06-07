//
//  KTINodeData.h
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KTINodeData : NSObject

@property(nonatomic) BOOL isNumValid;  //数据是否合法,默认为NO
@property(nonatomic,readonly) CGFloat minValue; //合法值中的最小值
@property(nonatomic,readonly) CGFloat maxValue; //和法值中的最大值

@property(nonatomic,retain,nullable) NSArray<__kindof NSNumber*>* allValues; //原始数据
@property(nonatomic,retain,nullable) NSData* extendData; //可以是图片，文字(文字也可以先绘制成图片,然后在传入，不过，此时绘制类型应该是图片),图片

+(nonnull KTINodeData*)transToNodeData:(CGFloat)value;

//K线数据转换为Node数据
+(nonnull KTINodeData*)transKlineData2NodeDataHighPrice:(CGFloat)highPrice LowPrice:(CGFloat)lowPrice OpenPrice:(CGFloat)openPrice ClosePrice:(CGFloat)closePrice;

@end


@interface KTIIndexData : NSObject

@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof KTINodeData*> *nodeDataArr;

+(nonnull KTIIndexData*)IndexWith:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr;

+(nonnull KTIIndexData*)transPrice2Index:(nonnull NSArray<__kindof NSNumber*>*) priceArr;

-(void)addNodeData:(nonnull KTINodeData*)nodeData;

-(void)addNodeDataFromArr:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr;

-(void)setNodeData:(nonnull NSArray<__kindof KTINodeData *>*)nodeDataArr;

-(void)clearAllNodeData;

//获取不合法值的个数
+(NSUInteger)getInvaildValueCountInIndex:(nonnull NSArray<__kindof KTINodeData*>*)values;

@end


//指标数组中必须保证所有的KTIIndexData的个数一致
@interface KTIIndexDataArr : NSObject

@property(nonatomic,readonly,retain,nonnull) NSArray<__kindof KTIIndexData*> *indexDataArr;
@property(nonatomic,readonly) NSUInteger nodeCount;  //指标节点的个数

+(nonnull KTIIndexDataArr*)IndexWith:(nonnull KTIIndexData*)nodeDataArr;

-(BOOL)addIndexData:(nonnull KTIIndexData*)indexData;

-(void)clearAllIndexData;

@end
