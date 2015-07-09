//
//  DataManager.h
//  CoreDataDemo
//
//  Created by John Hannan on 10/11/10.
//  Copyright 2010 Penn State University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataManager : NSObject {}

// Returns the 'singleton' instance of this class
+ (id)sharedInstance;

-(void) setFavoriteCampus:(NSInteger)newFav;
-(NSInteger) getFavoriteCampus;
-(void) addFood: (NSDictionary *) foodData;
-(void) editFood: (NSDictionary *) foodData atIndex:(NSInteger) index;
-(void) deleteMyFoodAtIndex: (NSInteger) index;
-(void) deleteLogFoodAtIndex: (NSInteger) index forDate: (NSDate *) date;
-(void) addToLog: (NSDictionary *) dict;
-(void) updateLogFood: (NSDictionary *) dict forDate: (NSDate *) date atIndex: (NSInteger) index;
-(NSArray *) getMyFoods;
-(NSArray *) getFoodsForDate: (NSDate *) date;
-(NSArray *) allDatesForLogs;
-(void)removeFoodsForDate:(NSDate *)date;
-(NSDictionary *) getDictionaryForEntity: (NSString *) entity withPredicate: (NSPredicate *) predicate atIndex: (NSInteger) index;

@end
