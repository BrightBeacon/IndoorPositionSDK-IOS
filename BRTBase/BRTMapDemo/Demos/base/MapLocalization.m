//
//  MapLocalization.m
//  mapdemo
//
//  Created by thomasho on 2017/12/16.
//  Copyright © 2017年 thomasho. All rights reserved.
//

#import "MapLocalization.h"

@implementation MapLocalization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *local = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 60, 80, 31)];
    [local setTitle:@"本地化" forState:UIControlStateNormal];
    [local setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [local addTarget:self action:@selector(localButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:local];
}

- (IBAction)localButtonClicked:(UIButton *)sender {
    [sender setSelected:!sender.isSelected];
    
    //切换本地化文件:zh-hans,zh-hant,en等，依赖MapLocalizable.string文件本地化设置
    [BRTMapEnvironment setMapCustomLanguage:sender.isSelected?@"en":@"Base"];
    [self.mapView reloadMapView];
}

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen
{
    //打印所有本层文字本地化字符串，可以直接copy到Localizable.strings进行翻译配置
    NSArray *labels = [mapView getPoiUsingPredicate:[NSPredicate predicateWithFormat:@"layer=%d",POI_LABEL]];
    NSMutableString *mstr = [NSMutableString string];
    for (BRTPoi *poi in labels) {
        [mstr appendFormat:@"\"%@\"=\"%@\";\n",poi.poiID,poi.name];
    }
    NSLog(@"%@",mstr);
}

@end
