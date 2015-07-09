//
//  Constants.h
//  PSUFoodServices
//
//  Created by John Hannan on 6/10/13.
//
//

FOUNDATION_EXPORT NSString *const campusDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const locationDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const menuDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const allMenuDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const eateriesDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const newsDataDownloadCompleted;
FOUNDATION_EXPORT NSString *const dataDownloadFailed;
FOUNDATION_EXPORT NSString *const applicationDidBecomeActive;
FOUNDATION_EXPORT NSString *const favoritesReady;

FOUNDATION_EXPORT NSInteger const kUniversityParkCampus;

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)