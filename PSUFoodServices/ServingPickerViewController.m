//
//  ServingPickerViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ServingPickerViewController.h"

@interface ServingPickerViewController()
@property (strong, nonatomic) NSDictionary *foodData;
@property (strong, nonatomic) NSString *servingSizeWhole;
@property (strong, nonatomic) NSString *servingSizePart;
@property (strong, nonatomic) NSMutableArray *wholeServings;
@property (strong, nonatomic) NSMutableArray *partServings;
@property (strong, nonatomic) NSString *servingString;

@property (strong, nonatomic) NSDate *foodDate;
@property (assign, nonatomic) NSInteger myIndex;

-(void) updateServingSize;

@end

@implementation ServingPickerViewController
@synthesize servingPickerView;
@synthesize servingsLabel;
@synthesize foodData;
@synthesize delegate;
@synthesize caloriesLabel;
@synthesize totCaloriesLabel;
@synthesize wholeServings;
@synthesize partServings;
@synthesize servingSizeWhole;
@synthesize servingSizePart;
@synthesize servingString;
@synthesize foodDate;
@synthesize myIndex;

- (IBAction)addButtonPressed:(id)sender {
    if([servingString floatValue] == 0.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!" message:@"Serving size cannot be 0. Select a different value and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: foodData];
        [dict setObject:servingString forKey: kServingSize];
    
        [self.delegate addFoodToLog:dict];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDictionary:(NSDictionary *)dict
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        wholeServings = [[NSMutableArray alloc] init];
        partServings = [[NSMutableArray alloc] init];
        
        foodData = dict;
        
        if([foodData objectForKey: kServingSize]) {
            NSArray *parts = [[foodData objectForKey: kServingSize] componentsSeparatedByString:@"."];
            servingSizeWhole = [[NSString alloc] initWithString: [parts objectAtIndex: 0]];
            servingSizePart = [[NSString alloc] initWithFormat: @".%@", [parts objectAtIndex: 1]];
        }
        else {
            servingSizeWhole = @"0";
            servingSizePart = @"0.0";
        }
        
        for(int i = 0; i <= 30; ++i) {
            [wholeServings addObject: [NSString stringWithFormat: @"%d", i]];
        }
        
        for(float i = 0.0; i < 1; i = i + .1) {
            [partServings addObject: [NSString stringWithFormat: @"% .1f", i]];
        }
        
        self.title = [foodData objectForKey: kName];
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
    // Changed the buttons.  JJH 7/12/12
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonPressed:)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    
    self.caloriesLabel.text = [NSString stringWithFormat:@"Calories Per Serving: %@", [foodData objectForKey: kCalories]];
    
    [self.servingPickerView setDelegate: self];
    [self.servingPickerView setDataSource:self];
    
    [servingPickerView reloadAllComponents];
    
    [servingPickerView selectRow:[servingSizeWhole intValue] inComponent:0 animated:YES];
    [servingPickerView selectRow: [[servingSizePart stringByReplacingOccurrencesOfString:@"." withString:@""] intValue] inComponent:1 animated:YES];
    
    [self updateServingSize];
}

- (void)viewDidUnload
{
    [self setServingPickerView:nil];
    [self setServingsLabel:nil];
    [self setCaloriesLabel:nil];
    [self setTotCaloriesLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Picker View Delegate methods
-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    
    if (component == 0) {
        title = [wholeServings objectAtIndex: row];
    }
    else {
        title = [partServings objectAtIndex: row];
    }
    
    return title;
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self updateServingSize];
}
                                                   
#pragma mark - Picker View Data Source methods
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    int row;
    if (component == 0) {
        row = [wholeServings count];
    }
    else {
        row = [partServings count];
    }
    return row;
}

#pragma mark - Private Methods
-(void) cancelButtonPressed {
    [self.delegate cancelButtonPressed];
}

-(void) updateServingSize {
    self.servingSizeWhole = [NSString stringWithFormat:@"%d",[servingPickerView selectedRowInComponent: 0]];
    self.servingSizePart = [NSString stringWithFormat:@".%d", [servingPickerView selectedRowInComponent:1]];
    
    self.servingString = nil;
    self.servingString = [[NSString alloc] initWithFormat:@"%.1f", [servingSizeWhole floatValue] + [servingSizePart floatValue]];
    
    servingsLabel.text = [NSString stringWithFormat: @"Serving Size: %@", servingString];
    
    totCaloriesLabel.text = [NSString stringWithFormat:@"Total Calories: %.1f", ([servingSizePart floatValue] + [servingSizeWhole floatValue]) * [[foodData objectForKey: kCalories] floatValue]];
}
@end
