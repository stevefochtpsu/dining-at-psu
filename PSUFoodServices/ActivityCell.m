//
//  ActivityCell.m
//  PSUFoodServices
//
//  Created by John Hannan on 6/17/13.
//
//

#import "ActivityCell.h"

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.activityView.color = [UIColor colorWithRed:0.270588 green:0.521569 blue:0.141176 alpha:1.0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
