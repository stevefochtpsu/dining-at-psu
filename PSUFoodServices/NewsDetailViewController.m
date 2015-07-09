//
//  NewsDetailViewController.m
//  PSUFoodServices
//
//  Created by MTSS MTSS on 2/24/12.
//  Copyright (c) 2012 Penn State. All rights reserved.
//

#import "NewsDetailViewController.h"

@interface NewsDetailViewController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NewsDetailViewController

@synthesize webView;


//- (id)initWithNewsItem:(NSDictionary *)newsItem
//{
//    self = [super init];
//    if (self) {
//        newsDictionary = newsItem;
//        self.title = [newsDictionary objectForKey:@"Title"];
//    }
//    
//        
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.title = @"News";
    
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {font-family: \"%@\"; font-size: %@;}\n"
                            "h1 {color: #666; font-weight:bold; text-align:center; font-size:24px; padding-top:50px}\n"
                            "h2 {color: gray; font-weight:bold; text-align:left; font-size:19px; padding-top:10px}\n"
                            "</style> \n"
                            "<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\n"
                            "</head> \n"
                            "<body> <h2>%@</h2>  %@</body> \n"
                            "</html>", @"helvetica", [NSNumber numberWithInt:17], self.newsTitle, self.newsDescription];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
