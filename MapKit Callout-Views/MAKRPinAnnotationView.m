//
//  MAKRPinAnnotationView.m
//  MapKit Callout-Views
//
//  Created by Brennan Stehling on 7/13/14.
//  Copyright (c) 2014 alexrepty. All rights reserved.
//

#import "MAKRPinAnnotationView.h"

#import "MAKRCalloutView.h"

@implementation MAKRPinAnnotationView

#pragma mark - Hit Test
#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    MAKRCalloutView *calloutView = nil;
    
    // find the callout view
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[MAKRCalloutView class]]) {
            calloutView = (MAKRCalloutView *)subview;
            break;
        }
    }
    
    if (calloutView) {
        // adjust point for placement of callout view
        CGPoint calculatedOrigin = calloutView.frame.origin;
        CGPoint adjustedPoint = CGPointMake(ABS(calculatedOrigin.x - point.x), ABS(calculatedOrigin.y - point.y));
        
        // check with the callout view (proper encapsultation)
        UIView *view = [calloutView hitTest:adjustedPoint withEvent:event];
        
        if (view) {
            return view;
        }
    }
    
    return CGRectContainsPoint(self.frame, point) ? self : nil;
}

@end
