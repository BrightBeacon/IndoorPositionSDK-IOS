//
//  ControlNorthVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "ControlsVC.h"

@interface ControlsVC ()

@end

@implementation ControlsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //比例尺
    self.mapView.showsScale = YES;
    self.mapView.scaleBarPosition = MGLOrnamentPositionTopLeft;
    self.mapView.scaleBarMargins = CGPointZero;
    
    //指南针
    self.mapView.compassView.hidden = NO;
    self.mapView.compassViewPosition = MGLOrnamentPositionTopRight;
    self.mapView.compassViewMargins = CGPointZero;
    
    //logo
    self.mapView.logoView.hidden = NO;
    self.mapView.logoViewPosition = MGLOrnamentPositionBottomLeft;
    self.mapView.logoViewMargins = CGPointZero;
}
@end
