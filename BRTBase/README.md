# BRTMap3D_IOS_SDK_Release

#### 项目介绍
BRTMap3D_IOS_SDK_DEMO

#### 使用说明

创建或打开XCode新项目

## 1、项目设置
* 再搜索Other Linker Flags->设置：<code>-ObjC -lc++ -lgeos -framework BRTMapSDK -framework BRTMapData -framework BRTLocationEngine</code>
 
## 2、拖动引入geos目录下geos.xcodeproj库（或编译成libgeos.a库）
使用xcodeproj项目方式引入，占用小，方便git提交等；编译使用libgeos.a中间文件较大

#### 拖动引入配置：<br/>
* 然后配置Build Phases->Target Dependencies->+geos
* 再配置Link Binary With Libraries引入libgeos.a

#### 打开BRT-Framework/geos编译geos.xcodeproj工程：<br/>
* libgeos.a库会根据平台生成到相应目录
* 配置Library Search Paths:（示例）<br/>
	$(PROJECT_DIR)/../BRT-Framework/geos/geos/Debug-$(PLATFORM_NAME)

## 3、拖动引入地图定位库（或配指向路径）
* 建筑数据公共库：[BRTMapData.framework](BRTMapDemo/BRTMapData.framework)
* 集成地图需要： [BRTMapSDK.framework](BRTMapDemo/BRTMapSDK.framework)
* 集成定位需要：[BRTLocationEngine.framework](BRTMapDemo/BRTLocationEngine.framework)
* ps:如出现头文件无法找到，请检查Framework Search Paths是否包含以上库路径

## 4、IOS8以上配置定位权限
* 打开Info.plist添加使用期间“WhenInUse”定位描述说明：NSLocationWhenInUseUsageDescription，（填写描述如：用于室内地图导航）
* 若应用需要使用后台及使用期间定位权限“Always”(含“WhenInUse”)，需添加3项以支持不同IOS版本：NSLocationAlwaysAndWhenInUseUsageDescription、NSLocationAlwaysUsageDescription和NSLocationWhenInUseUsageDescription

## 5、拖动引入BRTBundle.bundle资源
* 地图所需图标文件

#### 更新日志

***
3.0.5
修复：修正离线路网hint,修正distanceToRouteEnd

***
3.0.4
修复：释放layer方便配置，修正hints，修正本地化

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