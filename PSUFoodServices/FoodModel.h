//
//  FoodModel.h
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodModel : NSObject

@property (assign, nonatomic) NSInteger mealCode;

+(id) sharedInstance;

-(void) getArrayForDate: (NSDate *) date andLocation: (NSString *) locationCode;
@end
