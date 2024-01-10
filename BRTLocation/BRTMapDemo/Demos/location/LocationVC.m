//
//  beaconVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocationVC.h"
#import <BRTLocationEngine/BRTLocationEngine.h>

@interface LocationVC ()<BRTLocationManagerDelegate>
@property (nonatomic ,strong) BRTLocationManager *locationManager;
@property (nonatomic ,strong) CLLocationManager *lm;
@property (nonatomic ,strong) NSArray *locationBeacons;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

//使用完毕，一定结束定位，否则闪退。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdateLocation];
    self.locationManager = nil;
}

#pragma mark - **************** 地图回调方法

- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error{
    [super mapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请至少配置一个定位设备" message:@"UUID:FDA50693-A4E2-4FB1-AFCF-C6EB076478250\nmajor:10186\nminor:47997~48000" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"配置工具" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://app.brtbeacon.com/brightbeacon"]];
    }]];
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceRect = self.view.bounds;
        alert.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:alert animated:YES completion:nil];
//    [self.mapView setLocationSymbol:(UIImage *)];
    
    //可选设置请求运行时位置权限；需plist对应配置
    [BRTBLEEnvironment setRequestWhenInUseAuthorization:YES];
    
    //初始化定位数据
    self.locationManager = [[BRTLocationManager alloc] initWithBuilding:self.mapView.building appKey:kAppKey];
    
    //设置定位设备信号阈值
    [self.locationManager setRssiThreshold:-80];
    self.locationManager.delegate = self;
    
    //定位超时错误回调时间（秒）
    self.locationManager.requestTimeOut =  10;
    
    //限制最大定位设备个数5个
    [self.locationManager setMaxBeaconNumberForProcessing:5];
    [self.locationManager setLimitBeaconNumber:YES];
    
    //关闭定位热力数据上传
    [self.locationManager enableHeatData:NO];
    
    //启动定位
    [self.locationManager startUpdateLocation];

}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    //若有定位，从定位点开始规划路线
    if (self.locationManager.getLastLocation) {
        BRTLocalPoint *end = [BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:mapView] Floor:mapView.currentFloor];
        [self.mapView.routeManager requestRouteWithStart:self.locationManager.getLastLocation end:end];
    }
}

#pragma mark - **************** 定位回调方法

//返回beacon定位，固定1s/次
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateImmediateLocation:(BRTLocalPoint *)newImmediateLocation {
    //不要和didUpdateLocation同时显示位置，会导致位置跳动
    //[self.mapView showLocation:newImmediateLocation];
}

//返回beacon + 传感器优化定位，最快0.2s/次
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateLocation:(BRTLocalPoint *)newLocation {
    [self.mapView showLocation:newLocation];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.coordinate = newLocation.coordinate;
    ann.title = @"1";
    [self.mapView addAnnotation:ann];
}
/**
 *  位置更新失败事件回调
 *
 *  @param manager 定位引擎实例
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didFailUpdateLocation:(NSError *)error {
    NSLog(@"定位失败：%@",error);
    self.title = error.userInfo.allValues.description;
}

/**
 *  Beacon扫描结果事件回调，返回符合扫描参数的所有Beacon
 *
 *  @param manager 定位引擎实例
 *  @param beacons Beacon数组，[BRTBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedBeacons:(NSArray *)beacons {
//    NSLog(@"all beacons find:%@",beacons);
}

/**
 *  定位Beacon扫描结果事件回调，返回符合扫描参数的定位Beacon，定位Beacon包含坐标信息。此方法可用于辅助巡检，以及基于定位beacon的相关触发事件。
 *
 *  @param manager 定位引擎实例
 *  @param beacons 定位Beacon数组，[BRTPublicBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedLocationBeacons:(NSArray *)beacons {
    //显示扫描到的Beacon设备信息
    [self.mapView removeAnnotations:self.mapView.annotations];
    NSMutableArray *marray = [NSMutableArray array];
    NSInteger i = 0;
    for (BRTPublicBeacon *pb in beacons) {
        i++;
        if (pb.location.floor == self.mapView.currentFloor) {
            MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
            ann.coordinate = pb.location.coordinate;
            ann.title = [pb.minor.stringValue stringByAppendingFormat:@",%d(%ld)",pb.rssi,i];
            [marray addObject:ann];
        }
    }
    [self.mapView addAnnotations:marray];
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(nonnull id<MGLAnnotation>)annotation {
    NSString *reuseID = annotation.title;
    MGLAnnotationImage *annView = [mapView dequeueReusableAnnotationImageWithIdentifier:reuseID];
    if (annView == nil) {
        UIImage *image = [self imageFromString:reuseID attributes:nil size:CGSizeMake(80, 20)];
        annView = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:reuseID];
    }
    return annView;
}

- (UIImage *)imageFromString:(NSString *)string attributes:(NSDictionary *)attributes size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withAttributes:attributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  设备方向改变事件回调。处理方向箭头等功能。
 *
 *  @param manager    定位引擎实例
 *  @param mapHeading 新的方向结果
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateMapHeading:(double)mapHeading {
    NSLog(@"地图北偏角：%f",mapHeading);
    [self.mapView processDeviceRotation:mapHeading];
}
@end

