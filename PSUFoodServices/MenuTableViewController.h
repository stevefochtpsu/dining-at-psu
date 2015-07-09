//
//  MenuTableViewController.h
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 12/11/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "DateModalViewController.h"

@interface MenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//- (id)initWithModel:(Model *)aModel andCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;

- (void)mealChanged;
//- (void)showDatePicker;

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mealSegmentedControl;

@end
 