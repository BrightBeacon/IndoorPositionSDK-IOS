//
//  RouteOnlyVC.m
//  mapdemo
//
//  Created by thomasho on 2017/9/13.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "RouteOnlyVC.h"
#import <BRTMapSDK/BRTMapSDK.h>
#import <BRTMapData/BRTMapData.h>
#import <BRTMapSDK/BRTBuildingManager.h>

@interface RouteOnlyVC()<BRTOfflineRouteManagerDelegate> {
    BRTLocalPoint *startP;
}
@end

//演示不需要显示地图，只路径规划方法
@implementation RouteOnlyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *lbl = [[UILabel alloc] initWithFrame:[UIScreen mainScreen].bounds];
    lbl.textColor = [UIColor blackColor];
    lbl.text = @"不需地图，只使用路网数据，详情查看代码";
    [self.view addSubview:lbl];
    [BRTDownloader updateMap:kBuildingId AppKey:kAppKey OnCompletion:^(BRTMapUpdate *update, NSError *error) {
        BRTBuilding *building = [BRTBuildingManager parseBuilding:kBuildingId];
        NSArray<BRTFloorInfo *> *mapInfos = [BRTFloorInfo parseAllMapInfo:kBuildingId];
        if (building && mapInfos.count) {
            [self initRoute:building info:mapInfos];
        }
    }];
}

- (void)initRoute:(BRTBuilding *)building info:(NSArray <BRTFloorInfo *> *)mapinfos {
    BRTOfflineRouteManager *rm = [BRTOfflineRouteManager routeManagerWithBuilding:building MapInfos:mapinfos];
    rm.delegate = self;
    BRTFloorInfo *info = mapinfos.firstObject;
    startP = [BRTLocalPoint pointWithX:info.mapExtent.xmin Y:info.mapExtent.ymin Floor:info.floorNumber];
    [rm requestRouteWithStart:startP end:[BRTLocalPoint pointWithX:info.mapExtent.xmax Y:info.mapExtent.ymax Floor:info.floorNumber]];
}

- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs {
    BRTRoutePart *part = rs.allRoutePartArray.firstObject;
    do {
        NSArray<BRTDirectionalHint *> *hints = [part getRouteDirectionalHintsIgnoreDistance:0 angle:5];
        BRTDirectionalHint *hint = [part getDirectionHintForLocation:startP FromHints:hints];
        do {
            NSLog(@"-%@",[hint getDirectionString]);
            hint = hint.nextHint;
        } while (hint);
        NSLog(@"以上为%d层路径：%@",part.floor,part.description);
        part = part.nextPart;
    } while (part);
}

- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error {
    NSLog(@"%@",error);
}

@end
