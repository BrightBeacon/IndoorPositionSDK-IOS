//
//  MapLayer.m
//  mapdemo
//
//  Created by thomasho on 2017/7/28.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapLayer.h"

@interface MapLayer ()

@end

@implementation MapLayer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 200, 100, 44)];
    [btn setTitle:@"文字大小" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"隐藏文字层" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"设施大小" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 3;
    [btn setTitle:@"隐藏设施层" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            self.mapView.labelLayer.textFontSize = [NSExpression expressionForConstantValue:@18];
            break;
        case 1:
            self.mapView.labelLayer.visible = sender.isSelected;
            break;
        case 2:
            self.mapView.facilityLayer.iconScale = [NSExpression expressionForConstantValue:@1.5];
            break;
        case 3:
            self.mapView.facilityLayer.visible = sender.isSelected;
            break;
            
        default:
            break;
    }
    [sender setSelected:!sender.isSelected];
}

/*  文字分类图标
- (NSDictionary<NSNumber *,UIImage *> *)catergoryIconsForMapView:(BRTMapView *)mapView {
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    [mdic setObject:[UIImage imageNamed:@"美食"] forKey:@"010000"];
    [mdic setObject:[UIImage imageNamed:@"生活"] forKey:@"020000"];
    [mdic setObject:[UIImage imageNamed:@"服装"] forKey:@"021101"];
    [mdic setObject:[UIImage imageNamed:@"数码"] forKey:@"020300"];
    [mdic setObject:[UIImage imageNamed:@"皮具"] forKey:@"021109"];
    [mdic setObject:[UIImage imageNamed:@"配饰"] forKey:@"021202"];
    [mdic setObject:[UIImage imageNamed:@"亲子"] forKey:@"040200"];
    [mdic setObject:[UIImage imageNamed:@"其他"] forKey:@"default"];
    return mdic;
}*/
@end
