//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"
#import "Model.h"
#import "MenuTableViewController.h"
#import "InitialSlidingViewController.h"


#define kOffset 60
#define kSectionCount 6

enum menuSections {
    sectionLocations = 0,
    sectionCustomFoods,
    sectionLog,
    sectionNews,
    sectionFavorites,
    sectionPreferences
};

@interface MenuViewController()
@property (nonatomic, strong) NSArray *navControllers;
@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, strong) Model          *model;
@property (readonly) NSInteger favoriteCampus;
@property (nonatomic,strong) NSMutableArray *favoriteEateries;
@property BOOL modelReady;


@end

@implementation MenuViewController

-(NSInteger)favoriteCampus {
    return [self.model myCampus];
}

-(NSMutableArray*)favoriteEateries {
    return [self.model myEateries];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _model = [Model sharedInstance];
    }
    
    return self;
}




- (void)viewDidLoad
{
  [super viewDidLoad];
  
    CGFloat width = self.view.bounds.size.width - kOffset;
  [self.slidingViewController setAnchorRightRevealAmount:width];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    UIViewController *vc0 = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuNavController"];
    UIViewController *vc5 = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomFoodsNavController"];
    UIViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"LogNavController"];
    UIViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsNavController"];
    UIViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"FavsNavController"];
    UIViewController *vc4 = [self.storyboard instantiateViewControllerWithIdentifier:@"PrefsNavController"];
    _navControllers = @[vc0,vc5,vc1,vc2,vc3,vc4];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:locationDataDownloadCompleted
                                               object:nil];
    InitialSlidingViewController *initialVC = (InitialSlidingViewController*) self.parentViewController;
    initialVC.topViewController = vc0;
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if (self.modelReady && [self.favoriteEateries count] == 0) {  //initial value of preferences
//        [self selectAllEateries];
//    }
    
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionLocations];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
   
}


#pragma mark - TableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == sectionLocations) {
        return [self.favoriteEateries count]; 
    } else {
        return 1;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MainMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    // Configure the cell...
     cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    switch (indexPath.section) {
        case sectionLocations: {
            // get the favorite index, then get this index from model
//            NSNumber *num = [self.favoriteEateries objectAtIndex:indexPath.row];
//            NSInteger index = [num integerValue];
//            cell.textLabel.text = [self.model getLocationNameWithCampus:self.favoriteCampus andIndex:index];
            NSString *eateryName = [self.model favoriteEateryNameAtIndex:indexPath.row];
            cell.textLabel.text = eateryName;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
            break;
        case sectionCustomFoods:
            cell.textLabel.text = @"Custom Menu";
            break;

        case sectionLog:
            cell.textLabel.text = @"Daily Logs";
            break;
        case sectionNews:
            cell.textLabel.text = @"News";
            break;
        case sectionFavorites:
            cell.textLabel.text = @"Favorites";
            break;
        default:
            cell.textLabel.text = @"Preferences";
            break;
    }
    
    return cell;

}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UIViewController *newTopViewController = [self.navControllers objectAtIndex:indexPath.section];
    
    if (indexPath.section == sectionLocations) {  // Eatery - set the chosen eatery
        NSInteger row = indexPath.row;  // Eatery
        NSNumber *location = [self.favoriteEateries objectAtIndex:row];
        NSInteger locationIndex = [location integerValue];
        UINavigationController *navController = (UINavigationController*)newTopViewController;
        MenuTableViewController *aMenuTableViewController = (MenuTableViewController*) navController.topViewController;
        [aMenuTableViewController setCampus:self.favoriteCampus andLocation:locationIndex];
    }
  
  [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
  }];
}

#pragma mark - Notification Handler
- (void)downloadCompleted:(NSNotification *)notification
{
    self.modelReady = YES;
    
    if ([self.favoriteEateries count] == 0) {
        [self selectAllEateries];
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:sectionLocations];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Need to initialize the initial eatery - now we can do it, just use first one. 
    NSInteger row = 0;  
    NSNumber *location = [self.favoriteEateries objectAtIndex:row];  // favorite eatieries is empty some times!
    NSInteger locationIndex = [location integerValue];
    UINavigationController *navController = (UINavigationController*)self.slidingViewController.topViewController;
    MenuTableViewController *aMenuTableViewController = (MenuTableViewController*) navController.topViewController;
    [aMenuTableViewController setCampus:self.favoriteCampus andLocation:locationIndex];
}

#pragma mark - Eateries

// initially for a campus, all eateries are selected
-(void)selectAllEateries {
    NSInteger count = [self.model getLocationCount:self.favoriteCampus];
    [self.favoriteEateries removeAllObjects];
    for (int i=0; i<count; i++) {
        [self.favoriteEateries addObject:[NSNumber numberWithInt:i]];
    }
}


@end
