//
//  LocationTableViewController.m
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/12/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "LocationTableViewController.h"
#import "MenuTableViewController.h"
#import "ECSNavigationController.h"

@interface LocationTableViewController () 
@property (nonatomic, strong) Model          *model;
@property (readonly) NSInteger favoriteCampus;
@property (nonatomic,strong) NSMutableArray *favoriteEateries;
@property BOOL modelReady;

@property (nonatomic,strong) NSArray *buttonsArray;
-(IBAction)chooseFavoriteCampus;
@end

@implementation LocationTableViewController

@synthesize model;
@synthesize favoriteCampus;

//static NSString *locationDataDownloadCompleted = @"locationDataDownloadCompleted";

-(NSInteger)favoriteCampus {
    return [self.model myCampus];
}

-(NSMutableArray*)favoriteEateries {
    return [self.model myEateries];
}


- (id)initWithModel:(Model *)aModel 
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        model = aModel;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        model = [Model sharedInstance];
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
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Locations";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:locationDataDownloadCompleted
                                               object:nil];
    
//    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
//    UIBarButtonItem *hoursButton = [[UIBarButtonItem alloc] initWithTitle:@"Hours" style:UIBarButtonItemStylePlain target:self action:@selector(showHours)];
//    self.buttonsArray = @[mapButton,hoursButton];
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;

}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"Locations";
   
    if ([self.favoriteEateries count] == 0 && self.modelReady) {  //initial value of preferences
        [self selectAllEateries];
    }
    
        
     [self.tableView reloadData];
    return;
 
}

// Each Child in container must set its barbutton items on the container (parent) controller
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //self.parentViewController.navigationItem.rightBarButtonItems = @[];
    //self.parentViewController.navigationItem.title = @"Locations";
    //self.parentViewController.navigationItem.leftBarButtonItems = nil;
}



// not needed in iOS6
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([model getCampusCount]>0) {  // jjh just return 1
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return [self.favoriteEateries count];  //[model getLocationCount:self.favoriteCampus];
}

/*- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
 return [model getCampusNames];
 }*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[model getCampusName:self.favoriteCampus] capitalizedString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    // Configure the cell...
    // get the favorite index, then get this index from model
    NSNumber *num = [self.favoriteEateries objectAtIndex:indexPath.row];
    NSInteger index = [num integerValue];
    cell.textLabel.text = [model getLocationNameWithCampus:self.favoriteCampus andIndex:index];
    //cell.detailTextLabel.text = [locationNames objectAtIndex:[indexPath row]];
    
    return cell;
}

// Implemented in Storyboard Segue
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    LocationDetailViewController *aLocationDetailViewController = [[LocationDetailViewController alloc] initWithModel:model andCampus:self.favoriteCampus andLocation:[indexPath row]];
//    
//    [self.navigationController pushViewController:aLocationDetailViewController animated:YES];
//    
//    //self.title = @"Back";
//}

#pragma mark - Notification Handler
- (void)downloadCompleted:(NSNotification *)notification
{
    self.modelReady = YES;
    
    if ([self.favoriteEateries count] == 0) {
        [self selectAllEateries];
    }
    
    

    [self.tableView reloadData];
}

#pragma mark - Eateries

// initially for a campus, all eateries are selected
-(void)selectAllEateries {
    NSInteger count = [model getLocationCount:self.favoriteCampus];
    [self.favoriteEateries removeAllObjects];
    for (int i=0; i<count; i++) {
        [self.favoriteEateries addObject:[NSNumber numberWithInt:i]];
    }
}



#pragma mark - Actions
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
    
    
    CampusTableViewController *aCampusTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CampusTableViewController"];
    aCampusTableViewController.campusNames = [model getCampusNames];
    //CampusTableViewController *aCampusTableViewController = [[CampusTableViewController alloc] initWithCampuses:[model getCampusNames]];
    aCampusTableViewController.favoriteCampus = self.favoriteCampus;
    
    aCampusTableViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:aCampusTableViewController animated:YES completion:NULL];
}

//- (void)dismissModalWithCampus:(NSInteger)newCampusIndex {
//    [model setFavCampus:newCampusIndex];
//    self.favoriteCampus = newCampusIndex;
//    [self dismissModalViewControllerAnimated:YES];
//    
//    [self.tableView reloadData];
//}
//
//- (void)dismissModal {
//    [self dismissModalViewControllerAnimated:YES];
//}

-(void)showMap {
    [self performSegueWithIdentifier:@"MapSegue" sender:self];
}

-(void)showHours {
     [self performSegueWithIdentifier:@"HoursSegue" sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // compute location index first by finding where row
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSInteger row = indexPath.row;
    NSNumber *location = [self.favoriteEateries objectAtIndex:row];
    NSInteger locationIndex = [location integerValue];
    
    if ([segue.identifier isEqualToString:@"MenuSegue"]) {
        MenuTableViewController *aMenuTableViewController = segue.destinationViewController;
        
       
        [aMenuTableViewController setCampus:self.favoriteCampus andLocation:locationIndex];
    } 

}

@end
