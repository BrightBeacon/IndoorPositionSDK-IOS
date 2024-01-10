//
//  routeVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "RouteVC.h"
#import <AVFoundation/AVFoundation.h>

@interface RouteVC ()<BRTRouteManagerDelegate> {
    BOOL useClickForStop;
}

@property (nonatomic,strong) AVSpeechSynthesizer *speech;
@property (nonatomic,strong) NSMutableArray *stops;
@property (nonatomic,strong) NSString *fobiddenCid;

@end

@implementation RouteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clearButtonClicked:)];
}

- (void)dealloc {
    
}

- (IBAction)swithValueChanged:(UISegmentedControl *)sender {
    useClickForStop = sender.selectedSegmentIndex;
}
- (IBAction)fobiddenButtonClicked:(UIButton *)sender {
    NSArray *arr = [self.mapView getAllFacilityOnCurrentFloor];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"禁行设施类别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    for (BRTPoi *poi in arr) {
        [mdic setObject:poi.name forKey:@(poi.categoryID).stringValue];
    }
    for (NSString *key in mdic.allKeys) {
        [sheet addAction:[UIAlertAction actionWithTitle:[mdic valueForKey:key] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.fobiddenCid = key;
        }]];
    }
    UIPopoverPresentationController *popVC = sheet.popoverPresentationController;
    if (popVC) {
        popVC.sourceRect = sender.bounds;
        popVC.sourceView = sender;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}
//初始化路径图标
- (void)initSymbols
{
//      [self.mapView setRouteColor:[UIColor orangeColor]];
//    [self.mapView setRouteEndSymbol:<#(UIImage *)#>];
//    [self.mapView setRouteSwitchSymbol:<#(UIImage *)#>];
//    [self.mapView setRouteStartSymbol:<#(UIImage *)#>];
}
- (void)initLocationSymbol {
    //设置地图显示定位图标
    //    [self.mapView setLocationSymbol:locSymbol];
}
- (void)mapViewDidLoad:(BRTMapView *)mapView withError:(NSError *)error {
    [super mapViewDidLoad:mapView withError:error];
    if (error) {
        return;
    }
    BRTFloorInfo *info = mapView.floorInfos.firstObject;
    BRTLocalPoint *start = [BRTLocalPoint pointWithX:info.mapExtent.xmin Y:info.mapExtent.ymin Floor:info.floorNumber];
    BRTLocalPoint *end = [BRTLocalPoint pointWithX:info.mapExtent.xmax Y:info.mapExtent.ymax Floor:info.floorNumber];
    MGLPointAnnotation *ann  = [[MGLPointAnnotation alloc] init];
    ann.coordinate = start.coordinate;
    ann.title = @"1";
    MGLPointAnnotation *xannn = [[MGLPointAnnotation alloc] init];
    xannn.coordinate = end.coordinate;
    xannn.title = @"2";
    
    [self.mapView addAnnotations:@[ann,xannn]];
    
    [self initSymbols];
    [self initLocationSymbol];
    if ([self.mapView.building.routeVersion isEqualToString:@"V3"]) {
        NSArray *array = [NSArray arrayWithObjects:@"点击模拟定位",@"点击新增途径点", nil];
        UISegmentedControl *sw = [[UISegmentedControl alloc] initWithItems:array];
        [sw setFrame:CGRectMake(10, 80, self.view.frame.size.width - 20, 20)];
        [sw addTarget:self action:@selector(swithValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:sw];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 80, 50, 50)];
        [btn setTitle:@"禁行" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blackColor]];
        [btn addTarget:self action:@selector(fobiddenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)requesRoute {
    if (self.mapView.routeStart&&self.mapView.routeEnd) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.mapView.routeManager.delegate = self;
        [self.mapView.routeManager requestRouteWithStart:self.mapView.routeStart  forward:nil end:self.mapView.routeEnd stops:self.stops sortStop:NO vehicle:NO ignore:self.fobiddenCid?@[self.fobiddenCid]:nil];
    }
}

- (IBAction)clearButtonClicked:(id)sender {
    self.stops = nil;
    [self.mapView setRouteStart:nil];
    [self.mapView setRouteEnd:nil];
    [self.mapView removeRouteLayer];
}
#pragma mark - **************** 地图回调

- (void)mapView:(BRTMapView *)mapView poiSelected:(NSArray<BRTPoi *> *)array {
    
    if (self.mapView.routeResult) {
        if (useClickForStop) {
            if(self.stops == nil) self.stops = [NSMutableArray array];
            [self.stops addObject:array.firstObject.labelPoint];
            [self requesRoute];
            return;
        }
    }else {
        BRTPoi *poi = array.firstObject;
        MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
        ann.coordinate = poi.labelPoint.coordinate;
        ann.title = poi.name;
        [self.mapView addAnnotation:ann];
        [self.mapView selectAnnotation:ann animated:YES];
    }
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    if (useClickForStop) {
        return;
    }
    if (mapView.routeResult == nil) {
        return;
    }
    //模拟定位点
    BRTLocalPoint *newLocation = [BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:nil] Floor:mapView.currentFloor];
    //显示定位
    [self.mapView showLocation:newLocation];
    
    //初次移到中心点
    [self.mapView setCenterCoordinate:newLocation.coordinate];
    
    // 判断地图当前显示楼层是否与定位结果一致，若不一致则切换到定位结果所在楼层（楼层自动切换）
    if (self.mapView.currentFloor != newLocation.floor) {
        [self.mapView setFloor:newLocation.floor];
        return;
    }
    
    //有路径规划，判断是否到达终点附近，是否偏航等。进行提示。
    if (self.mapView.routeResult) {
        
        if ([self.mapView.routeResult isDeviatingFromRoute:newLocation withThrehold:5]) {
            //偏航5米，重新规划路径
            [self.mapView setRouteStart:newLocation];
            [self requesRoute];
            [self textToSpeech:@"你已偏航，重新规划路线。"];
            return;
        }
        
        double distance2end = [self.mapView.routeResult distanceToRouteEnd:newLocation];
        if (distance2end < 5) {
            if (self.mapView.routeResult.nextResult == nil) {
                [self clearButtonClicked:nil];
                [self textToSpeech:@"已到达终点附近,本次导航结束。"];
            }else{
                BRTRoutePart *part = [self.mapView.routeResult getNearestRoutePart:newLocation];
                [self.stops removeObject:part.getLastPoint];
                //设置分段下一路径
                [self.mapView setRouteResult:self.mapView.routeResult.nextResult];
                [self.mapView showRouteResultOnCurrentFloor];
                //简单提示
                double len = self.mapView.routeResult.length;
                int min = ceil(len/80);
                [self textToSpeech:[NSString stringWithFormat:@"已到达途径点，下一段全长%.0f米，大约需要%d分钟",len,min]];
            }
            return;
        }
        //显示路过和余下线段
        [self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:newLocation];
        
        //导航中，未偏航，可以直接吸附到最近的路径上。注意：本层可能无路网
        BRTRoutePart *part = [self.mapView.routeResult getNearestRoutePart:newLocation];
        if (part) {
            newLocation = [self.mapView.routeResult getNearPointOnRoute:newLocation];
            //移动位置超过2米，进行导航提示
            NSArray *routeGuides = [part getRouteDirectionalHintsIgnoreDistance:0 angle:10];
            if (routeGuides.count) {
                BRTDirectionalHint *hint = [part getDirectionHintForLocation:newLocation FromHints:routeGuides];
                [self.mapView processDeviceRotation:hint.currentAngle];
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
        }
    }
    [self.mapView showLocation:newLocation];
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
    self.title = text;
    [self.speech stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
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

- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo
{
    //显示当前楼层导航信息
    [self.mapView showRouteResultOnCurrentFloor];
}
#pragma mark - **************** 路径规划
- (void)routeManager:(BRTRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"没有找到路线" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    [self clearButtonClicked:nil];
    NSLog(@"%@", error);
}

- (void)routeManager:(BRTRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs
{
    BOOL isFirst = self.mapView.routeResult == nil;
    [self.mapView setRouteResult:rs];
    [self.mapView showRouteResultOnCurrentFloor];
    
    //获取当前楼层路段
    NSArray<BRTRoutePart *> *routePartArray = [rs getRoutePartsOnFloor:self.mapView.currentFloor];
    //缩放到路段
    MGLPolyline *line = routePartArray.firstObject.route;
    [self.mapView setVisibleCoordinates:line.coordinates count:line.pointCount edgePadding:UIEdgeInsetsZero animated:YES];
    //初始提示,偏航等重新规划不提示
    if (isFirst) {
        double len = self.mapView.routeResult.length;
        int min = ceil(len/80);
        [self textToSpeech:[NSString stringWithFormat:@"开始导航，本段全长%.0f米，大约需要%d分钟",len,min]];
    }
}

#pragma mark - **************** annotation & callout
- (BOOL)mapView:(BRTMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    return YES;
}
- (UIView *)mapView:(BRTMapView *)mapView leftCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 5;
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitle:@"起点" forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    return btn;
}
- (UIView *)mapView:(BRTMapView *)mapView rightCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 5;
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitle:@"终点" forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.tag = 1;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    return btn;
}

-(void)mapView:(BRTMapView *)mapView annotation:(id<MGLAnnotation>)annotation calloutAccessoryControlTapped:(UIControl *)control {
    if (control.tag) {
        [self.mapView setRouteEnd:[BRTLocalPoint pointWithCoor:annotation.coordinate Floor:mapView.currentFloor]];
    }else{
        [self.mapView setRouteStart:[BRTLocalPoint pointWithCoor:annotation.coordinate Floor:mapView.currentFloor]];
        [self.mapView showRouteStartSymbolOnCurrentFloor:self.mapView.routeStart];
    }
    [self requesRoute];
    [self.mapView removeAnnotations:self.mapView.annotations];
}
@end

