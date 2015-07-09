//
//  FavoritesCell.h
//  PSUFoodServices
//
//  Created by John Hannan on 6/14/13.
//
//

#import <UIKit/UIKit.h>

@interface FavoritesCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UILabel *area;
@property (nonatomic,weak) IBOutlet UILabel *location;
@end
