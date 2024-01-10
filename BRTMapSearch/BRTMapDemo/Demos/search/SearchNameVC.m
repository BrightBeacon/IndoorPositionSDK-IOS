//
//  SearchNameVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "SearchNameVC.h"
#import <BRTMapSDK/BRTSearchAdapter.h>

@interface SearchNameVC ()<UISearchBarDelegate>

@end

@implementation SearchNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,statusBarFrame.size.height + 44, self.view.frame.size.width, 44)];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        return;
    }
    BRTSearchAdapter *adapter = [[BRTSearchAdapter alloc] initWithBuildingID:self.buildingID distinct:1.0];
    NSArray<BRTPoi *> *list = [adapter queryPoi:searchText andFloor:self.mapView.currentFloor];
    NSMutableArray *pois = [NSMutableArray array];
    for (BRTPoi *poi in list) {
        MGLPointAnnotation *ann = [[MGLPointAnnotation alloc] init];
        ann.coordinate = poi.labelPoint.coordinate;
        ann.title = poi.name;
        [pois addObject:ann];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:pois];
}

@end
