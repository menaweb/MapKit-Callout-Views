//
//  MAKRViewController.m
//  MapKit Callout-Views
//
//  Created by Alexander Repty on 08.12.13.
//  Copyright (c) 2013 alexrepty. All rights reserved.
//

#import "MAKRViewController.h"

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MAKRSampleAnnotation.h"
#import "MAKRCalloutView.h"

NSString *const kMAKRViewControllerMapAnnotationViewReuseIdentifier = @"MAKRViewControllerMapAnnotationViewReuseIdentifier";

#pragma mark - Class Extension
#pragma mark -

@interface MAKRViewController () <MKMapViewDelegate>

@property(nonatomic,strong) IBOutlet MKMapView *mapView;

@property (nonatomic, weak) id<MKAnnotation> selectedAnnotation;
@property (nonatomic, weak) UIView *calloutView;

@end

@implementation MAKRViewController {
    BOOL _placeInsiderAnnotationView;
    BOOL _isPlacingCalloutView;
    BOOL _isUserMovingMapView;
    CGFloat _annotationViewHeight;
}

#pragma mark UIViewController Methods
#pragma mark -

- (void)viewDidLoad {
    _placeInsiderAnnotationView = FALSE;
    
	MAKRSampleAnnotation *annotation = [MAKRSampleAnnotation new];
	annotation.coordinate = CLLocationCoordinate2DMake(52.525923, 13.411399);
	annotation.title = @"Kino Babylon";
	annotation.subtitle = @"Rosa-Luxemburg-Str. 30, 10178 Berlin";
	
	[self.mapView addAnnotation:annotation];
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000.0, 1000.0);
	[self.mapView setRegion:region];
}

#pragma mark - Callout Placement
#pragma mark -

//// Place the callout view inside of the annotation view which allows for moving with the map view
- (void)placeCalloutView:(MAKRCalloutView *)calloutView insideAnnotationView:(MKAnnotationView *)annotationView {
    self.calloutView = calloutView;
    calloutView.alpha = 0.0f;
    
	[annotationView addSubview:calloutView];
    [calloutView setTitleText:annotationView.annotation.title subtitleText:annotationView.annotation.subtitle informationText:@"Today: AltTechTalks"];
	calloutView.center = CGPointMake((CGRectGetWidth(annotationView.bounds) / 2.0) - 9.0, -1.0 * CGRectGetHeight(calloutView.frame) / 2);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
        calloutView.alpha = 1.0f;
        [self.mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    } completion:^(BOOL finished) {
    }];
}

//// Place the callout view above the map view so the button can be tapped
- (void)placeCalloutView:(MAKRCalloutView *)calloutView overMapView:(MKMapView *)mapView aboveAnnotationView:(MKAnnotationView *)annotationView {
    _isPlacingCalloutView = TRUE;
    
    self.calloutView = calloutView;
    calloutView.alpha = 0.0f;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.15f delay:0.0f usingSpringWithDamping:3.0 initialSpringVelocity:12.0 options:options animations:^{
        [self.mapView setCenterCoordinate:annotationView.annotation.coordinate animated:TRUE];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self.view addSubview:calloutView];
            [self.view bringSubviewToFront:calloutView];
            
            [calloutView setTitleText:annotationView.annotation.title subtitleText:annotationView.annotation.subtitle informationText:@"Today: AltTechTalks"];
            
            _annotationViewHeight = CGRectGetHeight(annotationView.frame);
            CGRect frame = calloutView.frame;
            frame.origin = [self originForCalloutView:calloutView];
            calloutView.frame = frame;
            
            [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0 initialSpringVelocity:9.0 options:options animations:^{
                calloutView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                _isPlacingCalloutView = FALSE;
            }];
        });
    }];
}

//// Animates repositioning of callout view
- (void)repositionCalloutView:(UIView *)calloutView animated:(BOOL)animated {
    if (calloutView && self.selectedAnnotation) {
        CGRect frame = calloutView.frame;
        CGPoint origin = [self originForCalloutView:calloutView];
        frame.origin = origin;
        
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:animated ? 0.45f : 0.0f delay:0.0f usingSpringWithDamping:3.0 initialSpringVelocity:3.0 options:options animations:^{
            calloutView.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}

//// Provides origin for callout view to place it directly above the selected annotation
- (CGPoint)originForCalloutView:(UIView *)calloutView {
    CGPoint point = [self.mapView convertCoordinate:self.selectedAnnotation.coordinate toPointToView:self.mapView];
    CGPoint origin = CGPointMake(point.x - (CGRectGetWidth(calloutView.frame) / 2), point.y - CGRectGetHeight(calloutView.frame) - _annotationViewHeight);
    
    return origin;
}

//// Track the selected annotation when map is being moved
- (void)trackSelectedAnnotation {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (_isUserMovingMapView && self.selectedAnnotation) {
        [self repositionCalloutView:self.calloutView animated:TRUE];
        [self performSelector:@selector(trackSelectedAnnotation) withObject:nil afterDelay:0.1f];
    }
}

#pragma mark MKMapViewDelegate Methods
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:kMAKRViewControllerMapAnnotationViewReuseIdentifier];
    
    [view prepareForReuse];
    
	return view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for (MKAnnotationView *annotationView in views) {
		annotationView.canShowCallout = NO;
	}
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    self.selectedAnnotation = annotationView.annotation;
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutView"];
    
	MAKRCalloutView *calloutView = (MAKRCalloutView *)vc.view;
    calloutView.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (_placeInsiderAnnotationView) {
        [self placeCalloutView:calloutView insideAnnotationView:annotationView];
    }
    else {
        [self placeCalloutView:calloutView overMapView:mapView aboveAnnotationView:annotationView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView.annotation isEqual:self.selectedAnnotation]) {
        self.selectedAnnotation = nil;
    }
    
    if (_placeInsiderAnnotationView) {
        [self.calloutView removeFromSuperview];
    }
    else {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0f initialSpringVelocity:9.0f options:options animations:^{
            self.calloutView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.calloutView removeFromSuperview];
        }];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    _isUserMovingMapView = TRUE;
    self.calloutView.alpha = 0.25f;
    [self trackSelectedAnnotation];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _isUserMovingMapView = FALSE;
    self.calloutView.alpha = 1.0f;
}

@end
