//
//  MapSetting.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/20.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapSetting.h"
#import <BRTMapSDK/MercatorConvert.h>

@interface MapSetting ()

@end

@implementation MapSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 200, 100, 44)];
    [btn setTitle:@"缩放地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"倾斜地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"旋转地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 3;
    [btn setTitle:@"移动中心点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-60, 44, 44)];
    [btn setTitle:@"重置" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self.mapView setZoomLevel:MIN(self.mapView.zoomLevel + 1, 22) animated:YES];
            break;
        case 1:{
                MGLMapCamera *camera = self.mapView.camera;
                camera.pitch = 45;
                [self.mapView setCamera:camera];
            }
            break;
        case 2:
            [self.mapView setDirection:self.mapView.direction + 90 animated:YES];
            break;
        case 3:
            [self.mapView setCenterCoordinate:[self.mapView convertPoint:self.view.center toCoordinateFromView:nil] animated:YES];
            break;
            
        default:
            break;
    }
}

- (IBAction)resetButtonClicked:(id)sender {
    [self.mapView resetPosition];
    BRTFloorInfo *info = self.mapView.currentFloorInfo;
    MGLCoordinateBounds bounds = MGLCoordinateBoundsMake([MercatorConvert toCoordX:info.mapExtent.xmin Y:info.mapExtent.ymax],[MercatorConvert toCoordX:info.mapExtent.xmax Y:info.mapExtent.ymin]);
    [self.mapView setVisibleCoordinateBounds:bounds];
}
@end
