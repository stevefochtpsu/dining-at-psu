//
//  DateModalViewController.m
//  PSUFoodServices
//
//  Created by MTSS MTSS on 12/14/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import "DateModalViewController.h"

@interface DateModalViewController ()
@property (nonatomic,strong) NSDate *initialDate;
@end

@implementation DateModalViewController
@synthesize initialDate;

@synthesize delegate;
@synthesize datePicker;

- (id)initWithDate:(NSDate *)aDate
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.initialDate = aDate;
    }
    return self;
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate dismissModalWithDate:[datePicker date]];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate dismissModal];
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
   
    [datePicker setDate:self.initialDate];
}

- (void)viewDidUnload
{
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
