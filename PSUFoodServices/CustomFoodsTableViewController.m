//
//  CustomFoodsTableViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomFoodsTableViewController.h"
#import "DataManager.h"
#import "ECSNavigationController.h"
#import "LogSelectorCell.h"
#import "NutritionViewController.h"

@interface CustomFoodsTableViewController()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)servingStepperChanged:(id)sender;

@property (strong, nonatomic) NSMutableArray *foods;
@property (strong, nonatomic) NSMutableArray *foods4Meals;

//@property (assign, nonatomic) BOOL isMyFoods;

@property (strong, nonatomic) NSString *locString;

@property (strong, nonatomic) NSMutableDictionary *servingsDictionary;
@property (strong, nonatomic) NSMutableArray *servings4Meals;

@property (strong, nonatomic) NSArray *buttonsArray;

@property (nonatomic) NSInteger countOfItemsBeingAdded;
@property (nonatomic,strong) UIBarButtonItem *enterButton;
@property (nonatomic,strong) UIBarButtonItem *cancelButton;
@property (nonatomic,strong) UIBarButtonItem *addFoodButton;

//-(void) downloadCompleted: (NSNotification *) notification;
-(NSInteger)servingsForIndexPath:(NSIndexPath*)indexPath;
-(void)setServings:(NSInteger)size forIndexPath:(NSIndexPath*)indexPath;
-(void)enterServingsInfo;
-(void)resetServings;
@end

@implementation CustomFoodsTableViewController
@synthesize delegate;
@synthesize foods, foods4Meals;
@synthesize tableView;
//@synthesize isMyFoods;

@synthesize locString;
@synthesize servingsDictionary, servings4Meals;





#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.isMyFoods = YES;
    self.servingsDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    
    // set up tool bar
    _addFoodButton = [[UIBarButtonItem alloc] initWithTitle:@"New Food" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonPressed)];
    _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelServingsInfo:)];
    _enterButton = [[UIBarButtonItem alloc] initWithTitle:@"Enter" style:UIBarButtonItemStyleBordered target:self action:@selector(doneServingsInfo:)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[_cancelButton,flexSpace,_addFoodButton,flexSpace,_enterButton];
     self.navigationController.toolbarHidden = NO;
    [self enableEnteringButtons:NO];
    

    
    self.buttonsArray = @[self.editButtonItem];
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;

    DataManager *dataManager = [DataManager sharedInstance];
    
    self.foods = [NSMutableArray arrayWithArray:[dataManager getMyFoods]];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.foods removeAllObjects];
    DataManager *dataManager = [DataManager sharedInstance];
    [self.foods addObjectsFromArray:[dataManager getMyFoods]];
    [self.tableView reloadData];
    
    //self.editButtonItem.enabled = [self.foods count] > 0;  // only editable if we have foods to edit
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self enableEnteringButtons:NO];  // we can't be entering when view first appears
    self.editButtonItem.enabled = [self.foods count] > 0; // only editable if we have foods to edit
    
    self.navigationItem.title = @"Custom Foods";
    self.navigationItem.rightBarButtonItems = self.buttonsArray;

}

-(void)enableEnteringButtons:(BOOL)entering {
    self.enterButton.enabled = entering;
    self.cancelButton.enabled = entering;
    self.addFoodButton.enabled = !entering;
    self.editButtonItem.enabled = [self.foods count] > 0 && !entering;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
        return 1;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    
        return [foods count];

}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogSelectorCell";
    
    LogSelectorCell *cell = [atableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    NSDictionary *menuItem = [foods objectAtIndex:indexPath.row];
    [cell.textLabel setText:[menuItem objectForKey: kName]];
    NSString *calories = [menuItem objectForKey: kCalories];
    [cell.caloriesLabel setText:[NSString stringWithFormat:@"Calories: %@", calories]];
 
    // initialize the label and the stepper's value
    [cell.servingsLabel setText:[NSString stringWithFormat:@"%d", [self servingsForIndexPath:indexPath]]];
    cell.stepper.value = [self servingsForIndexPath:indexPath];
    

    
    return cell;
}



#pragma mark - Table view delegate


- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
     self.editButtonItem.enabled = [self.foods count] > 0; // reset editing button as needed
}

- (void)tableView:(UITableView *)atableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DataManager *dataManager = [DataManager sharedInstance];
        
        [self.foods removeObjectAtIndex: [indexPath row]];
        
        [dataManager deleteMyFoodAtIndex: indexPath.row];
        
        
        [atableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [atableView reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Serving Picker delegate
-(void) dismissServingPickerViewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) addFoodToLog:(NSDictionary *)foodLog {    
    DataManager *dataManager = [DataManager sharedInstance];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: kDateFormat];
    
    NSString *dateString = [dateFormatter stringFromDate: [NSDate date]];  // date is always current day!
    
    
    NSMutableDictionary *foodDict = [NSMutableDictionary dictionaryWithDictionary: foodLog];
    [foodDict setObject:dateString forKey:kDate];
    
    [dataManager addToLog: foodDict];
    
    // change this. instead of popping nav controller, just go back.  JJH 7/7/12  changed it back 7/13/12
    //[self.delegate cancelButtonPressed];
    //[self.navigationController popViewControllerAnimated:YES];
}

-(void) cancelButtonPressed {
    [self.delegate cancelButtonPressed];
}


#pragma mark - NewFoodViewController delegate

-(void) dismissNewFoodView
{
    DataManager *dataManager = [DataManager sharedInstance];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];}];
    
    [self.foods removeAllObjects];
    [self.foods addObjectsFromArray:[dataManager getMyFoods]];
//    self.foods = [[NSMutableArray alloc] initWithArray: [dataManager getMyFoods]];
    
    [self.tableView reloadData];
}


-(void) addNewFood:(NSDictionary *)foodData
{
    DataManager *dataManager = [DataManager sharedInstance];
    
    [dataManager addFood: foodData];
    [self resetServings]; // because this may have moved some of the existing items
    
    [self dismissNewFoodView];
}

#pragma mark - Actions & Segues

-(void) addButtonPressed {
    
    [self performSegueWithIdentifier:@"NewFoodSegue" sender:self];
    return;
    
//    NewFoodViewController *myModalViewController = [[NewFoodViewController alloc] initWithNibName:@"NewFoodViewController" bundle:[NSBundle mainBundle]];
//    
//    myModalViewController.delegate = self;
//    [myModalViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//    
//    [self presentModalViewController:myModalViewController animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewFoodSegue"]) {
        NewFoodViewController *newFoodViewController = segue.destinationViewController;
        newFoodViewController.delegate = self;
        newFoodViewController.isNew = YES;
    } else if ([segue.identifier isEqualToString:@"LogStatDetailSegue"]) {
        NutritionViewController *NutritionViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
       [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //NSDictionary *foodItemDictionary = [[[foods objectAtIndex:indexPath.section] objectForKey: @"Menu Items"] objectAtIndex:indexPath.row];
        NSDictionary *menuItem = [foods objectAtIndex:indexPath.row];
        [NutritionViewController setDictionary:menuItem Date:[NSDate date] isLog:YES andIndex:indexPath.row];
    }


}


#pragma mark - Servings Information
-(NSInteger)servingsForIndexPath:(NSIndexPath*)indexPath {
    NSNumber *size = [servingsDictionary objectForKey:indexPath];
    if (size) {
        return [size intValue];
    } else {
        return 0;
    }
}


-(void)resetServings {
    NSNumber *zero = [NSNumber numberWithInt:0];
   // [self.servingsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
    for (NSString *key in self.servingsDictionary.allKeys) {
        [self.servingsDictionary setObject:zero forKey:key];
    }
    [self enableEnteringButtons:NO];

    self.countOfItemsBeingAdded = 0;
}

-(void)setServings:(NSInteger)size forIndexPath:(NSIndexPath*)indexPath {
    NSNumber *currentNumber = [self.servingsDictionary objectForKey:indexPath];
    NSInteger currentSize = [currentNumber integerValue];
    if (currentSize==0 && size > 0) {
        self.countOfItemsBeingAdded++;
    } else if (currentSize > 0 && size == 0) {
        self.countOfItemsBeingAdded--;
    }
    [self enableEnteringButtons:(self.countOfItemsBeingAdded>0)];

    
    [self.servingsDictionary setObject:[NSNumber numberWithInt:size] forKey:indexPath];
}

-(UITableViewCell*)cellContainingView:(UIView*)view {
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    return (UITableViewCell*)view;
}

- (IBAction)servingStepperChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    NSInteger value = stepper.value;
    LogSelectorCell* cell =  (LogSelectorCell*)[self cellContainingView:stepper];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self setServings:value forIndexPath:indexPath];

}

// Add all the non-zero servings selections into the database
-(void)enterServingsInfo {
    //NSArray *keys = [servingsDictionary allKeys];
     DataManager *dataManager = [DataManager sharedInstance];
    NSDictionary *foodItemDictionary;
    
    for (NSIndexPath *indexPath in self.servingsDictionary) {
        NSNumber *num = [self.servingsDictionary objectForKey:indexPath];
        NSInteger servingSize = [num intValue];
        NSString *servingString = [NSString stringWithFormat:@"%d", servingSize];
        if (servingSize>0) {
            foodItemDictionary =  [dataManager getDictionaryForEntity:kMyFood withPredicate:nil atIndex:indexPath.row];
            
//            if (isMyFoods) {
//                foodItemDictionary =  [dataManager getDictionaryForEntity:kMyFood withPredicate:nil atIndex:indexPath.row];
//            }
//            else {
//                foodItemDictionary = [[[foods objectAtIndex:indexPath.section] objectForKey: @"Menu Items"] objectAtIndex:indexPath.row];
//            }
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: foodItemDictionary];
            [dict setObject:servingString forKey: kServingSize];
            [dict setObject:[NSDate date] forKey: kDate];  // date is always current day
            
            [self addFoodToLog:dict];
        }
    }
    
}

-(IBAction)doneServingsInfo:(id)sender {
   
    [self enterServingsInfo];
    //[self.delegate dismissSelector];
    //[self.navigationController popViewControllerAnimated:YES];
  
    [self.tableView reloadData];
    NSString *items = (self.countOfItemsBeingAdded>1) ? @"items" : @"item";
    NSString *message = [NSString stringWithFormat:@"%d %@ entered into today's log", self.countOfItemsBeingAdded, items];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Entered" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    
      [self resetServings];
}

-(void)cancelServingsInfo:(id)sender {
    [self resetServings];
    [self.tableView reloadData];
}

@end
