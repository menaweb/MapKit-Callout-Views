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

@property (weak, nonatomic) MKMapView *mapView;
@property (weak, nonatomic)MKAnnotationView *annotationView;

@end

@implementation MAKRCalloutView {
    BOOL _isPlacedInsiderAnnotationView;
    BOOL _isPlacingCalloutView;
    BOOL _isTracking;
}

#pragma mark - Public
#pragma mark -

// Set the title, subtitle and information text
- (void)setTitleText:(NSString *)titleText subtitleText:(NSString *)subtitleText informationText:(NSString *)informationText {
    self.titleLabel.text = titleText;
    self.subtitleLabel.text = subtitleText;
    self.informationLabel.text = informationText;
    
    [self adjustHeightWithIntrinsicSize];
}

//// Place the callout view inside of the annotation view which allows for moving with the map view
- (void)placeInsideAnnotationView:(MKAnnotationView *)annotationView {
    _isPlacedInsiderAnnotationView = TRUE;
    self.annotationView = annotationView;
    self.alpha = 0.0f;
    
	[annotationView addSubview:self];
    [self configure];
    
	self.center = CGPointMake((CGRectGetWidth(annotationView.bounds) / 2.0) - 9.0, -1.0 * CGRectGetHeight(self.frame) / 2);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
        self.alpha = 1.0f;
        [self.mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    } completion:^(BOOL finished) {
    }];
}

//// Place the callout view over the map view above teh annotation view so button can be tapped
- (void)placeOverMapView:(MKMapView *)mapView aboveAnnotationView:(MKAnnotationView *)annotationView {
    _isPlacedInsiderAnnotationView = FALSE;
    _isPlacingCalloutView = TRUE;
    
    self.mapView = mapView;
    self.annotationView = annotationView;
    
    self.alpha = 0.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.15f delay:0.0f usingSpringWithDamping:3.0 initialSpringVelocity:12.0 options:options animations:^{
        [mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [mapView.superview addSubview:self];
            [mapView.superview insertSubview:self aboveSubview:mapView];
            [self configure];

            CGRect frame = self.frame;
            frame.origin = self.calculatedOrigin;
            self.frame = frame;
            
            [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
                self.alpha = 1.0f;
            } completion:^(BOOL finished) {
                _isPlacingCalloutView = FALSE;
            }];
        });
    }];
}

//// Provides origin for callout view to place it directly above the selected annotation
- (CGPoint)calculatedOrigin {
    NSAssert(self.mapView, @"MapView is required");
    NSAssert(self.annotationView, @"AnnotationView is required");
    CGPoint point = [self.mapView convertCoordinate:self.annotationView.annotation.coordinate toPointToView:self.mapView];
    CGPoint origin = CGPointMake(point.x - (CGRectGetWidth(self.frame) / 2), point.y - CGRectGetHeight(self.frame) - CGRectGetHeight(self.annotationView.frame));
    
    return origin;
}

//// Animates repositioning of callout view
- (void)reposition:(BOOL)animated {
    if (self.annotationView.annotation) {
        CGFloat duration = animated ? 0.1f : 0.0f;
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:3.0 initialSpringVelocity:3.0 options:options animations:^{
            CGRect frame = self.frame;
            frame.origin = self.calculatedOrigin;
            self.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}

//// Starts tracking the movement of the annotation view
- (void)startTracking {
    if (_isPlacedInsiderAnnotationView) {
        return;
    }
    _isTracking = TRUE;
    self.alpha = 0.75f;
    [self track];
}

//// Stops tracking the movement of the annotation view
- (void)stopTracking {
    if (_isPlacedInsiderAnnotationView) {
        return;
    }
    [self reposition:FALSE];
    _isTracking = FALSE;
    self.alpha = 1.0f;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)buttonTapped:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - Private
#pragma mark -

- (void)track {
    [self reposition:TRUE];
    if (_isTracking) {
        [self performSelector:@selector(track) withObject:nil afterDelay:0.01f];
    }
}

- (void)configure {
    NSAssert(self.delegate, @"Delegate is required");
    if ([self.delegate respondsToSelector:@selector(configureCalloutView:withAnnotationView:)]) {
        [self.delegate configureCalloutView:self withAnnotationView:self.annotationView];
    }
    
    [self adjustHeightWithIntrinsicSize];
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
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.9].CGColor);
    
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
