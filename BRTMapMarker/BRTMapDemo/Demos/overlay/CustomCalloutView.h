//
//  CustomCalloutView.h
//  BRTMapProject
//
//  Created by thomasho on 2018/5/9.
//  Copyright © 2018年 thomasho. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Mapbox;


// MGLAnnotationView subclass
@interface MarkerAnnotationView : MGLAnnotationView

- (instancetype _Nonnull )initWithReuseIdentifier:(nullable NSString *)reuseIdentifier size:(CGFloat)size;

@end

@interface CustomCalloutView : UIView <MGLCalloutView>
@end

