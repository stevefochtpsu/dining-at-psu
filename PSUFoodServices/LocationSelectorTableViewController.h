//
//  LocationSelectorTableViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFoodsTableViewController.h"

@protocol LocationSelectorTableViewControllerDelegate<NSObject>
-(void) cancelButtonPressed;
@end

@interface LocationSelectorTableViewController : UITableViewController<CustomFoodsTableViewControllerDelegate>

@property (strong, nonatomic) id<LocationSelectorTableViewControllerDelegate> delegate;

-(id) initWithStyle:(UITableViewStyle)style Date: (NSDate *) date andItems: (NSArray *) items;
@end
