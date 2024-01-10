//
//  ViewController.m
//  mapdemo
//
//  Created by thomasho on 16/5/20.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "LocationDemoVC.h"
#import <BRTMapSDK/GeometryEngine.h>
#import <AVFoundation/AVFoundation.h>
#import <BRTLocationEngine/BRTLocationEngine.h>
#import <BRTMapSDK/BRTOfflineRouteManager.h>

@interface LocationDemoVC ()<BRTMapViewDelegate,BRTRouteManagerDelegate,BRTOfflineRouteManagerDelegate,BRTLocationManagerDelegate,UISearchBarDelegate>{
    IBOutlet UILabel *hintLabel;
    BRTDirectionalHint *_lastHint;
}

//语音合成器
@property (nonatomic,strong) AVSpeechSynthesizer *speech;
//定位管理器
@property (nonatomic,strong) BRTLocationManager *locationManager;
@end

@implementation LocationDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 100, 100, 44)];
    [btn setImage:[UIImage imageNamed:@"locbutton"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moniButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdateLocation];
}
#pragma mark - mapViewDidLoad
- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error{
    [super mapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    //自定义定位标识
    //[self.mapView setLocationSymbol:(UIImage *)];
    
    //初始化路径规划
    self.mapView.routeManager.delegate = self;
    
    //定位初始化
    //可选设置请求运行时位置权限；需plist对应配置
    //[BRTBLEEnvironment setRequestWhenInUseAuthorization:YES];
    
    //初始化定位数据
    self.locationManager = [[BRTLocationManager alloc] initWithBuilding:self.mapView.building appKey:kAppKey];
    
    //设置定位设备信号阈值
    [self.locationManager setRssiThreshold:-90];
    self.locationManager.delegate = self;
    
    //定位超时错误回调时间（秒）
    self.locationManager.requestTimeOut =  10;
    
    //限制最大定位设备个数5个
    [self.locationManager setMaxBeaconNumberForProcessing:5];
    [self.locationManager setLimitBeaconNumber:YES];
    
    //关闭定位热力数据上传
    [self.locationManager enableHeatData:NO];
    
    //开始定位
    [self.locationManager startUpdateLocation];
}

#pragma mark - **************** 定位回调
/**
 *  设备方向改变事件回调。处理方向箭头等功能。
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateMapHeading:(double)mapHeading {
    NSLog(@"地图北偏角：%f",mapHeading);
    [self.mapView processDeviceRotation:mapHeading];
}
//定位失败，未扫描到设备
- (void)BRTLocationManager:(BRTLocationManager *)manager didFailUpdateLocation:(NSError *)error {
    NSLog(@"didFailUpdateLocation:%@",error);
}

- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateLocation:(BRTLocalPoint *)newLocation{
    
    //初次移到中心点
    if (manager.getLastLocation == nil) {
        [self.mapView setCenterCoordinate:newLocation.coordinate];
    }
    
    // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
    if (self.mapView.currentFloor != newLocation.floor) {
        [self.mapView setFloor:newLocation.floor];
        return;
    }
    
    if (self.mapView.routeResult == nil) {
        //无路径规划显示，直接显示定位
        [self.mapView showLocation:newLocation animated:YES];
        return;
    }
    
    //有路径规划，判断是否到达终点附近，是否偏航等。进行提示。
    if ([self.mapView.routeResult isDeviatingFromRoute:newLocation withThrehold:5]) {
        //偏航5米，重新规划路径
        [self.mapView setRouteStart:newLocation];
        [self requestRoute];
        [self textToSpeech:@"你已偏航，重新规划路线。"];
        return;
    }
    
    double distance2end = [self.mapView.routeResult distanceToRouteEnd:newLocation];
    if (distance2end < 5) {
        [self.mapView removeRouteLayer];
        [self textToSpeech:@"已到达终点附近,本次导航结束。"];
        return;
    }
    //导航中，未偏航，可以直接吸附到最近的路径上。注意：本层可能无路网
    BRTRoutePart *part = [self.mapView.routeResult getNearestRoutePart:newLocation];
    if (part == nil) {
        [self.mapView showLocation:newLocation];
        return;
    }
    
    //显示路过和余下线段
    [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:newLocation];
    
    //吸附到路网上
    newLocation = [self.mapView.routeResult getNearPointOnRoute:newLocation];
    [self.mapView showLocation:newLocation];
    
    //移动位置超过3米，进行导航提示(记录hint防重复播报)
    NSArray *routeGuides = [part getRouteDirectionalHintsIgnoreDistance:3 angle:15];
    BRTDirectionalHint *hint = [part getDirectionHintForLocation:newLocation FromHints:routeGuides];
    if(hint == _lastHint) return;
    _lastHint = hint;
    
    //计算当前位置点，距离本段结束点、终点距离
    float len2End = [newLocation distanceWith:[BRTLocalPoint pointWithCoor:hint.endPoint Floor:newLocation.floor]];
    if (hint.length <= 10 || len2End <= 10) {
        if(hint.nextHint)[self textToSpeech:[NSString stringWithFormat:@"前方%@",[hint.nextHint getDirectionString]]];
        else if(part.nextPart)[self textToSpeech:[NSString stringWithFormat:@"前方乘扶梯到%d楼",part.nextPart.floor]];
        else [self textToSpeech:@"即将到达终点"];
    }else {
        //当前路段中间，或含微小弯道(依据getRouteDirectionalHintsIgnoreDistance:angle:)或直行部分
        [self textToSpeech:[NSString stringWithFormat:@"沿路前行%.0f米",len2End]];
    }
}

#pragma mark - **************** 路径规划

/**
 在线路网规划回调
 */
- (void)routeManager:(BRTRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)routeManager:(BRTRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs
{
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
    
    NSArray<BRTRoutePart *> *routePartArray = [rs getRoutePartsOnFloor:self.mapView.currentFloor];
    if (routePartArray && routePartArray.count > 0) {
        MGLPolyline *route = routePartArray.firstObject.route;
        [self.mapView setVisibleCoordinates:route.coordinates count:route.pointCount edgePadding:UIEdgeInsetsZero animated:YES];
    }
    double len = self.mapView.routeResult.length;
    int min = ceil(len/80);
    [self textToSpeech:[NSString stringWithFormat:@"开始导航，全程%.0f米，大约需要%d分钟",len,min]];
}

/**
 离线路网规划回调
 */
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
    [self routeManager:nil didSolveRouteWithResult:rs];
}
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    [self textToSpeech:@"路径规划失败"];
}
#pragma mark - **************** 地图回调

- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo
{
    [self.mapView showRouteResultOnCurrentFloor];
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen
{
    [self.view endEditing:YES];
    BRTLocalPoint *lp = [BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:nil] Floor:mapView.currentFloor];
    if (mapView.routeResult) {
        //模拟定位
        [self BRTLocationManager:self.locationManager didUpdateLocation:lp];
        return;
    }
    if (mapView.routeStart == nil) {
        [mapView setRouteStart:lp];
        [mapView showRouteStartSymbolOnCurrentFloor:lp];
    }else {
        [mapView setRouteEnd:lp];
        [self requestRoute];
    }
}

#pragma mark - **************** methods

- (void)requestRoute
{
    //在线规划
    //[self.mapView.routeManager requestRouteWithStart:self.mapView.routeStart End:self.mapView.routeEnd];
    
    //离线规划
    [self.mapView.routeOfflineManager requestRouteWithStart:self.mapView.routeStart end:self.mapView.routeEnd];
}

#pragma mark - Actions

- (IBAction)moniButtonClicked:(UIButton *)sender {
    if (self.mapView.routeResult) {
        NSArray *parts = [self.mapView.routeResult getRoutePartsOnFloor:self.mapView.currentFloor];
        BRTRoutePart *part = parts.firstObject;
        
        NSInteger index = sender.tag;
        if (index >= part.points.count) {
            index = 0;
        }
        BRTLocalPoint *pt = part.points[index];
        //模拟定位
        [self BRTLocationManager:self.locationManager didUpdateLocation:pt];
        [sender setTag:index + 1];
    }else{
        self.title = @"先规划路线";
    }
}
- (IBAction)cancelButtonClicked:(id)sender {
    [_locationManager stopUpdateLocation];
    [self.mapView removeLocation];
    [self.mapView removeRouteLayer];
    [self.view endEditing:YES];
}

#pragma mark - IOS自带语音合成
- (AVSpeechSynthesizer *)speech {
    if (!_speech) {
        _speech = [[AVSpeechSynthesizer alloc] init];
    }
    return _speech;
}

- (IBAction)textToSpeech:(NSString *)text
{
    [self.speech stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:text];  //需要转换的文本
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer < 9) {
        utterance.rate = 0.15;
    }else if(sysVer == 9){
        utterance.rate = 0.53;
    }else{
        utterance.rate = 0.5;
    }
    //    utterance.pitchMultiplier = 2;
    [self.speech speakUtterance:utterance];
}
@end

