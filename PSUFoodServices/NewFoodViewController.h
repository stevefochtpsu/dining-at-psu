//
//  NewFoodViewController.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 11/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewFoodViewControllerDelegate <NSObject>

-(void) dismissNewFoodView;

@optional
-(void) addNewFood:(NSDictionary *) foodData;
-(void) editFood: (NSDictionary *) dict atIndex: (NSInteger) index;

@end

@interface NewFoodViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) id<NewFoodViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isNew;


//-(id) initWithDictionary: (NSDictionary *) dictionary andIndex: (NSInteger) index;
-(void) setDictionary: (NSDictionary *) dictionary andIndex: (NSInteger) index;


@end
