//
//  LocationSelectorTableViewController.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationSelectorTableViewController.h"
#import "FoodModel.h"

@interface LocationSelectorTableViewController()

@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSDate *myDate;

@end

@implementation LocationSelectorTableViewController
@synthesize locations;
@synthesize myTableView;
@synthesize delegate;
@synthesize myDate;

//static NSString *AppDataDownloadCompleted = @"AppDataDownloadCompleted";

- (id)initWithStyle:(UITableViewStyle)style Date: (NSDate *) date andItems: (NSArray *) items
{
    self = [super initWithStyle:style];
    if (self) {
        myTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style: style];
        
        locations = items;
        //NSLog(@"Init Method: %d Locations", [locations count]);
        
        myTableView.delegate = self;
        myTableView.dataSource = self;
        
        myDate = date;
        
        self.view = myTableView;
        
        self.title = @"Select Location";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: kDateFormat];
        
        //NSLog(@"Location: %@", [dateFormatter stringFromDate: myDate]);
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.myTableView reloadData];
    
    // No need for cancel button here.  JJH 7/12/12
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(rightBarButtonPressed)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return [locations count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[locations objectAtIndex: section] objectForKey: @"eateries"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [cell.textLabel setText: [[[[locations objectAtIndex: indexPath.section] objectForKey: @"eateries"] objectAtIndex:indexPath.row] objectForKey: @"locationName"]];
    [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[locations objectAtIndex: section] objectForKey: @"header"];     
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    //LogSelectorTableViewController *logSelectorTableViewController = [[LogSelectorTableViewController alloc] initWithDate: myDate andLocation:[[[[locations objectAtIndex: indexPath.section] objectForKey: @"eateries"] objectAtIndex: indexPath.row] objectForKey: @"locationCode"]];
    
    //Using storyboards for custom tableview cells - JJH 7/13/12
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    LogSelectorTableViewController *logSelectorTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"StandardLogSelector"];
    
    NSString *location = [[[[locations objectAtIndex: indexPath.section] objectForKey: @"eateries"] objectAtIndex: indexPath.row] objectForKey: @"locationCode"];
    
    [logSelectorTableViewController setDate:self.myDate andLocation:location];
    logSelectorTableViewController.delegate = self;
    
    [self.navigationController pushViewController: logSelectorTableViewController animated:YES];
}

#pragma mark - LogSelectorTableViewController delegate
-(void) cancelButtonPressed {
    [self.delegate cancelButtonPressed];
}

#pragma mark - Private methods
-(void) rightBarButtonPressed {
    [self.delegate cancelButtonPressed];
}
@end
