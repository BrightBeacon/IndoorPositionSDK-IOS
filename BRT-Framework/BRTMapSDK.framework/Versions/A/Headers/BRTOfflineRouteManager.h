//
//  BRTOfflineRouteManager.h
//  MapProject
//
//  Created by thomasho on 18/5/11.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRTRouteResult.h"
#import <BRTMapData/BRTMapData.h>

@class BRTOfflineRouteManager;

/**
 *  离线路径管理代理协议
 */
@protocol BRTOfflineRouteManagerDelegate <NSObject>

@optional
/**
 *  解决路径规划返回方法
 *
 *  @param routeManager 离线路径管理实例
 *  @param rs           路径规划结果
 */
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didSolveRouteWithResult:(BRTRouteResult *)rs;

/**
 *  路径规划失败回调方法
 *
 *  @param routeManager 离线路径管理实例
 *  @param error        错误信息
 */
- (void)offlineRouteManager:(BRTOfflineRouteManager *)routeManager didFailSolveRouteWithError:(NSError *)error;

@end


/**
 *  离线路径管理类
 */
@interface BRTOfflineRouteManager : NSObject

/**
 *  路径规划起点
 */
@property (nonatomic, strong, readonly) BRTLocalPoint *startPoint;

/**
 *  路径规划终点
 */
@property (nonatomic, strong, readonly) BRTLocalPoint *endPoint;


/**
 *  离线路径管理代理
 */
@property (nonatomic, weak) id<BRTOfflineRouteManagerDelegate> delegate;

/**
 *  离线路径管理类的静态实例化方法
 *
 *  @param building     目标建筑
 *  @param mapInfoArray 目标建筑的所有楼层信息
 *
 *  @return 离线路径管理类实例
 */
+ (BRTOfflineRouteManager *)routeManagerWithBuilding:(BRTBuilding *)building MapInfos:(NSArray *)mapInfoArray;


/**
 *  请求路径规划，在代理方法获取规划结果
 *
 *  @param start 路径规划起点
 *  @param end   路径规划终点
 */
- (void)requestRouteWithStart:(BRTLocalPoint *)start end:(BRTLocalPoint *)end;

/**
 *  请求多途经点路径规划，在代理方法获取规划结果（多途径等仅支持路网版本V3以上）
 *
 *   @param start   起点
 *   @param forward 优选朝向点（支持1～2个点，可选，该方向若无法规划会尝试忽略）
 *   @param end     终点
 *   @param stops   途经点（可选）
 *   @param sort    对途经点重排序
 *   @param vehicle 使用车行导航
 *   @param cids    禁行设施类别ID（可选）
 */
- (void)requestRouteWithStart:(BRTLocalPoint *)start forward:(NSArray<BRTLocalPoint *> *)forward end:(BRTLocalPoint *)end stops:(NSArray<BRTLocalPoint *> *)stops sortStop:(BOOL)sort vehicle:(int)vehicle ignore:(NSArray<NSString *> *)cids;

/**
 计算距离路网最近的点

 @param point 目标点
 @return 路网上的点,未成功直接返回传入点
 */
- (BRTLocalPoint *)nearestPointOnRoute:(BRTLocalPoint *)point;

/**
 路网

 @return 整条路线
 */
- (MGLMultiPolyline *)route;

/**
 路网

 @return 楼层路线集
 */
- (MGLMultiPolyline *)routeOnFloor:(int)floor;


/**
 设置禁止通行点，双向禁止通行

 @param point 路径禁行拐点
 
 @return 是否成功
 */
- (BOOL)addForbiddenPoint:(BRTLocalPoint *)point;


/**
 设置禁止通行点，定向禁止通行
 
 @param point 路径禁行拐点
 @param to        禁行朝向点
 
 @return 是否成功
 
 */
- (BOOL)addForbiddenPoint:(BRTLocalPoint *)point forward:(BRTLocalPoint *)to;


/**
 移除所有禁止通行点
 */
- (void)removeForbiddenPoints;

@end
