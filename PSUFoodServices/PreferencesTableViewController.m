//
//  PreferencesTableViewController.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/6/13.
//
//

#import "PreferencesTableViewController.h"
#import "Model.h"
#import "ECSNavigationController.h"

#define kNoCampus -1
#define kNoFavoritesCellHeight 125.0

static NSString *CampusCellIdentifier = @"CampusCell";
static NSString *EateriesCellIdentifier = @"EateriesCell";
static NSString *FoodCellIdentifier = @"FoodCell";
static NSString *NoFavoritesCellIdentifier = @"NoFavoritesCell";

enum preferenceSections {
    sectionCampus = 0,
    sectionEateries,
    sectionFavorites
};


@interface PreferencesTableViewController ()
@property (nonatomic,strong) Model *model;
@property (readonly) NSInteger favoriteCampus;
@property (readonly) NSInteger eateryCount;
@property (nonatomic,strong) NSMutableArray *favoriteEateries;
@property (nonatomic,strong) NSMutableArray *favoriteFoods;
@property (nonatomic,strong) UISwitch *alertSwitch;
@end

@implementation PreferencesTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [Model sharedInstance];
        //_favoriteCampus = kNoCampus;
           }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
     _alertSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    self.alertSwitch.on = YES;
  
}

-(NSInteger)favoriteCampus {
    return [self.model myCampus];
}

-(NSMutableArray*)favoriteEateries {
    return [self.model myEateries];
}

-(NSInteger)eateryCount {
    return [self.model getLocationCount:self.favoriteCampus];
}

-(NSMutableArray*)favoriteFoods {
    return [self.model myFoods];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.favoriteEateries count] == 0) {  //initial value of preferences
        [self selectAllEateries];
    }
    
    self.editButtonItem.enabled = ([self.favoriteFoods count] > 0);
    
    [self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated {
   
}

// Each Child in container must set its barbutton items on the container (parent) controller
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.parentViewController.navigationItem.leftBarButtonItems = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;  // Campus, Eateries, Favorite Foods
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    } else if (section==1)  {
        return  [self.model getLocationCount:[self.model myCampus]];  //self.eateryCount;
    } else if (section==2)  {
        NSInteger count = [self.favoriteFoods count];
        if (count==0) {
            return 1;  // default cell explaining favorites
        } else {
            return count;
        }
    }
    return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section==0) {
        return @"Campus";
    } else if (section==1) {
        return @"Eateries";
    } else if (section==2) {
        return @"Favorites          Notifications:";
    }
    return @"";
}


// initially for a campus, all eateries are selected
-(void)selectAllEateries {
    [self.favoriteEateries removeAllObjects];
    for (int i=0; i<self.eateryCount; i++) {
        [self.favoriteEateries addObject:[NSNumber numberWithInt:i]];
    }
}


// is this item currently checked as a favorite?
-(BOOL)favoriteItem:(NSInteger)row {
    return [self.favoriteEateries count]==0 || [self.favoriteEateries containsObject:[NSNumber numberWithInt:row]];
}

// can this favorite item be de-selected?  Can't have 0 favorite eatieries
-(BOOL)selectableItem:(NSInteger)row {
    return (([self.favoriteEateries count]==0 && self.eateryCount > 1) || [self.favoriteEateries count]>1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CampusCellIdentifier forIndexPath:indexPath];
        cell.alpha = 1.0;  //set to default
        NSInteger campusIndex = [self.model myCampus];
        NSString *name = [self.model getCampusName:campusIndex];

        cell.textLabel.text = [name capitalizedString];
    } else if (indexPath.section == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:EateriesCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = [self.model getLocationNameWithCampus:self.favoriteCampus andIndex:[indexPath row]];
        
        // don't highlight when selected
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // add checkmarks to favorites
        if ([self favoriteItem:indexPath.row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {  // section 2 Favorite Foods
        NSInteger count = [self.favoriteFoods count];
        if (count==0) {
            cell = [tableView dequeueReusableCellWithIdentifier:NoFavoritesCellIdentifier forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:FoodCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = [self.favoriteFoods objectAtIndex:[indexPath row]];
        }
        // don't highlight when selected
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
   

    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section==2) && ([self.favoriteFoods count] > 0);  // favorite foods are editable
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *food = cell.textLabel.text;
        [self.model removeFavoriteFood:food];
        
        // Delete the row from the data source
        if ([self.favoriteFoods count] > 0) {  // just delete it if we still have favorites to show
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else { // deleted last favorite food - special case in that we now want to display the info cell explaining favorites & end editing mode
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionFavorites];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
            self.editButtonItem.enabled = NO;
            [self setEditing:NO animated:YES];
        }
    
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section == sectionFavorites && [self.favoriteFoods count]==0) {
        return kNoFavoritesCellHeight;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}




#pragma mark - Table view delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat tableViewWidth = tableView.bounds.size.width;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableViewWidth, 30)];
    UIColor *backgroundColor =  [UIColor clearColor]; //[UIColor colorWithRed:31.0/255.0 green:61.0/255.0 blue:1.0/255.0 alpha:1.0];
    [headerView setBackgroundColor:backgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableViewWidth - 10, 18)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    if (section == sectionFavorites) {
       
        CGFloat width = self.alertSwitch.frame.size.width;
        CGRect frame = CGRectMake(tableViewWidth-(width+10.0), 0.0, width, self.alertSwitch.frame.size.height);
        self.alertSwitch.frame = frame;
        [self.alertSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        self.alertSwitch.on = [self.model notificationsEnabled];
        [headerView addSubview:self.alertSwitch];
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 1) {  // eateries can be selected/unselected as favorites
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([self favoriteItem:indexPath.row]) {  // currently a favorite
            if ([self selectableItem:indexPath.row]) {  //can be selected (unfavorited)
                cell.accessoryType = UITableViewCellAccessoryNone;
                [self.model removeEateryAtIndex:indexPath.row];
                //[self.favoriteEateries removeObject:[NSNumber numberWithInt:indexPath.row]];
            }
        } else {  // not currently a favorite, making it one
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            //[self.favoriteEateries addObject:[NSNumber numberWithInt:indexPath.row]];
             [self.model addEateryAtIndex:indexPath.row];
        }
    } else if (indexPath.section == 2) {  // favorite foods
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    }
   
}

#pragma mark - Actions
-(void)switchChanged {
    [self.model toggleNotifications];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionFavorites] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
