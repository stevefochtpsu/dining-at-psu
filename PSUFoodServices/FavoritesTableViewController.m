//
//  FavoritesTableViewController.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/10/13.
//
//

#import "FavoritesTableViewController.h"
#import "FavoritesCell.h"
#import "ActivityCell.h"
#import "ECSNavigationController.h"
#import "Model.h"

#define kNumberOfDays 5

NSString * const allDataDownloaded = @"allDataDownloaded";

@interface FavoritesTableViewController ()
@property (nonatomic,strong) Model *sharedModel;

@property (nonatomic,strong) NSMutableArray *menuDates;
@property (nonatomic,strong) NSMutableArray *menuMenus;
@property (nonatomic,strong) NSMutableArray *menuFavorites;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSArray *locationNames;
@property (nonatomic,strong) NSArray *locationCodes;
@property (readonly) NSInteger numberOfDaysDownloaded;
@property BOOL favoritesReady;
- (IBAction)refreshTable:(id)sender;

@end

@implementation FavoritesTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.sharedModel = [Model sharedInstance];

//        _menuDates = [NSMutableArray arrayWithCapacity:kNumberOfDays];
//        _menuMenus = [NSMutableArray arrayWithCapacity:kNumberOfDays];
//        _menuFavorites = [NSMutableArray array];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kDateFormat];
    }
    return self;
}

-(NSInteger)favoriteCampus {
    return [self.sharedModel myCampus];
}

-(NSMutableArray*)favoriteEateries {
    return [self.sharedModel myEateries];
}

-(NSInteger)numberOfDaysDownloaded {
   return [self.menuMenus count];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(displayFavorites:)
                                                     name:favoritesReady
                                                   object:nil];
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    self.title = @"Favorites";
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sharedModel prepareDatesAndMenus];  // refresh upon appearance as things might have changed (dates/favorites)
   }


#pragma mark - Notification Handlers

-(void)displayFavorites:(NSNotification*)notification {
    [self.refreshControl endRefreshing];
    
    NSDictionary *userInfo = [notification userInfo];
    self.locationCodes = [userInfo objectForKey:@"locationCodes"];
    self.locationNames = [userInfo objectForKey:@"locationNames"];
    self.menuFavorites = [userInfo objectForKey:@"menuFavorites"];
    self.menuDates = [userInfo objectForKey:@"menuDates"];

    self.favoritesReady = YES;
    [self.tableView reloadData];
}


#pragma mark - Table view data source

-(BOOL)emptySection:(NSInteger)section {
    return [[self.menuFavorites objectAtIndex:section] count] == 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfDays;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *date = [self.dateFormatter stringFromDate:[self.menuDates objectAtIndex:section]];
    return date;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.favoritesReady) {
        if ([self emptySection:section]) {
            return 1;   // 1 cell stating no favorites on this day
        } else {
        return [[self.menuFavorites objectAtIndex:section] count];
        }
    } else {
        return 1; // stating that we're updating the menu
    }

    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoritesCell";
    static NSString *ActivityCellIdentifier = @"ActivityCell";
    if (!self.favoritesReady) {
         ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:ActivityCellIdentifier forIndexPath:indexPath];
        [cell.activityView startAnimating];
        return cell;
        
    } else {
        FavoritesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if ([self emptySection:indexPath.section]) {
            cell.name.text = @"No Favorites on Menus";
            cell.area.text = @"";
            cell.location.text = @"";
        } else {
            NSArray *favoritesForSection = [self.menuFavorites objectAtIndex:indexPath.section];
            NSDictionary *menuItem = [favoritesForSection objectAtIndex:indexPath.row];
            NSString *itemName = [menuItem objectForKey:@"name"];
            NSString *itemArea = [menuItem objectForKey:@"area"];
            
            NSNumber *locationCode = [menuItem objectForKey:@"locationCode"];
            NSInteger index = [self.locationCodes indexOfObject:locationCode];
            NSString *location = [self.locationNames objectAtIndex:index];
            
            cell.name.text = itemName;
            cell.location.text = location;
            cell.area.text = itemArea;
        }
            return cell;
    }

}


#pragma mark - Table view delegate
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


#pragma mark - Refresh Action

- (IBAction)refreshTable:(id)sender {
    [self.sharedModel prepareDatesAndMenus]; 
}
@end
