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
#import "MAKRPinAnnotationView.h"
#import "MAKRCalloutView.h"

NSString *const kMAKRViewControllerMapAnnotationViewReuseIdentifier = @"MAKRViewControllerMapAnnotationViewReuseIdentifier";

// Disables log messages when debugging is turned off
#ifndef NDEBUG

#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define DebugLog(message, ...)

#endif

#define kDefaultTitle @"Custom Callout View"

#pragma mark - Class Extension
#pragma mark -

@interface MAKRViewController () <MKMapViewDelegate, MAKRCalloutViewDelegate>

@property(nonatomic,strong) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

@property (nonatomic, weak) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, weak) MAKRCalloutView *calloutView;

@property (nonatomic, strong) NSArray *items;

@end

#define kTitleKey @"title"
#define kSubtitleKey @"subtitle"
#define kInformationKey @"information"
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"

@implementation MAKRViewController

#pragma mark View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    self.items = @[
                   @{kTitleKey: @"Kino Babylon", kSubtitleKey : @"Rosa-Luxemburg-Str. 30, 10178 Berlin", kInformationKey : @"Today: AltTechTalks", kLatitudeKey : @52.525923, kLongitudeKey : @13.411399},
                   @{kTitleKey: @"Berlin Carré", kSubtitleKey : @"Karl-Liebknecht-Str. 13, 10178 Berlin", kInformationKey : @"Monday: Mobile Monday", kLatitudeKey : @52.522180, kLongitudeKey : @13.407492},
                   @{kTitleKey: @"Alexanderplatz", kSubtitleKey : @"Alexanderplatz 9, 10178 Berlin", kInformationKey : @"Tuesday: NSCoder Nights", kLatitudeKey : @52.521285, kLongitudeKey : @13.410120}
                  ];
    
    for (NSDictionary *itemDict in self.items) {
        MAKRSampleAnnotation *annotation = [[MAKRSampleAnnotation alloc] init];
        annotation.title = itemDict[kTitleKey];
        annotation.subtitle = itemDict[kSubtitleKey];
        annotation.information = itemDict[kInformationKey];
        annotation.coordinate = CLLocationCoordinate2DMake([itemDict[kLatitudeKey] floatValue], [itemDict[kLongitudeKey] floatValue]);
        
        [self.mapView addAnnotation:annotation];
    }

    if (self.mapView.annotations.count) {
        id <MKAnnotation> annotation = self.mapView.annotations[0];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000.0, 1000.0);
        [self.mapView setRegion:region];
    }
    
    self.titleLabel.text = kDefaultTitle;
    self.subtitleLabel.text = @"";
    self.informationLabel.text = @"";
}

#pragma mark MKMapViewDelegate Methods
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kMAKRViewControllerMapAnnotationViewReuseIdentifier];
    
    if (!annotationView) {
        annotationView = [[MAKRPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMAKRViewControllerMapAnnotationViewReuseIdentifier];
    }
    
    NSAssert(annotationView, @"Annotation View must be defined.");
    
    [annotationView prepareForReuse];
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	for (MKAnnotationView *annotationView in views) {
		annotationView.canShowCallout = FALSE;
	}
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
    self.selectedAnnotationView = annotationView;
    
    self.titleLabel.text = annotationView.annotation.title;
    
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutView"];
    
	MAKRCalloutView *calloutView = (MAKRCalloutView *)vc.view;
    calloutView.delegate = self;
    calloutView.translatesAutoresizingMaskIntoConstraints = YES;
    calloutView.bubbleBackgroundColor = [UIColor whiteColor];
    calloutView.bubbleStrokeColor = [UIColor lightGrayColor];
    self.calloutView = calloutView;
    
    [calloutView placeInMapView:self.mapView insideAnnotationView:annotationView];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView isEqual:self.selectedAnnotationView]) {
        self.selectedAnnotationView = nil;
        
        self.titleLabel.text = kDefaultTitle;
        self.subtitleLabel.text = @"";
        self.informationLabel.text = @"";
        
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
    }
}

#pragma mark - MAKRCalloutViewDelegate
#pragma mark -

- (void)configureCalloutView:(MAKRCalloutView *)calloutView withAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView.annotation isKindOfClass:[MAKRSampleAnnotation class]]) {
        MAKRSampleAnnotation *sampleAnnotation = (MAKRSampleAnnotation *)annotationView.annotation;
        [self.calloutView setTitleText:sampleAnnotation.title subtitleText:sampleAnnotation.subtitle informationText:sampleAnnotation.information];
    }
}

- (void)calloutView:(MAKRCalloutView *)calloutView buttonTappedWithAnnotationView:(MKAnnotationView *)annotationView {
    if ([annotationView.annotation isKindOfClass:[MAKRSampleAnnotation class]]) {
        MAKRSampleAnnotation *sampleAnnotation = (MAKRSampleAnnotation *)annotationView.annotation;
        self.subtitleLabel.text = sampleAnnotation.subtitle;
        self.informationLabel.text = sampleAnnotation.information;
    }
}

@end
