//
//  CampusTableViewController.m
//  PSUFoodServices
//
//  Created by MTSS MTSS on 3/2/12.
//  Copyright (c) 2012 Penn State. All rights reserved.
//

#import "CampusTableViewController.h"
#import "Model.h"

@interface CampusTableViewController ()
@property (nonatomic,strong) Model *model;
@property NSInteger selectedRow;
@end

@implementation CampusTableViewController
@synthesize favoriteCampus;

@synthesize selectedRow;
@synthesize campusNames;


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [Model sharedInstance];
        self.campusNames = [self.model getCampusNames];
        self.favoriteCampus = [self.model myCampus];
    }
    return self;
}

//- (id)initWithCampuses:(NSMutableArray *)campuses
//{
//    self = [self initWithNibName:@"CampusTableViewController" bundle:nil];
//    if (self) {
//        campusNames = campuses;
//    }
//    
//    return self;
//}

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
    
    
    self.title = @"Choose Campus";
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.backBarButtonItem.title = @"";  // no back button!
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [campusNames count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CampusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    
    // Configure the cell...
    cell.textLabel.text = [[campusNames objectAtIndex:indexPath.row] capitalizedString];
    if (indexPath.row == self.favoriteCampus) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.favoriteCampus inSection:0];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    //self.favoriteCampus = indexPath.row;
     [self.model setMyCampus:indexPath.row];
    
    
    // we're done! pop the controller
    [self.navigationController popViewControllerAnimated:YES];
}


@end
