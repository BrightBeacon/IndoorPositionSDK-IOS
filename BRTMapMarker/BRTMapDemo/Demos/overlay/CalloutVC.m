//
//  CalloutVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/14.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "CalloutVC.h"
#import "CustomCalloutView.h"

@interface CalloutVC ()

@end

@implementation CalloutVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
	//通过X、Y搜索点击的POI
	NSArray<BRTPoi *> *array = [mapView extractPoiOnCurrentFloorWithPoint:screen];
    if (array.count == 0) {
        [mapView removeAnnotations:mapView.annotations];
    }else{
        MGLPointAnnotation *poiAnn = [[MGLPointAnnotation alloc] init];
        poiAnn.coordinate = array.firstObject.labelPoint.coordinate;
        poiAnn.title = array.firstObject.name;
        [self.mapView addAnnotation:poiAnn];
        [mapView selectAnnotation:poiAnn animated:NO];
    }
}

#pragma mark - **************** 默认弹窗事件
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    // Only show callouts for `Hello world!` annotation.
    return YES;
}

- (UIView<MGLCalloutView> *)mapView:(BRTMapView *)mapView calloutViewForAnnotation:(id<MGLAnnotation>)annotation
{
    // Instantiate and return our custom callout view.
    CustomCalloutView *calloutView = [[CustomCalloutView alloc] init];
    calloutView.representedObject = annotation;
    return calloutView;
}

- (void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation
{
    // Optionally handle taps on the callout.
    NSLog(@"Tapped the callout for: %@", annotation);
    
    // Hide the callout.
    //[mapView deselectAnnotation:annotation animated:YES];
    //remove the annotation
    [self.mapView removeAnnotations:self.mapView.annotations];
}

#pragma mark - ****************   annotatonView
// This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(id <MGLAnnotation>)annotation {
    // This example is only concerned with point annotations.
    if (![annotation isKindOfClass:[MGLPointAnnotation class]]) {
        return nil;
    }
    
    // For better performance, always try to reuse existing annotations. To use multiple different annotation views, change the reuse identifier for each.
    MarkerAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"draggablePoint"];
    
    // If there’s no reusable annotation view available, initialize a new one.
    if (!annotationView) {
        annotationView = [[MarkerAnnotationView alloc] initWithReuseIdentifier:@"draggablePoint" size:0];
    }
    
    return annotationView;
}

@end
