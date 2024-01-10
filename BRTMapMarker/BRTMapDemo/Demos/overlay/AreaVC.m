//
//  AreaVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "AreaVC.h"
#import <BRTMapSDK/GeometryEngine.h>

@interface AreaVC ()
{
    CLLocationCoordinate2D *polygonCoords;
    NSInteger index;
    UILabel *tipLabel;
}

@end

@implementation AreaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tipLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    tipLabel.text = @"请任意点击三点";
    [self.view addSubview:tipLabel];
    
    polygonCoords = malloc(sizeof(CLLocationCoordinate2D)* 100);
    
    self.mapView.tintColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.99];
}


#pragma mark - **************** mapview

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    
    polygonCoords[index++] = [self.mapView convertPoint:screen toCoordinateFromView:mapView];
    
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.coordinate = polygonCoords[index-1];
    [mapView addAnnotation:ann];
    
    if (index > 2) {
        MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:polygonCoords count:index];
        [mapView addAnnotation:polygon];
        
        tipLabel.text = [NSString stringWithFormat:@"面积%.2f平方米",[[GeometryEngine defaultEngine] areaOfGeometry:polygon]];
    }
}


@end
