//
//  ServingPickerViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServingPickerViewControllerDelegate <NSObject>

-(void) addFoodToLog: (NSDictionary *) foodLog;
-(void) cancelButtonPressed;

@optional
-(void) dismissServingPickerViewController;

@end

@interface ServingPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *servingPickerView;
@property (weak, nonatomic) IBOutlet UILabel *servingsLabel;
@property (strong, nonatomic) id<ServingPickerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *totCaloriesLabel;

- (IBAction)addButtonPressed:(id)sender;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andDictionary: (NSDictionary *) dict;
@end
