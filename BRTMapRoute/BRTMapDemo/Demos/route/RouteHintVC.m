//
//  RouteHintVC.m
//  mapdemo
//
//  Created by thomasho on 2017/8/1.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteHintVC.h"
#import <BRTMapSDK/GeometryEngine.h>
#import <AVFoundation/AVFoundation.h>

@interface RouteHintVC ()<BRTRouteManagerDelegate> {
    double distancePassed;
}
@property (nonatomic,strong) AVSpeechSynthesizer *speech;
@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation RouteHintVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 120)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = @"距离提示";
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"模拟导航" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)moveButtonClicked:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    BRTRouteResult *rs = weakSelf.mapView.routeResult;
    BRTRoutePart *part = [rs getRoutePartsOnFloor:weakSelf.mapView.routeStart.floor].firstObject;
    if (part == nil) {
        return;
    }
    distancePassed = 0;
    BRTDirectionalHint *hint = [part getDirectionHintForLocation:part.getFirstPoint FromHints:[part getRouteDirectionalHintsIgnoreDistance:0 angle:10]];
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:hint.startPoint fromDistance:19 pitch:50 heading:hint.currentAngle];
    [self.mapView setCamera:camera withDuration:2 animationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] completionHandler:^{
        [weakSelf moveToLocalPoint:part.getFirstPoint];
    }];
}


- (void)moveToLocalPoint:(BRTLocalPoint *)lp {
    //如果楼层不一致，切换楼层
    if (lp.floor != self.mapView.currentFloor) {
        [self.mapView setFloor:lp.floor];
    }
    
    //显示定位点
    [self showLocationAnnotation:lp];
    
    //显示路径经过段和结束段分隔
    //    [self.mapView showRemainingRouteResultOnCurrentFloor:lp];
    //    [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:lp];
    
    //是否到达终点附近0.5米
    BRTRouteResult *rs = self.mapView.routeResult;
    if ([rs distanceToRouteEnd:lp] < 0.5) {
        return;
    }
    
    //lp临近的路径段，本层若没有会返回nil
    BRTRoutePart *part = [rs getNearestRoutePart:lp];
    if (part == nil) {
        return;
    }
    
    //获取part上距离坐标
    GeometryEngine *engine = [GeometryEngine defaultEngine];
    BRTLocalPoint *tmp;
    
    //每次移动0.1米
    distancePassed += 0.1;
    MGLPolyline *line = part.route;
    if (distancePassed <= [engine lengthOfGeometry:line]) {
        CLLocationCoordinate2D pt = [engine pointOnLine:line atDistance:distancePassed];
        tmp = [BRTLocalPoint pointWithCoor:pt Floor:part.floor];
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:tmp];
        
        NSArray *hintsOfPart = [part getRouteDirectionalHintsIgnoreDistance:0 angle:10];
        BRTDirectionalHint *hint = [part getDirectionHintForLocation:tmp FromHints:hintsOfPart];
        //提示线段切换时，播报语音并立即切换视角
        if (!hint.passed) {
            hint.passed = 1;
            [self textToSpeech:hint.getDirectionString];
            
            MGLMapCamera *fromCamera = self.mapView.camera;
            CLLocationCoordinate2D pt = [engine pointOnLine:line atDistance:distancePassed+5];
            MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:pt fromDistance:fromCamera.altitude pitch:fromCamera.pitch heading:360+hint.currentAngle];
            [self.mapView setCamera:camera withDuration:0.5 animationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
        //每1米移动一下视角到，下1米
        if(((int)distancePassed)%10 == 0){
            MGLMapCamera *fromCamera = self.mapView.camera;
            CLLocationCoordinate2D pt = [engine pointOnLine:line atDistance:distancePassed+10];
            MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:pt fromDistance:fromCamera.altitude pitch:fromCamera.pitch heading:360+hint.currentAngle];
            [self.mapView setCamera:camera withDuration:2 animationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        }
        self.tipsLabel.text = [NSString stringWithFormat:@"方向：%@\n本段长度%.2f\n本段角度%.2f\n剩余/全长：%.2f/%.2f",hint.getDirectionString,hint.length,hint.currentAngle,[self.mapView.routeResult distanceToRouteEnd:lp],self.mapView.routeResult.length];
    }else{
        distancePassed = 0;
        tmp = part.nextPart.getFirstPoint;
    }
    //0.01秒后，移动到下一个点
    if (tmp) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            [NSThread sleepForTimeInterval:0.01];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self moveToLocalPoint:tmp];
            });
        });
    }
}


- (AVSpeechSynthesizer *)speech {
    if (!_speech) {
        _speech = [[AVSpeechSynthesizer alloc] init];
    }
    return _speech;
}
//TTS 文本合成语音
- (IBAction)textToSpeech:(NSString *)text
{
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    float sysVer = [UIDevice currentDevice].systemVersion.floatValue;
    if (sysVer < 9) {
        utterance.rate = 0.15;
    }else if(sysVer == 9){
        utterance.rate = 0.53;
    }else{
        utterance.rate = 0.5;
    }
    [self.speech speakUtterance:utterance];
}

#pragma mark - **************** 地图点击

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    BRTPoi *poi = [mapView extractPoiOnCurrentFloorWithPoint:screen].firstObject;
    if (!poi) {
        self.tipsLabel.text = @"请选择有POI范围的区域";
        return;
    }
    if (self.mapView.routeStart == nil) {
        [self.mapView setRouteStart:[BRTLocalPoint pointWithCoor:poi.labelPoint.coordinate Floor:mapView.currentFloor]];
        [self.mapView showRouteStartSymbolOnCurrentFloor:self.mapView.routeStart];
    }else {
        [self.mapView setRouteEnd:[BRTLocalPoint pointWithCoor:poi.labelPoint.coordinate Floor:mapView.currentFloor]];
        [self.mapView showRouteEndSymbolOnCurrentFloor:self.mapView.routeEnd];
        [mapView.routeManager requestRouteWithStart:self.mapView.routeStart end:self.mapView.routeEnd];
    }
}

//楼层加载回调；如果已有路径规划，显示本层规划，并缩放全屏显示
- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo {
    if (self.mapView.routeResult) {
        [self.mapView showRouteResultOnCurrentFloor];
        //        [self.mapView zoomToResolution:mapInfo.mapSize.x/self.mapView.frame.size.width withCenterPoint:mapView.baseLayer.fullEnvelope.center animated:YES];
    }
}

#pragma mark - **************** 路径规划回调
- (void)routeManager:(BRTRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
    [self.mapView setRouteStart:self.mapView.routeStart];
    [self.mapView setRouteEnd:self.mapView.routeEnd];
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
    void(^runOnMainThead)(void) = ^{
        self.tipsLabel.text = [NSString stringWithFormat:@"全长%.2f米;",rs.length];
    };
    if ( [NSThread isMainThread] )runOnMainThead();
    else dispatch_async( dispatch_get_main_queue(), runOnMainThead);
}

- (void)routeManager:(BRTRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@",error);
    }
    [self.mapView removeRouteLayer];
}

#pragma mark - **************** custom annotation
- (void)showLocationAnnotation:(BRTLocalPoint *)lp {
    [self.mapView removeAnnotations:self.mapView.annotations];
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.coordinate = lp.coordinate;
    ann.title  = @"location";
    [self.mapView addAnnotation:ann];
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id<MGLAnnotation>)annotation {
    if (![annotation.title isEqualToString:@"location"]) {
        return nil;
    }
    MGLAnnotationImage *annImage = [mapView dequeueReusableAnnotationImageWithIdentifier:annotation.title];
    if (!annImage) {
        annImage = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:annotation.title] reuseIdentifier:annotation.title];
    }
    return annImage;
}
@end
