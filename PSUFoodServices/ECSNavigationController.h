//
//  ECSNavigationController.h
//  PSUFoodServices
//
//  Created by John Hannan on 6/9/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
//#import "UnderRightViewController.h"

@interface ECSNavigationController : UINavigationController

- (IBAction)revealMenu:(id)sender;
- (IBAction)revealUnderRight:(id)sender;

@end
