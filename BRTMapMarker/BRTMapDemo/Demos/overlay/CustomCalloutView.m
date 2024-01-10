//
//  CustomCalloutView.m
//  BRTMapProject
//
//  Created by thomasho on 2018/5/9.
//  Copyright © 2018年 thomasho. All rights reserved.
//
//
//  CustomCalloutView.m
//

#import "CustomCalloutView.h"

@implementation MarkerAnnotationView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier size:(CGFloat)size {
    self = [self initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        // `draggable` is a property of MGLAnnotationView, disabled by default.
//        self.draggable = true;
        
        // This property prevents the annotation from changing size when the map is tilted.
        self.scalesWithViewingDistance = false;
        
        // Begin setting up the view.
        self.frame = CGRectMake(0, 0, size, size);
        
//        self.backgroundColor = [UIColor darkGrayColor];
        
        // Use CALayer’s corner radius to turn this view into a circle.
//        self.layer.cornerRadius = size / 2;
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 0.1;
    }
    return self;
}

@end

// Set defaults for custom tip drawing
static CGFloat const tipHeight = 10.0;
static CGFloat const tipWidth = 20.0;

@interface CustomCalloutView ()
@property (strong, nonatomic) UIButton *mainBody;
@end

@implementation CustomCalloutView {
    id <MGLAnnotation> _representedObject;
    __unused UIView *_leftAccessoryView;/* unused */
    __unused UIView *_rightAccessoryView;/* unused */
    __weak id <MGLCalloutViewDelegate> _delegate;
    BOOL _dismissesAutomatically;
    BOOL _anchoredToAnnotation;
}

@synthesize representedObject = _representedObject;
@synthesize leftAccessoryView = _leftAccessoryView;/* unused */
@synthesize rightAccessoryView = _rightAccessoryView;/* unused */
@synthesize delegate = _delegate;
@synthesize anchoredToAnnotation = _anchoredToAnnotation;
@synthesize dismissesAutomatically = _dismissesAutomatically;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        // Create and add a subview to hold the callout’s text
        UIButton *mainBody = [UIButton buttonWithType:UIButtonTypeSystem];
        mainBody.backgroundColor = [self backgroundColorForCallout];
        mainBody.tintColor = [UIColor whiteColor];
        mainBody.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        mainBody.layer.cornerRadius = 4.0;
        self.mainBody = mainBody;
        
        [self addSubview:self.mainBody];
    }
    
    return self;
}


#pragma mark - MGLCalloutView API

- (void)presentCalloutFromRect:(CGRect)rect inView:(UIView *)view constrainedToRect:(CGRect)constrainedRect animated:(BOOL)animated
{
    // Do not show a callout if there is no title set for the annotation
    if (![self.representedObject respondsToSelector:@selector(title)]||self.representedObject.title.length == 0)
    {
        return;
    }
    
    [view addSubview:self];
    
    // Prepare title label
    [self.mainBody setTitle:self.representedObject.title forState:UIControlStateNormal];
    [self.mainBody sizeToFit];
    
    if ([self isCalloutTappable])
    {
        // Handle taps and eventually try to send them to the delegate (usually the map view)
        [self.mainBody addTarget:self action:@selector(calloutTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        // Disable tapping and highlighting
        self.mainBody.userInteractionEnabled = NO;
    }
    
    // Prepare our frame, adding extra space at the bottom for the tip
    CGFloat frameWidth = self.mainBody.bounds.size.width;
    CGFloat frameHeight = self.mainBody.bounds.size.height + tipHeight;
    CGFloat frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0);
    CGFloat frameOriginY = rect.origin.y - frameHeight;
    self.frame = CGRectMake(frameOriginX, frameOriginY,
                            frameWidth, frameHeight);
    
    if (animated)
    {
        self.alpha = 0.0;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    }
}

- (void)dismissCalloutAnimated:(BOOL)animated
{
    if (self.superview)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }
        else
        {
            [self removeFromSuperview];
        }
    }
}

// Allow the callout to remain open during panning.
- (BOOL)dismissesAutomatically {
    return NO;
}

- (BOOL)isAnchoredToAnnotation {
    return YES;
}

// https://github.com/mapbox/mapbox-gl-native/issues/9228
- (void)setCenter:(CGPoint)center {
    center.y = center.y - CGRectGetMidY(self.bounds);
    [super setCenter:center];
}

#pragma mark - Callout interaction handlers

- (BOOL)isCalloutTappable
{
    if ([self.delegate respondsToSelector:@selector(calloutViewShouldHighlight:)]) {
        return [self.delegate performSelector:@selector(calloutViewShouldHighlight:) withObject:self];
    }
    
    return NO;
}

- (void)calloutTapped
{
    if ([self isCalloutTappable] && [self.delegate respondsToSelector:@selector(calloutViewTapped:)])
    {
        [self.delegate performSelector:@selector(calloutViewTapped:) withObject:self];
    }
}

#pragma mark - Custom view styling

- (UIColor *)backgroundColorForCallout
{
    return [UIColor darkGrayColor];
}

- (void)drawRect:(CGRect)rect
{
    // Draw the pointed tip at the bottom
    UIColor *fillColor = [self backgroundColorForCallout];
    
    CGFloat tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0);
    CGPoint tipBottom = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y + rect.size.height);
    CGFloat heightWithoutTip = rect.size.height - tipHeight - 1;
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef tipPath = CGPathCreateMutable();
    CGPathMoveToPoint(tipPath, NULL, tipLeft, heightWithoutTip);
    CGPathAddLineToPoint(tipPath, NULL, tipBottom.x, tipBottom.y);
    CGPathAddLineToPoint(tipPath, NULL, tipLeft + tipWidth, heightWithoutTip);
    CGPathCloseSubpath(tipPath);
    
    [fillColor setFill];
    CGContextAddPath(currentContext, tipPath);
    CGContextFillPath(currentContext);
    CGPathRelease(tipPath);
}

@end

