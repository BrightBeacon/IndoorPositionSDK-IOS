//
//  DemoTableVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "DemoTableVC.h"

@interface DemoTableVC () {
    NSString *_buildingID,*_appkey;
}
@property (nonatomic,strong) NSDictionary *mapDemoList;
@property (nonatomic,strong) NSArray *sortedKey;
@property (nonatomic,strong) NSMutableArray *selectedIndex;

@end

@implementation DemoTableVC


+ (DemoTableVC *)demoWithBuilding:(NSString *)building appkey:(NSString *)appkey {
    return [[DemoTableVC alloc] initWithBuilding:building appkey:appkey];
}

- (instancetype)initWithBuilding:(NSString *)buliding appkey:(NSString *)appkey {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _buildingID = buliding;
        _appkey = appkey;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndex = [NSMutableArray array];
    self.title = @"智石演示";
    self.mapDemoList = @{
                         @"地图事件":@[@{@"·拾取POI":@"POIVC"},@{@"·手势控制":@"GestureVC"}],
                         @"地图控件":@[@{@"·常用控件":@"ControlsVC"}]
                         };
    self.sortedKey = @[@"地图事件",@"地图控件"];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    [self sectionButtonClicked:nil];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"BRTBundle" ofType:@"bundle"];
//    NSBundle *bundle = [NSBundle bundleWithPath:path];
//    UIImage *image = [UIImage imageNamed:@"routeArrow" inBundle:bundle compatibleWithTraitCollection:nil];
//    NSLog(@"%@_%@",bundle,image);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sortedKey.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.selectedIndex containsObject:@(section)]?[[self.mapDemoList valueForKey:self.sortedKey[section]] count]:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
    NSString *key = self.sortedKey[indexPath.section];
    NSDictionary *dic = [self.mapDemoList valueForKey:key][indexPath.row];
    cell.textLabel.text = dic.allKeys[0];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 31)];
    btn.tag = section;
    [btn setTitle:self.sortedKey[section] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderWidth = 0.3;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return btn;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.mapDemoList[self.sortedKey[indexPath.section]][indexPath.row];
    NSString *vcs = dic.allValues[0];
    NSString *title = dic.allKeys[0];
	Class cls = NSClassFromString(vcs);
    UIViewController *vc = [cls new];
    [vc setValue:_buildingID forKey:@"buildingID"];
    [vc setValue:_appkey forKey:@"appKey"];
	vc.title = title;
	[self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)sectionButtonClicked:(UIButton *)sender {
    if ([self.selectedIndex containsObject:@(sender.tag)]) {
        [self.selectedIndex removeObject:@(sender.tag)];
    }else {
        [self.selectedIndex addObject:@(sender.tag)];
    }
    [self.tableView reloadData];
}
@end
