//
//  ContainerViewController.m
//  
//
//  Created by John Hannan on 6/5/13.
//  Copyright (c) 2013 John Hannan. All rights reserved.
//

#import "ContainerViewController.h"
#import "LocationTableViewController.h"
#import "NewsTableViewController.h"
#import "LogTableViewController.h"
#import "PreferencesTableViewController.h"


#define kAnimateDuration 0.25
#define kMenuHeight 194.0

@interface ContainerViewController ()

@property (strong,nonatomic) UITableViewController *tableViewController;
@property (strong, nonatomic) NSArray *containerArray;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSTimer *menuTimer;
@property CGRect visibleMenuFrame;
@property CGRect hiddenMenuFrame;

-(BOOL)menuShowing;

- (IBAction)ChooseView:(id)sender;

@end

@implementation ContainerViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    self.visibleMenuFrame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, kMenuHeight);
    self.hiddenMenuFrame = CGRectOffset(self.visibleMenuFrame, 0.0, -kMenuHeight);
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    self.tableViewController.tableView.frame = self.hiddenMenuFrame;
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.dataSource = self;
    
    
    [self addChildViewController:self.tableViewController];
    
    [self.view addSubview:self.tableViewController.tableView];
    [self.tabBarController didMoveToParentViewController:self];
    
    
    LocationTableViewController *vc1 = [self.storyboard instantiateViewControllerWithIdentifier: @"LocationTableViewController"];
    LogTableViewController *vc2 = [self.storyboard instantiateViewControllerWithIdentifier: @"LogTableViewController"];
    NewsTableViewController *vc3 = [self.storyboard instantiateViewControllerWithIdentifier: @"NewsTableViewController"];
    PreferencesTableViewController *vc4 = [self.storyboard instantiateViewControllerWithIdentifier: @"PreferencesTableViewController"];
    vc1.view.frame = self.view.frame;
    vc2.view.frame = self.view.frame;
    vc3.view.frame = self.view.frame;
    vc4.view.frame = self.view.frame;
    
    self.containerArray = @[vc1,vc2,vc3,vc4];
    
    [self displayContentController:vc1];
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableViewController.tableView cellForRowAtIndexPath:self.currentIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    


}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}



-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content];       
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];  
    
    [self.view sendSubviewToBack:content.view];
}

- (void) hideContentController: (UIViewController*) content
{
    [content willMoveToParentViewController:nil];  
    [content.view removeFromSuperview];           
    [content removeFromParentViewController];     
}

- (void) cycleFromViewController: (UIViewController*) oldC
                toViewController: (UIViewController*) newC
{
    [oldC willMoveToParentViewController:self];                  
    [self addChildViewController:newC];
    
 
    
    [self transitionFromViewController: oldC toViewController: newC   
                              duration: 0.25 options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL 
                            completion:^(BOOL finished) {
                                [oldC removeFromParentViewController];                  
                                [newC didMoveToParentViewController:self];
                                [self.view sendSubviewToBack:newC.view];
                            }];
}

-(void)showMenu {
    if (!self.menuShowing) {

        self.tableViewController.tableView.alpha = 1.0;
        [UIView animateWithDuration:kAnimateDuration animations:^{self.tableViewController.tableView.frame = self.visibleMenuFrame;} completion:NULL];
        self.menuTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideMenu) userInfo:nil repeats:NO];
    }
}

-(void)hideMenu {
    [self.menuTimer invalidate];
    self.menuTimer = nil;
    
    if (self.menuShowing) {
        [UIView animateWithDuration:kAnimateDuration animations:^{self.tableViewController.tableView.frame = self.hiddenMenuFrame;} completion:^(BOOL finished){self.tableViewController.tableView.alpha = 0.0;}];
    }
}

-(BOOL)menuShowing {
    CGFloat yOrigin = self.tableViewController.tableView.frame.origin.y;
    return (yOrigin>=0.0);
}

- (IBAction)ChooseView:(id)sender {
    if (self.menuShowing) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
  
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Menu";
            break;
        case 1:
            cell.textLabel.text = @"Daily Log";
            break;
        case 2:
            cell.textLabel.text = @"News";
            break;
        default:
            cell.textLabel.text = @"Preferences";
            break;
    }

    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger oldRow = self.currentIndexPath.row;
    NSInteger newRow = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (oldRow != newRow) { 
        //uncheck previous selection
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.currentIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // check new selection
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentIndexPath = indexPath;
        
       // switch view controllers
        UIViewController *fromVC = [self.containerArray objectAtIndex:oldRow];
        UIViewController *toVC = [self.containerArray objectAtIndex:newRow];
        
        [UIView animateWithDuration:kAnimateDuration animations:^{self.tableViewController.tableView.frame = self.hiddenMenuFrame;} completion:^(BOOL finished) {
            [self cycleFromViewController:fromVC toViewController:toVC];

        }];
        
        [self.menuTimer invalidate];
        self.menuTimer = nil;
    }
    
    //[self hideMenu];

}
@end
