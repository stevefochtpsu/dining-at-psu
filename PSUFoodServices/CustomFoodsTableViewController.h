//
//  CustomFoodsTableViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServingPickerViewController.h"
#import "NewFoodViewController.h"

@protocol CustomFoodsTableViewControllerDelegate

-(void) dismissSelector;
-(void) cancelButtonPressed;

@end

@interface CustomFoodsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NewFoodViewControllerDelegate>
@property (strong, nonatomic) id<CustomFoodsTableViewControllerDelegate> delegate;


@end
