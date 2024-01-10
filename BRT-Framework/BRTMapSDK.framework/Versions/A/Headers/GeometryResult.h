//
//  GeometryResult.h
//  BRTMapProject
//
//  Created by thomasho on 2018/5/11.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GeometryResult : NSObject

/// 相交段起点坐标
@property (nonatomic,assign) CLLocationCoordinate2D preCoordinate;

/// 相交段末点坐标
@property (nonatomic,assign) CLLocationCoordinate2D nextCoordinate;

/// 相交点坐标
@property (nonatomic,assign) CLLocationCoordinate2D crossCoordinate;

/// 相交段～整段路径中：index
@property (nonatomic,assign) NSUInteger pointIndex;

/// 整段路径～相交点：总长
@property (nonatomic,assign) CLLocationDistance preDistance;

/// 相交点～整段路尾：总长
@property (nonatomic,assign) CLLocationDistance nextDistance;

/// 相交点～传入点：距离
@property (nonatomic,assign) CLLocationDistance crossDistance;


/// 相交点=起点=终点
/// @param coord 相交点
+ (instancetype)resultWithCoordinate:(CLLocationCoordinate2D)coord;

/// 相交点，本段起点，本段末点
/// @param coord 相交点
/// @param pre 本段起点
/// @param next 本段终点
/// @param index 本段所在整段index
+ (instancetype)resultWithCoordinate:(CLLocationCoordinate2D)coord pre:(CLLocationCoordinate2D)pre next:(CLLocationCoordinate2D)next index:(NSUInteger)index;

@end
