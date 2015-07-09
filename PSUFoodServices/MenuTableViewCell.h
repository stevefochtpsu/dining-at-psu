//
//  MenuTableViewCell.h
//  PSUFoodServices
//
//  Created by John Hannan on 6/5/13.
//
//

#import <UIKit/UIKit.h>

@interface MenuTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UITextView *textView;
@property (nonatomic,strong) IBOutlet UIImageView *favorite;
@property (nonatomic,strong) IBOutlet UILabel *caloriesLabel;
@property (nonatomic,strong) IBOutlet UIStepper *stepper;
@property (nonatomic,strong) IBOutlet UILabel *quantity;

-(IBAction)stepperChanged:(id)sender;
@end
