//
//  MAKRSampleAnnotation.h
//  MapKit Callout-Views
//
//  Created by Alexander Repty on 08.12.13.
//  Copyright (c) 2013 alexrepty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MAKRSampleAnnotation : NSObject <MKAnnotation>

@property(nonatomic,assign) CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *subtitle;
@property(nonatomic,copy) NSString *information;

@end
