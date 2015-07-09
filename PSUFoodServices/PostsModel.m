//
//  PostsModel.m
//  CheeseShoppePrototype
//
//  Created by MTSS on 12/12/12.
//  Copyright (c) 2012 rrb5068. All rights reserved.
//

#import "PostsModel.h"
#import "Model.h" 

#define kSecondsInDay 86400


static NSString *const PostsXMLFeed = @"http://www.foodservices.psu.edu/FoodServices/template-Food-Services.cfm?xml=food-services-news,RSS2.0";

static NSString * const kItem = @"item";
static NSString * const kTitle = @"title";
static NSString * const kPubDate = @"pubDate";
static NSString * const kDescription = @"description";


@interface PostsModel()

@property (nonatomic,strong) NSMutableArray *postItems;
@property (nonatomic,strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong) NSMutableDictionary *currentItem;
@property (nonatomic,strong) NSMutableString *currentString;
@property (nonatomic,strong) NSDate *lastRefresh;
@property (nonatomic,strong) NSOperationQueue *fetchQueue;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@property (nonatomic,strong) NSURL  *campusRSSURL;  // each campus can have its own feed
@property NSInteger myCampusIndex;
@end

@implementation PostsModel

+(id)sharedInstance {
    static id singleton = nil;
    if (singleton == nil) {
        singleton = [[self alloc] init];
    }

   
    
    return singleton;
}

-(id)init {
    self = [super init];
    if (self) {
        _fetchQueue = [[NSOperationQueue alloc] init];

        self.lastRefresh = [NSDate date];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat: kDateFormat];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadCompleted)
                                                     name:campusDataDownloadCompleted
                                                   object:nil];


    }
    return self;
}


-(void)downloadCompleted {
       [self fetchXMLPosts];
}

-(void)fetchXMLPosts {
    
    // get the RSS URL when we fetch so we can be sure to get updated campus index (in case it changes)
    Model *model = [Model sharedInstance];
    self.myCampusIndex = [model myCampus];
    self.campusRSSURL = [model getNewsURLForCampus:self.myCampusIndex];
    
    _postItems = [[NSMutableArray alloc] initWithCapacity:15];
    
    // URL could be nil if campus doesn't have a news feed. Just do nothing, leave array empty
    if (!self.campusRSSURL) {
        [self notify];  // just notify observer that data is ready
        return;
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //NSURL *url = [NSURL URLWithString:self.PostsXMLFeed];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.campusRSSURL];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:self.fetchQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to Retrieve Data."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                  
                                                  otherButtonTitles: nil];
            [alert show];
        } else {
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            parser.delegate = self;
            [parser parse];}
    }];
    
}

//-(void)fetchXMLPosts {
//    _postItems = [[NSMutableArray alloc]initWithCapacity:75];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    NSURL *url = [NSURL URLWithString:PostsXMLFeed];
//    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
//    parser.delegate = self;
//    [parser parse];
//}


-(NSDate*)dateForPubDateString:(NSString*)pub_date {
    // NSString *const incomingDateFormat = @"yyyy-MM-dd HH:mm:ss";  //json feed
    NSString *const incomingDateFormat = @"E, d M y HH:mm:ss ZZZZ" ;
    NSDateFormatter *incomingDateFormatter =[[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    [incomingDateFormatter setLocale:enUSPOSIXLocale];
    [incomingDateFormatter setDateFormat:incomingDateFormat];
    [incomingDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    
    NSDate *date = [incomingDateFormatter dateFromString:pub_date];
    
    if (date == nil) {
        NSLog(@"Error with date");
    }
    
    return date;
}






#pragma mark - Public Methods
-(NSInteger)count {
    return [self.postItems count];
}



-(NSString*)titleForRow:(NSInteger)row {
    NSDictionary *itemDictionary = [self.postItems objectAtIndex:row];
    NSString *title = [itemDictionary objectForKey:kTitle];
    return title;
}





-(NSString*)descriptionForRow:(NSInteger)row  {
    NSDictionary *itemDictionary = [self.postItems objectAtIndex:row];
    NSString *desc = [itemDictionary objectForKey:kDescription];
    return desc;
}

-(NSString*)dateForRow:(NSInteger)row {
    NSDictionary *itemDictionary = [self.postItems objectAtIndex:row];
    NSDate *date =  [itemDictionary objectForKey:kPubDate];
    return [self.dateFormatter stringFromDate:date];
}



-(void)refetchPosts {
    [self fetchXMLPosts];
    self.lastRefresh = [NSDate date];
}

-(void)refetchPostsIfStale {
    NSTimeInterval interval = [self.lastRefresh timeIntervalSinceNow];
    Model *model = [Model sharedInstance];
    if (interval > kSecondsInDay || self.myCampusIndex != [model myCampus]) {  //more than a day old or campus has changed
        [self refetchPosts];
    }
}


#pragma mark - NSXML Parser Delegate

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
//    [[NSNotificationCenter defaultCenter] postNotificationName:ApiPostFetchCompleted object:self];
}

-(void)notify {
    [[NSNotificationCenter defaultCenter]postNotificationName:newsDataDownloadCompleted object:self];
}



-(BOOL)isInteresting:(NSString*)element {
    NSArray *interestingItems = @[kTitle,kPubDate,kDescription]; //,kMediaContent,kMediaTitle];
    return ([interestingItems containsObject:element]);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
 
    if ([elementName isEqualToString:kItem]) {
		self.currentItem = [[NSMutableDictionary alloc] initWithCapacity:3];
	} else if ([self isInteresting:elementName]) {
        self.currentString = [[NSMutableString alloc] initWithCapacity:100];
    } else {
        self.currentString = nil;
    }
    

}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
 
    
    if ([elementName isEqualToString:kTitle]) {
        [self.currentItem setObject:self.currentString forKey:kTitle];
    } else if ([elementName isEqualToString:kPubDate]) {
        NSDate *date = [self dateForPubDateString:self.currentString];
        [self.currentItem setObject:date forKey:kPubDate];
    }  else if ([elementName isEqualToString:kDescription]) {
//        NSRange rangeOfSubstring = [self.currentString rangeOfString:@"<img"];
//        NSString *s;
//        if(rangeOfSubstring.location != NSNotFound) {
//            s  = [self.currentString substringToIndex:rangeOfSubstring.location];
//        } else {
//            s = self.currentString;
//        }
//        
//        rangeOfSubstring = [self.currentString rangeOfString:@"<a"];
//        if(rangeOfSubstring.location != NSNotFound) {
//            s  = [s substringToIndex:rangeOfSubstring.location];
//        }
//
        
        [self.currentItem setObject:self.currentString forKey:kDescription];

        
        }    else if ([elementName isEqualToString:kItem]) {
     
        [self.postItems addObject:self.currentItem];
    }
    self.currentString = nil;
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Unable to Retrieve Data."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                          
                                          otherButtonTitles: nil];
    [alert show];
}


@end
