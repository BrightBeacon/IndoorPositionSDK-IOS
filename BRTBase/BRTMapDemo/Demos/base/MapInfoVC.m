//
//  MapInfoVC.m
//  mapdemo
//
//  Created by 何涛 on 2017/7/18.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapInfoVC.h"

@interface MapInfoVC ()

@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation MapInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 140)];
    self.tipsLabel.numberOfLines = 0;
    [self.view addSubview:self.tipsLabel];
}

- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo {
    NSString *tips = [NSString stringWithFormat:@"地图信息：%@  \n北偏角：%0.2f\n楼层信息：%@\n缩放等级：%.2f",mapView.building.name,mapView.building.initAngle,floorInfo.mapID,mapView.zoomLevel];
    self.tipsLabel.text = tips;
}

- (void)mapViewRegionIsChanging:(BRTMapView *)mapView {
    NSString *tips = [NSString stringWithFormat:@"地图信息：%@  \n地图倾斜：%0.2f\n地图旋转：%0.2f\n缩放等级：%.2f",mapView.building.name,mapView.camera.pitch,mapView.direction,mapView.zoomLevel];
    self.tipsLabel.text = tips;
}

@end
