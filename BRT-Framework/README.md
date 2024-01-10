# BRT-Framework

## 1、地图/定位库
* 都需要引入：[BRTMapData.framework](./BRTMapData.framework)
* 只集成地图需要：[BRTMapSDK.framework](./BRTMapSDK.framework)+[./Mapbox.framework](./Frameworks)+[geos/](./geos)
* 只集成定位需要：[BRTLocationEngine.framework](BRTMapDemo/BRTLocationEngine.framework)
* ps:如出现头文件无法找到，请检查Framework Search Paths是否包含以上库路径
* Mapbox.framework是动态库，需要加入到：Building Phases->Embed Frameworks下，发布到App Store需要在Building Phases中添加Run Script来移除模拟器版本:

```
bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Mapbox.framework/strip-frameworks.sh"
```
## 2、libgeos.a文件引入
* 直接拖动libgeos.a到项目，xCode一般会自动添加头文件和库引用。
* 或通过路径引入，配置librarySearchPaths指向(libgeos.a->所在文件夹目录），headerSearchPaths指向（include目录），buildSetting还需添加OtherLinkFlags:-lgeos

#### 智石科技

* [智石官网](http://www.brtbeacon.com)
* [帮助文档](http://help.brtbeacon.com)
* [社区提问](http://bbs.brtbeacon.com)

#### 商务合作、地图绘制咨询[4000-999-023](tel:4000999023)