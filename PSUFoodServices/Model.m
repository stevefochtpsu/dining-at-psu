//
//  Model.m
//  PennStateFoodServices
//
//  Created by MTSS MTSS on 11/22/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//


#import "Model.h"
#import "DataManager.h"
#import "Reachability.h"

#define kNoCampus -1
#define kCacheLimit 30
#define kNumberOfDays 5  // days of favorites on menu to check
#define kNotificationHour 6

static NSString *const dataArchive = @"data.archive";

@interface Model()
@property (nonatomic,strong) NSDictionary           *dataDictionary;
@property (nonatomic,retain) NSMutableArray         *campusArray;
@property (nonatomic,retain) NSMutableArray         *hoursArray;
@property (nonatomic,retain) NSMutableArray         *newsArray;
@property (nonatomic,strong) NSDate                 *newsUpdateDate;
@property (nonatomic,strong) NSDate                 *hoursUpdateDate;
@property (nonatomic,retain) NSMutableArray         *campusNames;
@property (nonatomic,retain) NSURLConnection        *campusesConnection;    
@property (nonatomic,retain) NSURLConnection        *locationsConnection;
@property (nonatomic,retain) NSURLConnection        *menuConnection;
@property (nonatomic,retain) NSURLConnection        *allMenuConnection;
@property (nonatomic,retain) NSURLConnection        *hoursConnection;
@property (nonatomic,retain) NSURLConnection        *eateriesConnection;
@property (nonatomic,retain) NSURLConnection        *newsConnection;
@property (nonatomic,retain) NSMutableData          *campusesData;
@property (nonatomic,retain) NSMutableData          *locationsData;
@property (nonatomic,retain) NSMutableData          *menuData;
@property (nonatomic,retain) NSMutableData          *allMenuData;
@property (nonatomic,retain) NSMutableData          *eateriesData;
@property (nonatomic,retain) NSMutableData          *hoursData;
@property (nonatomic,retain) NSMutableData          *newsData;
@property NSInteger                                 currentMenuMealNumber;

@property (nonatomic,strong) DataManager *dataManager;

@property (nonatomic,strong) Reachability* internetReachable;
@property (nonatomic,strong) Reachability* hostReachable;
@property  NetworkStatus internetStatus;
@property  NetworkStatus hostStatus;
@property BOOL statusUpdated;

@property (nonatomic,strong) NSCache *menuCache;
@property (nonatomic,strong) NSString *menuKey;  // need to remember it

@property (nonatomic,retain) UIAlertView *alertView;

//Favorites
@property (nonatomic,strong) NSMutableArray *favoritesNotifications;
@property (nonatomic,strong) NSMutableArray *menuDates;
@property (nonatomic,strong) NSMutableArray *menuMenus;
@property (nonatomic,strong) NSMutableArray *menuFavorites;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSCalendar *gregorianCalendar;


@property (nonatomic,strong)  NSUserDefaults *prefs;
@property (nonatomic,strong) NSComparator eateryComparator;
@end


@implementation Model

@synthesize campusArray, hoursArray, newsArray, campusNames, campusesConnection, locationsConnection, menuConnection, allMenuConnection, eateriesConnection, hoursConnection, newsConnection, campusesData, locationsData, menuData, eateriesData, hoursData, newsData, currentMenuMealNumber;

@synthesize internetReachable, hostReachable, internetStatus, hostStatus, statusUpdated;

@synthesize myCampus=_myCampus, myEateries=_myEateries, myFoods=_myFoods;

static NSString *const campusesURLString = @"http://api.absecom.psu.edu/rest/facilities/campuses/v1/221723";
static NSString *const locationsURLString = @"http://api.absecom.psu.edu/rest/facilities/areas/v1/221723";
static NSString *const menusURLString = @"http://api.absecom.psu.edu/rest/services/food/menus/v1/221723?";
static NSString *const allMenusURLString = @"http://api.absecom.psu.edu/rest/services/food/menus/v1/221723?date=";
static NSString *const eateriesURLString = @"http://api.absecom.psu.edu/rest/facilities/locations/v1/221723?location=";
static NSString *const hoursURLString = @"http://api.absecom.psu.edu/rest/facilities/hours/v1/221723";
static NSString *const newsURLString = @"http://api.absecom.psu.edu/rest/services/food/news/v1/221723";

+ (id)sharedInstance
{
	static id singleton = nil;
	
	if (singleton == nil) {
		singleton = [[self alloc] init];
    }
	
    return singleton;
}

- (id) init {
    self = [super init];
    if (self) {
     
        _myCampus = kNoCampus;
     
        
        self.prefs = [NSUserDefaults standardUserDefaults];
        
      
        _notificationsEnabled= [self.prefs boolForKey:@"notificationsEnabled"];
        
        self.dataManager = [DataManager sharedInstance];
        
        [self initializeData];
        
        //Check for Reachability
        // check for internet connection
        self.statusUpdated = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        self.internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        self.hostReachable = [Reachability reachabilityWithHostname: @"api.absecom.psu.edu"];
        [hostReachable startNotifier];

        
                        
        
        campusArray = [[NSMutableArray alloc] initWithCapacity:20];
        hoursArray = [[NSMutableArray alloc] initWithCapacity:20];
        newsArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
       
        self.menuCache.countLimit = kCacheLimit;
        
        //Favorites
        _favoritesNotifications = [NSMutableArray arrayWithCapacity:kNumberOfDays];
        _menuDates = [NSMutableArray arrayWithCapacity:kNumberOfDays];
        _menuMenus = [NSMutableArray arrayWithCapacity:kNumberOfDays];
        _menuFavorites = [NSMutableArray array];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:kDateFormat];
        _gregorianCalendar  =  [NSCalendar currentCalendar];
        
        //comparator for sorting eateries (which is just an array of NSNumbers indexing the campus names)
        self.eateryComparator = ^(id obj1, id obj2) {  // args will be NSNumbers
            Model *sharedModel = [Model sharedInstance];  //using this to avoid possible retain cycle in the block
            NSInteger index1 = [obj1 integerValue];
            NSInteger index2 = [obj2 integerValue];
            NSString *name1 = [sharedModel getLocationNameWithCampus:sharedModel.myCampus andIndex:index1];
            NSString *name2 = [sharedModel getLocationNameWithCampus:sharedModel.myCampus andIndex:index2];
            return [name1 caseInsensitiveCompare:name2];
        };
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(menuDownloadCompleted:)
                                                     name:allMenuDataDownloadCompleted
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(prepareDatesAndMenus)
                                                     name:locationDataDownloadCompleted
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateOnResume)
                                                     name:applicationDidBecomeActive
                                                   object:nil];


    }
    return self;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


-(void)initializeData {
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dataArchive];
    
    // can't save the cache
     _menuCache = [[NSCache alloc] init];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (fileExists) {
        self.dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        self.campusArray = [self.dataDictionary objectForKey:@"campusArray"];
        self.hoursArray = [self.dataDictionary objectForKey:@"hoursArray"];
        self.newsArray = [self.dataDictionary objectForKey:@"newsArray"];
        self.menuDates = [self.dataDictionary objectForKey:@"menuDates"];
        self.menuMenus = [self.dataDictionary objectForKey:@"menuMenus"];
        self.menuFavorites = [self.dataDictionary objectForKey:@"menuFavorites"];
        self.favoritesNotifications = [self.dataDictionary objectForKey:@"favoritesNotifications"];
      
    } else {
        self.campusArray = [NSMutableArray array];
        self.hoursArray = [NSMutableArray array];
        self.newsArray = [NSMutableArray array];
        self.menuDates = [NSMutableArray array];
        self.menuMenus = [NSMutableArray array];
        self.menuFavorites = [NSMutableArray array];
        self.favoritesNotifications = [NSMutableArray array];

        _dataDictionary = @{@"campusArray":self.campusArray, @"hoursArray":self.hoursArray, @"newsArray":self.newsArray, @"menuDates":self.menuDates, @"menuMenus":self.menuMenus, @"menuFavorites":self.menuFavorites, @"favoritesNotifications":self.favoritesNotifications};
    }

}

-(void)saveData {
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dataArchive];
    [NSKeyedArchiver archiveRootObject:self.dataDictionary toFile:path];
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    self.internetStatus = [internetReachable currentReachabilityStatus];
    self.hostStatus = [hostReachable currentReachabilityStatus];
    self.statusUpdated = YES;
    
    if (self.internetStatus == NotReachable) {
        if (self.alertView) {  // only create an alert if one is not already showing
            _alertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Check Network Status" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [self.alertView show];
        }
        
    } else     if (self.hostStatus == NotReachable) {
        if (self.alertView) {
            _alertView = [[UIAlertView alloc] initWithTitle:@"Service Not Available" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [self.alertView show];
        }
        
    } else    {
        if (campusArray.count == 0) {  // we should only need to load this once - EVER
            NSURLRequest *campusURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:campusesURLString]];
            campusesConnection = [[NSURLConnection alloc] initWithRequest:campusURLRequest delegate:self];
        }
        if (hoursArray.count == 0 || [self staleHours]) {
            [self updateHours];
        }
        if (newsArray.count == 0|| [self staleNews]) {
            [self updateNews];
        }
    }
}

// news older than a day is stale
-(BOOL)staleNews {
    NSTimeInterval seconds = -[self.newsUpdateDate timeIntervalSinceNow];
    return (seconds/kSecondsInADay > 1.0);
}

-(void)updateNews {
    [self.newsArray removeAllObjects];
    NSURLRequest *newsURLRequst = [NSURLRequest requestWithURL:[NSURL URLWithString:newsURLString]];
    newsConnection = [[NSURLConnection alloc] initWithRequest:newsURLRequst delegate:self];

}

-(void)updateHours {
    NSURLRequest *hoursURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:hoursURLString]];
    hoursConnection = [[NSURLConnection alloc] initWithRequest:hoursURLRequest delegate:self];

}

// news older than a week is stale
-(BOOL)staleHours {
    NSTimeInterval seconds = -[self.newsUpdateDate timeIntervalSinceNow];
    return (seconds/kSecondsInADay > 7.0);
}

-(NSInteger)myCampus {
    if (_myCampus == kNoCampus) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSNumber *num = [prefs objectForKey:@"campus"];
        _myCampus = [num integerValue];
    }
    return _myCampus;
}

-(void)setMyCampus:(NSInteger)newCampus {
    _myCampus = newCampus;
    [self.myEateries removeAllObjects];  // reset to all eateries
    
    [self.prefs setInteger:newCampus forKey:@"campus"];
    [self.prefs setObject:self.myEateries forKey:@"eateries"];
    [self.prefs synchronize];
}

-(NSMutableArray*)myEateries {
    if (_myEateries == nil) {
       
        _myEateries = [[self.prefs arrayForKey:@"eateries"] mutableCopy];
    }
    return _myEateries;
}

-(NSMutableArray*)myFoods {
    if (_myFoods == nil) {
        
        _myFoods = [[self.prefs arrayForKey:@"foods"] mutableCopy];
    }
    return _myFoods;
}

// Favorite Eateries are just an array of (NSNumber) indexes into th array of location names for a campus
-(void)addEateryAtIndex:(NSInteger)index {
    [self.myEateries addObject:[NSNumber numberWithInt:index]];
    [self.myEateries sortUsingComparator:self.eateryComparator];
    
    [self.prefs setObject:self.myEateries forKey:@"eateries"];
}
-(void)removeEateryAtIndex:(NSInteger)index {
    [self.myEateries removeObject:[NSNumber numberWithInt:index]];
    [self.prefs setObject:self.myEateries forKey:@"eateries"];
}

-(NSString*)favoriteEateryNameAtIndex:(NSInteger)index {
    NSNumber *num = [self.myEateries objectAtIndex:index];
    NSInteger nameIndex = [num integerValue];
    return  [self getLocationNameWithCampus:self.myCampus andIndex:nameIndex];

}

#pragma mark - Favorites

-(void)toggleNotifications {
    _notificationsEnabled = !_notificationsEnabled;
    [self.prefs setBool:self.notificationsEnabled forKey:@"notificationsEnabled"];
    [self.prefs synchronize];
   // [self updateNotifications];  // done when app enters background
}

-(void)updateNotifications {
      [self prepareFavorites];
//    if (self.notificationsEnabled) {
//        [self prepareFavorites];
//    } else {
//        //cancel any previous notifications
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    }

}

-(BOOL)isFavoriteFood:(NSString *)food {
    return [self.myFoods containsObject:food];
}

-(void)addFavoriteFood:(NSString *)food {
    [self.myFoods addObject:food];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.myFoods forKey:@"foods"];
    // since favorites have changed, better update notifications  // now done when app enters background
//    if (self.notificationsEnabled) {
//        [self createNotifications];
//    }
}

-(void)removeFavoriteFood:(NSString *)food {
    [self.myFoods removeObject:food];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.myFoods forKey:@"foods"];
    // since favorites have changed, better update notifications // now done when app enters background
//    if (self.notificationsEnabled) {
//        [self createNotifications];
//    }
}


-(void) addFoodToLog:(NSDictionary *)foodLog forDate:(NSDate*)myDate{
    
    NSString *dateString = [self.dateFormatter stringFromDate: myDate];
    
    NSMutableDictionary *foodDict = [NSMutableDictionary dictionaryWithDictionary: foodLog];
    [foodDict setObject:dateString forKey:kDate];
    
    [self.dataManager addToLog: foodDict];
    
}

-(NSArray *) allDatesForLogs {
    return [self.dataManager allDatesForLogs];
}

-(NSArray *) foodsForDate:(NSDate *)date {
    return [self.dataManager getFoodsForDate:date];
}

-(void)removeFoodsForDate:(NSDate *)date {
    [self.dataManager removeFoodsForDate:date];
}

- (NSMutableArray *) getCampusNames {
    if (!self.campusNames) {
        campusNames = [[NSMutableArray alloc] initWithCapacity:20];
        for (NSDictionary *campusDict in campusArray)
            [campusNames addObject:[campusDict objectForKey:@"Campus Name"]];
    } 
        
    return campusNames;
}

- (NSInteger) getCampusCount {
    return [campusArray count];
}

- (NSString *) getCampusName:(NSInteger)campusIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:campusIndex];
    
    return (NSString *) [campusDict objectForKey:@"Campus Name"];
}

-(NSURL*)getNewsURLForCampus:(NSInteger)campusIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:campusIndex];
    id link =  [campusDict objectForKey:@"RSS Link"];
  
    // Link could be empty, in which case we return nil
    if (link == [NSNull null]) {
        return nil;
    } else {
        NSString *urlString = (NSString*)link;
        NSURL *url = [NSURL URLWithString:urlString];
        return url;
    }

}

- (NSInteger) getLocationCount:(NSInteger)campusIndex {
    //NSLog(@"GetLocation: %@", self.campusArray);
    NSMutableDictionary *campusDict = [self.campusArray objectAtIndex:campusIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
   // NSLog(@"Getting count: %@, %@", campusDict, locationArray);
    return [locationArray count];
}

-(NSArray*)locationsForCampusIndex:(NSInteger)campusIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:campusIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    
//    NSMutableArray *locationCodeArray = [[NSMutableArray alloc]initWithCapacity:10];
//    NSLog(@"LocationArray: %@", locationArray);
//    for (NSDictionary *dict in locationArray) {
//        NSNumber *code = [dict objectForKey:@"Location Number"];
//        [locationCodeArray addObject:code];
//    }

    return locationArray;

}

- (NSString *) getLocationNameWithCampus:(NSInteger)campusIndex andIndex:(NSInteger)locationIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:campusIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    NSMutableDictionary *locationDict = [locationArray objectAtIndex:locationIndex];
    
    if (locationArray != nil)
        return [locationDict objectForKey:@"Location Name"];
    
    return @"";
}

- (NSMutableDictionary *) getLocationDictForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:cIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    
    return [locationArray objectAtIndex:lIndex];
}

- (NSInteger) getLocationNumberWithCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:cIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    NSMutableDictionary *locationDict = [locationArray objectAtIndex:lIndex];
    
    if (locationArray != nil)
        return [[locationDict objectForKey:@"Location Number"] intValue];
    
    return -1;
}

- (BOOL) eateryHasHours:(NSInteger)menuCatNum {
    for (NSDictionary *hoursDict in hoursArray) {
        NSString *menuCatString = [hoursDict objectForKey:@"Menu Category Number"];
        
        if (menuCatString != nil && menuCatString != (id)[NSNull null])
            if ([menuCatString intValue] == menuCatNum)
                return YES;
    }
    
    return NO;
}

- (NSMutableArray *) getHoursForEatery:(NSInteger)menuCatNum {
    NSMutableArray *hourDictArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (NSDictionary *hoursDict in hoursArray) {
        NSString *menuCatString = [hoursDict objectForKey:@"Menu Category Number"];
        
        if (menuCatString != nil && menuCatString != (id)[NSNull null])
            if ([menuCatString intValue] == menuCatNum)
                [hourDictArray addObject:hoursDict];
    }

    return hourDictArray;
}

-(NSString*)cacheKeyForCampus:(NSInteger)campusIndex andLocation:(NSInteger)locationIndex andMeal:(NSInteger)mealIndex andDate:(NSString *)dateString {
    NSString *key = [NSString stringWithFormat:@"%d-%d-%d-%@", campusIndex, locationIndex, mealIndex, dateString];
    return key;
}

-(void)allMenusForDate:(NSString *)dateString{
    NSString *urlString = [allMenusURLString stringByAppendingString:[NSString stringWithFormat:@"%@", dateString]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    allMenuConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void) loadMenuForCampus:(NSInteger)campusIndex andLocation:(NSInteger)locationIndex andMeal:(NSInteger)mealIndex andDate:(NSString *)dateString{
    // Check if we've already cached this menu, otherwise request it
   self.menuKey = [self cacheKeyForCampus:campusIndex andLocation:locationIndex andMeal:mealIndex andDate:dateString];
    NSArray *menu =  [self.menuCache objectForKey:self.menuKey];
    if (menu) {
        [[NSNotificationCenter defaultCenter] postNotificationName:menuDataDownloadCompleted object:self userInfo:@{@"array":menu}];
    } else {
        NSInteger locNumber = [self getLocationNumberWithCampus:campusIndex andLocation:locationIndex];
        NSString *urlString = [menusURLString stringByAppendingString:[NSString stringWithFormat:@"date=%@&location=%d", dateString, locNumber]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        menuConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        currentMenuMealNumber = mealIndex;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    return;
}

- (void) loadEateriesForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSInteger locNumber = [self getLocationNumberWithCampus:cIndex andLocation:lIndex];
    NSString *urlString = [eateriesURLString stringByAppendingString:[NSString stringWithFormat:@"%d", locNumber]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    eateriesConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    return;
}

- (NSMutableDictionary *) getCampusDictWithCampusCode:(NSString *)aCode {
    for (NSMutableDictionary *aCampusDict in campusArray) {
        NSString *curCampusCode = [aCampusDict objectForKey:@"Campus Code"];
        if ([curCampusCode isEqualToString:aCode])
            return aCampusDict;
    }
    
    return nil;
}

- (NSNumber *) getLongitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:cIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    NSMutableDictionary *locationDict = [locationArray objectAtIndex:lIndex];
    NSNumber *longitude = [locationDict objectForKey:@"Longitude"];
    
    if (longitude != nil)
        return longitude;
    else 
        return [NSNumber numberWithFloat:0.0];
}

- (NSNumber *) getLatitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:cIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    NSMutableDictionary *locationDict = [locationArray objectAtIndex:lIndex];
    NSNumber *latitude = [locationDict objectForKey:@"Latitude"];

    if (latitude != nil)
        return latitude;
    else 
        return [NSNumber numberWithFloat:0.0];
}

- (NSDictionary *) getLatitudeAndLongitudeForCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    NSMutableDictionary *campusDict = [campusArray objectAtIndex:cIndex];
    NSMutableArray *locationArray = [campusDict objectForKey:@"Locations"];
    NSMutableDictionary *locationDict = [locationArray objectAtIndex:lIndex];
    NSNumber *latitude = [locationDict objectForKey:@"Latitude"];
    NSNumber *longitude = [locationDict objectForKey:@"Longitude"];
    
    if (latitude != nil)
        return @{@"latitude":latitude, @"longitude":longitude};
    else
        return nil;
}

- (NSMutableArray *) getNews {
    return newsArray;
}

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == campusesConnection)
        self.campusesData = [NSMutableData data];    // start off with new data
    else if (connection == locationsConnection)
        self.locationsData = [NSMutableData data];
    else if (connection == menuConnection)
        self.menuData = [NSMutableData data];
    else if (connection == allMenuConnection)
        self.allMenuData = [NSMutableData data];
    else if (connection == eateriesConnection)
        self.eateriesData = [NSMutableData data];
    else if (connection == hoursConnection)
        self.hoursData = [NSMutableData data];
    else if (connection == newsConnection)
        self.newsData = [NSMutableData data];
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == campusesConnection)
        [self.campusesData appendData:data]; 
    else if (connection == locationsConnection)
        [self.locationsData appendData:data];
    else if (connection == menuConnection)
        [self.menuData appendData:data];
    else if (connection == allMenuConnection)
        [self.allMenuData appendData:data];
    else if (connection == eateriesConnection)
        [self.eateriesData appendData:data];
    else if (connection == hoursConnection)
        [self.hoursData appendData:data];
    else if (connection == newsConnection)
        [self.newsData appendData:data];
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!self.alertView) {  // only create an alert if one isn't already created (and not dismissed)
        _alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Retrieve Data"
                                                message:@"Connection Failed"
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
        [self.alertView show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:dataDownloadFailed object:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.alertView = nil;  // so we're ready for a new alert
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------

-(NSArray*)jsonArrayFromData:(NSData*)data {
//    NSString *source = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSDictionary *jsonDict = [source JSONValue];
//    NSArray *jsonArray = [jsonDict objectForKey:@"DATA"];
    NSDictionary *jsonDict =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *jsonArray = [jsonDict objectForKey:@"DATA"];
    return jsonArray;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    if (connection == campusesConnection) {

        NSArray *campusesJSONArray = [self jsonArrayFromData:self.campusesData];
    
        // Add each campus code and campus name to a dictionary in the campus array
        for (NSArray *aCampus in campusesJSONArray) {
            NSString *campusCode = [aCampus objectAtIndex:0];
            NSString *campusName = [aCampus objectAtIndex:1];
            NSString *rssLink = [aCampus objectAtIndex:2];
            NSMutableDictionary *newCampus = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:campusCode, campusName, rssLink, nil] forKeys:[NSArray arrayWithObjects:@"Campus Code", @"Campus Name", @"RSS Link", nil]];
        
            [campusArray addObject:newCampus];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:campusDataDownloadCompleted object:self];
            
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:locationsURLString]];
        locationsConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    }
    else if (connection == locationsConnection) {

        NSArray *locationsJSONArray = [self jsonArrayFromData:self.locationsData];
        
        for (NSArray *aLocation in locationsJSONArray) {
            NSNumber *locationNumber = [aLocation objectAtIndex:0];
            NSString *locationName = [aLocation objectAtIndex:1];
            NSString *campusCode = [aLocation objectAtIndex:2];
            NSString *longString = [aLocation objectAtIndex:3];
            NSString *latString = [aLocation objectAtIndex:4];
            
            
            NSNumber *coordLat;
            NSNumber *coordLong;
            
            if ((NSNull*)longString != [NSNull null] && (NSNull*)latString != [NSNull null])  {  // some locations don't have lat/long info
                coordLong = [NSNumber numberWithFloat:[longString floatValue]];
                coordLat = [NSNumber numberWithFloat:[latString floatValue]];
            }
            else {
                coordLong = [NSNumber numberWithFloat:0.0];
                coordLat = [NSNumber numberWithFloat:0.0];
            }
            
            NSMutableDictionary *curCampusDict = [self getCampusDictWithCampusCode:campusCode];
            NSMutableDictionary *newLocationDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:locationNumber, locationName, campusCode, coordLong, coordLat, nil] forKeys:[NSArray arrayWithObjects:@"Location Number", @"Location Name", @"Campus Code", @"Longitude", @"Latitude", nil]];
            
            // Determine if locations array exists. If it doesn't, create it.
            NSMutableArray *locations = [curCampusDict objectForKey:@"Locations"];
            if (locations == nil)
                [curCampusDict setValue:[NSMutableArray arrayWithObject:newLocationDict] forKey:@"Locations"];
            else
                [locations addObject:newLocationDict];
        }
        
        NSMutableArray *newCampusArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSMutableDictionary *aCampusDict in campusArray) {
            NSMutableArray *locations = [aCampusDict objectForKey:@"Locations"];
            
            if (locations != nil)
                [newCampusArray addObject:aCampusDict];
            
            self.campusArray = newCampusArray;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:locationDataDownloadCompleted object:self];
    }
    else if (connection == menuConnection || connection == allMenuConnection) {
        NSData *data =  (connection == menuConnection) ? menuData : self.allMenuData;
      
        NSArray *menuItemsArray = [self jsonArrayFromData:data];
        
        // Keep track of menu categories to easily check if one already exists
        NSMutableArray *menuCategories = [[NSMutableArray alloc] initWithCapacity:20];
        NSMutableArray *menuCategoryArray = [[NSMutableArray alloc] initWithCapacity:20];
        
        for (NSArray *menuItem in menuItemsArray) {
            
            NSNumber *mealNumber = [menuItem objectAtIndex:2];
            NSNumber *locationCode = [menuItem objectAtIndex:4];
            NSString *menuCatName = [menuItem objectAtIndex:7];
            NSString *itemName = [menuItem objectAtIndex:10];
            NSString *calories = [menuItem objectAtIndex:23];
            NSString *totalFat = [menuItem objectAtIndex:25];
            NSString *saturatedFat = [menuItem objectAtIndex:27];
            NSString *transFat = [menuItem objectAtIndex:29];
            NSString *cholesterol = [menuItem objectAtIndex:31];
            NSString *sodium = [menuItem objectAtIndex:33];
            NSString *carbohydrates = [menuItem objectAtIndex:35];
            NSString *dietaryFiber = [menuItem objectAtIndex:37];
            NSString *sugars = [menuItem objectAtIndex:39];
            NSString *protein = [menuItem objectAtIndex:41];
            
            if ([mealNumber intValue] == currentMenuMealNumber || connection == allMenuConnection) {
                NSMutableDictionary *menuCatDict;
                // if category already exists, get the dictionary
                if ([menuCategories containsObject:menuCatName])
                    for (NSMutableDictionary *aDict in menuCategoryArray) {
                        NSString *curMenuCatName = [aDict objectForKey:kName];
                        if ([curMenuCatName isEqualToString:menuCatName])
                        {
                            menuCatDict = aDict;
                            break;
                        }
                    }
                else {
                    menuCatDict = [NSMutableDictionary dictionaryWithObject:menuCatName forKey:kName];
                    [menuCatDict setValue:[NSMutableArray arrayWithCapacity:20] forKey:@"Menu Items"];
                    [menuCategoryArray addObject:menuCatDict];
                }
                
                NSMutableArray *itemArray = [menuCatDict objectForKey:@"Menu Items"];
                NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithObject:itemName forKey:kName];
                [newItem setValue:calories forKey:kCalories];
                [newItem setValue:totalFat forKey:kTotalFat];
                [newItem setValue:saturatedFat forKey:kSatFat];
                [newItem setValue:transFat forKey:kTransFat];
                [newItem setValue:cholesterol forKey:kCholesterol];
                [newItem setValue:sodium forKey:kSodium];
                [newItem setValue:carbohydrates forKey:kTotalCarb];
                [newItem setValue:dietaryFiber forKey:kDietaryFiber];
                [newItem setValue:sugars forKey:kSugars];
                [newItem setValue:protein forKey:kProtein];
                [newItem setValue:locationCode forKey:kLocationCode];
                
                [itemArray addObject:newItem];
                
                [menuCategories addObject:menuCatName];
            }
        
        }
        
    
        
        //NSDictionary *dict = @{@"notification":menuDataDownloadCompleted, @"userInfo":menuCategoryArray};
        //[self performSelectorOnMainThread:@selector(postThis:) withObject:dict waitUntilDone:NO];
        if (connection == menuConnection) {
             [[NSNotificationCenter defaultCenter] postNotificationName:menuDataDownloadCompleted object:self userInfo: @{@"array":menuCategoryArray}];
            //Cache the menu for future use
            [self.menuCache setObject:menuCategoryArray forKey:self.menuKey];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:allMenuDataDownloadCompleted object:self userInfo: @{@"array":menuCategoryArray}];
        }
    
    }
    else if (connection == eateriesConnection) {

        NSArray *eateriesJSONArray = [self jsonArrayFromData:self.eateriesData];
        
        NSMutableArray *eateriesArray = [[NSMutableArray alloc] initWithCapacity:5];
        
        for (NSArray *anEatery in eateriesJSONArray) {
            NSString *menuCatNumber = [anEatery objectAtIndex:0];
            NSString *menuCatName = [anEatery objectAtIndex:1];
            NSString *locationNumber = [anEatery objectAtIndex:2];
            NSString *locationName = [anEatery objectAtIndex:3];
        
            [eateriesArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:menuCatNumber, menuCatName, locationNumber, locationName, nil] forKeys:[NSArray arrayWithObjects:@"Menu Category Number", @"Menu Category Name", @"Location Number", @"Location Name", nil]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:eateriesDataDownloadCompleted object:self userInfo:@{@"array":eateriesArray}];
    }
    else if (connection == hoursConnection) {
        
        NSArray *hoursJSONArray = [self jsonArrayFromData:self.hoursData];
        
        for (NSArray *array in hoursJSONArray) {
            NSString *menuCatNumber = [array objectAtIndex:0];
            NSString *dayStart = [array objectAtIndex:1];
            NSString *dayEnd = [array objectAtIndex:2];
            NSString *timeOpen = [array objectAtIndex:3];
            NSString *timeClose = [array objectAtIndex:4];
            NSString *closedIndefinitely = [array objectAtIndex:5];
            
            [hoursArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:menuCatNumber, dayStart, dayEnd, timeOpen, timeClose, closedIndefinitely, nil] forKeys:[NSArray arrayWithObjects:@"Menu Category Number", @"Day Start", @"Day End", @"Time Open", @"Time Close", @"Closed Indefinitely", nil]]];
        }
    }
    else if (connection == newsConnection) {
        
        NSArray *newsJSONArray = [self jsonArrayFromData:self.newsData];
        
        for (NSArray *array in newsJSONArray) {
            NSString *date = [array objectAtIndex:0];
            NSString *title = [array objectAtIndex:1];
            NSString *desc = [array objectAtIndex:2];
            
            [newsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:date, title, desc, nil] forKeys:[NSArray arrayWithObjects:@"Date", @"Title", @"Description", nil]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:newsDataDownloadCompleted object:self userInfo: @{@"array":newsArray}];
    }
}

-(void)postThis:(NSDictionary*)dictionary {
    NSString *notificationString = [dictionary objectForKey:@"notification"];
    id userInfo = [dictionary objectForKey:@"userInfo"];
     [[NSNotificationCenter defaultCenter] postNotificationName:notificationString object:self userInfo:userInfo];
}

#pragma mark - Disclaimer Info
-(BOOL)disclaimerShown {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL shown = [prefs boolForKey:@"disclaimerShown"];
    
    return shown;
}
-(void)disclaimerWasShown {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:@"disclaimerShown"];
    [prefs synchronize];
}


#pragma mark - Favorites

-(NSInteger)numberOfDaysDownloaded {
    return [self.menuMenus count];
}

-(void)updateOnResume {
    if (self.numberOfDaysDownloaded>0) {  // only update the favorites if we've already prepared dates/menus previously
        [self prepareDatesAndMenus];
    }
}

-(void)prepareDatesAndMenus {
    NSDate *today = [NSDate date];
    NSString *todayString = [self.dateFormatter stringFromDate:today];
    

    //clear out old dates
    while ([self.menuDates count] > 0 && ![todayString isEqualToString:[self.dateFormatter stringFromDate:[self.menuDates objectAtIndex:0]]])  {
        [self.menuDates removeObjectAtIndex:0];
        [self.menuMenus removeObjectAtIndex:0];
    }
    
    if ([self numberOfDaysDownloaded] == kNumberOfDays) {  // up to date! //[self.menuDates count]
        [self updateNotifications];  // but favorites might have changed
        
    } else {  // we'll add days to fill out array
        NSInteger indexOfFirstDaytoLoad = [self.menuDates count];
        for (int i=indexOfFirstDaytoLoad; i<kNumberOfDays; i++) {
            NSDate *date = [NSDate dateWithTimeInterval: kSecondsInADay*i sinceDate:today];
            [self.menuDates setObject:date atIndexedSubscript:i];
        }
        NSDate *date = [NSDate dateWithTimeInterval: kSecondsInADay*indexOfFirstDaytoLoad sinceDate:today];
        [self allMenusForDate:[self.dateFormatter stringFromDate:date]];
    }
    
}


#pragma mark - Notification Handlers
-(void)menuDownloadCompleted:(NSNotification*)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSArray *menu = [userInfo objectForKey:@"array"];
    [self.menuMenus setObject:menu atIndexedSubscript:self.numberOfDaysDownloaded];
    
    if (self.numberOfDaysDownloaded < kNumberOfDays) {  // more to download, on to next one
        NSDate *next = [self.menuDates objectAtIndex:self.numberOfDaysDownloaded];
        [self allMenusForDate:[self.dateFormatter stringFromDate:next]];
    } else {  // done downloading all the menus
        [self prepareFavorites];
      
        // good time to save state
        [self saveData];
        
    }
}

// Called after we have all the menus
-(void)prepareFavorites {
    
    //cancel any previous notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [self.favoritesNotifications removeAllObjects];
    
    
    //get location codes for my campus and filter these out of menus
    NSArray *locationDictionaries = [self locationsForCampusIndex:[self myCampus]];
    // Get the Location codes & names
    NSMutableArray *tempLocationCodes = [NSMutableArray array];
    NSMutableArray *tempLocationNames = [NSMutableArray array];
    for (NSDictionary *dict in locationDictionaries) {
        [tempLocationCodes addObject:[dict objectForKey:@"Location Number"]];
        [tempLocationNames addObject:[dict objectForKey:@"Location Name"]];
    }
    NSArray *locationNames = tempLocationNames;
    NSArray *locationCodes = tempLocationCodes;
    
    //get favorite foods
    NSArray *favoriteFoods = [self myFoods];
    
    //seach menus for favorite foods, creating data source for the tableView sections
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"locationCode IN %@ AND name IN %@", locationCodes, favoriteFoods];
    for (int day=0; day<[self numberOfDaysDownloaded]; day++) {    //use actual data rather that constant kNumberOfDays
        NSArray *arrayOfMenus = [self.menuMenus objectAtIndex:day];
        NSMutableArray *favoritesForDay = [NSMutableArray array];
        for (NSDictionary *menuDict in arrayOfMenus) {
           // NSLog(@"MenuDict: %@", menuDict);
            NSArray *menuArray = [menuDict objectForKey:@"Menu Items"];
            NSString *menuArea = [menuDict objectForKey:@"name"];
            NSArray *favoritesOnMenu = [menuArray filteredArrayUsingPredicate:predicate];
            
            // create dictionary with just menu item name, location code, and menu area
            NSMutableArray *newFavorites = [NSMutableArray array];
            for (NSDictionary *dict in favoritesOnMenu) {
                [newFavorites addObject:@{@"name":[dict objectForKey:@"name"], @"locationCode":[dict objectForKey:@"locationCode"], @"area":menuArea}];
            }
            [favoritesForDay addObjectsFromArray:newFavorites];
        }
        
        //remove duplicates
        NSSet *favoritesSet = [NSSet setWithArray:favoritesForDay];
        NSArray *theFavorites = [favoritesSet allObjects];
        [self.menuFavorites setObject:theFavorites atIndexedSubscript:day];
        
        //add local notification (except for today - day 0) if we have favorites on that day
        if (day>0 && [theFavorites count]>0) {
            
            NSDate *date = [self.menuDates objectAtIndex:day];
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertAction = @"OK";
            notification.alertBody = [NSString stringWithFormat:@"%d Favorites available on %@", [theFavorites count], [self.dateFormatter stringFromDate:date]];
            notification.timeZone = [NSTimeZone defaultTimeZone];
            
            // set time on fire Date to be 6am
            
            NSDateComponents *components = [self.gregorianCalendar components: NSUIntegerMax fromDate: date];
            [components setTimeZone:[NSTimeZone localTimeZone]];
            [components setHour: kNotificationHour];  // 6am???
            [components setMinute: 06];
            [components setSecond: 00];
            NSDate *fireDate = [self.gregorianCalendar dateFromComponents: components];
            notification.fireDate = fireDate;
            
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.applicationIconBadgeNumber = 1;
            notification.userInfo = @{}; // just want a non-nil object for handling in application:didFinishLaunching?
            
            [self.favoritesNotifications addObject:notification];
            
            //[[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    
    if (self.notificationsEnabled) {
          [[UIApplication sharedApplication] setScheduledLocalNotifications:self.favoritesNotifications];
    }
  
    
    
    NSDictionary *favoritesDictionary = @{@"locationNames":locationNames, @"locationCodes":locationCodes, @"menuFavorites":self.menuFavorites, @"menuDates":self.menuDates};
    [[NSNotificationCenter defaultCenter] postNotificationName:favoritesReady object:self userInfo:favoritesDictionary];

}

@end
