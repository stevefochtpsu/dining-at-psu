//
//  LocationMapViewController.h
//  PSUFoodServices
//
//  Created by MTSS MTSS on 12/13/11.
//  Copyright (c) 2011 Penn State. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationMapViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic,strong) CompletionBlock completionBlock;
- (id)initWithLocationName:(NSString *)locName andLongitude:(NSNumber *)locLong andLatitude:(NSNumber *)locLat;
- (void)setLocationName:(NSString *)locName andLongitude:(NSNumber *)locLong andLatitude:(NSNumber *)locLat;



@end
