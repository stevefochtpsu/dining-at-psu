//
//  MenuTableViewController.m
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/11/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MenuTableViewCell.h"
#import "ECSNavigationController.h"

#import "LocationMapViewController.h"
#import "HoursViewController.h"

#import "DisclaimerViewController.h"


#define kTextFieldWidth 250
#define kMealCount 4
#define kDisclaimerDelay 1.0

@interface MenuTableViewController()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logBarButton;
@property (nonatomic,retain) Model *model;

@property (strong, nonatomic) NSMutableArray *foods4Meals;  // cache downloaded food results for 4 meals
@property (strong, nonatomic) NSMutableDictionary *servingsDictionary;  // logging info
@property (strong, nonatomic) NSMutableArray *servings4Meals;
@property (strong, nonatomic)  UIBarButtonItem *mapButton;


@property NSInteger campusIndex;
@property NSInteger locationIndex;
@property NSInteger mealNumber;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,retain) NSDateFormatter *dateFormat;
@property (nonatomic,retain) NSMutableArray *menuArray;
@property (nonatomic,retain) UIDatePicker *aDatePicker;
@property (nonatomic, strong) UILabel *titleLabel;
@property BOOL logging;
@property (readonly) BOOL noMenu;
@property BOOL tableReady;

@property (nonatomic, strong) DisclaimerViewController *dvc;


-(void) updateTitle;
- (IBAction)logMode:(id)sender;
- (IBAction)servingStepperChanged:(id)sender;

-(IBAction)dismssModal:(UIStoryboardSegue*)segue;

@end

@implementation MenuTableViewController
@synthesize menuTableView;
@synthesize mealSegmentedControl;
@synthesize campusIndex, locationIndex, mealNumber, model, date, dateFormat, menuArray, aDatePicker;
@synthesize titleLabel;



-(id)initWithCoder:(NSCoder *)aDecoder {
        self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [Model sharedInstance];
    }
    return self;
}


//- (id)initWithModel:(Model *)aModel andCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex
//{
//    self = [super init];
//    if (self) {
//        [self setModel:aModel andCampus:cIndex andLocation:lIndex];
//    }
//    return self;
//}

- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    campusIndex = cIndex;
    locationIndex = lIndex;
    mealNumber = 1;
    
    [self resetMeals];
    
    self.title = [self.model getLocationNameWithCampus:self.campusIndex andIndex:self.locationIndex];
    
    date = [NSDate date];
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
 
    [self updateTitle];
    
    [self mealChanged];

}

-(BOOL)noMenu {
    return ([self.menuArray count] == 0);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)createToolbar {
    // Left Arrow Button
    UIImage *leftArrow;
    leftArrow = IS_OS_7_OR_LATER ? [UIImage imageNamed:@"smallGreenLeftArrow.png"] : [UIImage imageNamed:@"arrow_left.png"];
    UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 60, 44.1);
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 25);
    [leftButton setImage:leftArrow forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [leftButton setShowsTouchWhenHighlighted:NO];
    
    // Right Arrow Button
    UIImage *rightArrow;
    rightArrow = IS_OS_7_OR_LATER ? [UIImage imageNamed:@"smallGreenRightArrow.png"] : [UIImage imageNamed:@"arrow_right.png"];
    UIButton *rightButton = [UIButton buttonWithType: UIButtonTypeCustom];
    rightButton.frame = CGRectMake(155, 0, 60, 44.1);
    rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20);
    [rightButton setImage:rightArrow forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightButtonClicked)
          forControlEvents:UIControlEventTouchUpInside];
    [rightButton setShowsTouchWhenHighlighted:NO];
    
    // Creates view containing left arrow, title, right arrow
    UIView *myTitleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 200, 44.1)];
    //myTitleView.backgroundColor = [UIColor redColor];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44.1)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    UIColor *bColor = [UIColor colorWithRed:31.0/255.0 green:61.0/255.0 blue:1.0/255.0 alpha:1.0];
    titleLabel.textColor = IS_OS_7_OR_LATER ? bColor : [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
     titleLabel.text = @"";  // initially blank, will be updated when we have date
    
    [myTitleView addSubview: leftButton];
    [myTitleView addSubview: rightButton];
    [myTitleView addSubview: titleLabel];
    
    // Set navigation bar's title view to custom title view
    //self.navigationItem.titleView = myTitleView;
    
    UIBarButtonItem *dateNavButton = [[UIBarButtonItem alloc] initWithCustomView:myTitleView];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *hoursButton = [[UIBarButtonItem alloc] initWithTitle:@"Hours" style:UIBarButtonItemStyleBordered target:self action:@selector(showHours)];
    self.mapButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(showMap)];
    
 
    
    
    self.toolbarItems = @[self.mapButton, flexSpace, dateNavButton, flexSpace, hoursButton];
    
    //[self updateTitle]; // date not set here

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:menuDataDownloadCompleted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFailed)
                                                 name:dataDownloadFailed
                                               object:nil];
    
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    //UIBarButtonItem *dateButton = [[UIBarButtonItem alloc] initWithTitle:@"Date" style:UIBarButtonItemStylePlain target:self action:@selector(showDatePicker)];
    //self.navigationItem.rightBarButtonItem = dateButton;
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    [self createToolbar];
        
    [mealSegmentedControl addTarget:self action:@selector(mealChanged) forControlEvents:UIControlEventValueChanged];
    
    self.foods4Meals = [[NSMutableArray alloc] initWithCapacity:kMealCount];
    self.servings4Meals = [[NSMutableArray alloc] initWithCapacity:kMealCount];
    for (int i=0; i<kMealCount; i++) {
        NSMutableDictionary *servings =  [[NSMutableDictionary alloc] initWithCapacity:10];
        [self.servings4Meals addObject: servings];
        [self.foods4Meals addObject:[NSNull null]];
    }
    
    // initialize the menu
    self.mealSegmentedControl.selectedSegmentIndex = 0;
    //[self mealChanged];

}

-(void)resetMeals{
    for (int i=0; i<kMealCount; i++) {
        [self.foods4Meals replaceObjectAtIndex:i withObject:[NSNull null]];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.title = @"Menu"; //[dateFormat stringFromDate:date];
        self.navigationController.toolbarHidden = NO;
    [self.menuTableView reloadData];  // is this needed?
}

//TODO: add disclaimer once we have text
-(void)viewDidAppear:(BOOL)animated {
//    if (![self.model disclaimerShown]) {
//        [self performSegueWithIdentifier:@"DisclaimerSegue" sender:self];
//    }
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
    
    if (self.logging) {  // if leaving page still in logging mode
        [self logMode:self.logBarButton];   // update the log button
        //self.logging = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.tableReady) {
        return 0;
    } else if ([self noMenu]) {
        return 1;
    } else {
    return [menuArray count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self noMenu]) {
        return @"";
    }
    
    NSMutableDictionary *menuCat = [menuArray objectAtIndex:section];
 
    if (menuCat != nil)
        return [menuCat objectForKey:kName];
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self noMenu]) {
        return 1;
    }
    NSMutableDictionary *menuCat = [menuArray objectAtIndex:section];
    NSMutableArray *itemArray = [menuCat objectForKey:@"Menu Items"];
    
    if (itemArray != nil)
        return [itemArray count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MenuCell";
  
    static NSString *BlankCellIdentifier = @"BlankCell";

   
    if ([self noMenu]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BlankCellIdentifier];
        cell.textLabel.text = @"No Menu Available";
        return cell;
    }
    
    NSMutableDictionary *menuCat = [menuArray objectAtIndex:[indexPath section]];
    NSMutableArray *itemArray = [menuCat objectForKey:@"Menu Items"];
    NSMutableDictionary *menuItem = [itemArray objectAtIndex:[indexPath row]];
    
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (menuItem != nil) {
        NSString *food = [menuItem objectForKey:kName];
        cell.textView.text = food;
        NSString *calories = [NSString stringWithFormat:@"Calories: %@",[menuItem objectForKey:kCalories]];
        cell.caloriesLabel.text = calories;
        CGSize size = [cell.textView.text sizeWithFont:cell.textView.font
                                                constrainedToSize:CGSizeMake(kTextFieldWidth, 600.0)];
        cell.textView.frame = CGRectMake(0.0, 0.0, cell.textView.frame.size.width, size.height+10);
       
        //[cell.contentView bringSubviewToFront:cell.caloriesLabel];
        //Favorites
        cell.favorite.hidden = !([self.model isFavoriteFood:food]);
        
        if (self.logging) {
            cell.caloriesLabel.hidden = NO;
            cell.stepper.hidden = NO;
            cell.quantity.hidden = NO;
            // set the quantity
            NSNumber *size = [self.servingsDictionary objectForKey:indexPath];
            NSInteger sizeValue = size ? [size integerValue] : 0;
            cell.quantity.text = [NSString stringWithFormat:@"%d", sizeValue];
            cell.stepper.value = sizeValue;
        } else {
            cell.caloriesLabel.hidden = YES;
            cell.stepper.hidden = YES;
            cell.quantity.hidden = YES;
        }

    }
    else 
        cell.textLabel.text = @"";
    
    return cell;
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self noMenu]) {
        return 44.0;
    }
    
    NSMutableDictionary *menuCat = [menuArray objectAtIndex:[indexPath section]];
    NSMutableArray *itemArray = [menuCat objectForKey:@"Menu Items"];
    NSMutableDictionary *menuItem = [itemArray objectAtIndex:[indexPath row]];
    NSString *text = [menuItem objectForKey:kName];
   
        return [text
                sizeWithFont:[UIFont fontWithName:@"Helvetica" size:20.0]
                constrainedToSize:CGSizeMake(kTextFieldWidth, 600.0)].height + (self.logging ? 46.0 : 10.0);  // take Calories label into account in logging mode
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UIColor *backgroundColor = [UIColor colorWithRed:31.0/255.0 green:61.0/255.0 blue:1.0/255.0 alpha:1.0];
    [headerView setBackgroundColor:backgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
   
    return headerView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MenuTableViewCell class]]) {
        MenuTableViewCell *menuCell = (MenuTableViewCell*)cell;
        NSString *food = menuCell.textView.text;
        if ([self.model isFavoriteFood:food]) {
            [self.model removeFavoriteFood:food];
            menuCell.favorite.hidden = YES;
        } else {
            [self.model addFavoriteFood:food];
            menuCell.favorite.hidden = NO;
        }

    }
    }

#pragma mark - Actions

- (void)mealChanged
{
    NSInteger index = [self.mealSegmentedControl selectedSegmentIndex];
    self.servingsDictionary = [self.servings4Meals objectAtIndex:index];
    self.mealNumber = index + 1;
     if ([self.foods4Meals objectAtIndex:index] == [NSNull null]) {
          self.mealSegmentedControl.userInteractionEnabled = NO;
          [self.model loadMenuForCampus:campusIndex andLocation:locationIndex andMeal:mealNumber andDate:[dateFormat stringFromDate:date]];
 
     } else {
         self.menuArray = [self.foods4Meals objectAtIndex:index];
         [self.menuTableView reloadData];

     }
    
   
}



- (void)downloadCompleted:(NSNotification *)notification
{
    id sender = [notification object];
   
    // only care about menus requested for display, not for favorite processing
    if ((Model*)sender != self.model) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    self.menuArray = [userInfo objectForKey:@"array"];
    
//    if ([menuArray count] == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Menu Available"
//                                                            message:nil
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
    
    NSInteger index = [self.mealSegmentedControl selectedSegmentIndex];
    [self.foods4Meals setObject:self.menuArray atIndexedSubscript:index];
    
    self.tableReady = YES;
 
    self.mealSegmentedControl.userInteractionEnabled = YES;
   [self.menuTableView reloadData];
    
    // enable map button only if we have non-zero coordinates
    NSDictionary *coordDictionary = [model getLatitudeAndLongitudeForCampus:self.campusIndex andLocation:self.locationIndex];
    NSNumber *latitude = [coordDictionary objectForKey:@"latitude"];
    self.mapButton.enabled = ([latitude integerValue] != 0);

}

-(void)downloadFailed {
    self.mealSegmentedControl.userInteractionEnabled = YES;

}


#pragma mark - Title Bar buttons

-(void) updateTitle{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    NSString *todayString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: self.date]];
    
    self.titleLabel.text = todayString;
}

- (IBAction)logMode:(id)sender {
    UIBarButtonItem *logButton = (UIBarButtonItem*)sender;
    self.logging = !self.logging;
    
    if (self.logging) {
        logButton.title = @"Done";
        self.navigationController.toolbarHidden = YES;  // no toolbar actions while logging!
        self.navigationItem.leftBarButtonItem.enabled = NO;  // no accessing menu while logging!
    } else {
        logButton.title = @"Log";
        [self doneServingsInfo:nil];  // finally enter the info
        [self resetServings];
         self.navigationController.toolbarHidden = NO;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    NSArray *indexPaths = [self.menuTableView indexPathsForVisibleRows];
    [self.menuTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.menuTableView reloadData];
}


-(void) updateMenu {
     [model loadMenuForCampus:campusIndex andLocation:locationIndex andMeal:mealNumber andDate:[dateFormat stringFromDate:date]];
}

-(void) leftButtonClicked
{
    self.date = [NSDate dateWithTimeInterval: -kSecondsInADay sinceDate:self.date];
    [self updateTitle];
    [self resetMeals];
    [self updateMenu];
}

-(void) rightButtonClicked
{
    /*
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: kDateFormat];
    NSString *currentDateString = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: self.date]];
    NSString *todayString = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: [NSDate date]]];
    */

        self.date = [NSDate dateWithTimeInterval: kSecondsInADay sinceDate:self.date];
        [self updateTitle];
        [self resetMeals];
        [self updateMenu];

}


#pragma mark - Button Actions
-(void)showMap {
    [self performSegueWithIdentifier:@"MapSegue" sender:self];
}

-(void)showHours {
    [self performSegueWithIdentifier:@"HoursSegue" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
  if ([segue.identifier isEqualToString:@"MapSegue"]) {
        LocationMapViewController *aMapViewController = segue.destinationViewController;
        NSString *name = [model getLocationNameWithCampus:self.campusIndex andIndex:self.locationIndex];
      NSDictionary *coordDictionary = [model getLatitudeAndLongitudeForCampus:self.campusIndex andLocation:self.locationIndex];
      NSNumber *latitude = [coordDictionary objectForKey:@"latitude"];
      NSNumber *longitude = [coordDictionary objectForKey:@"longitude"];
        [aMapViewController setLocationName:name andLongitude:longitude andLatitude:latitude];
      aMapViewController.completionBlock = ^(id obj){[self dismissViewControllerAnimated:YES completion:NULL];};
      
    } else if ([segue.identifier isEqualToString:@"HoursSegue"]) {
        HoursViewController *anHoursViewController = segue.destinationViewController;
        [anHoursViewController setCampus:self.campusIndex andLocation:self.locationIndex];
        anHoursViewController.completionBlock = ^(id obj){[self dismissViewControllerAnimated:YES completion:NULL];};
        
    }
    
}


#pragma mark - Servings Information
-(NSInteger)servingsForIndexPath:(NSIndexPath*)indexPath {
    NSNumber *size = [self.servingsDictionary objectForKey:indexPath];
    if (size) {
        return [size intValue];
    } else {
        return 0;
    }
}


-(void)resetServings {
    NSNumber *zero = [NSNumber numberWithInt:0];
    for (NSMutableDictionary* servingsDictionary in self.servings4Meals) {
        NSArray *keys = [servingsDictionary allKeys];
        for (id key in keys) {
            [servingsDictionary setObject:zero forKey:key];
        }
    }
    
   
}

-(void)setServings:(NSInteger)size forIndexPath:(NSIndexPath*)indexPath {
    [self.servingsDictionary setObject:[NSNumber numberWithInt:size] forKey:indexPath];
}

-(MenuTableViewCell*)menuTableViewCellForView:(UIView*)view {
    while (![view isKindOfClass:[MenuTableViewCell class]]) {
        view = view.superview;
    }
    MenuTableViewCell *cell = (MenuTableViewCell*)view;
    return cell;
}

- (IBAction)servingStepperChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    NSInteger value = stepper.value;
    //MenuTableViewCell *cell =  (MenuTableViewCell *)[[stepper superview] superview];  //stepper -> contentView -> cell
    MenuTableViewCell *cell = [self menuTableViewCellForView:stepper];
    NSIndexPath *indexPath = [self.menuTableView indexPathForCell:cell];
    [self setServings:value forIndexPath:indexPath];
    
}

// Add all the non-zero servings selections into the database
-(void)enterServings:(NSDictionary*)servingsDict fromMenu:(NSArray*)menu {
    
    NSDictionary *foodItemDictionary;
    
    for (NSIndexPath *indexPath in servingsDict) {
        NSNumber *num = [servingsDict objectForKey:indexPath];
        NSInteger servingSize = [num intValue];
        NSString *servingString = [NSString stringWithFormat:@"%d", servingSize];
        if (servingSize>0) {
            
            NSDictionary *menuCatDictionary = [menu  objectAtIndex:indexPath.section];
            NSArray *menuItems = [menuCatDictionary objectForKey: @"Menu Items"];
            foodItemDictionary = [menuItems  objectAtIndex:indexPath.row];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: foodItemDictionary];
            [dict setObject:servingString forKey: kServingSize];
            [self.model addFoodToLog:dict forDate:self.date];
        }
    }
    
}

-(IBAction)doneServingsInfo:(id)sender {
   
        for (int i=0; i<4; i++) {
            NSDictionary *dict = [self.servings4Meals objectAtIndex:i];
            NSArray *menu = [self.foods4Meals objectAtIndex:i];
            [self enterServings:dict fromMenu:menu];
        }
    [self resetServings];  // zero it all out since we're done.

}



#pragma mark - Unwind Segue
-(IBAction)dismssModal:(UIStoryboardSegue*)segue {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.model disclaimerWasShown];
}




@end
