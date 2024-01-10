# 定位SDK接入流程

#### 项目介绍
本demo为演示定位SDK接入，同时提供了定位+地图SDK展示，实际项目也可以单独仅集成定位SDK。

#### 使用说明

创建或打开XCode新项目

## 1、项目设置
* 定位地图通用Other Linker Flags->设置：<code>-ObjC -lc++ -lgeos -framework BRTMapSDK -framework BRTMapData -framework BRTLocationEngine</code>
* 如仅使用定位Other Linker Flags->设置：<code>-ObjC -framework BRTMapData -framework BRTLocationEngine</code>
 
## 2、引入地图所需空间计算库[GEOS](./geos/libgeos.a)
* 检查配置Build Phases->Target Dependencies->geos
* 再配置Link Binary With Libraries引入libgeos.a

ps：(如未勾选拷贝geos文件到项目文件夹内，可能需手动配置geos及头文件所在路径)

## 3、引入地图/定位库（或配指向路径）
* 建筑数据公共库：[BRTMapData.framework](./BRTMapData.framework)
* 集成地图需要： [BRTMapSDK.framework](./BRTMapSDK.framework),[Mapbox.framework需配置为Embed Frameworks并添加runScript移除发布APP时移除模拟器版本脚本](./Mapbox.framework)
* 集成定位需要：[BRTLocationEngine.framework](./BRTLocationEngine.framework)

ps:如出现头文件无法找到，请检查Framework Search Paths是否包含以上库路径

## 4、配置蓝牙定位权限
* 打开Info.plist添加使用期间“WhenInUse”定位描述说明：NSLocationWhenInUseUsageDescription，（填写描述如：用于室内地图导航）
* 若应用需要使用后台及使用期间定位权限“Always”(含“WhenInUse”)，需添加3项以支持不同IOS版本：NSLocationAlwaysAndWhenInUseUsageDescription、NSLocationAlwaysUsageDescription和NSLocationWhenInUseUsageDescription

#### 智石科技

* [智石官网](http://www.brtbeacon.com)
* [帮助文档](http://help.brtbeacon.com)
* [社区提问](http://bbs.brtbeacon.com)

#### 商务合作、地图绘制咨询[4000-999-023](tel:4000999023)