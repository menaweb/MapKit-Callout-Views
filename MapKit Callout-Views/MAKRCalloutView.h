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
//@property (nonatomic, readonly) CGPoint calculatedOrigin;

@property (nonatomic, strong) UIColor *bubbleStrokeColor;
@property (nonatomic, strong) UIColor *bubbleBackgroundColor;

@property (weak, nonatomic, readonly) IBOutlet UIButton *calloutButton;

- (void)setTitleText:(NSString *)titleText subtitleText:(NSString *)subtitleText informationText:(NSString *)informationText;

- (void)placeInMapView:(MKMapView *)mapView insideAnnotationView:(MKAnnotationView *)annotationView;

@end

@protocol MAKRCalloutViewDelegate <NSObject>

@required

- (void)configureCalloutView:(MAKRCalloutView *)calloutView withAnnotationView:(MKAnnotationView *)annotationView;

- (void)calloutView:(MAKRCalloutView *)calloutView buttonTappedWithAnnotationView:(MKAnnotationView *)annotationView;

@end
