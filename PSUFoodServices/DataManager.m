//
//  DataManager.m
//  CoreDataDemo
//
//  Created by John Hannan on 10/11/10.
//  Copyright 2010 Penn State University. All rights reserved.
//

#import "DataManager.h"
#define kUPIndex 9  // really bad idea!


@interface DataManager ()

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSArray *allLogKeys;
@property (nonatomic,strong) NSArray *allFoodKeys;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;

-(NSArray *) makeArrayForFoodObjects: (NSArray *) managedObjects;
-(NSArray *) makeArrayForLogObjects: (NSArray *) logArray;
-(NSDictionary *) makeDictionaryForFoodObject: (NSManagedObject *) foodObject;
-(NSDictionary *) makeDictionaryForLogObject: (NSManagedObject *) logObject;


// Checks to see if any database exists on disk
- (BOOL)databaseExists;

// Returns an array of objects already in the database for the given Entity Name and Predicate
- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;

- (void) setValues: (NSDictionary *) values forEntity: (NSManagedObject *) entity;



@end

@implementation DataManager
@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;


#pragma mark - Initialization


+(void)createDatabaseFor:(DataManager*)dataManager {
    
    
    [dataManager managedObjectContext];
        

    // Save the database
    [dataManager saveContext];
}


// We do not use alloc to create an instance of this object.  We use this class method
// Only one object ever created.  Database will be created the first time this app is run
+ (id)sharedInstance
{
	static id singleton = nil;
	
	if (singleton == nil) {
		singleton = [[self alloc] init];
        if (![singleton databaseExists]) 
            [self createDatabaseFor:singleton];
    }
	
    return singleton;
}

-(id)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat: kDateFormat];
        
        _allLogKeys = @[kName,kCalories,kTotalFat,kSatFat,kTransFat,kCholesterol,kSodium,kTotalCarb,kDietaryFiber,kSugars,kProtein,kServingSize,kDate];
        _allFoodKeys = @[kName,kCalories,kTotalFat,kSatFat,kTransFat,kCholesterol,kSodium,kTotalCarb,kDietaryFiber,kSugars,kProtein];
    }
    return self;
}


#pragma mark - Save Context

- (void)saveContext {
    
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"PSUFoodServices" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"PSUFoodServices.sqlite"]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (NSString *)databasePath
{
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"PSUFoodServices.sqlite"];
}


- (BOOL)databaseExists
{
	NSString	*path = [self databasePath];
	BOOL		databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	return databaseExists;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Fetching Data 

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
	NSManagedObjectContext	*context = [self managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	
	NSFetchRequest	*request = [[NSFetchRequest alloc] init];
	request.entity = entity;
	request.predicate = predicate;
	
    if (![entityName isEqualToString:@"Campus"]){
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kName ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptors];
    }
	
	NSArray	*results = [context executeFetchRequest:request error:nil];
    
	return results;
}

#pragma mark - Private Methods
-(void) setValues:(NSDictionary *)values forEntity:(NSManagedObject *)entity {
    for (NSString *key in self.allFoodKeys) {
        [entity setValue:[values objectForKey: key] forKey:key];
    }
    /*
    [entity setValue:[values objectForKey: kName] forKey:kName];
    [entity setValue:[values objectForKey: kCalories] forKey:kCalories];
    [entity setValue:[values objectForKey: kTotalFat] forKey:kTotalFat];
    [entity setValue:[values objectForKey: kSatFat] forKey:kSatFat];
    [entity setValue:[values objectForKey: kTransFat] forKey: kTransFat];
    [entity setValue:[values objectForKey: kCholesterol] forKey:kCholesterol];
    [entity setValue:[values objectForKey: kSodium] forKey: kSodium];
    [entity setValue:[values objectForKey: kTotalCarb] forKey:kTotalCarb];
    [entity setValue:[values objectForKey: kDietaryFiber] forKey:kDietaryFiber];
    [entity setValue:[values objectForKey: kSugars] forKey:kSugars];
    [entity setValue:[values objectForKey: kProtein] forKey:kProtein];
    */
    
   
    
    [self saveContext];
}

-(void) setLogValues: (NSDictionary *) logValues forEntity: (NSManagedObject *) entity {
    for (NSString *key in self.allLogKeys) {
        [entity setValue:[logValues objectForKey: key] forKey:key];
    }
    /*
    [entity setValue:[logValues objectForKey: kName] forKey:kName];
    [entity setValue:[logValues objectForKey: kCalories] forKey:kCalories];
    [entity setValue:[logValues objectForKey: kTotalFat] forKey:kTotalFat];
    [entity setValue:[logValues objectForKey: kSatFat] forKey:kSatFat];
    [entity setValue:[logValues objectForKey: kTransFat] forKey: kTransFat];
    [entity setValue:[logValues objectForKey: kCholesterol] forKey:kCholesterol];
    [entity setValue:[logValues objectForKey: kSodium] forKey: kSodium];
    [entity setValue:[logValues objectForKey: kTotalCarb] forKey:kTotalCarb];
    [entity setValue:[logValues objectForKey: kDietaryFiber] forKey:kDietaryFiber];
    [entity setValue:[logValues objectForKey: kSugars] forKey:kSugars];
    [entity setValue:[logValues objectForKey: kProtein] forKey:kProtein];
    [entity setValue:[logValues objectForKey: kServingSize] forKey: kServingSize];
    [entity setValue:[logValues objectForKey: kDate] forKey:kDate];
    */
    [self saveContext];
}

// Creates an array of dictionaries for MyFood entity
// Dictionary contains only name and calories (information necessary for table display)
-(NSArray *) makeArrayForFoodObjects: (NSArray *) managedObjects {
    NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:[managedObjects count]];
    
    for (NSManagedObject *foodObject in managedObjects) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.allFoodKeys) {
            id obj = [foodObject valueForKey:key];
            if (obj) {
                [dict setValue:obj forKey:key];
            }
        }
//        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[foodObject valueForKey: kName], kName, [foodObject valueForKey:kCalories], kCalories, [foodObject valueForKey: kTotalFat], kTotalFat, [foodObject valueForKey:kSatFat], kSatFat, [foodObject valueForKey: kTransFat], kTransFat, [foodObject valueForKey: kCholesterol], kCholesterol, [foodObject valueForKey: kSodium], kSodium, [foodObject valueForKey: kTotalCarb], kTotalCarb, [foodObject valueForKey:kDietaryFiber], kDietaryFiber, [foodObject valueForKey: kSugars], kSugars, [foodObject valueForKey: kProtein], kProtein,  nil];
        
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[food valueForKey: kName], kName, [food valueForKey:kCalories], kCalories, nil];
        
        [myArray insertObject: dict atIndex: [myArray count]];
    }
    
    return myArray;
}

// Creates an array of dictionaries for LogItem entity
// Dictionary contains only name, serving size,  calories and date (information necessary for table display)
-(NSArray *) makeArrayForLogObjects: (NSArray *) managedObjects {
    NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:[managedObjects count]];
    
    for (NSManagedObject *foodObject in managedObjects) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.allLogKeys) {
            id obj = [foodObject valueForKey:key];
            if (obj) {
                [dict setValue:obj forKey:key];
            }
        }
        
        //        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[foodObject valueForKey: kName], kName, [foodObject valueForKey:kCalories], kCalories, [foodObject valueForKey: kTotalFat], kTotalFat, [foodObject valueForKey:kSatFat], kSatFat, [foodObject valueForKey: kTransFat], kTransFat, [foodObject valueForKey: kCholesterol], kCholesterol, [foodObject valueForKey: kSodium], kSodium, [foodObject valueForKey: kTotalCarb], kTotalCarb, [foodObject valueForKey:kDietaryFiber], kDietaryFiber, [foodObject valueForKey: kSugars], kSugars, [foodObject valueForKey: kProtein], kProtein, [foodObject valueForKey:kServingSize], kServingSize,[foodObject valueForKey:kDate], kDate, nil];
        
        
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[food valueForKey: kName], kName, [food valueForKey:kCalories], kCalories, [food valueForKey:kServingSize], kServingSize, [food valueForKey:kDate], kDate, nil];
        
        [myArray insertObject: dict atIndex: [myArray count]];
    }
    
    return myArray;
}

-(NSDictionary *) makeDictionaryForFoodObject: (NSManagedObject *) foodObject {

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.allFoodKeys) {
            id obj = [foodObject valueForKey:key];
            if (obj) {
                [dict setValue:obj forKey:key];
            }
        }

//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[foodObject valueForKey: kName], kName, [foodObject valueForKey:kCalories], kCalories, [foodObject valueForKey: kTotalFat], kTotalFat, [foodObject valueForKey:kSatFat], kSatFat, [foodObject valueForKey: kTransFat], kTransFat, [foodObject valueForKey: kCholesterol], kCholesterol, [foodObject valueForKey: kSodium], kSodium, [foodObject valueForKey: kTotalCarb], kTotalCarb, [foodObject valueForKey:kDietaryFiber], kDietaryFiber, [foodObject valueForKey: kSugars], kSugars, [foodObject valueForKey: kProtein], kProtein,  nil];
    
    return dict;
}

-(NSDictionary *) makeDictionaryForLogObject: (NSManagedObject *) logObject {
    //DataManager *dataManager = [DataManager sharedInstance];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary: [self makeDictionaryForFoodObject: logObject]];
    
 
    [dict setObject: [logObject valueForKey: kDate] forKey:kDate];
    [dict setObject: [logObject valueForKey: kServingSize] forKey:kServingSize];

    return dict;
}

#pragma mark - Public Methods

-(void) setFavoriteCampus:(NSInteger)newFav {
    // Check to see if a favorite campus already exists
    //DataManager *dataManager = [DataManager sharedInstance];
    NSArray *favCampusArray = [self fetchManagedObjectsForEntity:@"Campus" withPredicate:nil];
    
    // If it doesn't add a new entity
    if ([favCampusArray count] == 0) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSManagedObject *favCampus = [NSEntityDescription insertNewObjectForEntityForName:@"Campus" inManagedObjectContext:managedObjectContext];
        [favCampus setValue:[NSNumber numberWithInt:newFav] forKey:@"index"];
    }
    // If it does, edit the entity
    else {
        NSEntityDescription *favCampus = [favCampusArray objectAtIndex:0];
        
        [favCampus setValue:[NSNumber numberWithInt:newFav] forKey:@"index"];
    }
    
    [self saveContext];
}

-(NSInteger) getFavoriteCampus {
    //DataManager *dataManager = [DataManager sharedInstance];
    NSArray *favCampusArray = [self fetchManagedObjectsForEntity:@"Campus" withPredicate:nil];
        if ([favCampusArray count] > 0) {
        NSManagedObject *favCampus = [favCampusArray objectAtIndex:0];
       
        return [[favCampus valueForKey:@"index"] intValue];
    }
    
    //Default to University Park
    return kUPIndex;
}

-(void) addFood:(NSDictionary *)foodData
{
    //DataManager *dataManager = [DataManager sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObject *newFood = [NSEntityDescription insertNewObjectForEntityForName:kMyFood inManagedObjectContext: managedObjectContext];
    
    [self setValues: foodData forEntity:newFood];
}

-(void) editFood: (NSDictionary *) foodData atIndex: (NSInteger) index
{
    //DataManager *dataManager = [DataManager sharedInstance];
    
    NSArray *foods = [self fetchManagedObjectsForEntity:kMyFood withPredicate:nil];
    
    NSManagedObject *myFood = [foods objectAtIndex: index];
    
    [self setValues: foodData forEntity:myFood];
}

-(NSArray *) getMyFoods
{
    //DataManager *dataManager = [DataManager sharedInstance];
    NSArray * myFoodObjects = [self fetchManagedObjectsForEntity:kMyFood withPredicate:nil];
    
    // construct array of project names and pid

    NSArray *foods = [self makeArrayForFoodObjects: myFoodObjects];
    
    return foods;
}

-(void) deleteMyFoodAtIndex:(NSInteger)index
{
    //DataManager *dataManager = [DataManager sharedInstance];
    NSArray *foodObjects = [self fetchManagedObjectsForEntity: kMyFood withPredicate: nil];
    
    [_managedObjectContext deleteObject: [foodObjects objectAtIndex: index]];
    
    [self saveContext];
}

-(void) deleteLogFoodAtIndex:(NSInteger) index forDate :(NSDate *)date
{
   
    
    NSString *dateString = [NSString stringWithFormat: @"%@", [self.dateFormatter stringFromDate: date]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", dateString];
    
    //DataManager *dataManager = [DataManager sharedInstance];
    
    NSArray *foodObjects = [self fetchManagedObjectsForEntity: kLogItem withPredicate: predicate];
    
    [_managedObjectContext deleteObject: [foodObjects objectAtIndex: index]];
    
    [self saveContext];
}
-(NSArray *) getFoodsForDate:(NSDate *)date {
  
    
    //DataManager *dataManager = [DataManager sharedInstance];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", [self.dateFormatter stringFromDate: date]];

    NSArray *foodObjects = [self fetchManagedObjectsForEntity:kLogItem withPredicate: predicate];
    
    NSArray *foods = [self makeArrayForLogObjects: foodObjects];
    
    return foods;
}

-(NSArray *) allDatesForLogs {
    NSArray *foodObjects = [self fetchManagedObjectsForEntity:kLogItem withPredicate: nil];
    NSArray *allFoods = [self makeArrayForLogObjects: foodObjects];
    NSMutableArray *allDates = [NSMutableArray arrayWithCapacity:10];
    
    for (NSDictionary *foodDict in allFoods) {
        NSString *dateString = [foodDict objectForKey:kDate];
        NSDate *date = [self.dateFormatter dateFromString:dateString];
        [allDates addObject:date];
    }
    
    NSSet *set = [NSSet setWithArray:allDates];  //removes duplicates
    NSMutableArray *uniqueDates = [[set allObjects] mutableCopy];
    
    // sort the dates in descending order
    [uniqueDates sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = obj1;
        NSDate *date2 = obj2;
        NSComparisonResult result = [date1 compare: date2];
        return  (result == NSOrderedAscending) ? NSOrderedDescending : NSOrderedAscending;
    }];
    //[uniqueDates sortUsingSelector:@selector(compare:)];

    return uniqueDates;
}

-(void)removeFoodsForDate:(NSDate *)date {
    NSString *dateString = [NSString stringWithFormat: @"%@", [self.dateFormatter stringFromDate: date]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", dateString];
    NSArray *foodObjects = [self fetchManagedObjectsForEntity: kLogItem withPredicate: predicate];
    for (NSManagedObject *foodItem in foodObjects) {
        [_managedObjectContext deleteObject: foodItem];
    }
    [self saveContext];
}

-(void) addToLog:(NSDictionary *)dict {
    //DataManager *dataManager = [DataManager sharedInstance];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSManagedObject *newLog = [NSEntityDescription insertNewObjectForEntityForName:kLogItem inManagedObjectContext: managedObjectContext];
    
    [self setLogValues:dict forEntity:newLog];
}

-(void) updateLogFood:(NSDictionary *)dict forDate:(NSDate *) date atIndex :(NSInteger)index {
    //DataManager *dataManager = [DataManager sharedInstance];
 
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date=%@", [self.dateFormatter stringFromDate: date]];
                              
    NSArray *foods = [self fetchManagedObjectsForEntity:kLogItem withPredicate:predicate];
    
    NSManagedObject *myFood = [foods objectAtIndex: index];
    
    [myFood setValue:[dict objectForKey: kServingSize] forKey:kServingSize];
    
    [self saveContext];
}

-(NSDictionary *) getDictionaryForEntity:(NSString *)entity withPredicate: (NSPredicate *) predicate atIndex:(NSInteger)index {
    //DataManager *dataManager = [DataManager sharedInstance];
    NSArray *foodObjects = [self fetchManagedObjectsForEntity:entity withPredicate:predicate];
    
    NSManagedObject *foodItem = [foodObjects objectAtIndex: index];
    NSDictionary *myDict;
    
    if([entity isEqualToString: kLogItem]) {
        myDict = [NSDictionary dictionaryWithDictionary: [self makeDictionaryForLogObject:foodItem]];
    }
    else {
        myDict = [NSDictionary dictionaryWithDictionary: [self makeDictionaryForFoodObject:foodItem]];
    }
    return myDict;
}
@end
