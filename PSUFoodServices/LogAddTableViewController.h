//
//  LogAddTableViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFoodsTableViewController.h"
#import "LocationSelectorTableViewController.h"
#import "CampusTableViewController.h"

@protocol LogAddTableViewControllerDelegate <NSObject>

-(void) dismissLogAddTableViewController;

@end

@interface LogAddTableViewController : UITableViewController <CustomFoodsTableViewControllerDelegate, LocationSelectorTableViewControllerDelegate>

@property (strong, nonatomic) id<LogAddTableViewControllerDelegate> delegate;

-(id) initWithDate: (NSDate *) date;
-(void) setWithDate: (NSDate *) date;

@end
