//
//  LayerVC.m
//  mapdemo
//
//  Created by thomasho on 16/12/16.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import "MarkerVC.h"

// MGLPointAnnotation subclass
@interface CustomPointAnnotation : MGLPointAnnotation
@end

@implementation CustomPointAnnotation
@end

// MGLAnnotationView subclass
@interface CustomAnnotationView : MGLAnnotationView
@property (nonatomic,strong) UILabel *titleLabel;
@end

@implementation CustomAnnotationView
- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier text:(NSString *)text {
    self = [self initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
    // Force the annotation view to maintain a constant size when the map is tilted.
        if (text.length) {
            self.scalesWithViewingDistance = false;
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            self.titleLabel.text = text;
            self.titleLabel.textColor = [UIColor blackColor];
            [self addSubview:self.titleLabel];
        }else{
            self.layer.cornerRadius = 20;
            self.layer.masksToBounds = YES;
            self.backgroundColor = [UIColor cyanColor];
        }
    }
    return self;
}
@end

@implementation MarkerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double height = self.view.frame.size.height;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 150, 100, 44)];
    [btn setTitle:@"添加图片" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 100, 100, 44)];
    btn.tag = 1;
    [btn setTitle:@"添加文字" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(15, height - 50, 100, 44)];
    btn.tag = 2;
    [btn setTitle:@"添加标点" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(operButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:btn];
}

- (IBAction)operButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{
            MGLPointAnnotation *hello = [[MGLPointAnnotation alloc] init];
            hello.coordinate = self.mapView.centerCoordinate;
            [self.mapView addAnnotation:hello];
        }
            break;
        case 1:{
            CustomPointAnnotation *ann = [[CustomPointAnnotation alloc] init];
            ann.coordinate = self.mapView.centerCoordinate;
            ann.title = @"测试文字";
            [self.mapView addAnnotation:ann];
        }
            break;
        case 2:{
            CustomPointAnnotation *hello = [[CustomPointAnnotation alloc] init];
            hello.coordinate = self.mapView.centerCoordinate;
            [self.mapView addAnnotation:hello];
        }
            break;
            
        default:
            break;
    }
    [sender setSelected:!sender.isSelected];
}

#pragma mark - **************** delegate

- (void)mapView:(BRTMapView *)mapView didClickAtPoint:(CGPoint)screen {
    self.mapView.labelLayer.symbolHeight = [NSExpression expressionForConstantValue:@5];
    self.mapView.facilityLayer.symbolHeight = [NSExpression expressionForConstantValue:@5];
    [self.mapView removeAnnotations:self.mapView.annotations];
}
- (MGLAnnotationImage *)mapView:(BRTMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[CustomPointAnnotation class]]) {
        return nil;
    }
    // Try to reuse the existing annotation image, if it exists.
    MGLAnnotationImage *annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:@"location"];
    
    // If the annotation image hasn‘t been set yet, initialize it here.
    if (!annotationImage) {
        // Leaning from the Noun Project.
        UIImage *image = [UIImage imageNamed:@"location"];
        
        // The anchor point of an annotation is currently always the center. To
        // shift the anchor point to the bottom of the annotation, the image
        // asset includes transparent bottom padding equal to the original image
        // height.
        //
        // To make this padding non-interactive, we create another image object
        // with a custom alignment rect that excludes the padding.
        image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
        
        // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"location"];
    }
    
    return annotationImage;
}

- (MGLAnnotationView *)mapView:(BRTMapView *)mapView viewForAnnotation:(id <MGLAnnotation>)annotation {
    // This example is only concerned with point annotations.
    if (![annotation isKindOfClass:[CustomPointAnnotation class]]) {
        return nil;
    }
    
    // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
    NSString *reuseIdentifier =  ((CustomPointAnnotation *)annotation).title?:@"";
    
    // For better performance, always try to reuse existing annotations.
    CustomAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    // If there’s no reusable annotation view available, initialize a new one.
    if (!annotationView) {
        annotationView = [[CustomAnnotationView alloc] initWithReuseIdentifier:reuseIdentifier text:((CustomPointAnnotation *)annotation).title];
        annotationView.frame = CGRectMake(0, 0, 40, 40);
    }
    return annotationView;
}

//允许显示默认弹窗
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    // Always allow callouts to popup when annotations are tapped.
    return YES;
}
- (UIView *)mapView:(MGLMapView *)mapView leftCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation {
    return [UIButton buttonWithType:UIButtonTypeContactAdd];
}
- (UIView *)mapView:(MGLMapView *)mapView rightCalloutAccessoryViewForAnnotation:(id<MGLAnnotation>)annotation {
    return [UIButton buttonWithType:UIButtonTypeInfoLight];
}
@end
