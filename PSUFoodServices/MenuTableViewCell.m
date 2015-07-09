//
//  MenuTableViewCell.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/5/13.
//
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)stepperChanged:(id)sender {
    UIStepper *theStepper = (UIStepper*)sender;
    NSInteger value = theStepper.value;
    self.quantity.text = [NSString stringWithFormat:@"%d",value];
}

@end
