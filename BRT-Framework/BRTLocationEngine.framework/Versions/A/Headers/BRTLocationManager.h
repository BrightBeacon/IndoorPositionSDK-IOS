//
//  BRTLocationManager.h
//  BLEProject
//
//  Created by thomasho on 18/2/11.
//  Copyright (c) 2018年 thomasho. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <BRTMapData/BRTMapData.h>
#import "BRTLocationError.h"
#import "BRTBLEEnvironment.h"

@protocol BRTLocationManagerDelegate;

@class BRTMapBeacon,BRTPublicBeacon;

/**
 定位引擎
 */
@interface BRTLocationManager : NSObject

/**
 *  使用地图参数，初始化定位引擎
 *
 *  @param building 目标建筑(必须含有buildingID+initAngle用于定位方向校准)
 *  @param aKey 用户appkey
 *
 *  @return 定位引擎实例
 */
- (id)initWithBuilding:(BRTBuilding *)building appKey:(NSString *)aKey;


/**
 *  使用建筑ID+initAngle，初始化定位引擎
 *
 *  @param buildingID 目标建筑ID
 *  @param initAngle 定位数据朝向(即地图正上方)所在北偏角（获取方法：持手机面向地图正上方所在指南针方向；影响didUpdateLocation，didUpdateMapHeading)
 *  @param aKey 用户appkey
 *
 *  @return 定位引擎实例
 */
- (id)initWithBuildingID:(NSString *)buildingID initAngle:(double)initAngle appKey:(NSString *)aKey;

/**
 *  开启定位引擎
 */
- (void)startUpdateLocation;

/**
 *  停止定位引擎
 */
- (void)stopUpdateLocation;

/**
 *  获取最近一次的综合性位置信息（较稳）
 *
 *  @return 位置信息
 */
- (BRTLocalPoint *)getLastLocation;


/**
 *  获取最近一次的信号位置信息（较快）
 *
 *  @return 位置信息
 */
- (BRTLocalPoint *)getLastImmediateLocation;

/**
 *  设置用于额外添加需要扫描的Beacon（默认已扫描建筑设备中包含的regions，结果在didRangedBeacons查看）
 *
 *  @param region Beacon Region参数
 */
- (void)setBeaconRegion:(CLBeaconRegion *)region;

/**
 * 设置定位数据朝向(即地图正上方)所在北偏角（获取方法：持手机面向地图正上方所在指南针方向；影响didUpdateLocation，didUpdateMapHeading)
 *
 * @param angle 初始化角度
 */
- (void)setInitAngle:(double)angle;

/**
 *  设置是否限制定位使用的beacon个数
 *
 *  @param lbn 是否限制
 */
- (void)setLimitBeaconNumber:(BOOL)lbn;

/**
 *  设置用于定位的beacon最大个数
 *
 *  @param mbn 用于定位的beacon最大个数，即选取不多于mbn个beacon进行定位
 */
- (void)setMaxBeaconNumberForProcessing:(int)mbn;

/**
 *  设置beacon信号阈值
 *
 *  @param threshold 低于此信号阈值将不触发定位回调（仅影响didUpdateLocation，didUpdateImmediateLocation）
 */
- (void)setRssiThreshold:(int)threshold;


/**
 设置上传定位数据构建后台热力图

 @param enable 是否上传
 */
- (void)enableHeatData:(BOOL)enable;

/**
 *  请求超时时间，即超过此时间没有结果返回认为定位失败（回调didFailUpdateLocation）
 */
@property (nonatomic, assign) float requestTimeOut;


/**
 *  当前building的建筑ID
 */
@property (nonatomic, strong) NSString *buildingID;

/**
 *  定位引擎协议代理
 */
@property (nonatomic, assign) id<BRTLocationManagerDelegate> delegate;

@end

/**
 *  定位引擎代理协议
 */
@protocol BRTLocationManagerDelegate <NSObject>

/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 *  与[BRTLocationManager:didUpdateImmediationLocation:]方法相近，此方法回调结果融合计步器信息，稳定性较好，适合用于步行场景下。
 *
 *  @param manager     定位引擎实例
 *  @param newLocation 新的位置结果
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateLocation:(BRTLocalPoint *)newLocation;

/**
 *  定位引擎失败事件回调
 *
 *  @param manager 定位引擎实例
 *  @param error 错误信息
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didFailUpdateLocation:(NSError *)error;

@optional

/**
 *  位置更新事件回调，位置更新并返回新的位置结果。
 *  
 *  与[BRTLocationManager:didUpdateLocatin:]方法相近，此方法回调结果未融合计步器信息，灵敏度较高，适合用于行车场景下
 *
 *  @param manager 定位引擎实例
 *  @param newImmediateLocation 新的位置结果
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateImmediateLocation:(BRTLocalPoint *)newImmediateLocation;

/**
 *  Beacon扫描结果事件回调，返回符合扫描参数的所有Beacon
 *
 *  @param manager 定位引擎实例
 *  @param beacons Beacon数组，[BRTMapBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedBeacons:(NSArray<BRTMapBeacon *> *)beacons;

/**
 *  定位Beacon扫描结果事件回调，返回符合扫描参数的定位Beacon，定位Beacon包含坐标信息。此方法可用于辅助巡检，以及基于定位beacon的相关触发事件。
 *
 *  @param manager 定位引擎实例
 *  @param beacons 定位Beacon数组，[BRTPublicBeacon]
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didRangedLocationBeacons:(NSArray<BRTPublicBeacon *> *)beacons;

/**
 *  当前设备地磁北方向改变事件回调。
 *
 *  @param manager    定位引擎实例
 *  @param deviceHeading 手机设备北偏角（指南针方向）
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateDeviceHeading:(double)deviceHeading;

/**
 *  当前地图地磁北方向改变事件回调。已经加入initAngle修正，可以直接用于设置地图旋转、定位箭头旋转方向等功能。
 *  initAngle：室内地图北偏角度（获取方法：持手机面向地图正上方所在指南针方向）
 *
 *  @param manager    定位引擎实例
 *  @param mapHeading 相对于地图的正北偏角（mapHeading = deviceHeading - initAngle）
 */
- (void)BRTLocationManager:(BRTLocationManager *)manager didUpdateMapHeading:(double)mapHeading;

@end
