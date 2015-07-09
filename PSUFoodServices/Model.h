//
//  Model.h
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 11/22/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject <UIAlertViewDelegate>

+ (id)sharedInstance;

@property (nonatomic) NSInteger myCampus;
@property (nonatomic,strong) NSMutableArray *myEateries;
@property (nonatomic,strong) NSMutableArray *myFoods;

@property  (readonly) BOOL disclaimerShown;
-(void)disclaimerWasShown;

-(void)addEateryAtIndex:(NSInteger)index;
-(void)removeEateryAtIndex:(NSInteger)index;
-(NSString*)favoriteEateryNameAtIndex:(NSInteger)index;

@property (readonly) BOOL notificationsEnabled;
-(void)toggleNotifications;
-(void)updateNotifications;
-(BOOL)isFavoriteFood:(NSString*)food;
-(void)addFavoriteFood:(NSString*)food;
-(void)removeFavoriteFood:(NSString*)food;
-(void) addFoodToLog:(NSDictionary *)foodLog forDate:(NSDate*)myDate;
-(NSArray *) allDatesForLogs;
-(NSArray *) foodsForDate:(NSDate *)date;
-(void)removeFoodsForDate:(NSDate *)date;

-(BOOL)staleNews;
-(BOOL)staleHours;
-(void)updateNews;
-(void)updateHours;

// stuff for favorites
-(void)allMenusForDate:(NSString *)dateString;
-(NSArray*)locationsForCampusIndex:(NSInteger)campusIndex;
-(void)prepareDatesAndMenus;

//- (NSInteger)favoriteCampus;
//- (void) setFavoriteCampus:(NSInteger)newFav;

- (NSMutableArray *) getCampusNames;
- (NSInteger) getCampusCount;
- (NSString *) getCampusName:(NSInteger)campusIndex;
- (NSURL*)getNewsURLForCampus:(NSInteger)campusIndex;
- (NSInteger) getLocationCount:(NSInteger)campusIndex;
- (NSString *) getLocationNameWithCampus:(NSInteger)campusIndex andIndex:(NSInteger)locationIndex;
- (NSMutableDictionary *) getLocationDictForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (NSInteger) getLocationNumberWithCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (BOOL) eateryHasHours:(NSInteger)menuCatNum;
- (NSMutableArray *) getHoursForEatery:(NSInteger)menuCatNum;
- (void) loadMenuForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex andMeal:(NSInteger)mIndex andDate:(NSString *)dateString;
- (void) loadEateriesForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (NSMutableDictionary *) getCampusDictWithCampusCode:(NSString *)aCode;
- (NSNumber *) getLongitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (NSNumber *) getLatitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (NSDictionary *) getLatitudeAndLongitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex;
- (NSMutableArray *) getNews;



@end
