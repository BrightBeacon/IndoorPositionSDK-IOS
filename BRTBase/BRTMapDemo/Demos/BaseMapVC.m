//
//  BaseMapVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "BaseMapVC.h"
#import <BRTMapSDK/BRTRouteManager.h>
@interface BaseMapVC ()<UIActionSheetDelegate,BRTMapViewDelegate>
@property (nonatomic,strong) UIButton *floorButton;
@end

@implementation BaseMapVC

- (void)viewDidLoad {
    NSLog(@"当前地图SDK版本：%@",[BRTMapEnvironment getSDKVersion]);
    
    self.mapView = [[BRTMapView alloc] initWithFrame:self.view.bounds];
    [self.mapView setBackgroundColor:[UIColor whiteColor]];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    [self.mapView setDelegate:self];
    [self.mapView loadWithBuilding:_buildingID appkey:_appKey];
}

- (void)dealloc {
	NSLog(@"check if '%@' recycled",NSStringFromClass(self.class));
}

#pragma mark - **************** 地图加载完成回调
- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error {
    if (!error) {
        [self showZoomControl];
        [self showFloorControl];
    }else{
        [[[UIAlertView alloc] initWithTitle:error.domain message:[NSString stringWithFormat:@"地图加载错误：%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - **************** 楼层、缩放控件示例
- (void)showFloorControl
{
    [_floorButton removeFromSuperview];
    
    _floorButton = [[UIButton alloc] initWithFrame:CGRectMake(100, self.view.frame.size.height-60, self.view.bounds.size.width-200, 42)];
    _floorButton.layer.cornerRadius = 21;
    [_floorButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _floorButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _floorButton.layer.borderWidth = 1.0;
    [_floorButton setBackgroundColor:[UIColor whiteColor]];
    [_floorButton setTitle:[self.mapView.floorInfos.firstObject valueForKey:@"floorName"] forState:UIControlStateNormal];
    [_floorButton addTarget:self action:@selector(showFloor:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_floorButton];
}

- (void)showFloor:(UIButton *)sender {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择楼层" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (BRTFloorInfo *mapInfo in self.mapView.floorInfos) {
        [sheet addAction:[UIAlertAction actionWithTitle:mapInfo.floorName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *floorName = action.title;
            BRTFloorInfo *mapInfo = [BRTFloorInfo searchMapInfoFromArray:weakSelf.mapView.floorInfos FloorName:floorName];
            [weakSelf.mapView setFloor:mapInfo.floorNumber];
            [weakSelf.floorButton setTitle:floorName forState:UIControlStateNormal];
        }]];
    }
    UIPopoverPresentationController *popVC = sheet.popoverPresentationController;
    if (popVC) {
        popVC.sourceRect = self.floorButton.bounds;
        popVC.sourceView = self.floorButton;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)showZoomControl {
    CGRect frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 160, 40, 40);
    UIButton *zin = [[UIButton alloc] initWithFrame:frame];
    [zin setImage:[UIImage imageNamed:@"zoomin"] forState:UIControlStateNormal];
    [zin addTarget:self action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zin];
    
    frame = CGRectMake(self.view.bounds.size.width - 60, self.view.bounds.size.height - 120, 40, 40);
    UIButton *zout = [[UIButton alloc] initWithFrame:frame];
    [zout setImage:[UIImage imageNamed:@"zoomout"] forState:UIControlStateNormal];
    [zout addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zout];
}

- (void)zoomIn:(id)sender {
    [self.mapView setZoomLevel:MIN(self.mapView.maximumZoomLevel, self.mapView.zoomLevel+1)];
}

- (void)zoomOut:(id)sender {
    [self.mapView setZoomLevel:MAX(self.mapView.minimumZoomLevel, self.mapView.zoomLevel-1)];
}
@end
