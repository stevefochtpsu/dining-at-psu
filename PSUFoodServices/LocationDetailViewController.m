//
//  LocationDetailViewController.m
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/12/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "MenuTableViewController.h"
#import "LocationMapViewController.h"
#import "HoursViewController.h"

@interface LocationDetailViewController ()
@property (weak, nonatomic) Model *model;
@property (weak, nonatomic) NSString *name;
@property NSInteger campusIndex;
@property NSInteger locationIndex;
@end

@implementation LocationDetailViewController
@synthesize mapView;
@synthesize scrollView;
@synthesize model, name, campusIndex, locationIndex;

- (id)initWithModel:(Model *)aModel andCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex
{
    self = [super init];
    if (self) {
        model = aModel;
        campusIndex = cIndex;
        locationIndex = lIndex;
        name = [model getLocationNameWithCampus:cIndex andIndex:lIndex];
        
        self.title = name;
    }
    
    return self;
}

- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    //model = aModel;
    campusIndex = cIndex;
    locationIndex = lIndex;
    name = [model getLocationNameWithCampus:cIndex andIndex:lIndex];
    
    self.title = name;

}

//- (IBAction)menuButtonPressed:(id)sender {
//    MenuTableViewController* aMenuTableViewController = [[MenuTableViewController alloc] initWithModel:model andCampus:campusIndex andLocation:locationIndex];
//    [self.navigationController pushViewController:aMenuTableViewController animated:YES];
//    
//    //self.title = @"Back";
//}

//- (IBAction)mapButtonPressed:(id)sender {
//    LocationMapViewController *aMapViewController = [[LocationMapViewController alloc] initWithLocationName:name andLongitude:[model getLongitudeForCampus:campusIndex andLocation:locationIndex] andLatitude:[model getLatitudeForCampus:campusIndex andLocation:locationIndex]];
//    
//    [self.navigationController pushViewController:aMapViewController animated:YES];
//    
//    //self.title = @"Back";
//}

//- (IBAction)hoursButtonPressed:(id)sender {
//    HoursViewController *anHoursViewController = [[HoursViewController alloc] initWithModel:model andCampus:campusIndex andLocation:locationIndex];
//    
//    [self.navigationController pushViewController:anHoursViewController animated:YES];
//}

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
    
    [scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                   initWithTitle: @"Back" 
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem:backButton];
    //[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];

}


// Not used in iOS6
//- (void)viewDidUnload
//{
//    [self setMapView:nil];
//    [self setScrollView:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MenuSegue"]) {
        MenuTableViewController* aMenuTableViewController = segue.destinationViewController;
        [aMenuTableViewController setCampus:campusIndex andLocation:locationIndex];
    } else if ([segue.identifier isEqualToString:@"MapSegue"]) {
         LocationMapViewController *aMapViewController = segue.destinationViewController;
        [aMapViewController setLocationName:name andLongitude:[model getLongitudeForCampus:campusIndex andLocation:locationIndex] andLatitude:[model getLatitudeForCampus:campusIndex andLocation:locationIndex]];
    } else if ([segue.identifier isEqualToString:@"HoursSegue"]) {
        HoursViewController *anHoursViewController = segue.destinationViewController;
        [anHoursViewController setCampus:campusIndex andLocation:locationIndex];

    }
}

@end

