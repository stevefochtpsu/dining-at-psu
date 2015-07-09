//
//  HoursViewController.m
//  PSUFoodServices
//
//  Created by H KENNETH ROSENBERRY on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HoursViewController.h"
#define kBottomInset 60

@interface HoursViewController()

@property (weak, nonatomic) IBOutlet UIWebView *eateriesWebView;


@property (weak, nonatomic) Model *model;
@property NSInteger campusIndex;
@property NSInteger locationIndex;
- (IBAction)donePressed:(id)sender;
@property (weak, nonatomic) NSString *name;
@end

@implementation HoursViewController

@synthesize eateriesWebView;
@synthesize model, campusIndex, locationIndex, name;


static NSArray *days;

//- (id)initWithModel:(Model *)aModel andCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex
//{
//    self = [super init];
//    if (self) {
//        [self setModel:aModel andCampus:cIndex andLocation:lIndex];
//    }
//    
//    return self;
//}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [Model sharedInstance];
    }
    return self;
}

- (void)setCampus:(NSInteger)cIndex andLocation:(NSInteger)lIndex {
    //model = aModel;
    campusIndex = cIndex;
    locationIndex = lIndex;
    name = [self.model getLocationNameWithCampus:cIndex andIndex:lIndex];
    
    self.title = @"Hours";
    days = [NSArray arrayWithObjects:@"Su", @"M", @"Tu", @"W", @"Th", @"F", @"Sa", nil];
    [self.model loadEateriesForCampus:campusIndex andLocation:locationIndex];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadCompleted:)
                                                 name:eateriesDataDownloadCompleted
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.model staleHours]) {
        [self.model updateHours];
    }
    
    UIEdgeInsets edgeInsets = self.eateriesWebView.scrollView.contentInset;
    edgeInsets.bottom += kBottomInset;
    self.eateriesWebView.scrollView.contentInset = edgeInsets;
}



- (void)downloadCompleted:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSArray *eateriesArray = [userInfo objectForKey:@"array"];
    NSMutableString *eateriesString = [NSMutableString stringWithCapacity:200];
    
    for (NSDictionary *aDict in eateriesArray)
        if ([model eateryHasHours:[[aDict objectForKey:@"Menu Category Number"] intValue]]) {
            
            NSString *category = [aDict objectForKey:@"Menu Category Name"];
            NSString *categoryhtml = [NSString stringWithFormat:@"<h2>%@</h2>", category];
            [eateriesString appendString:categoryhtml];
            
            //start table
            [eateriesString appendString:@"<table><tbody>"];
            
            
            NSMutableArray *hoursArray = [model getHoursForEatery:[[aDict objectForKey:@"Menu Category Number"] intValue]];
            
            for (NSDictionary *hourDict in hoursArray) {
                NSString *dayStart = [hourDict objectForKey:@"Day Start"];
                NSString *dayEnd = [hourDict objectForKey:@"Day End"];
                NSString *timeOpen = [hourDict objectForKey:@"Time Open"];
                NSString *timeClose = [hourDict objectForKey:@"Time Close"];
                NSString *closedIndefinitely = [hourDict objectForKey:@"Closed Indefinitely"];
                
                //start row
                [eateriesString appendString:@"<tr>"];
                
                
                // If closed that day, don't print hours
                if (![closedIndefinitely isEqualToString:@"Y"]) {
                    NSString *startDay =  [days objectAtIndex:[dayStart intValue] - 1];
                    NSString *endDay = @"";
                    if (dayEnd != (id)[NSNull null])
                        endDay = [NSString stringWithFormat:@"-%@", [days objectAtIndex:[dayEnd intValue] - 1]];
                    //add days
                    [eateriesString appendFormat:@"<td>%@%@<br /></td>", startDay,endDay]; 
                    
                    // add hours
                    NSString *hours = [NSString stringWithFormat:@"<td>%@-%@</td>", timeOpen, timeClose];
                    [eateriesString appendString:hours];
                    
                }
                //end row
                [eateriesString appendString:@"</tr>"];
            }
            
            //end table
            [eateriesString appendString:@"</tbody></table><br /><br />"];
        }
    
   
    
    if ([eateriesString length] == 0)
        [eateriesString appendString:@"<h1>No Hours Listed</h1>"];
    
    
    
     NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
     "<head> \n"
     "<style type=\"text/css\"> \n"
     "body {font-family: \"%@\"; font-size: %@; color: white; background-color: #1F3D01}\n"
     "h1 {color: #999; font-weight:bold; text-align:center; font-size:24px; padding-top:50px}\n"
     "h2 {color: #999; font-weight:bold; text-align:left; font-size:19px; padding-top:10px}\n"
     "</style> \n"
     "<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\n"
     "</head> \n"
     "<body>%@</body> \n"
     "</html>", @"helvetica", [NSNumber numberWithInt:17], eateriesString];
     
     [self.eateriesWebView loadHTMLString:htmlString baseURL:nil];
     

    
}


- (IBAction)donePressed:(id)sender {
    self.completionBlock(nil);
}
@end
