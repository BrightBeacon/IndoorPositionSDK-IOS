//
//  BaseMapVC.h
//  mapdemo
//
//  Created by thomasho on 16/12/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BRTMapSDK/BRTMapSDK.h>

@interface BaseMapVC : UIViewController<BRTMapViewDelegate>

@property (nonatomic,strong) NSString *buildingID,*appKey;
@property (nonatomic,strong) BRTMapView *mapView;

@end
