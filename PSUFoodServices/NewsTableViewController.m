//
//  NewsTableViewController.m
//  PSUFoodServices
//
//  Created by MTSS MTSS on 2/24/12.
//  Copyright (c) 2012 Penn State. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsDetailViewController.h"
#import "ECSNavigationController.h"
#import "PostsModel.h"
#define kRefreshDelay 1.0
#define kNoNewsCellHeight 44.0

@interface NewsTableViewController ()

@property (weak, nonatomic) PostsModel *postsModel;
@property (weak, nonatomic) NSMutableArray *newsArray;
@property (weak, nonatomic) UIFont *cellFont;
@end

@implementation NewsTableViewController

@synthesize  cellFont;

//static NSString *newsDataDownloadCompleted = @"newsDataDownloadCompleted";

//- (id)initWithModel:(Model *)aModel 
//{
//    self = [super initWithStyle:UITableViewStylePlain];
//    if (self) {
//        model = aModel;
//        self.title = @"News";
//        cellFont = [UIFont boldSystemFontOfSize:18];
//    }
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
                _postsModel = [PostsModel sharedInstance];
        cellFont = [UIFont fontWithName:@"Helvetica" size:20.0];
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:newsDataDownloadCompleted
                                               object:nil];
    
    UIImage *image = [UIImage imageNamed:@"menuButton.png"];
    ECSNavigationController *navController = (ECSNavigationController*)self.navigationController;
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:navController action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
}

// delay the call to refresh posts to give tableview a chance to redraw rows before model resets the data
-(void)refresh {
    [self performSelector:@selector(refreshDelay) withObject:nil afterDelay:kRefreshDelay];
}
-(void)refreshDelay {
    [self.postsModel refetchPosts];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.postsModel refetchPostsIfStale];

}

// Each Child in container must set its barbutton items on the container (parent) controller
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //self.parentViewController.navigationItem.rightBarButtonItems = nil;
    self.parentViewController.navigationItem.title = @"News";
    self.parentViewController.navigationItem.leftBarButtonItems = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(BOOL)noNews {
    return [self.postsModel count] == 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self noNews]) {
        return 1;  // one item, saying there's no news
    } else {
        return [self.postsModel count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = cellFont;
    
    if ([self noNews]) {
        cell.textLabel.text = @"              No News Items";
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = [self.postsModel titleForRow: [indexPath row]];
        cell.detailTextLabel.text = [self.postsModel dateForRow: [indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self noNews]) {
        return kNoNewsCellHeight;
    }
    
    NSString *title = [self.postsModel titleForRow: [indexPath row]];
    
    CGSize maxCellSize = CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX);
    
//    NSMutableDictionary *atts = [[NSMutableDictionary alloc] init];
//    [atts setObject:[UIFont fontWithName:@"Helvetica" size:20.0] forKey:NSFontAttributeName];
//    
//    CGRect rect = [title boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:atts context:nil];
//    CGSize size2 = rect.size;

    
    CGSize cellSize = [title sizeWithFont:cellFont constrainedToSize:maxCellSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return cellSize.height + 40;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
//{
//    NewsDetailViewController *aNewsDetailViewController = [[NewsDetailViewController alloc] initWithNewsItem:[newsArray objectAtIndex:[indexPath row]]];
//    
//    [self.navigationController pushViewController:aNewsDetailViewController animated:YES];
//    
//    //self.title = @"Back";
//}

- (void)downloadCompleted:(NSNotification *)notification
{
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"NewsDetailSegue"]) {
        NewsDetailViewController *newsDetailViewController = (NewsDetailViewController*)segue.destinationViewController;
        newsDetailViewController.newsDescription = [self.postsModel descriptionForRow: [indexPath row]];
         newsDetailViewController.newsTitle = [self.postsModel titleForRow: [indexPath row]];
    }
}

@end
