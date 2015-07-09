//
//  LogViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LogTableViewController.h"
#import "CustomFoodsTableViewController.h"
#import "DataManager.h"
#import "NutritionViewController.h"
#import "ECSNavigationController.h"

#define kSecondsInADay 86400

@interface LogTableViewController()

@property (nonatomic, strong) NSMutableArray *foodItems;
//@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSArray *buttonsArray;
@property (nonatomic,strong) NSArray *toolbarArray;

-(void) updateTitle;
-(void) updateTable;

//-(IBAction) addButtonPressed:(id)sender;

-(float) totalCalories;

@end

@implementation LogTableViewController
//@synthesize myTableView;
@synthesize currentDate;
@synthesize foodItems;
@synthesize titleLabel;

-(id) init
{ self = [super init];
    if (self) {
        [self initialize];
        //[self createToolbar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        //[self createToolbar];  // no toolbar showing dates since we're using a table of dates now
    }
    
    return self;
}



-(void)initialize {
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat: kDateFormat];
    
    //self.navigationItem.hidesBackButton = YES;
    
    // Gets Today's Date
    //NSDate *today = [NSDate date];
    //currentDate = today;  // set during segue now
    
    [self updateTitle];

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
    UIImage *leftArrow = [UIImage imageNamed:@"arrow_left.png"];
    UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 60, 44.1);
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 25);
    [leftButton setImage:leftArrow forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonClicked)
         forControlEvents:UIControlEventTouchUpInside];
    [leftButton setShowsTouchWhenHighlighted:NO];
    
    // Right Arrow Button
    UIImage *rightArrow = [UIImage imageNamed:@"arrow_right.png"];
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
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    [myTitleView addSubview: leftButton];
    [myTitleView addSubview: rightButton];
    [myTitleView addSubview: titleLabel];
    
    // Set navigation bar's title view to custom title view
    //self.navigationItem.titleView = myTitleView;
    
    UIBarButtonItem *dateNavButton = [[UIBarButtonItem alloc] initWithCustomView:myTitleView];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
   
    //self.navigationItem.rightBarButtonItems = @[mapButton,hoursButton];
    
    self.toolbarArray = @[flexSpace, dateNavButton, flexSpace];
   
    
    [self updateTitle];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the vie w from its nib.
     //self.myTableView = self.tableView;
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];

    self.buttonsArray = @[self.editButtonItem];
    
    // No menu button on this controller
//    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
//    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
//    self.navigationItem.leftBarButtonItem = menuButton;

  
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateTitle];
    //self.navigationController.toolbarHidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.navigationController.toolbarHidden = YES;
}

// Each Child in container must set its barbutton items on the container (parent) controller
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.toolbarItems = self.toolbarArray;
    
    
    self.navigationItem.title = @"Daily Log";
    self.navigationItem.rightBarButtonItems = self.buttonsArray;
    
    [self updateTable];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
      self.navigationItem.rightBarButtonItem.enabled = [self.foodItems count] > 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    // Return the number of rows in the section.
    return [foodItems count];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat: @"Total Calories: %.1f", [self totalCalories]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyFoodsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *menuItem = [foodItems objectAtIndex: indexPath.row];
    NSNumber *servingNum = [menuItem objectForKey:kServingSize];
    NSNumber *caloriesNum = [menuItem objectForKey: kCalories];
    NSString *itemName = [menuItem objectForKey: kName];
    float calories = [caloriesNum floatValue] * [servingNum floatValue];
    [cell.textLabel setText: itemName];
    NSInteger servingSize = [servingNum integerValue];
    NSString *servingInfo;
    if (servingSize==1) {
        servingInfo = @"(1 Serving)";
    } else {
        servingInfo = [NSString stringWithFormat:@"(%d Servings)", servingSize];
    }
    [cell.detailTextLabel setText: [NSString stringWithFormat: @"Calories: %.1f %@", calories, servingInfo]];
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        /*
         DataManager *dataManager = [DataManager sharedInstance];
         [projects removeObjectAtIndex: [indexPath row]];
         
         [dataManager deleteManagedObjectAtIndex: [indexPath row]];
         
         
         [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
         */
        // Delete the row from the data source
        
        DataManager *dataManager = [DataManager sharedInstance];
        
        [foodItems removeObjectAtIndex: [indexPath row]];
        
        [dataManager deleteLogFoodAtIndex: [indexPath row] forDate: self.currentDate];
        
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    //self.navigationItem.rightBarButtonItem.enabled = [self.foodItems count] > 0;
    
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *menuItem = [foodItems objectAtIndex: indexPath.row];
 
    NSString *itemName = [menuItem objectForKey: kName];
    
    //NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
    //[atts setObject:[UIFont fontWithName:@"Helvetica" size:20.0] forKey:NSFontAttributeName];
    
    
    //CGRect rect = [itemName boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:atts context:nil];
    //CGSize size2 = rect.size;

    
    CGFloat itemHeight = [itemName
                          sizeWithFont:[UIFont fontWithName:@"Helvetica" size:21.0]
                          constrainedToSize:CGSizeMake(self.tableView.bounds.size.width, 600.0)].height;
    return itemHeight + 22.0;  //add extra space for Calories
    
}


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    DataManager *dataManager = [DataManager sharedInstance];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: kDateFormat];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", [dateFormatter stringFromDate: currentDate]];
    //NSLog(@"%@", predicate);
    
    NSDictionary *dict = [dataManager getDictionaryForEntity: kLogItem withPredicate:predicate atIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    NutritionViewController *NutritionViewController = [[NutritionViewController alloc] initWithDictionary:dict Date:currentDate isLog: YES andIndex:indexPath.row];
    
    [self.navigationController pushViewController:NutritionViewController animated:YES];
    
}
*/

#pragma mark - Navigation Button Methods

//-(void)addButtonPressed{
//    [self performSegueWithIdentifier:@"LogAddSegue" sender:self];
//}

-(void) leftButtonClicked
{
    currentDate = [NSDate dateWithTimeInterval: -kSecondsInADay sinceDate:currentDate];
    [self updateTitle];
    [self updateTable];
}

-(void) rightButtonClicked
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: kDateFormat];
    NSString *currentDateString = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: currentDate]];
    NSString *todayString = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: [NSDate date]]];
    
    if(![currentDateString isEqualToString: todayString]) {
        currentDate = [NSDate dateWithTimeInterval: kSecondsInADay sinceDate:currentDate];
        [self updateTitle];
        [self updateTable];
    }
}

//-(void) addButtonPressed:(id)sender {
//    LogAddTableViewController *logAddTableView = [[LogAddTableViewController alloc] initWithDate: currentDate];
//    logAddTableView.delegate = self;
//    
//    UINavigationController *logAddNavigationController = [[UINavigationController alloc] initWithRootViewController:logAddTableView];
//    
//    [logAddNavigationController.navigationBar setTintColor:[UIColor colorWithRed:0.270588 green:0.521569 blue:0.141176 alpha:1.0]];
//    
//    logAddNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentModalViewController: logAddNavigationController animated:YES];
//}

#pragma mark - CustomFoodsTableViewController delegate methods
-(void) dismissSelector {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self updateTable];
}

-(void)cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private methods
-(void) updateTitle{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d"];
    NSString *todayString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: currentDate]];
    
    self.titleLabel.text = todayString;
}

-(void) updateTable {
    DataManager *dataManager = [DataManager sharedInstance];
    
    self.foodItems = nil;
    self.foodItems = [[NSMutableArray alloc] initWithArray:[dataManager getFoodsForDate: currentDate]];
    
    [self.tableView reloadData];
}

-(float) totalCalories {
    float totalCalories = 0;
    for (NSDictionary *food in foodItems) {
        totalCalories = totalCalories + [[food objectForKey: kCalories] floatValue] * [[food objectForKey: kServingSize] floatValue];
    }
    return totalCalories;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
    if ([segue.identifier isEqualToString:@"LogAddSegue"]) {
     
        CustomFoodsTableViewController *CustomFoodsTableViewController = segue.destinationViewController;
        DataManager *dataManager = [DataManager sharedInstance];
        NSArray *foods = [NSMutableArray arrayWithArray:[dataManager getMyFoods]];
        [CustomFoodsTableViewController  setFoods:foods andDate:self.currentDate];
        
        CustomFoodsTableViewController.delegate = self;
        
       
    } else
        */
        if ([segue.identifier isEqualToString:@"LogStatSegue"]) {
        DataManager *dataManager = [DataManager sharedInstance];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", [self.dateFormatter stringFromDate: currentDate]];
     
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dict = [dataManager getDictionaryForEntity: kLogItem withPredicate:predicate atIndex:indexPath.row];
        
        [self.tableView deselectRowAtIndexPath: indexPath animated:YES];
        NutritionViewController *NutritionViewController = segue.destinationViewController;
        [NutritionViewController setDictionary:dict Date:currentDate isLog: NO andIndex:indexPath.row];

    }
}

@end