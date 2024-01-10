//
//  RouteDistanceVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteDistanceVC.h"
#import <BRTMapSDK/GeometryEngine.h>

@interface RouteDistanceVC ()<BRTRouteManagerDelegate>

@property (nonatomic,strong) UILabel *tipsLabel;

@end

@implementation RouteDistanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 120)];
    self.tipsLabel.numberOfLines = 0;
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.text = @"距离提示";
    [self.view addSubview:self.tipsLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.frame.size.height - 50, 100, 44)];
    [btn setTitle:@"模拟位置" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(moveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self initSymbols];
}

//初始化路径图标
- (void)initSymbols {
//    [self.mapView setRouteStartSymbol:startSymbol];
//    [self.mapView setRouteEndSymbol:endSymbol];
//    [self.mapView setRouteSwitchSymbol:switchSymbol];
}

//自定义路径符号
- (void)customRouteSymbols {
    //[self.mapView setPassedRouteSymbol:passedCS];
    //[self.mapView setRouteSymbol:cs];
}

- (IBAction)moveButtonClicked:(id)sender {
    BRTRouteResult *rs = self.mapView.routeResult;
    BRTRoutePart *part = [rs getRoutePartsOnFloor:self.mapView.currentFloor].firstObject;
    if (part == nil) {
        return;
    }
    //随机获取本层路径点（缩放、居中、显示该点、显示经过/剩余路段）
    CLLocationCoordinate2D coord = part.route.coordinates[arc4random()%part.route.pointCount];
    BRTLocalPoint *lp = [BRTLocalPoint pointWithCoor:coord Floor:self.mapView.currentFloor];
    [self showRouteInfo:lp];
}

- (void)showRouteInfo:(BRTLocalPoint *)lp {
    BRTRoutePart *part = [self.mapView.routeResult getNearestRoutePart:lp];
    [self.mapView setVisibleCoordinates:part.route.coordinates count:part.route.pointCount edgePadding:UIEdgeInsetsZero animated:YES];
    [self.mapView showLocation:lp];
    //[self.mapView showPassedAndRemainingRouteResultOnCurrentFloor:lp];
    
    //获取路径、路段长度、方向提示信息
    double total = self.mapView.routeResult.length;
    double remaining = [self.mapView.routeResult distanceToRouteEnd:lp];
    double currentPartLen = [[GeometryEngine defaultEngine] lengthOfGeometry:part.route];
    
    //hint为当前段路径提示信息；默认会忽略小于2米和小于10度的路径。
    BRTDirectionalHint *hint = [part getDirectionHintForLocation:lp FromHints:[part getRouteDirectionalHintsIgnoreDistance:2 angle:10]];
    //    [self.mapView showRouteHintForDirectionHint:hint Centered:NO];
    double currentHintLen = hint.length;
    double currentHintRemaining = [[GeometryEngine defaultEngine] distanceBetweenCoordinates:hint.endPoint to:lp.coordinate];
    double nextHintLen = hint.nextHint.length;
    
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.title = @"x";
    ann.coordinate = hint.endPoint;
    [self.mapView addAnnotation:ann];
    
    self.tipsLabel.text = [NSString stringWithFormat:@"全长%.2f米\n总剩余：%.2f米\n本层路径长：%.2f米\n当前路段总长(约)：%.2f米\n当前路段剩余：%.2f米\n当前路段方向：%@\n下一段总长：%.2f米\n下一段方向：%@",total,remaining,currentPartLen,currentHintLen,currentHintRemaining,hint.getDirectionString,nextHintLen,hint.nextHint.getDirectionString];
}
//地图点击事件；选取、设置起点和终点
- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    if (!MGLCoordinateInCoordinateBounds([mapView convertPoint:screen toCoordinateFromView:mapView], mapView.visibleCoordinateBounds)) {
        self.tipsLabel.text = @"请选择地图内的点";
        return;
    }
    if (self.mapView.routeResult) {
        [self showRouteInfo:[BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:mapView] Floor:mapView.currentFloor]];
        return;
    }
    //清除路径显示
    [self.mapView removeRouteLayer];
    if (!self.mapView.routeStart) {
        [self.mapView setRouteStart:[BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:mapView] Floor:mapView.currentFloor]];
        [self.mapView showRouteStartSymbolOnCurrentFloor:self.mapView.routeStart];
    }else {
        [self.mapView setRouteEnd:[BRTLocalPoint pointWithCoor:[mapView convertPoint:screen toCoordinateFromView:mapView] Floor:mapView.currentFloor]];
        [self.mapView showRouteEndSymbolOnCurrentFloor:self.mapView.routeEnd];
        [mapView.routeManager requestRouteWithStart:self.mapView.routeStart end:self.mapView.routeEnd];
    }
}

//楼层加载回调；如果已有路径规划，显示本层规划，并缩放全屏显示
- (void)mapView:(BRTMapView *)mapView didFinishLoadingFloor:(BRTFloorInfo *)floorInfo {
    if (self.mapView.routeResult) {
        [self.mapView showRouteResultOnCurrentFloor];
        //[self.mapView zoomToResolution:mapInfo.mapSize.x/self.mapView.frame.size.width withCenterPoint:mapView.baseLayer.fullEnvelope.center animated:YES];
    }
}

#pragma mark - **************** 路径规划回调
- (void)routeManager:(BRTRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
    [self.mapView setRouteResult:rs];
//    [self customRouteSymbols];
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
@end
