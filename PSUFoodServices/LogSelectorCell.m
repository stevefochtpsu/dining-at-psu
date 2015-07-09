//
//  LogSelectorCell.m
//  PSUFoodServices
//
//  Created by John Hannan on 7/5/12.
//  Copyright (c) 2012 Penn State University. All rights reserved.
//

#import "LogSelectorCell.h"
#define kDeleteButtonWidth 65
static CGFloat const kAnimationDuration = 0.2;

@implementation LogSelectorCell
@synthesize textLabel;
@synthesize caloriesLabel;
@synthesize servingsLabel;
@synthesize stepper;

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

- (IBAction)servingChanged:(id)sender {
    UIStepper *theStepper = (UIStepper*)sender;
    NSInteger value = theStepper.value;
    servingsLabel.text = [NSString stringWithFormat:@"%d",value];
}

#pragma mark - respond to state changes
-(void)willTransitionToState:(UITableViewCellStateMask)state {
    static BOOL deleting;
    [super willTransitionToState:state];
    
    if (IS_OS_7_OR_LATER) {
        return;
    }
 
    if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
        deleting = YES;
        __block CGRect frame = self.textLabel.frame;
        __block CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width-kDeleteButtonWidth, frame.size.height);
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.textLabel.frame = newFrame;
            self.stepper.alpha = 0.0;
            self.servingsLabel.alpha = 0.0;
        }];
    } else if (deleting) {
        deleting = NO;
        __block CGRect frame = self.textLabel.frame;
        __block CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width+kDeleteButtonWidth, frame.size.height);
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.textLabel.frame = newFrame;
            self.stepper.alpha = 1.0;
            self.servingsLabel.alpha = 1.0;
        }];

    }

}

@end
