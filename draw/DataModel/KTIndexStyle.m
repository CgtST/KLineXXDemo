//
//  KTIndexStyle.m
//  KlineTrend
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTIndexStyle.h"

@interface KTIndexStyle()

@property(nonatomic,readwrite,copy,nonnull) NSString *indexLineName; //指标线名称
@property(nonatomic,readwrite) KTIndexDrawType indexDrawType;
@property(nonatomic,readwrite) NSInteger klineDrawStype; //指标线绘制样式 (drawkline2时绘制K线的方式 0-普通空心阳 1-实心阳 2-美国线)

@end

@implementation KTIndexStyle

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic
{
    self = [super init];
    if(nil != self)
    {
        _buserRiseDownColor = NO;
        self.bshow = YES;
        self.indexLineName = [[dataDic objectForKey:@"LName"] uppercaseString];  //由于指标库将xml文件中的名字进行了大小写转换，而显示时需要显示大写字母名称，所以在这里做了指标名称大写转换
        self.indexDrawType = (KTIndexDrawType)[[dataDic objectForKey:@"LType"] integerValue];
        if(KTIndexDrawTypeVol == self.indexDrawType || KTIndexDrawTypeColorStick == self.indexDrawType)
        {
            _buserRiseDownColor = YES;
        }
        if(KTIndexDrawTypeHollowStick == self.indexDrawType)
        {
            NSString *eData = [dataDic objectForKey:@"EData"];
            NSArray<__kindof NSString*> *arr = [eData componentsSeparatedByString:@" "];
            self.width = [arr.firstObject doubleValue];
            BOOL bhollow = [arr.lastObject boolValue];
            if(NO == bhollow)
            {
                self.indexDrawType = KTIndexDrawTypeColorStick;
            }
        }
       
        
        self.klineDrawStype = [[dataDic objectForKey:@"DStyle"] integerValue];
        NSString *colorStr = [dataDic objectForKey:@"LColor"];
        if(colorStr.length > 2)
        {
            self.indexColor = [self trans2Color:[colorStr substringWithRange:NSMakeRange(2, colorStr.length - 2)]]; //去掉0x字符
        }
        else
        {
            self.indexColor = nil;
        }
        
        self.nodeWidth = -1;
    }
    return self;
}

#pragma mark - private

-(nullable UIColor*)trans2Color:(nonnull NSString*)colorStr
{
    if(colorStr.length < 6)
    {
        return nil;
    }
    int red = 0,green = 0,blue = 0, alpha = 255;
    if(colorStr.length >=6)
    {
        red = [self str2Int:[colorStr substringWithRange:NSMakeRange(0, 2)]];
        green = [self str2Int:[colorStr substringWithRange:NSMakeRange(2, 2)]];
        blue = [self str2Int:[colorStr substringWithRange:NSMakeRange(4, 2)]];
    }
    if(colorStr.length >=8)
    {
        alpha = [self str2Int:[colorStr substringWithRange:NSMakeRange(6, 2)]];
    }
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

-(int)str2Int:(NSString*)str
{
    NSAssert(2 == str.length, @"颜色字符串不对");
    str = [str uppercaseString];
    char cha[2] = {'0','0'};
    cha[0] = [str UTF8String][0];
    cha[1] = [str UTF8String][1];
    int colorValue = 0;
    for(int i = 0;i < 2;i++)
    {
        int value = cha[i] - 48; //数值
        if(value >=10)
        {
            value = cha[i] - 55;  //字符
        }
        colorValue = colorValue * 16 + value;
    }
    return colorValue;
}


@end


#pragma mark - KTIndexOneNodeData

@interface KTIndexOneNodeData ()
{
    NSMutableArray<__kindof NSNumber*> *m_nodeDataArr;
}
@end


//指标一个节点的数据
@implementation KTIndexOneNodeData

-(nonnull instancetype)initWithDic:(nonnull NSDictionary*)dataDic Count:(NSUInteger) dataCount
{
    self = [super init];
    if(nil != self)
    {
        _maxValue = CGFLOAT_MIN;
        _minValue = CGFLOAT_MAX;
        _extraData = nil;
        m_nodeDataArr = [NSMutableArray array];
        for(NSUInteger i = 0;i <  dataCount;i++)
        {
            NSString *keyStr = [NSString stringWithFormat:@"Value%i",(int)(i+ 1)];
            CGFloat value = [[dataDic objectForKey:keyStr] doubleValue];
            if(value > self.maxValue)
            {
                _maxValue = value;
            }
            if(value < self.minValue)
            {
                _minValue = value;
            }
            [m_nodeDataArr addObject:@(value)];
        }
        _nodeDataCount = m_nodeDataArr.count;
    }
    return self;
}

-(nonnull NSArray<__kindof NSNumber*>*)getAllData
{
    return [NSArray arrayWithArray:m_nodeDataArr];
}

#pragma mark - 重写setter和getter函数

@dynamic firstData;
-(nonnull NSNumber*)firstData
{
    return m_nodeDataArr.firstObject;
}

@dynamic secondData;
-(nullable NSNumber*)secondData
{
    if(m_nodeDataArr.count > 1)
    {
        return [m_nodeDataArr objectAtIndex:1];
    }
    return nil;
}



@end
