//
//  LocationDetailViewController.h
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/12/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Model.h"

@interface LocationDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//- (id)initWithModel:(Model *)aModel andCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;

- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;

//- (IBAction)menuButtonPressed:(id)sender;
//- (IBAction)mapButtonPressed:(id)sender;
//- (IBAction)hoursButtonPressed:(id)sender;

@end
