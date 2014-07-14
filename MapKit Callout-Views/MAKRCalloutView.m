//
//  MAKRCalloutView.m
//  MapKit Callout-Views
//
//  Created by Alexander Repty on 09.12.13.
//  Copyright (c) 2013 alexrepty. All rights reserved.
//

#import "MAKRCalloutView.h"

#define kHeightOfArrow 10
#define kWidthOfArrow 20

#pragma mark - Class Extension
#pragma mark -

@interface MAKRCalloutView ()

@property(weak, nonatomic) IBOutlet UIView *containerView;
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property(weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (weak, readwrite, nonatomic) IBOutlet UIButton *calloutButton;

@property (weak, nonatomic) MKMapView *mapView;
@property (weak, nonatomic) MKAnnotationView *annotationView;

@property (nonatomic, readonly) CGPoint calculatedOrigin;

@end

@implementation MAKRCalloutView {
    BOOL _isPlacingCalloutView;
    BOOL _isTracking;
}

#pragma mark - Initialization
#pragma mark -

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.bubbleStrokeColor = [UIColor lightGrayColor];
    self.bubbleBackgroundColor = [UIColor whiteColor];
}

#pragma mark - Public
#pragma mark -

//// Set the title, subtitle and information text
- (void)setTitleText:(NSString *)titleText subtitleText:(NSString *)subtitleText informationText:(NSString *)informationText {
    self.titleLabel.text = titleText;
    self.subtitleLabel.text = subtitleText;
    self.informationLabel.text = informationText;
    
    [self adjustHeightWithIntrinsicSize];
}

//// Place the callout view inside of the annotation view which allows for moving with the map view
- (void)placeInMapView:(MKMapView *)mapView insideAnnotationView:(MKAnnotationView *)annotationView {
    self.mapView = mapView;
    self.annotationView = annotationView;
    self.alpha = 0.0f;
    
	[annotationView addSubview:self];
    [self configure];
    
    CGRect frame = self.frame;
    frame.origin = self.calculatedOrigin;
    self.frame = frame;
    
    [mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
        self.alpha = 1.0f;
        [self.mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Hit Test
#pragma mark -

//// Test if the point is in the button which is the only area the user can tap
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.calloutButton.frame, point) ? self.calloutButton : nil;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)buttonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(calloutView:buttonTappedWithAnnotationView:)]) {
        [self.delegate calloutView:self buttonTappedWithAnnotationView:self.annotationView];
    }
}

#pragma mark - Private
#pragma mark -

//// Calls delegate to allow for setting content and adjusting size before creating bubble image
- (void)configure {
    NSAssert(self.delegate, @"Delegate is required");
    if ([self.delegate respondsToSelector:@selector(configureCalloutView:withAnnotationView:)]) {
        [self.delegate configureCalloutView:self withAnnotationView:self.annotationView];
    }
    
    [self adjustHeightWithIntrinsicSize];
}

//// Provides origin for callout view to place it directly above the selected annotation
- (CGPoint)calculatedOrigin {
    NSAssert(self.annotationView, @"AnnotationView is required");
    
    CGFloat xPos = (((CGRectGetWidth(self.frame) / 2) - (CGRectGetWidth(self.annotationView.frame) / 2)) * -1) + self.annotationView.calloutOffset.x;
    CGFloat yPos = CGRectGetHeight(self.frame) * -1;
    CGPoint origin = CGPointMake(xPos, yPos);
    
    return origin;
}

- (void)adjustHeightWithIntrinsicSize {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect frame = self.frame;
    // container height + arrow height (container provides margins)
    frame.size.height = CGRectGetHeight(self.containerView.frame) + kHeightOfArrow;
    self.frame = frame;
    
    UIImage *backgroundImage = [self drawRoundedCorners:self.frame.size position:0.5 borderRadius:10 strokeWidth:1];
    self.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
}

//// Draw the bubble view
- (UIImage *)drawRoundedCorners:(CGSize)size position:(CGFloat)position borderRadius:(CGFloat)borderRadius strokeWidth:(CGFloat)strokeWidth {
    CGSize arrowSize = CGSizeMake(kWidthOfArrow, kHeightOfArrow);
    
    // define the 4 sides
    CGFloat left = strokeWidth;
    CGFloat right = size.width - strokeWidth;
    CGFloat top = strokeWidth;
    CGFloat bottom = size.height - strokeWidth - arrowSize.height;
    
    // define the 4 corners (started at top/left going clockwise)
    CGPoint point1 = CGPointMake(left, top);
    CGPoint point2 = CGPointMake(right, top);
    CGPoint point3 = CGPointMake(right, bottom);
    CGPoint point4 = CGPointMake(left, bottom);
    
    // define the points where each rounded corner will start and end (started at top/left going clockwise)
    CGPoint pointA __unused = CGPointMake(left, top + borderRadius);
    CGPoint pointB = CGPointMake(left + borderRadius, top);
    CGPoint pointC __unused = CGPointMake(right - borderRadius, top);
    CGPoint pointD = CGPointMake(right, top + borderRadius);
    CGPoint pointE __unused = CGPointMake(right, bottom - borderRadius);
    CGPoint pointF = CGPointMake(right - borderRadius, bottom);
    CGPoint pointG = CGPointMake(left + borderRadius, bottom);
    CGPoint pointH = CGPointMake(left, bottom - borderRadius);
    
    // define arrow position
    CGFloat arrowMiddle = size.width * position;
    CGPoint arrowLeftBase = CGPointMake(arrowMiddle - (arrowSize.width/2), bottom);
    CGPoint arrowRightBase = CGPointMake(arrowMiddle + (arrowSize.width/2), bottom);
    CGPoint arrowPoint = CGPointMake(arrowMiddle, bottom + arrowSize.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.bubbleStrokeColor.CGColor);
    CGContextSetFillColorWithColor(context, [self.bubbleBackgroundColor colorWithAlphaComponent:0.9].CGColor);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, pointB.x, pointB.y);
    
    // CGContextAddArcToPoint
    // Note: the first point is where the hard corner would be without corner radius and the 2nd point is where the line ends
    
    CGContextAddArcToPoint(context, point2.x, point2.y, pointD.x, pointD.y, borderRadius);
    CGContextAddArcToPoint(context, point3.x, point3.y, pointF.x, pointF.y, borderRadius);
    
    // draw arrow if the position is not zero
    if (position > 0) {
        // line from F to right arrow base
        CGContextAddLineToPoint(context, arrowRightBase.x, arrowRightBase.y);
        // line from right arrow base to arrow point
        CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        // line from arrow point to left arrow base
        CGContextAddLineToPoint(context, arrowLeftBase.x, arrowLeftBase.y);
        // line from left arrow base to G
        CGContextAddLineToPoint(context, pointG.x, pointG.y);
    }
    
    CGContextAddArcToPoint(context, point4.x, point4.y, pointH.x, pointH.y, borderRadius);
    CGContextAddArcToPoint(context, point1.x, point1.y, pointB.x, pointB.y, borderRadius);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
