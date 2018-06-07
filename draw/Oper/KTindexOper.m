//
//  KTindexOper.m
  
//
//  Created by 段鸿仁 on 16/1/15.
//  Copyright © 2016年 zscf. All rights reserved.
//

#import "KTindexOper.h"
#import "KTCalcuLationOper.h"
#import "KTDraw.h"

@implementation KTindexOper

//构造绘制单元时优先重用 indexDrawArr 中的对象
+(nonnull NSArray<__kindof id<KTIndexDelegate>>*)createDrawDelegate:(nonnull NSArray<__kindof KTIndexStyle*>*) indexStyleArr from:(nonnull NSArray<__kindof id<KTIndexDelegate>>*)oldIndexDraw
{
    NSMutableArray<__kindof id<KTIndexDelegate>> *newIndexDraw = [NSMutableArray array];
    NSMutableArray<__kindof id<KTIndexDelegate>> *reusedIndexDraw = [NSMutableArray arrayWithArray:oldIndexDraw];
    for(KTIndexStyle *style in indexStyleArr)
    {
        id<KTIndexDelegate> drawDelegate = [KTindexOper createIndexDraw:style.indexDrawType from:reusedIndexDraw];
        drawDelegate.bshow = style.bshow;
        [reusedIndexDraw removeObject:drawDelegate];
        [newIndexDraw addObject:drawDelegate];
        
        if(YES == [drawDelegate isKindOfClass:[KTCurveIndexDraw class]])
        {
            ((KTCurveIndexDraw*)drawDelegate).lineColor = style.indexColor;
        }
    }
    return [NSArray arrayWithArray:newIndexDraw];
}

#pragma mark - 曲线

+(void)setCuverData:(nonnull NSArray<__kindof KTIndexOneNodeData*>*)indexDataArr toCurveDraw:(nonnull KTCurveIndexDraw*)curveDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTIndexOperParam*)param
{
    NSAssert(centerPosx.count >= indexDataArr.count, @"曲线计算传入的中心点不正确");
    NSMutableArray<__kindof NSValue*> *pointsValue = [NSMutableArray array];
    for(NSUInteger i = 0;i < indexDataArr.count;i++)
    {
        CGFloat value = [[indexDataArr objectAtIndex:i].firstData doubleValue];
        CGFloat ypos = value;
        if(value < KT_INDEX_INVALID_VALUE) //有效值
        {
             ypos = [KTindexOper value2Pixel:value Param:param];
        }
        CGFloat xpos = [[centerPosx objectAtIndex:i] doubleValue];
        [pointsValue addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, ypos)]];
    }
    curveDraw.pointValues = pointsValue;
}

//更新最后一个绘制点，不考虑绘制范围的改变
+(void)updateLastPoint:(nonnull KTCurveIndexDraw*)curveDraw NewValue:(CGFloat)value Param:(nonnull KTIndexOperParam*)param ;
{
    if(value > KT_INDEX_INVALID_VALUE) //过滤无效值
    {
        return;
    }
    CGFloat lastDrawPtX = [KTindexOper value2Pixel:value Param:param];
    NSMutableArray<__kindof NSValue*> *drawPointArr = [NSMutableArray arrayWithArray:curveDraw.pointValues];
    CGFloat xpos = [drawPointArr.lastObject CGPointValue].x;
    //修改最后一个点的纵坐标
    [drawPointArr removeLastObject];
    [drawPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, lastDrawPtX)]];
    curveDraw.pointValues = drawPointArr;
}

//添加一个绘制点，不考虑绘制范围的改变
+(void)addNextPoint:(nonnull KTCurveIndexDraw*)curveDraw NewValue:(CGFloat)value CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)allCenterX  Param:(nonnull KTIndexOperParam*)param
{
    NSAssert(allCenterX.count >= curveDraw.pointValues.count, @"曲线计算传入的中心点不正确");
    CGFloat lastDrawPtY = value;
    if(value < KT_INDEX_INVALID_VALUE) //有效值
    {
        lastDrawPtY = [KTindexOper value2Pixel:value Param:param];
    }
    NSMutableArray<__kindof NSValue*> *drawPointArr = [NSMutableArray array];
    if(curveDraw.pointValues.count ==  allCenterX.count) //所有的数据都有效，并且点足够时
    {
        //绘制点前移
        for(NSUInteger pointIndex = 0;pointIndex < curveDraw.pointValues.count - 1;pointIndex ++)
        {
            CGPoint pt = [[curveDraw.pointValues objectAtIndex:pointIndex + 1] CGPointValue];
            pt.x = [[allCenterX objectAtIndex:pointIndex] doubleValue];
            [drawPointArr addObject:[NSValue valueWithCGPoint:pt]];
        }
        [drawPointArr addObject:[NSValue valueWithCGPoint:CGPointMake([allCenterX.lastObject doubleValue], lastDrawPtY)]];
    }
    else //没有绘制满
    {
        if(curveDraw.startPos > 0) //有无效值
        {
            curveDraw.startPos -=1;
            //所有的点前移
            for(NSUInteger pointIndex = 0;pointIndex < curveDraw.pointValues.count;pointIndex ++)
            {
                CGPoint pt = [[curveDraw.pointValues objectAtIndex:pointIndex] CGPointValue];
                pt.x = [[allCenterX objectAtIndex:curveDraw.startPos + pointIndex] doubleValue];
                [drawPointArr addObject:[NSValue valueWithCGPoint:pt]];
            }
            //添加最后一个点的纵坐标
            CGFloat centerX = [[allCenterX objectAtIndex:curveDraw.startPos + drawPointArr.count] doubleValue];
            [drawPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(centerX, lastDrawPtY)]];
        }
        else
        {
            //需要添加点
            [drawPointArr addObjectsFromArray:curveDraw.pointValues];
            //添加最后一个点的纵坐标
            CGFloat centerX = [[allCenterX objectAtIndex:drawPointArr.count] doubleValue];
            [drawPointArr addObject:[NSValue valueWithCGPoint:CGPointMake(centerX, lastDrawPtY)]];

        }
    }
    curveDraw.pointValues = drawPointArr;
}

#pragma mark - 特殊绘制

//曲线数据的设置
+(void)setData:(nonnull NSArray<__kindof KTIndexOneNodeData*> *)indexDataArr toSepDraw:(nonnull KTSepIndexDraw*)sepDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)centerPosx Param:(nonnull KTIndexOperParam*)param
{
    NSAssert(centerPosx.count >= indexDataArr.count, @"曲线计算传入的中心点不正确");
    NSMutableArray<__kindof NSValue*> *firstValueArr = [NSMutableArray array];
    NSMutableArray<__kindof NSValue*> *secondValueArr = [NSMutableArray array];
    for(NSUInteger i = 0;i < indexDataArr.count;i++)
    {
        CGFloat value1 = [[indexDataArr objectAtIndex:i].firstData doubleValue];
        CGFloat value2 = [[indexDataArr objectAtIndex:i].secondData doubleValue];
        if(value1 > KT_INDEX_INVALID_VALUE) //过滤无效值
        {
            continue;
        }
        CGFloat xpos = [[centerPosx objectAtIndex:i] doubleValue];
        CGFloat ypos1 = [KTindexOper value2Pixel:value1 Param:param];
        CGFloat ypos2 = [KTindexOper value2Pixel:value2 Param:param];
        [firstValueArr addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, ypos1)]];
        [secondValueArr addObject:[NSValue valueWithCGPoint:CGPointMake(xpos, ypos2)]];
    }
    [sepDraw setData:firstValueArr sDataArr:secondValueArr];
}

+(void)updateLastNode:(nonnull KTIndexOneNodeData*) nodeData toSepDraw:(nonnull KTSepIndexDraw*)sepDraw  Param:(nonnull KTIndexOperParam*)param
{
    CGFloat value1 = [nodeData.firstData doubleValue];
    CGFloat value2 = [nodeData.secondData doubleValue];
    if(value1 > KT_INDEX_INVALID_VALUE) //过滤无效值
    {
        return;
    }
    CGFloat ypos1 = [KTindexOper value2Pixel:value1 Param:param];
    CGFloat ypos2 = [KTindexOper value2Pixel:value2 Param:param];
    [sepDraw updateLastData:ypos1 secondData:ypos2];
}

+(void)addNextNode:(nonnull KTIndexOneNodeData*) nodeData toSepDraw:(nonnull KTSepIndexDraw*)sepDraw XCenter:(nonnull NSArray<__kindof NSNumber*>*)allCenterX Param:(nonnull KTIndexOperParam*)param
{
    CGFloat value1 = [nodeData.firstData doubleValue];
    if(value1 > KT_INDEX_INVALID_VALUE) //过滤无效值
    {
        return;
    }
    NSArray<__kindof NSValue*> *firstDataArr = [sepDraw getFirstDataArr];
    NSArray<__kindof NSValue*> *secondDataArr = [sepDraw getSecondDataArr];
    NSAssert(allCenterX.count >= firstDataArr.count, @"曲线计算传入的中心点不正确");
    
    NSUInteger drawCount = sepDraw.startPos + sepDraw.validCount;
    NSAssert(drawCount <= allCenterX.count, @"绘制个数不可能超过所有绘制单元个数");
    
    if(drawCount ==  allCenterX.count) //所有的数据都已经绘制了
    {
        NSMutableArray<__kindof NSValue*> *newFirstDataArr = [NSMutableArray array];
        NSMutableArray<__kindof NSValue*> *newSecondDataArr = [NSMutableArray array];
        //绘制点前移
        for(NSUInteger pointIndex = 0;pointIndex < firstDataArr.count - 1;pointIndex ++)
        {
            NSUInteger centerIndex = pointIndex + sepDraw.startPos;
            //firstDataArr
            {
                CGPoint lastPt = [firstDataArr[pointIndex+1] CGPointValue];
                lastPt.x = [allCenterX[centerIndex] doubleValue];
                [newFirstDataArr addObject:[NSValue valueWithCGPoint:lastPt]];
            }
            //secondDataArr
            {
                CGPoint lastPt = [secondDataArr[pointIndex+1] CGPointValue];
                lastPt.x = [allCenterX[centerIndex] doubleValue];
                [newSecondDataArr addObject:[NSValue valueWithCGPoint:lastPt]];
            }
        }
        CGFloat ypos1 = [KTindexOper value2Pixel:value1 Param:param];
        CGFloat ypos2 = [KTindexOper value2Pixel:[nodeData.secondData doubleValue] Param:param];
        [newFirstDataArr addObject:[NSValue valueWithCGPoint:CGPointMake([allCenterX.lastObject doubleValue], ypos1)]];
        [newSecondDataArr addObject:[NSValue valueWithCGPoint:CGPointMake([allCenterX.lastObject doubleValue], ypos2)]];
        [sepDraw setData:newFirstDataArr sDataArr:newSecondDataArr];
        if(sepDraw.startPos > 0)
        {
            sepDraw.startPos -=1;   //无效值减少一个
        }
    }
    else //没有绘制满
    {
        //添加最后一个点的纵坐标
        CGFloat centerX = [allCenterX[drawCount] doubleValue];
        CGFloat ypos1 = [KTindexOper value2Pixel:value1 Param:param];
        CGFloat ypos2 = [KTindexOper value2Pixel:[nodeData.secondData doubleValue] Param:param];
        [sepDraw addNextData:CGPointMake(centerX, ypos1) secondData:CGPointMake(centerX, ypos2)];
    }
}
#pragma mark - 组合

//创建组合指标的绘制单元
+(void)createUnit:(nonnull KTCombinIndexDraw*)comDraw IndexDraw:(nonnull KTIndexStyle*)indexStyle Count:(NSUInteger)count
{
    if(comDraw.drawCount > 0)
    {
        id<KTUnitDrawDelegate> drawUnit = [comDraw getUnitAt:comDraw.drawCount - 1];
        if(NO ==[drawUnit isKindOfClass:[KTindexOper getUnitClass:indexStyle.indexDrawType]])
        {
            [comDraw removeAllDrawUnit]; //移除所有的绘制单元
        }
        else
        {
            //移除多余的元素
            while (comDraw.drawCount > count)
            {
                [comDraw removeLastDrawUnit];
            }
            //补充不足的元素
            while (comDraw.drawCount < count)
            {
                [comDraw addUnitDraw:[drawUnit copyDraw]];
            }
        }
        for(NSUInteger i = 0 ; i < comDraw.drawCount;i++)
        {
            [comDraw mofiyColor:indexStyle.indexColor AtIndex:i];
        }
    }
    //没有绘制对象时，重新构造新的对象
    if(0 ==comDraw.drawCount)
    {
        for(NSUInteger i = 0; i < count;i++)
        {
            id<KTUnitDrawDelegate> drawUint = [KTindexOper createUnitDraw:indexStyle.indexDrawType];
            drawUint.unitColor  = indexStyle.indexColor;
            if(nil != drawUint)
            {
                [comDraw addUnitDraw:drawUint];
            }
        }
    }
}

//设置数据到组合视图
+(void)setIndexData:(nonnull NSArray<__kindof KTIndexOneNodeData*>*)nodeDataArr CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)CenterXArr toComDraw:(nonnull KTCombinIndexDraw*)comDraw Param:(nonnull KTIndexOperParam*)param
{
    NSAssert(CenterXArr.count >=nodeDataArr.count, @"指标绘制中心点个数太少");
    NSAssert(comDraw.drawCount >=nodeDataArr.count, @"指标绘制单元太少");
    for(NSUInteger i = 0; i<nodeDataArr.count;i++)
    {
        id<KTUnitDrawDelegate> drawUnit = [comDraw getUnitAt:i];
        drawUnit.unitXcenter = [[CenterXArr objectAtIndex:i] doubleValue];
        [KTindexOper setData:[nodeDataArr objectAtIndex:i] toUnit:drawUnit Param:param];
    }
}

//更新最后一个绘制单元，不考虑绘制范围的改变
+(void)updateLastUnit:(nonnull id<KTUnitDrawDelegate>)lastUnit nodeData:(nonnull KTIndexOneNodeData*)nodeData Param:(nonnull KTIndexOperParam*)param;
{
    [KTindexOper setData:nodeData toUnit:lastUnit Param:param];
}

//添加一个绘制单元，不考虑绘制范围的改变
+(void)addNextUnittoComDraw:(nonnull KTCombinIndexDraw*)comDraw  nodeData:(nonnull KTIndexOneNodeData*)nodeData CenterXArr:(nonnull NSArray<__kindof NSNumber*>*)centerXArr  Param:(nonnull KTIndexOperParam*)param
{
    NSAssert(centerXArr.count >=comDraw.drawCount, @"指标绘制中心点个数太少");
    NSAssert(comDraw.drawCount > 0, @"没有绘制单元不走这个函数");
    id<KTUnitDrawDelegate> addUnit = nil;
    if(centerXArr.count ==  comDraw.drawCount)  //所有的数据都有效，并且单元足够时
    {
        //后面的单元前移
        for(NSUInteger unitIndex = comDraw.drawCount - 1;unitIndex > 0;unitIndex --)
        {
            [comDraw getUnitAt:unitIndex].unitXcenter = [comDraw getUnitAt:unitIndex - 1].unitXcenter;
        }
        addUnit = [comDraw removeFirstDrawUnit];
    }
    else
    {
        addUnit = [[comDraw getUnitAt:0] copyDraw];
    }
    
    //添加最后一个单元
    addUnit.unitXcenter = [[centerXArr objectAtIndex:comDraw.drawCount] doubleValue];
    [comDraw addUnitDraw:addUnit];
    [KTindexOper setData:nodeData toUnit:addUnit Param:param];
}

#pragma mark - private

+(void)setData:(nonnull KTIndexOneNodeData*)nodeData toUnit:(nonnull id<KTUnitDrawDelegate>) drawUnit Param:(nonnull KTIndexOperParam*)param
{
    if(YES == [drawUnit isKindOfClass:[KTStraightLineUnitDraw class]]) //实心柱子画法
    {
        CGFloat maxValue = [nodeData.firstData doubleValue];
        CGFloat minValue = [nodeData.firstData doubleValue];
        if(1 == nodeData.nodeDataCount)
        {
            maxValue = maxValue > 0 ? maxValue : 0;
            minValue = minValue > 0 ? 0 : minValue;
        }
        else
        {
            maxValue = [nodeData.secondData doubleValue] > [nodeData.firstData doubleValue] ? [nodeData.secondData doubleValue]: [nodeData.firstData doubleValue];
            minValue = [nodeData.secondData doubleValue] < [nodeData.firstData doubleValue] ? [nodeData.secondData doubleValue]: [nodeData.firstData doubleValue];
        }

        KTStraightLineUnitDraw *straigUnit = (KTStraightLineUnitDraw*)drawUnit;
        if(maxValue > KT_INDEX_INVALID_VALUE)  //无效值的处理
        {
            straigUnit.bValid = NO;
        }
        else
        {
            straigUnit.bValid = YES;
            straigUnit.startyPos = [KTindexOper value2Pixel:minValue Param:param];
            straigUnit.endyPos = [KTindexOper value2Pixel:maxValue Param:param];
        }
    }
    else if(YES == [drawUnit isKindOfClass:[KTHollowStickUnitDraw class]]) //空心柱子的画法
    {
        CGFloat maxValue = [nodeData.firstData doubleValue];
        CGFloat minValue = [nodeData.firstData doubleValue];
        if(1 == nodeData.nodeDataCount)
        {
            maxValue = maxValue > 0 ? maxValue : 0;
            minValue = minValue > 0 ? 0 : minValue;
        }
        else
        {
            maxValue = [nodeData.secondData doubleValue] > [nodeData.firstData doubleValue] ? [nodeData.secondData doubleValue]: [nodeData.firstData doubleValue];
            minValue = [nodeData.secondData doubleValue] < [nodeData.firstData doubleValue] ? [nodeData.secondData doubleValue]: [nodeData.firstData doubleValue];
        }
        
        KTHollowStickUnitDraw *hollowUnit = (KTHollowStickUnitDraw*)drawUnit;
        if(maxValue > KT_INDEX_INVALID_VALUE)  //无效值的处理
        {
            hollowUnit.bValid = NO;
        }
        else
        {
            hollowUnit.bValid = YES;
            hollowUnit.startyPos = [KTindexOper value2Pixel:minValue Param:param];
            hollowUnit.endyPos = [KTindexOper value2Pixel:maxValue Param:param];
        }
      
    }
    else if(YES == [drawUnit isKindOfClass:[KTCircleUnitDraw class]]) //圆的画法
    {
        KTCircleUnitDraw *circleUnit = (KTCircleUnitDraw*)drawUnit;
        CGFloat value = [nodeData.firstData doubleValue];
        if(value > KT_INDEX_INVALID_VALUE)  //无效值的处理
        {
            circleUnit.bValid = NO;
        }
        else
        {
            circleUnit.bValid = YES;
            circleUnit.yPosCenter = [KTindexOper value2Pixel:value Param:param];;
        }
    }
    else if(YES == [drawUnit isKindOfClass:[KTIconUnitDraw class]]) //特殊图形的画法
    {
        KTIconUnitDraw *iconUnit = (KTIconUnitDraw*)drawUnit;
        CGFloat value = [nodeData.firstData doubleValue];
        if(value > KT_INDEX_INVALID_VALUE)  //无效值的处理
        {
            iconUnit.bValid = NO;
        }
        else
        {
            iconUnit.bValid = YES;
            iconUnit.yPosCenter = [KTindexOper value2Pixel:value Param:param];;
        }
    }
    else if(YES == [drawUnit isKindOfClass:[KTTextUnitDraw class]]) //文字绘制
    {
       // KTTextUnitDraw *textUnit = (KTTextUnitDraw*)drawUnit;
    }
    else
    {
        NSAssert(false, @"遇到没有的绘制单元");
    }
}


+(Class)getUnitClass:(KTIndexDrawType)drawType
{
    if(KTIndexDrawTypeVol == drawType)
    {
        return [KTStraightLineUnitDraw class];
    }
    else if(KTIndexDrawTypeCircle == drawType)
    {
        return [KTCircleUnitDraw class];
    }
    else if(KTIndexDrawTypeColorStick == drawType)
    {
        return [KTStraightLineUnitDraw class];
    }
    else if(KTIndexDrawTypeHollowStick == drawType)
    {
        return [KTHollowStickUnitDraw class];
    }
    else if(KTIndexDrawTypeIcon == drawType)
    {
        return [KTIconUnitDraw class];
    }
    else if(KTIndexDrawTypeText == drawType)
    {
        return [KTTextUnitDraw class];
    }
    else
    {
        NSLog(@"没有找到对应的绘制单元");
        return [KTStraightLineUnitDraw class];
    }
}

+(nonnull id<KTUnitDrawDelegate>)createUnitDraw:(KTIndexDrawType)drawType
{
    Class class = [KTindexOper getUnitClass:drawType];
    return [[class alloc] init];
}

//获取绘制对象
+(nonnull id<KTIndexDelegate>)createIndexDraw:(KTIndexDrawType) drawType from:(nonnull NSArray<__kindof id<KTIndexDelegate>>*)drawArr
{
    Class drawClass = [KTindexOper getIndexDrawClass:drawType];
    id<KTIndexDelegate> drawDelegate = nil;
    for(id<KTIndexDelegate> indexDraw in drawArr)
    {
        if(YES == [indexDraw isKindOfClass:drawClass])
        {
            drawDelegate = indexDraw;
            break;
        }
    }
    if(nil == drawDelegate)
    {
        drawDelegate = [[drawClass alloc] init];
    }
    return drawDelegate;
}

+(Class)getIndexDrawClass:(KTIndexDrawType) drawType
{
    if(KTIndexDrawTypeCurve == drawType)
    {
        return [KTCurveIndexDraw class];
    }
    else if(KTIndexDrawTypeAreaSep == drawType)
    {
        return [KTSepIndexDraw class];
    }
    return [KTCombinIndexDraw class];
}


+(CGFloat)value2Pixel:(CGFloat)value Param:(nonnull KTIndexOperParam*)param
{
    return [KTCalcuLationOper valueToPixel:value minValue:param.minValue MaxValue:param.maxValue Rect:param.drawRect];
}
@end

#pragma mark - KTIndexOperParam

@implementation KTIndexOperParam


@end
