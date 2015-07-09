//
//  NutritionViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NutritionViewController.h"
#import "DataManager.h"

#define kTotFatDV 65
#define kSatFatDV 20
#define kCholesterolDV 300
#define kSodiumDV 2400
#define kCarbDV 300
#define kFiberDV 25

@interface NutritionViewController()

@property (weak, nonatomic) IBOutlet UILabel *servingLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totFatLabel;
@property (weak, nonatomic) IBOutlet UILabel *satFatLabel;
@property (weak, nonatomic) IBOutlet UILabel *transFatLabel;
@property (weak, nonatomic) IBOutlet UILabel *cholesterolLabel;
@property (weak, nonatomic) IBOutlet UILabel *sodiumLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sugarLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinLabel;
@property (weak, nonatomic) IBOutlet UILabel *totFatDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *satFatDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *cholesterolDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *sodiumDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *totCarbDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *fiberDVLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSDictionary *foodItem;
@property (strong, nonatomic) NSDate *myDate;
@property (assign, nonatomic) NSInteger myIndex;
@property (assign, nonatomic) BOOL isFoodLog;
@property (assign, nonatomic) float serving;

-(NSString *) totalFatDV;
-(NSString *) satFatDV;
-(NSString *) cholesterolDV;
-(NSString *) sodiumDV;
-(NSString *) carbDV;
-(NSString *) fiberDV;

-(void) updateLabels;
//-(void) editButtonPressed;

@end
@implementation NutritionViewController
@synthesize servingLabel;
@synthesize caloriesLabel;
@synthesize totFatLabel;
@synthesize satFatLabel;
@synthesize transFatLabel;
@synthesize cholesterolLabel;
@synthesize sodiumLabel;
@synthesize carbLabel;
@synthesize fiberLabel;
@synthesize sugarLabel;
@synthesize proteinLabel;
@synthesize totFatDVLabel;
@synthesize satFatDVLabel;
@synthesize cholesterolDVLabel;
@synthesize sodiumDVLabel;
@synthesize totCarbDVLabel;
@synthesize fiberDVLabel;
@synthesize nameLabel;
@synthesize foodItem, myDate, myIndex, isFoodLog, serving;

/*
-(id) initWithDictionary:(NSDictionary *)dict Date:(NSDate *)date isLog: (BOOL) isLog andIndex:(NSInteger)index
{
    self = [super initWithNibName:@"NutritionViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        [self setDictionary:dict Date:date isLog:isLog andIndex:index];
            }
    return self;
}
 */

-(void) setDictionary:(NSDictionary *) dict Date:(NSDate *) date isLog: (BOOL) isLog andIndex: (NSInteger) index {
    foodItem = dict;
    myDate = date;
    myIndex = index;
    isFoodLog = isLog;
    _editable = isLog;
    
    self.title = @"Nutrition";
    
    if([foodItem objectForKey: kServingSize] != nil) {
        serving = [[foodItem objectForKey: kServingSize] floatValue];
        //NSLog(@"Serving Size: %@", [foodItem objectForKey: kServingSize]);
    }
    else {
        serving = 1.0;
    }

}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateLabels];
    
    if (!self.isEditable) {
         self.navigationItem.rightBarButtonItem = nil;  // edit button
    }
   
    
    // deleted this functionality -jjh 7/15/12  // restored it 10/25/13 in storyboard
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
}

- (void)viewDidUnload
{
    [self setServingLabel:nil];
    [self setCaloriesLabel:nil];
    [self setTotFatLabel:nil];
    [self setSatFatLabel:nil];
    [self setTransFatLabel:nil];
    [self setCholesterolLabel:nil];
    [self setSodiumLabel:nil];
    [self setCarbLabel:nil];
    [self setFiberLabel:nil];
    [self setSugarLabel:nil];
    [self setProteinLabel:nil];
    [self setTotFatDVLabel:nil];
    [self setSatFatDVLabel:nil];
    [self setCholesterolDVLabel:nil];
    [self setSodiumDVLabel:nil];
    [self setTotCarbDVLabel:nil];
    [self setFiberDVLabel:nil];
    [self setNameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - New Food View Controller Delegate
-(void) dismissNewFoodView
{
    DataManager *dataManager = [DataManager sharedInstance];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    self.foodItem = [dataManager getDictionaryForEntity:kMyFood withPredicate:nil atIndex:myIndex];
    
    [self updateLabels];
}

-(void) editFood:(NSDictionary *)dict atIndex:(NSInteger)index {
    DataManager *dataManager = [DataManager sharedInstance];
    
    [dataManager editFood:dict atIndex:index];
    
    [self dismissNewFoodView];
}

#pragma mark - Serving Picker View Controller Delegate
-(void) addFoodToLog:(NSDictionary *)foodLog {
    DataManager *dataManager = [DataManager sharedInstance];
    
    [dataManager updateLogFood:foodLog forDate:myDate atIndex:myIndex];
    
    [self dismissViewControllerAnimated: YES completion:NULL];
    
    self.foodItem = foodLog;
    
    self.serving = [[foodItem objectForKey: kServingSize] floatValue];
    
    [self updateLabels];
}

-(void) cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma  mark - Private methods
-(void) updateLabels {
    nameLabel.text = [foodItem objectForKey: kName];
    
    servingLabel.text = [NSString stringWithFormat:@"%.1f servings", serving];
    
    NSArray *labelsArray = [[NSArray alloc] initWithObjects:caloriesLabel, totFatLabel, satFatLabel, transFatLabel, cholesterolLabel, sodiumLabel, carbLabel, fiberLabel, sugarLabel, proteinLabel, nil];
    NSArray *keysArray = [[NSArray alloc] initWithObjects:kCalories, kTotalFat, kSatFat, kTransFat, kCholesterol, kSodium, kTotalCarb, kDietaryFiber, kSugars, kProtein, nil];
    
    for(UILabel *myLabel in labelsArray) {
        if([foodItem objectForKey: [keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]]] != nil) {
            if([[keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]] isEqualToString: kCholesterol] || [[keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]] isEqualToString: kSodium]) {
                myLabel.text = [NSString stringWithFormat: @"%.1f mg", serving * [[foodItem objectForKey: [keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]]] floatValue]];
            }
            else if([[keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]] isEqualToString: kCalories]) {
                myLabel.text = [NSString stringWithFormat: @"%.1f", serving * [[foodItem objectForKey: [keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]]] floatValue]];
            }
            else {
                myLabel.text = [NSString stringWithFormat: @"%.1f g", serving * [[foodItem objectForKey: [keysArray objectAtIndex: [labelsArray indexOfObject: myLabel]]] floatValue]];
            }
        }
        else {
            myLabel.text = @"N/A";
        }
    }
    
    totFatDVLabel.text = [self totalFatDV];
    satFatDVLabel.text = [self satFatDV];
    cholesterolDVLabel.text = [self cholesterolDV];
    sodiumDVLabel.text = [self sodiumDV];
    totCarbDVLabel.text = [self carbDV];
    fiberDVLabel.text = [self fiberDV];
}

-(NSString *) totalFatDV {
    if([self.foodItem objectForKey: kTotalFat]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kTotalFat] floatValue] / kTotFatDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

-(NSString *) satFatDV {
    if([self.foodItem objectForKey: kSatFat]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kSatFat] floatValue] / kSatFatDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

-(NSString *) cholesterolDV {
    if([self.foodItem objectForKey: kCholesterol]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kCholesterol] floatValue] / kCholesterolDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

-(NSString *) sodiumDV {
    if([self.foodItem objectForKey: kSodium]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kSodium] floatValue] / kSodiumDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

-(NSString *) carbDV {
    if([self.foodItem objectForKey: kTotalCarb]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kTotalCarb] floatValue] / kCarbDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

-(NSString *) fiberDV {
    if([self.foodItem objectForKey: kDietaryFiber]) {
        return [NSString stringWithFormat: @"%.1f%%", [[self.foodItem objectForKey: kDietaryFiber] floatValue] / kFiberDV * 100 * serving];
    }
    else {
        return @"N/A";
    }
}

/*
-(void) editButtonPressed {
    if(isFoodLog) {
        ServingPickerViewController *servingPickerViewController = [[ServingPickerViewController alloc] initWithNibName:@"ServingPickerViewController" bundle:[NSBundle mainBundle] andDictionary:foodItem];
        servingPickerViewController.delegate = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:servingPickerViewController];
        
        [servingPickerViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
        
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
    else {
        DataManager *dataManager = [DataManager sharedInstance];
        
        NSDictionary *myDict = [dataManager getDictionaryForEntity:kMyFood withPredicate:nil atIndex:myIndex];
        
        NewFoodViewController *newFoodViewController = [[NewFoodViewController alloc] initWithDictionary:myDict andIndex:myIndex];
        newFoodViewController.delegate = self;
        
        [newFoodViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:newFoodViewController animated:YES completion:NULL];
    }
}
 */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditFoodSegue"]) {
        //DataManager *dataManager = [DataManager sharedInstance];
        //NSDictionary *myDict = [dataManager getDictionaryForEntity:kMyFood withPredicate:nil atIndex:myIndex];
        
        NewFoodViewController *newFoodViewController = segue.destinationViewController;
        [newFoodViewController setDictionary:self.foodItem andIndex:myIndex];
        newFoodViewController.delegate = self;
        newFoodViewController.isNew = NO;

    }
}
@end
