//
//  FoodModel.m
//  PSUFoodServices
//
//  Created by Huy Nguyen on 12/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodModel.h"
#import "SBJson.h"

@interface FoodModel()

@property (strong, nonatomic) NSMutableData *foodData;
@property (strong, nonatomic) NSURLConnection *menuConnection;

@end

@implementation FoodModel
@synthesize foodData;
@synthesize menuConnection;
@synthesize mealCode;

static NSString *AppDataDownloadCompleted = @"AppDataDownloadCompleted";

static NSString *const eateriesURLString = @"http://api.absecom.psu.edu/rest/services/food/menus/v1/221723";

static NSInteger mealNumberIndex = 2;
static NSInteger categoryIndex = 7;
static NSInteger nameIndex = 10;
static NSInteger calorieIndex = 23;
static NSInteger totFatIndex = 25;
static NSInteger satFatIndex = 27;
static NSInteger transFatIndex = 29;
static NSInteger cholesterolIndex = 31;
static NSInteger sodiumIndex = 33;
static NSInteger totCarbIndex = 35;
static NSInteger fiberIndex = 37;
static NSInteger sugarIndex = 39;
static NSInteger proteinIndex = 41;

#pragma mark - Initialization

-(id) init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

+(id) sharedInstance {
    static id singleton = nil;
    
    if(singleton == nil) {
        singleton = [[self alloc] init];
    }
    
    return singleton;
}

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.foodData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.foodData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Retrieve Food Data"
														message:@"Check Network Status"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    
    
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    NSString *source = [[NSString alloc] initWithData:foodData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [source JSONValue];
    NSArray *menuItemsArray = [jsonDict objectForKey:@"DATA"];
    
    // Keep track of menu categories to easily check if one already exists
    NSMutableArray *menuCategories = [[NSMutableArray alloc] initWithCapacity:20];
    NSMutableArray *menuCategoryArray = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSArray *menuItem in menuItemsArray) {
        NSNumber *mealNumber = [menuItem objectAtIndex:mealNumberIndex];
        NSString *menuCatName = [menuItem objectAtIndex:categoryIndex];
        NSString *itemName = [menuItem objectAtIndex:nameIndex];
        NSString *calories = [menuItem objectAtIndex:calorieIndex];
        NSString *totalFat = [menuItem objectAtIndex:totFatIndex];
        NSString *saturatedFat = [menuItem objectAtIndex:satFatIndex];
        NSString *transFat = [menuItem objectAtIndex:transFatIndex];
        NSString *cholesterol = [menuItem objectAtIndex:cholesterolIndex];
        NSString *sodium = [menuItem objectAtIndex:sodiumIndex];
        NSString *carbohydrates = [menuItem objectAtIndex:totCarbIndex];
        NSString *dietaryFiber = [menuItem objectAtIndex:fiberIndex];
        NSString *sugars = [menuItem objectAtIndex:sugarIndex];
        NSString *protein = [menuItem objectAtIndex:proteinIndex];
        
        if ([mealNumber intValue] == mealCode) {
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
            
            [itemArray addObject:newItem];
            
            [menuCategories addObject:menuCatName];
        }
        
        //NSLog(@"%@", itemName);
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDataDownloadCompleted object:menuCategoryArray];
}

#pragma mark - Public Method
-(void) getArrayForDate:(NSDate *)date andLocation:(NSString *)locationCode{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: kDateFormat];
    
    NSString *requestString = [NSString stringWithFormat: @"%@?date=%@&location=%@", eateriesURLString, [dateFormatter stringFromDate: date], locationCode];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL: [NSURL URLWithString:requestString]];
    
    menuConnection = [[NSURLConnection alloc] initWithRequest: urlRequest delegate: self];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
@end
