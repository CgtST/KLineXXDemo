//
//  KTIIndexStyle.m
//  KlineTrendIndex
//
//  Created by 段鸿仁 on 16/10/20.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIIndexStyle.h"
#import <UIKit/UIKit.h>

const NSUInteger K_KlineSepIndex = 1;    //K线特殊指标
const NSUInteger K_TrendNewSepIndex = 2; //分时最新价
const NSUInteger K_TrendAvgSepIndex = 3; //分时均价

NSString  * _Nonnull const KTIKineStyleSign = @"KTI_kline_Style_Sign";   //K线
NSString  * _Nonnull const KTITrendNewPriceStyleSign = @"KTI_TrendNewPrice_Style_Sign"; //分时最新价
NSString  * _Nonnull const KTITrendAvgPriceStyleSign = @"KTI_TrendAvgPrice_Style_Sign"; //分时均价

@interface KTIIndexStyle ()

@property(nonatomic,readwrite,copy,nonnull) NSString *indexName;
@property(nonatomic,readwrite) KTIIndexDrawType drawType;  //绘制类型
@property(nonatomic) KTIKLineDrawType klineType;
@property(nonatomic,readwrite) KTIIndexUnitType unitType; //单元宽度类型
@property(nonatomic) CGFloat unitWith; //单元宽度或者比例

@property(nonatomic,readonly,retain,nonnull) NSMutableDictionary<__kindof NSNumber*,__kindof UIColor*> *colorDic;
@property(nonatomic,readonly,retain,nonnull) NSMutableDictionary<__kindof NSNumber*,__kindof id<KTIUnitColorDelegate>> *colorDelegateDic;
@property(nonatomic) NSUInteger sepIndex;
@property(nonatomic,copy,nullable) NSString*  styleSign; //可以用于区分指标的不同
@end

@implementation KTIIndexStyle

-(nonnull instancetype)init
{
    self = [super init];
    if(nil != self)
    {
        self.indexName = @"";
        self.drawType = KTIIndexDrawTypeCurveLine;
        self.lineWidth = 1.0/[[self class] scale];;
        self.unitFillType = KTIIndexUnitFillTypeFillOnly;
        [self setUnitScale:0.9];
        self.klineType = KTIKLineDrawTypeSolid;
        _colorDic = [NSMutableDictionary dictionary];
        _colorDelegateDic = [NSMutableDictionary dictionary];
        self.sepIndex = 0;
        self.styleSign = nil;
    }
    return self;
}

+(nonnull instancetype)initWithDrawType:(KTIIndexDrawType)drawType IndexName:(nonnull NSString*)indexName
{
    KTIIndexStyle *style = [[KTIIndexStyle alloc] init];
    style.drawType = drawType;
    style.indexName = indexName;
    return style;
}

#pragma mark - 颜色

-(void)setColor:(nonnull UIColor*)color ColorType:(KTIIndexColorType)type
{
    [self.colorDic setObject:color forKey:@(type)];
}

-(nullable UIColor*)getColor:(KTIIndexColorType)type
{
    return self.colorDic[@(type)];
}

-(void)setColorDelegate:(nonnull id<KTIUnitColorDelegate>)colorDelegate ColorType:(KTIIndexColorType)type
{
    [self.colorDelegateDic setObject:colorDelegate forKey:@(type)];
}

-(nullable id<KTIUnitColorDelegate>)getColorDelegate:(KTIIndexColorType)type
{
    return self.colorDelegateDic[@(type)];
}

#pragma mark - 单元绘制宽度

-(void)setSpaceWidth:(CGFloat)spaceWidth
{
    self.unitWith = spaceWidth;
    self.unitType = KTIIndexUnitTypeSpaceFix;
}

-(void)setUintWidth:(CGFloat)unitWidth
{
    self.unitWith = unitWidth;
    self.unitType = KTIIndexUnitTypeUnitFix;
}

-(void)setUnitScale:(CGFloat)unitScale
{
    self.unitWith = unitScale;
    if(self.unitWith > 1.0 || self.unitWith <=0)
    {
        self.unitWith = 1.0;
    }
    self.unitType = KTIIndexUnitTypeScale;
}

//获取单元的绘制宽度，传入的是单元的占位宽度
-(CGFloat)getUnitDrawWidth:(CGFloat)cellWidth
{
    CGFloat width = self.unitWith;
    if(KTIIndexUnitTypeSpaceFix == self.unitType)
    {
        width = cellWidth - self.unitWith;
    }
    else if(KTIIndexUnitTypeScale == self.unitType)
    {
        width = cellWidth * self.unitWith;
    }
    //像素化
    width = (NSInteger)(width * [[self class] scale]);
    width = width < 1 ? 1 : width;
    width = width / [[self class] scale];
    return width;
}

#pragma mark -

-(void)setKlineDrawType:(KTIKLineDrawType)type
{
    self.klineType = type;
}

-(KTIKLineDrawType)getKlineDrawType
{
    return self.klineType;
}

-(nonnull NSString*)uniqueSignStr  //唯一标识
{
    if(nil == self.styleSign)
    {
        CFUUIDRef puuid = CFUUIDCreate(nil);
        CFStringRef uuidString = CFUUIDCreateString(nil, puuid );
        self.styleSign = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
        CFRelease(puuid);
        CFRelease(uuidString);
    }
    return self.styleSign;
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    if( 0 != self.sepIndex )  //特殊指标不允许拷贝
    {
        return self;
    }
    
    KTIIndexStyle *style = [[KTIIndexStyle allocWithZone:zone] init];
    style.indexName = self.indexName;
    
    style.drawType = self.drawType;
    style.lineWidth = self.lineWidth;
    
    style.unitType = self.unitType;
    style.unitFillType = self.unitFillType;
    style.unitWith = self.unitWith;
    
    style.styleSign = self.styleSign;
    style.sepIndex = self.sepIndex;
    [style.colorDic removeAllObjects];
    [style.colorDic addEntriesFromDictionary:self.colorDic];
    [style.colorDelegateDic removeAllObjects];
    [style.colorDelegateDic addEntriesFromDictionary:self.colorDic];
    
    return style;
}

#pragma mark - 特殊指标

//单例模式，构造特殊指标(不允许拷贝) - K线
+(nonnull KTIIndexStyle*)shareKlineIndexSyle
{
    static KTIIndexStyle *klineStyle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      klineStyle = [KTIIndexStyle initWithDrawType:KTIIndexDrawTypeKLine IndexName:@"kline"];
                      [klineStyle setSpaceWidth:1];
                      klineStyle.styleSign = KTIKineStyleSign;
                      klineStyle.sepIndex = K_KlineSepIndex;
                  });
    return klineStyle;
}

//单例模式，构造特殊指标(不允许拷贝) - 分时最新价
+(nonnull KTIIndexStyle*)shareTrendNewPriceIndexSyle
{
    static KTIIndexStyle *trendNewStyle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      trendNewStyle = [KTIIndexStyle initWithDrawType:KTIIndexDrawTypeCurveLine IndexName:@"trendNewPrice"];
                      trendNewStyle.styleSign = KTITrendNewPriceStyleSign;
                      trendNewStyle.sepIndex = K_TrendNewSepIndex;
                  });
    return trendNewStyle;

}

//单例模式，构造特殊指标(不允许拷贝) - 分时均价
+(nonnull KTIIndexStyle*)shareTrendAvgPriceIndexSyle
{
    static KTIIndexStyle *trendAvgStyle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      trendAvgStyle = [KTIIndexStyle initWithDrawType:KTIIndexDrawTypeCurveLine IndexName:@"trendAvgPrice"];
                      trendAvgStyle.styleSign = KTITrendAvgPriceStyleSign;
                      trendAvgStyle.sepIndex = K_TrendAvgSepIndex;
                  });
    return trendAvgStyle;
}

#pragma mark - private

+(CGFloat)scale
{
    static CGFloat scale = -1;
    if(scale < 0)
    {
        scale = [UIScreen mainScreen].scale;
    }
    return scale;
}

@end
