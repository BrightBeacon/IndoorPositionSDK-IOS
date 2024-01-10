//
//  GeometryEngine.h
//  BRTMapProject
//
//  Created by thomasho on 2018/4/18.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapbox/Mapbox.h>
#import "GeometryResult.h"

@interface GeometryEngine : NSObject

+ (GeometryEngine *)defaultEngine;

/**
获得线段长度

@param line 线
@return 长度
*/
- (CLLocationDistance)lengthOfGeometry:(MGLPolyline *)line;

/**
获得区域面积

@param polygon 区域
@return 面积
*/
- (double)areaOfGeometry:(MGLPolygon *)polygon;

/**
获得两点经纬度距离

@param from 起点
@param to 终点
@return 长度
*/
- (CLLocationDistance)distanceBetweenCoordinates:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;


/**
获取Line上距离Point最近的点

@param line 目标Line
@param point 点
@return 距离
*/
- (CLLocationDistance)distanceToGeometry:(MGLPolyline *)line toPoint:(CLLocationCoordinate2D)point;


/**
获取Line上距离Point最近的点及距离结果

@param line 目标Line
@param point 点
@return 返回查找结果
 */
- (GeometryResult *)nearestCoordinateInGeometry:(MGLPolyline *)line toPoint:(CLLocationCoordinate2D)point;


/**
区域是否包含点

@param polygon 区域
@param coordinate 点
@return 是否包含
*/
- (BOOL)geometry:(MGLPolygon *)polygon contains:(CLLocationCoordinate2D )coordinate;


/**
 获得线上距离为distance的坐标

 @param line 线
 @param distance 距离
 @return 点
 */
- (CLLocationCoordinate2D)pointOnLine:(MGLPolyline *)line atDistance:(double)distance;


/**
 两点切割线段
 
 按照两点距离在该线上最接近的两点进行切割，如果两点临近线上同一点，返回nil

 @param line 线
 @param start 切割临近点
 @param end 切割临近点
 @return 中间线段
 */
- (MGLPolyline * _Nullable)cutLine:(MGLPolyline *_Nonnull)line start:(CLLocationCoordinate2D)start end:(CLLocationCoordinate2D)end;

@end
