//
//  LogTableViewCell.m
//  PSUDining
//
//  Created by John Hannan on 10/30/13.
//
//

#import "LogTableViewCell.h"
#define kDeleteButtonWidth 65
static CGFloat const kAnimationDuration = 0.2;

@implementation LogTableViewCell

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
            self.textLabel.numberOfLines = 1;

        }];
    } else if (deleting) {
        deleting = NO;
        __block CGRect frame = self.textLabel.frame;
        __block CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width+kDeleteButtonWidth, frame.size.height);
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.textLabel.frame = newFrame;
              self.textLabel.numberOfLines = 0;
        }];
        
    }
    
}


@end
