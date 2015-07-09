//
//  NewFoodViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewFoodViewController.h"

static CGFloat const kExtraScrollRoom = 200.0;

@interface NewFoodViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *caloriesTextField;
@property (weak, nonatomic) IBOutlet UITextField *totalFatTextField;
@property (weak, nonatomic) IBOutlet UITextField *satFatTextField;
@property (weak, nonatomic) IBOutlet UITextField *transFatTextField;
@property (weak, nonatomic) IBOutlet UITextField *cholesterolTextField;
@property (weak, nonatomic) IBOutlet UITextField *sodiumTextField;
@property (weak, nonatomic) IBOutlet UITextField *carbTextField;
@property (weak, nonatomic) IBOutlet UITextField *fiberTextField;
@property (weak, nonatomic) IBOutlet UITextField *sugarsTextField;
@property (weak, nonatomic) IBOutlet UITextField *proteinTextField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarTitle;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButon;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong,nonatomic) NSArray *allTextFields;
@property (strong,nonatomic) NSArray *allKeys;

//- (IBAction)dismissKeyboard:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;


@property (strong, nonatomic) NSDictionary *foodData;
@property (assign, nonatomic) NSInteger foodIndex;

@end

@implementation NewFoodViewController
@synthesize delegate;
@synthesize scrollView;
@synthesize nameTextField;
@synthesize caloriesTextField;
@synthesize totalFatTextField;
@synthesize satFatTextField;
@synthesize transFatTextField;
@synthesize cholesterolTextField;
@synthesize sodiumTextField;
@synthesize carbTextField;
@synthesize fiberTextField;
@synthesize sugarsTextField;
@synthesize proteinTextField;
@synthesize navBarTitle;
@synthesize cancelButon;
@synthesize doneButton;
@synthesize navigationBar;
@synthesize isNew;
@synthesize foodData;
@synthesize foodIndex;



-(void)setDictionary:(NSDictionary *)dictionary andIndex:(NSInteger)index {
    self.foodData = [[NSDictionary alloc] initWithDictionary: dictionary];
    self.foodIndex = index;
}




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // [navigationBar setTintColor:[UIColor colorWithRed:0.270588 green:0.521569 blue:0.141176 alpha:1.0]];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + kExtraScrollRoom);
    
    // keep these two arrays in sync!
    _allTextFields = @[nameTextField,caloriesTextField,totalFatTextField,satFatTextField,transFatTextField,cholesterolTextField,sodiumTextField,carbTextField,fiberTextField,sugarsTextField,proteinTextField];
    _allKeys = @[kName,kCalories,kTotalFat,kSatFat,kTransFat,kCholesterol,kSodium,kTotalCarb,kDietaryFiber,kSugars,kProtein];

    
    if (!isNew) {
        doneButton.title = @"Save";
        
        navBarTitle.title = [foodData objectForKey: kName];
        
        for (int i=0; i<self.allTextFields.count; i++) {
            UITextField *textField = [self.allTextFields objectAtIndex:i];
            NSString *key = [self.allKeys objectAtIndex:i];
            textField.text = [foodData objectForKey:key];
        }
        /*
        nameTextField.Text = [foodData objectForKey: kName];
        caloriesTextField.text = [foodData objectForKey: kCalories];
        totalFatTextField.text = [foodData objectForKey: kTotalFat];
        satFatTextField.text = [foodData objectForKey: kSatFat];
        transFatTextField.text = [foodData objectForKey: kTransFat];
        cholesterolTextField.text = [foodData objectForKey: kCholesterol];
        sodiumTextField.text = [foodData objectForKey: kSodium];
        carbTextField.text = [foodData objectForKey: kTotalCarb];
        fiberTextField.text = [foodData objectForKey: kDietaryFiber];
        sugarsTextField.text = [foodData objectForKey: kSugars];
        proteinTextField.text = [foodData objectForKey: kProtein];
         */
    }
     
    
  
}

- (void)viewDidUnload
{
    [self setCancelButon:nil];
    [self setDoneButton:nil];
    [self setScrollView:nil];
    [self setNameTextField:nil];
    [self setCaloriesTextField:nil];
    [self setTotalFatTextField:nil];
    [self setSatFatTextField:nil];
    [self setTransFatTextField:nil];
    [self setCholesterolTextField:nil];
    [self setSodiumTextField:nil];
    [self setCarbTextField:nil];
    [self setFiberTextField:nil];
    [self setSugarsTextField:nil];
    [self setProteinTextField:nil];
    [self setNavBarTitle:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TextField Delegate methods
-(void) textFieldDidBeginEditing:(UITextField *)textField {
    [scrollView scrollRectToVisible: CGRectMake(0, textField.frame.origin.y - (self.view.frame.size.height / 4.0), self.view.frame.size.width, self.view.frame.size.height) animated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Private methods
- (IBAction)cancelButtonPressed:(id)sender {
    [delegate dismissNewFoodView];
}

- (IBAction)doneButtonPressed:(id)sender {
    NSString *name = [nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *calories = [caloriesTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (name.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!" message: @"Food name is required. Enter a food name and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    else if(calories.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh!" message: @"Calorie value is required. Enter a calorie value and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    else {
        // make dictionary of non-blank items
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int i=0; i<self.allTextFields.count; i++) {
            UITextField *textField = [self.allTextFields objectAtIndex:i];
            NSString *key = [self.allKeys objectAtIndex:i];
            if (textField.text) {
                [dict setObject:textField.text forKey:key];
            }
        }

        
//        [[NSDictionary alloc] initWithObjectsAndKeys: nameTextField.text, kName, caloriesTextField.text, kCalories, totalFatTextField.text, kTotalFat, satFatTextField.text, kSatFat, transFatTextField.text, kTransFat, cholesterolTextField.text, kCholesterol, sodiumTextField.text, kSodium, carbTextField.text, kTotalCarb, fiberTextField.text, kDietaryFiber, sugarsTextField.text, kSugars, proteinTextField.text, kProtein, nil];
        
        if (isNew) {
            [delegate addNewFood: dict];
        }
        else {
            //NSLog(@"%d", foodIndex);
            [delegate editFood: dict atIndex: foodIndex];
        }
    }
}




@end
