//
//  GestureVC.m
//  mapdemo
//
//  Created by thomasho on 2017/7/31.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "GestureVC.h"

@interface GestureVC ()
@end

@implementation GestureVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 200, 100, 44)];
    [btn setTitle:@"禁止旋转" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"禁止缩放" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"禁止移动" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 3;
    [btn setTitle:@"禁止多点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            self.mapView.rotateEnabled = !self.mapView.rotateEnabled;
        }
            break;
        case 1:
        {
            self.mapView.zoomEnabled = !self.mapView.zoomEnabled;
        }
            break;
        case 2:
        {
            self.mapView.scrollEnabled = !self.mapView.scrollEnabled;
        }
            break;
        case 3:
        {
            self.mapView.pitchEnabled = NO;
            self.mapView.multipleTouchEnabled = !self.mapView.multipleTouchEnabled;
        }
            break;
            
        default:
            self.mapView.pitchEnabled = !self.mapView.pitchEnabled;
            break;
    }
    [sender setSelected:!sender.isSelected];
}

//地图区域变化通知
- (void)mapViewRegionIsChanging:(BRTMapView *)mapView {
    NSLog(@"缩放等级：%f,正北偏角：%f，倾角：%f",mapView.zoomLevel,mapView.direction,mapView.camera.pitch);
}

@end
