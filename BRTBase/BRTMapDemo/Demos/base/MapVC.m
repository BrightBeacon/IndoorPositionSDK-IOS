//
//  MapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()
@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //自动高亮
    self.mapView.highlightPOIOnSelection = YES;
    
    //默认高亮颜色
//    [self.mapView setDefaultHighlightColor:[UIColor cyanColor]];
}

#pragma mark - **************** 地图回调
- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    CLLocationCoordinate2D mappoint = [mapView convertPoint:screen toCoordinateFromView:mapView];
    [mapView showLocation:[BRTLocalPoint pointWithCoor:mappoint Floor:mapView.currentFloor]];
}

//地图楼层切换
- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo
{
    NSLog(@"%@",floorInfo);
}

//随机高亮颜色
- (UIColor *)mapView:(BRTMapView *)mapView highlightColorForPoi:(BRTPoi *)poi {
    return [UIColor colorWithRed:arc4random()%255/255. green:arc4random()%255/255. blue:arc4random()%255/255. alpha:1];
}

@end
