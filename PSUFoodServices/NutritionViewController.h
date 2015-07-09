//
//  NutritionViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServingPickerViewController.h"
#import "NewFoodViewController.h"

@interface NutritionViewController : UIViewController <NewFoodViewControllerDelegate, ServingPickerViewControllerDelegate>

@property (nonatomic,getter = isEditable) BOOL editable;

//-(id) initWithDictionary:(NSDictionary *) dict Date:(NSDate *) date isLog: (BOOL) isLog andIndex: (NSInteger) index;
-(void) setDictionary:(NSDictionary *) dict Date:(NSDate *) date isLog: (BOOL) isLog andIndex: (NSInteger) index;

@end
