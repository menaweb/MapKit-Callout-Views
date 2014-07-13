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

// Disables log messages when debugging is turned off
#ifndef NDEBUG

#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define DebugLog(message, ...)

#endif

#pragma mark - Class Extension
#pragma mark -

@interface MAKRViewController () <MKMapViewDelegate, MAKRCalloutViewDelegate>

@property(nonatomic,strong) IBOutlet MKMapView *mapView;

//@property (nonatomic, weak) id<MKAnnotation> selectedAnnotation;
@property (nonatomic, weak) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, weak) MAKRCalloutView *calloutView;

@end

@implementation MAKRViewController {
    BOOL _placeInsideAnnotationView;
}

#pragma mark View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    _placeInsideAnnotationView = FALSE;
    
	MAKRSampleAnnotation *annotation = [MAKRSampleAnnotation new];
	annotation.coordinate = CLLocationCoordinate2DMake(52.525923, 13.411399);
	annotation.title = @"Kino Babylon";
	annotation.subtitle = @"Rosa-Luxemburg-Str. 30, 10178 Berlin";
	
	[self.mapView addAnnotation:annotation];
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000.0, 1000.0);
	[self.mapView setRegion:region];
}

#pragma mark MKMapViewDelegate Methods
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kMAKRViewControllerMapAnnotationViewReuseIdentifier];
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMAKRViewControllerMapAnnotationViewReuseIdentifier];
    }
    
    NSAssert(annotationView, @"Annotation Vie must be defined.");
    
    [annotationView prepareForReuse];
    
//    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    annotationView.canShowCallout = YES;
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for (MKAnnotationView *annotationView in views) {
		annotationView.canShowCallout = FALSE;
	}
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    self.selectedAnnotationView = annotationView;
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutView"];
    
	MAKRCalloutView *calloutView = (MAKRCalloutView *)vc.view;
    calloutView.delegate = self;
    calloutView.translatesAutoresizingMaskIntoConstraints = YES;
    self.calloutView = calloutView;
    
    if (_placeInsideAnnotationView) {
        [calloutView placeInsideAnnotationView:annotationView];
    }
    else {
        [calloutView placeOverMapView:self.mapView aboveAnnotationView:annotationView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView isEqual:self.selectedAnnotationView]) {
        self.selectedAnnotationView = nil;
        
        if (_placeInsideAnnotationView) {
            [self.calloutView removeFromSuperview];
            self.calloutView = nil;
        }
        else {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
            [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:9.0f initialSpringVelocity:9.0f options:options animations:^{
                self.calloutView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self.calloutView removeFromSuperview];
                self.calloutView = nil;
            }];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.calloutView startTracking];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.calloutView stopTracking];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - MAKRCalloutViewDelegate
#pragma mark -

- (void)configureCalloutView:(MAKRCalloutView *)calloutView withAnnotationView:(MKAnnotationView *)annotationView {
    [self.calloutView setTitleText:annotationView.annotation.title subtitleText:annotationView.annotation.subtitle informationText:@"Today: AltTechTalks"];
}

@end
