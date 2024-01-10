//
//  MapCoorVC.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapCoorVC.h"
#import <BRTMapSDK/MercatorConvert.h>

@interface MapCoorVC ()

@property (nonatomic,strong) UILabel *tipsLabel;
@property (nonatomic,strong) NSArray *customCoors;

@end

@implementation MapCoorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 80)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.font  = [UIFont systemFontOfSize:13];
    self.tipsLabel.text = @"坐标转换";
    [self.view addSubview:self.tipsLabel];
    
}


- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo {
    double xmin = floorInfo.mapExtent.xmin;
    double xmax = floorInfo.mapExtent.xmax;
    double ymin = floorInfo.mapExtent.ymin;
    double ymax = floorInfo.mapExtent.ymax;
    //周围坐标
    CLLocationCoordinate2D mapCoords[] ={[MercatorConvert toCoordX:xmin Y:ymin],
        [MercatorConvert toCoordX:xmin Y:ymax],
        [MercatorConvert toCoordX:xmax Y:ymax],
        [MercatorConvert toCoordX:xmax Y:ymin],
        [MercatorConvert toCoordX:xmin Y:ymin]};
    
    // Remove any existing polyline(s) from the map.
    if (self.mapView.annotations.count) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    //显示红色矩形边框
    MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:mapCoords count:5];
    [self.mapView addAnnotation:polyline];
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    CLLocationCoordinate2D latlng = [mapView convertPoint:screen toCoordinateFromView:mapView];
    self.tipsLabel.text = [NSString stringWithFormat:@"屏幕坐标：%.4f,%.4f\n地图经纬度：%.4f,%.4f\n",screen.x,screen.y,latlng.latitude,latlng.longitude];
}

@end
