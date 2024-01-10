//
//  LineVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "LineVC.h"
#import <BRTMapSDK/GeometryEngine.h>

@interface LineVC ()
{
    UILabel *tipLabel;
    CLLocationCoordinate2D *mapCoords;
    NSInteger index;
}
@end

@implementation LineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    tipLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    tipLabel.text = @"请任意点击两点连线";
    [self.view addSubview:tipLabel];
    
    mapCoords = malloc(sizeof(CLLocationCoordinate2D)* 100);
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    
    CLLocationCoordinate2D coord = [self.mapView convertPoint:screen toCoordinateFromView:nil];
    mapCoords[index++] = coord;
    
    if (index > 1) {
        MGLPolyline *polyline = [MGLPolyline polylineWithCoordinates:mapCoords count:index];
        [mapView addAnnotation:polyline];
        
        MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
        ann.coordinate = coord;
        [mapView addAnnotation:ann];
        
        tipLabel.text = [NSString stringWithFormat:@"全长%.2f米",[[GeometryEngine defaultEngine] lengthOfGeometry:polyline]];
    }
}

@end
