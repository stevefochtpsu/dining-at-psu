//
//  DailyLogSummaryTableViewController.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/12/13.
//
//

#import "DailyLogSummaryTableViewController.h"
#import "Model.h"
#import "LogTableViewController.h"
#import "ECSNavigationController.h"

@interface DailyLogSummaryTableViewController ()
@property (nonatomic,strong) Model *model;
@property (nonatomic,strong) NSMutableArray *logDates;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@end

@implementation DailyLogSummaryTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [Model sharedInstance];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat: kDateFormat];
        self.title = @"Daily Logs";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.logDates = [[self.model allDatesForLogs] mutableCopy];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.rightBarButtonItem.enabled = [self.logDates count] > 0; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.logDates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogSummaryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDate *date = [self.logDates objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.dateFormatter stringFromDate:date];
    
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
        NSDate *date = [self.logDates objectAtIndex:indexPath.row];
        [self.model removeFoodsForDate:date];
        self.logDates = [[self.model allDatesForLogs] mutableCopy];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    //self.navigationItem.rightBarButtonItem.enabled = [self.logDates count] > 0;
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

#pragma mark - Editing
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (self.editing) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    self.navigationItem.rightBarButtonItem.enabled = [self.logDates count] > 0;
}

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   }
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DailyLogSegue"]) {
        LogTableViewController *logTableViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      
        NSDate *date = [self.logDates objectAtIndex:indexPath.row];
        logTableViewController.currentDate = date;
    }
}


@end
