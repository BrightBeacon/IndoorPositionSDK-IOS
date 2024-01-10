//
//  SearchDistanceVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchDistanceVC.h"
#import <BRTMapSDK/BRTSearchAdapter.h>
#import <BRTMapSDK/MercatorConvert.h>

@interface SearchDistanceVC ()

@end

@implementation SearchDistanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    [mapView removeAnnotations:mapView.annotations];
    
    CLLocationCoordinate2D coord = [mapView convertPoint:screen toCoordinateFromView:mapView];
    [mapView addAnnotation:[self getCircle:[MercatorConvert toMercator:coord] R:50]];
    
    BRTSearchAdapter *adapter = [[BRTSearchAdapter alloc] initWithBuildingID:self.buildingID distinct:1.0];
    NSArray *pois = [adapter queryPoiByCenter:coord Radius:50 Floor:mapView.currentFloor];
    NSMutableArray *annotations = [NSMutableArray array];
    for (BRTPoi *pe in pois) {
        MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
        ann.coordinate = pe.labelPoint.coordinate;
        ann.title = pe.name;
        ann.subtitle = pe.poiID;
        [annotations addObject:ann];
    }
    [mapView addAnnotations:annotations];
}

//画圆形
- (MGLPolygon *)getCircle:(IPVector *)center R:(double) radius {
    CLLocationCoordinate2D points[50];
    double sin;
    double cos;
    double x;
    double y;
    for (double i = 0; i < 50; i++) {
        sin = sinf(M_PI * 2 * i / 50.0);
        cos = cosf(M_PI * 2 * i / 50.0);
        x = center.x + radius * sin;
        y = center.y + radius * cos;
        points[(int) i] = [MercatorConvert toCoordX:x Y:y];
    }
    return [MGLPolygon polygonWithCoordinates:points count:50];
}

//配置显示颜色和透明度
- (UIColor *)mapView:(BRTMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation {
    return [UIColor cyanColor];
}
- (CGFloat)mapView:(BRTMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation {
    return 0.5;
}
@end

