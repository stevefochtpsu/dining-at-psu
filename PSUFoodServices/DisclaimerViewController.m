//
//  DisclaimerViewController.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/14/13.
//
//

#import "DisclaimerViewController.h"

@interface DisclaimerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DisclaimerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
//                NSString *disclaimerString = @"Penn State is not responsible for this app.";
//        
//        NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
//                                "<head> \n"
//                                "<style type=\"text/css\"> \n"
//                                "body {font-family: \"%@\"; font-size: %@; color: white; background-color: #1F3D01}\n"
//                                "h1 {color: #999; font-weight:bold; text-align:center; font-size:24px; padding-top:50px}\n"
//                                "h2 {color: #999; font-weight:bold; text-align:left; font-size:19px; padding-top:10px}\n"
//                                "</style> \n"
//                                "<meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=1.0;'>\n"
//                                "</head> \n"
//                                "<body>%@</body> \n"
//                                "</html>", @"helvetica", [NSNumber numberWithInt:17], disclaimerString];
//        
//        [self.webView loadHTMLString:htmlString baseURL:nil];
//
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
