//
//  POIVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/19.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "POIVC.h"

@implementation POIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭自动高亮
    self.mapView.highlightPOIOnSelection = NO;
    //默认高亮色
    [self.mapView setDefaultHighlightColor:[UIColor cyanColor]];
}

//poi选中回调
- (void)mapView:(BRTMapView *)mapView poiSelected:(NSArray<BRTPoi *> *)array {
    //高亮一组POI
    [mapView highlightPois:array];
    
    //显示默认图标
    MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
    ann.coordinate = array.firstObject.labelPoint.coordinate;
    ann.title = array.firstObject.name;
    [mapView addAnnotation:ann];
}

//高亮颜色自定义
- (UIColor *)mapView:(BRTMapView *)mapView highlightColorForPoi:(BRTPoi *)poi {
    if (poi.name.length) {
        return [UIColor redColor];
    }
    //nil will use defaultHighlightColor.
    return nil;
}
@end
