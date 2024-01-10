# IndoorMapPostion_IOS_SDK_Release

#### 项目介绍
IndoorMapPositon_IOS_SDK

#### 使用说明

创建或打开XCode新项目

## 1、引入地图定位库（或配指向路径）
* 公共资源库：[BRTMapData.framework](BRT-Framework/BRTMapData.framework)
* 地图支撑库： [BRTMapSDK.framework](BRT-Framework/BRTMapSDK.framework)，[Mapbox.framework](BRT-Framework/Mapbox.framework)，[geos.a](BRT-Framework/geos/)
* 定位支撑库：[BRTLocationEngine.framework](BRT-Framework/BRTLocationEngine.framework)

注意：请将Mapbox.framework添加到Build Phases->Embed Frameworks，并添加指向文件中的RunScript:

```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Mapbox.framework/strip-frameworks.sh"
```


## 2、需配置定位/蓝牙权限描述字符串
* 打开Info.plist添加蓝牙描述说明：NSBluetoothAlwaysUsageDescription，（填写描述如：使用蓝牙进行室内定位）
* 打开Info.plist添加使用期间“WhenInUse”定位描述说明：NSLocationWhenInUseUsageDescription，（填写描述如：使用室内定位进行导航）
* 若应用需要使用后台及使用期间定位权限“Always”(含“WhenInUse”)，需添加3项以支持不同IOS版本：NSLocationAlwaysAndWhenInUseUsageDescription、NSLocationAlwaysUsageDescription和NSLocationWhenInUseUsageDescription

#### 更新日志
***
3.3.2
允许使用styleURL配置支持的在线底图，需在info.plist配置可用的AccessToken
<code>- (instancetype)initWithFrame:(CGRect)frame styleURL:(NSURL *)styleURL;</code>

***
3.3.1
优化：允许起终点图标重叠，搜索支持自定义
新增：BRTSearchAdapter->initWithDBPath:table:

***
3.2.0
优化：升级mapbox
新增：楼层路网数据：routeOfFloor

***
3.1.9
修复：地图图标机型自适配
新增：BRTPoi: 新增所在大区信息（zoneID和zoneName），新增大区层级zoneLayer

***
3.1.8
修复：BRTPoi: buildingID和floorID
优化：getPoiOnCurrentFloorWithPoiID无需传人layer
新增：symbol图标解析，ICON_NAME，LEVEL_MIN，LEVEL_MAX解析

***
3.1.6
修复：经过的路线在其他楼层出现
优化：数据几何结构
新增：shade层，可用于展示大区信息等

***
3.1.5
修复：部分离线路线规划失败闪退

***
3.1.4
新增：地图、定位数据离线化支持

***
3.1.3
新增：离线路网增加多层级规划

***
3.1.2
修复：离线路网内存优化

***
3.1.1
修复：离线路网偶然截取闪退

***
3.1.0
修复：修复路网总距离计算

***
3.0.9
修复：离线路网算法更新

***
3.0.8
修复：新增设施选中

***
3.0.7
修复：路网颜色，设置地图加载8s超时，定位方向开关验证

***
3.0.6
新增：多功能在线导航，详见示例：RouteVC

***
3.0.5
修复：修正离线路网hint,修正distanceToRouteEnd

***
3.0.4
新增：
1、mapview释放labellayer和facilitylayer方便配置
2、本地化labellayer设置
修复：修正hints闪退

***
3.0.3
修复：闪退，mapload和floor顺序

***
3.0.2
新增：地图智能本地化，图文混排，独立搜索API
修复：路径规划泄漏

***
3.0.1
新增：BRTPoi新增labelPoint
修复：加载逻辑，路网优化

***
3.0.0

版本发布


#### 智石科技

* [智石官网](http://www.brtbeacon.com)
* [帮助文档](http://help.brtbeacon.com)
* [社区提问](http://bbs.brtbeacon.com)

#### 商务合作、地图绘制咨询[4000-999-023](tel:4000999023)
