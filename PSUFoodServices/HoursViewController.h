//
//  HoursViewController.h
//  PSUFoodServices
//
//  Created by H KENNETH ROSENBERRY on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface HoursViewController : UIViewController

@property (nonatomic,strong) CompletionBlock completionBlock;
- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;


@end
