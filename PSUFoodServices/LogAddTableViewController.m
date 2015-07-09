//
//  LogAddTableViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LogAddTableViewController.h"
#import "LogSelectorTableViewController.h"
#import "DataManager.h"
#import "Model.h"
#import "LocationSelectorTableViewController.h"
#import "LogAddCell.h"


#define kTitle @"title"
#define kLocation @"locations"

@interface LogAddTableViewController()

//@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSDate *menuDate;
@property (strong, nonatomic) NSArray *sources;
@property (strong, nonatomic) NSDictionary *customDictionary;
@property (strong, nonatomic) Model *model;
@property (readonly) NSInteger favoriteCampus;
@property (nonatomic,strong) NSMutableArray *favoriteEateries;

@property (strong, nonatomic) NSArray *campusCodes;



-(void) cancelButtonPressed;

@end

@implementation LogAddTableViewController
@synthesize delegate;
//@synthesize myTableView;
@synthesize menuDate;
@synthesize sources;
@synthesize favoriteCampus, model, customDictionary, campusCodes;

-(NSInteger)favoriteCampus {
    return [self.model myCampus];
}

-(NSMutableArray*)favoriteEateries {
    return [self.model myEateries];
}


-(id) initWithDate:(NSDate *)date {
    self = [super init];
    if (self) {
        [self setWithDate:date];
            }
    return self;
}

-(void) setWithDate: (NSDate *) date {
    menuDate = date;
    self.title = @"Select Source";
    self.model = [Model sharedInstance];
    
    
    // Create table
//    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - 44.1) style:UITableViewStyleGrouped];
//    
//    myTableView.delegate = self;
//    myTableView.dataSource = self;
//    
//    self.view = myTableView;
    
    
    // Create data source for table
    NSArray *pennStateLocations = [[NSArray alloc] initWithObjects:@"University Park", @"Commonwealth Campuses", nil ];
    NSDictionary *pennStateDict = [[NSDictionary alloc] initWithObjectsAndKeys: @"Penn State Eateries", kTitle, pennStateLocations, kLocation, nil];
    
    NSArray *custom = [[NSArray alloc] initWithObjects:@"My Foods", nil];
    self.customDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: @"Custom", kTitle, custom, kLocation, nil];
    
    sources = [[NSArray alloc] initWithObjects:pennStateDict, self.customDictionary, nil];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView reloadData];
    
    self.campusCodes = [NSArray arrayWithObjects: 
                        [NSArray arrayWithObject:@"40"], // Altoona
                        [NSArray arrayWithObject:@"42"], // Beaver
                        [NSArray arrayWithObject:@"56"], // Berks
                        [NSArray arrayWithObject:@"44"], //Greater Allegheny
                        [NSArray arrayWithObject:@"52"], //Hazelton
                        [NSArray arrayWithObject:@"54"], //MontAlto
                        [NSArray arrayWithObjects:@"46", //Behrend
                                @"47", nil],
                        [NSArray arrayWithObject:@"50"], //Harrisburg
                        [NSArray arrayWithObject:@"58"], //Schuylkill
                         [NSArray arrayWithObjects:@"11", //UP: Findley
                                @"17",  // North Foods District
                                @"14",  // Pollock
                                @"13",  // South
                                @"24",  // The Mix
                                @"16",nil], // West Food District
                        [NSArray arrayWithObject:@"49"], //Wilkes Barre
                         [NSArray arrayWithObject:@"48"], //Worthington-Scranton
                        nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // No need to cancel here. bad navigation.  -JJH 7/12/12  added back in 7/13/12
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Campus" style:UIBarButtonItemStylePlain target:self action:@selector(chooseFavoriteCampus)];
}

- (void)viewDidUnload
{
    
    self.campusCodes = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 2;  // favorite campus + custom //[sources count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    // Return the number of rows in the section.
    if (section==0) {  // local eateries
        
        if ([[model getCampusNames] count] == 0) {  // No Data
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Campus Data Available"
                                                                message:@"Check Network Connection"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            return 0;  // nothing to show
        } else {
                return [self.favoriteEateries count]; //[model getLocationCount:self.favoriteCampus];
        }
    } else {
        return [[self.customDictionary objectForKey: kLocation] count];
    }
    //return [[[sources objectAtIndex: section] objectForKey: kLocation] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LogAddCell *cell;
    static NSString *standardCellIdentifier = @"StandardLogAddCell";
    static NSString *customCellIdentifier = @"CustomLogAddCell";
    

    if (indexPath.section==0) { //favorite campus
       
        cell = [tableView dequeueReusableCellWithIdentifier:standardCellIdentifier forIndexPath:indexPath];


        // get the favorite index, then get this index from model
        NSNumber *num = [self.favoriteEateries objectAtIndex:indexPath.row];
        NSInteger index = [num integerValue];
        cell.textLabel.text = [model getLocationNameWithCampus:self.favoriteCampus andIndex:index];
        
//        NSString *name = [model getLocationNameWithCampus:self.favoriteCampus andIndex:[indexPath row]];
//        [cell.textLabel setText:name];
    } else {  // Custom Foods
       
        cell = [tableView dequeueReusableCellWithIdentifier:customCellIdentifier forIndexPath:indexPath];

        [cell.textLabel setText: [[self.customDictionary objectForKey: kLocation ] objectAtIndex: indexPath.row]];
    }
    
    
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[sources objectAtIndex: section] objectForKey: kTitle];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

#pragma mark - Table view delegate

-(NSString*)locationCodeforCampusIndex:(NSInteger)index {
    NSArray *campusEateries = [self.campusCodes objectAtIndex:self.favoriteCampus];
    return [campusEateries objectAtIndex:index];
}


// handled by segue now
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        [self performSegueWithIdentifier:@"StandardLogAddSegue" sender:self];
    } else if (section == 1) {
         [self performSegueWithIdentifier:@"CustomLogAddSegue" sender:self];
    }
}
 */

//    DataManager *dataManager = [DataManager sharedInstance];
//    NSArray *foods;
//
//    if (indexPath.section == 0) {  // UP or Commonwealth Campuses
//        
//        //Using storyboards for custom tableview cells - JJH 7/13/12
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//        LogSelectorTableViewController *logSelectorTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"StandardLogSelector"];
//        
//        //NSString *location = [[[[locations objectAtIndex: indexPath.section] objectForKey: @"eateries"] objectAtIndex: indexPath.row] objectForKey: @"locationCode"];
//        NSString *location = [self locationCodeforCampusIndex:indexPath.row];
//        
//        [logSelectorTableViewController setDate:self.menuDate andLocation:location];
//        logSelectorTableViewController.delegate = self;
//        
//        [self.navigationController pushViewController: logSelectorTableViewController animated:YES];
//        
//        /*
//        NSArray *eateries = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"Eateries" ofType:@"plist"]];
//        
//        foods = [eateries objectAtIndex: indexPath.row];
//        
//        LocationSelectorTableViewController *locationSelectorTableViewController = [[LocationSelectorTableViewController alloc] initWithStyle:UITableViewStyleGrouped Date: menuDate andItems: foods];
//        locationSelectorTableViewController.delegate = self;
//        
//        [self.navigationController pushViewController: locationSelectorTableViewController animated:YES];
//         */
//    }
//    
//    else  if (indexPath.section == 1) {  // Custom - My Foods
//        foods = [NSMutableArray arrayWithArray:[dataManager getMyFoods]];
//        
//        //LogSelectorTableViewController *logSelectorTableViewController = [[LogSelectorTableViewController alloc] initWithArray:foods andDate: menuDate];
//        
//        //Using Storyboard for custom table views -JJH 7/13/12
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
//        LogSelectorTableViewController *logSelectorTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyFoodsLogSelector"];
//        [logSelectorTableViewController  setFoods:foods andDate:menuDate];
//        
//        logSelectorTableViewController.delegate = self;
//        
//        [self.navigationController pushViewController: logSelectorTableViewController animated:YES];
//    }
//}

#pragma mark - LogSelectorTableViewController delegate

-(void) cancelButtonPressed {
    [self.delegate dismissLogAddTableViewController];
}

-(void) campusButtonPressed {
    
}


/*
#pragma  mark - Choose Favorite Campus
- (void)chooseFavoriteCampus {
    if ([[model getCampusNames] count] == 0) {  // No Data
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Campus Data Available"
                                                            message:@"Check Network Connection"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    CampusTableViewController *aCampusTableViewController = [[CampusTableViewController alloc] initWithCampuses:[model getCampusNames]];
    aCampusTableViewController.favoriteCampus = self.favoriteCampus;
    
    aCampusTableViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    aCampusTableViewController.campusModalDelegate = self;
    [self presentModalViewController:aCampusTableViewController animated:YES];
}

- (void)dismissModalWithCampus:(NSInteger)newCampusIndex {
    [model setFavCampus:newCampusIndex];
    self.favoriteCampus = newCampusIndex;
    [self dismissModalViewControllerAnimated:YES];
    
    [self.tableView reloadData];
}

- (void)dismissModal {
    [self dismissModalViewControllerAnimated:YES];
}
 */

// Can't get this to work directly!  Using Tableview delegate and performSegue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"StandardLogAddSegue"]) {
        LogSelectorTableViewController *logSelectorTableViewController = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSInteger row = indexPath.row;
        NSNumber *locationNumber = [self.favoriteEateries objectAtIndex:row];
        
        NSString *location = [self locationCodeforCampusIndex:[locationNumber integerValue]];
        
        [logSelectorTableViewController setDate:self.menuDate andLocation:location];
        logSelectorTableViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"CustomLogAddSegue"]) {
        LogSelectorTableViewController *logSelectorTableViewController = segue.destinationViewController;
        
        DataManager *dataManager = [DataManager sharedInstance];
        NSArray *foods = [NSMutableArray arrayWithArray:[dataManager getMyFoods]];
        [logSelectorTableViewController  setFoods:foods andDate:menuDate];
        
        logSelectorTableViewController.delegate = self;
    }
}


@end
