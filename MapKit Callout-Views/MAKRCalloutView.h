//
//  MAKRCalloutView.h
//  MapKit Callout-Views
//
//  Created by Alexander Repty on 09.12.13.
//  Copyright (c) 2013 alexrepty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@protocol MAKRCalloutViewDelegate;

@interface MAKRCalloutView : UIView

@property (weak, nonatomic) id <MAKRCalloutViewDelegate> delegate;
@property (nonatomic, readonly) CGPoint calculatedOrigin;

- (void)setTitleText:(NSString *)titleText subtitleText:(NSString *)subtitleText informationText:(NSString *)informationText;

- (void)placeInsideAnnotationView:(MKAnnotationView *)annotationView;
- (void)placeOverMapView:(MKMapView *)mapView aboveAnnotationView:(MKAnnotationView *)annotationView;
- (void)reposition:(BOOL)animated;

- (void)startTracking;
- (void)stopTracking;

@end

@protocol MAKRCalloutViewDelegate <NSObject>

@required

- (void)configureCalloutView:(MAKRCalloutView *)calloutView withAnnotationView:(MKAnnotationView *)annotationView;

@end