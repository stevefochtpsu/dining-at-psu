//
//  LogSelectorCell.h
//  PSUFoodServices
//
//  Created by John Hannan on 7/5/12.
//  Copyright (c) 2012 Penn State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogSelectorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *servingsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
- (IBAction)servingChanged:(id)sender;

@end
