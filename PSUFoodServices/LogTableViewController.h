//
//  LogTableViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogAddTableViewController.h"

@interface LogTableViewController : UITableViewController <CustomFoodsTableViewControllerDelegate>
@property (nonatomic, strong) NSDate *currentDate;
@end
