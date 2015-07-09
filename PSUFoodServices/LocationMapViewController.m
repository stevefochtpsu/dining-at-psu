//
//  LocationMapViewController.m
//  PSUFoodServices
//
//  Created by MTSS MTSS on 12/13/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "LocationMapViewController.h"

@interface LocationMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSNumber *longitude;
@property (nonatomic,retain) NSNumber *latitude;
@property (nonatomic,retain) CLLocationManager *locationManager;
- (IBAction)donePressed:(id)sender;
@end

@implementation LocationMapViewController
@synthesize mapView, name, longitude, latitude, locationManager;

- (id)initWithLocationName:(NSString *)locName andLongitude:(NSNumber *)locLong andLatitude:(NSNumber *)locLat
{
    self = [super init];
    if (self) {
        [self setLocationName:locName andLongitude:locLong andLatitude:locLat];
    }
    
    return self;
}

- (void)setLocationName:(NSString *)locName andLongitude:(NSNumber *)locLong andLatitude:(NSNumber *)locLat {
    name = locName;
    longitude = locLong;
    latitude = locLat;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Map";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([longitude floatValue] == 0 && [latitude floatValue] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Retrieve Data"
                                                            message:@"No location data available."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    
    MKPointAnnotation *mkPointAnnotation = [[MKPointAnnotation alloc] init];
    mkPointAnnotation.coordinate = coord;
    mkPointAnnotation.title = name;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 900.0, 900.0);
    [self.mapView setRegion:region animated:YES];
    
    [mapView addAnnotation:mkPointAnnotation];
    
    locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	[locationManager setDistanceFilter:kCLDistanceFilterNone];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	
	[locationManager startUpdatingLocation];
	
	if ([CLLocationManager headingAvailable])
		[locationManager startUpdatingHeading];
    
	[mapView setShowsUserLocation:YES];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)donePressed:(id)sender {
      self.completionBlock(nil);
}
@end
