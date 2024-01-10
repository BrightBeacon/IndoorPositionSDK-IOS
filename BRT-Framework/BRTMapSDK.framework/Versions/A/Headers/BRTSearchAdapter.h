//
//  BRTSearchAdapter.h
//  MapProject
//
//  Created by thomasho on 18/5/26.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BRTPoi.h"

@interface BRTSearchAdapter : NSObject


/// 初始化自定义查询DB（仅支持使用queryAnySql方法）
/// @param path DB路径
/// @param table sqllite表名
- (id)initWithDBPath:(NSString *)path table:(NSString *)table;

/**
 初始化建筑DB搜索

 @param buildingID 建筑ID
 @return 搜索类
 */
- (id)initWithBuildingID:(NSString *)buildingID;

/**
 初始化<=范围(米)去重搜索类

 @param buildingID 建筑ID
 @param threshold 去除阈值(米)内重复名称的数据（例如同一电梯可能有区域POI和设施POI）
 @return 搜索类
 */
- (id)initWithBuildingID:(NSString *)buildingID distinct:(double)threshold;


/**
 根据sql规则检索，并返回POI结果

 @param sql 限定查询POI的sql语句，否则无法正常返回（例：select * from POI where ？，返回BRTPOI数组）
 @return POI结果数组
 */
 - (NSArray<BRTPoi *> *)querySql:(NSString *)sql;

/**
 根据sql规则检索，并返回Sql查询结果（例：select count(*) as sum from POI，返回{"sum":20}）

@param sql 任意sql语句
@return sql结果Dic数组
*/
- (NSArray<NSDictionary *> *)queryAnySql:(NSString *)sql;

/**
 根据关键字模糊检索所有楼层POI名称

 @param searchText 关键字
 @return POI数组
 */
- (NSArray<BRTPoi *> *)queryPoi:(NSString *)searchText;

/**
 根据关键字模糊和楼层检索POI名称

 @param name 检索关键字
 @param floor 楼层
 @return POI数组
 */
- (NSArray<BRTPoi *> *)queryPoi:(NSString *)name andFloor:(int)floor;


/**
 根据类别ID检索所有楼层POI

 @param cids 类别ID；多个以,隔开
 @return POI数组
 */
- (NSArray<BRTPoi *> *)queryPoiByCategoryID:(NSString *)cids;

/**
 根据类别ID和楼层检索POI

 @param cids 类别ID；多个以,隔开
 @param floor 楼层
 @return POI数组
 */
- (NSArray<BRTPoi *> *)queryPoiByCategoryID:(NSString *)cids andFloor:(int)floor;


/**
 搜索point半径约radius范围内floor楼层的poi

 @param point 中心点
 @param radius 半径
 @param floor 楼层，如：-1，1
 @return POI数组，由近及远排序
 */
- (NSArray<BRTPoi *> *)queryPoiByCenter:(CLLocationCoordinate2D)point Radius:(double) radius Floor:(int) floor;
@end
